import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart' as dartz hide State;
import 'package:decimal/decimal.dart';
import 'package:demo_app/core/session/credentials_manager.dart';
import 'package:demo_app/data/models/credit_info.dart';
import 'package:demo_app/data/models/pump_live_status_model.dart';
import 'package:demo_app/data/models/pump_station_histories.dart';
import 'package:demo_app/data/models/single_pump_station_history_criteria.dart';
import 'package:demo_app/domain/usecases/pump_live_status.dart';
import 'package:demo_app/domain/usecases/single_pump_station_history.dart';
import 'package:demo_app/domain/usecases/user_credit.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttControlScreen extends StatefulWidget {
  final bool initialPumpOn;
  final int pumpId;
  final int userId;

  const MqttControlScreen({
    super.key,
    this.initialPumpOn = false,
    required this.pumpId,
    required this.userId,
  });

  @override
  State<MqttControlScreen> createState() => _MqttControlScreenState();
}

class _MqttControlScreenState extends State<MqttControlScreen> {
  late MqttServerClient client;
  bool isConnected = false;
  late bool pumpOn;
  String? startedByPhone;
  String statusMessage = 'Disconnected';
  StreamSubscription? _subscription;

  // HiveMQ Cloud Credentials
  final String broker = 'f243f2652cba47c98eafc4c61bd2b618.s1.eu.hivemq.cloud';
  final int port = 8883;
  final String username = 'tuheen.badc';
  final String password = 'rafu@12Rakin@9';
  String get topic => 'pump/control/${widget.pumpId}';

  @override
  void initState() {
    super.initState();
    pumpOn = widget.initialPumpOn;
    connect();
  }

  Future<void> connect() async {
    final String clientId = 'flutter-pump-${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient.withPort(broker, clientId, port);
    
    // SSL/TLS Configuration for HiveMQ Cloud
    client.secure = true;
    client.useWebSocket = false;
    client.setProtocolV311();
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onBadCertificate = (dynamic cert) => true; 
    client.logging(on: true);

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .startClean();
    client.connectionMessage = connMsg;

    try {
      if (mounted) setState(() => statusMessage = 'Connecting...');
      await client.connect();
    } catch (e) {
      debugPrint('MQTT connection exception: $e');
      if (mounted) {
        setState(() => statusMessage = 'Connection Error');
      }
      client.disconnect();
    }
  }

  void onConnected() {
    if (!mounted) return;
    setState(() {
      isConnected = true;
      statusMessage = 'Connected';
    });
    
    // Subscribe to listen for status updates
    client.subscribe(topic, MqttQos.atLeastOnce);
    
    // Clean up old listener and set up new one
    _subscription?.cancel();
    _subscription = client.updates!.listen(_onMessage);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c == null || c.isEmpty) return;
    
    final recMess = c[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final String cleanPayload = payload.trim();
    final String receivedTopic = c[0].topic;
    
    // Accept messages from the specific pump topic OR the general control topic
    if (receivedTopic.contains(topic) || receivedTopic == 'pump/control/${widget.pumpId}') {
      bool? isStarting;
      String? pNum;

      try {
        final Map<String, dynamic> data = jsonDecode(cleanPayload);
        final String action = (data['action']?.toString() ?? "").toUpperCase();
        pNum = data['phone']?.toString();
        
        if (['STOP', 'OFF', '0', 'FALSE'].contains(action)) {
          isStarting = false;
        } else if (['START', 'ON', '1', 'TRUE'].contains(action)) {
          isStarting = true;
        }
      } catch (_) {
        final upper = cleanPayload.toUpperCase();
        if (upper.contains('STOP') || upper.contains('OFF')) {
          isStarting = false;
        } else if (upper.contains('START')) {
          isStarting = true;
        }
      }

      if (isStarting != null && mounted) {
        final bool status = isStarting;
        setState(() {
          pumpOn = status;
          if (status) {
            // Update owner ONLY if the message has a valid phone number (not "0" or "999")
            if (pNum != null && pNum != "123" && pNum != "999" && pNum.isNotEmpty) {
              startedByPhone = pNum;
            } else {
              startedByPhone ??= 'Physical Device';
            }
          } else {
            // Correctly clear the owner when the pump stops
            startedByPhone = null;
          }
        });
      }
    }
  }

  void onDisconnected() {
    if (mounted) {
      setState(() {
        isConnected = false;
        statusMessage = 'Disconnected';
      });
    }
  }

  void sendCommand(String action) async {
    if (!isConnected) return;

    final credentials = serviceLocator<CredentialsManager>();

    // 1. If user clicks START, check status from cloud (PumpLiveStatus)
    if (action == 'START') {
      setState(() => statusMessage = 'Checking Status...');

      final dartz.Either liveStatusResult = await serviceLocator<PumpLiveStatusUseCase>().call(param: widget.userId);
      
      bool? isCurrentlyRunning;
      
      liveStatusResult.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Communication Error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (data) {
          if (data is PumpLiveStatusResponse) {
            isCurrentlyRunning = data.running;
          }
        },
      );

      if (isCurrentlyRunning == null) {
        if (mounted) setState(() => statusMessage = 'Connected');
        return;
      }

      if (isCurrentlyRunning!) {
        if (mounted) {
          setState(() {
            statusMessage = 'Connected';
            // Removed automatic pumpOn = true to keep UI in local state
            // if the server still reports it as running after a quick stop
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pump is Running'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 1.1 If stopped, check history for cooldown (30s)
      final dartz.Either historyResult = await serviceLocator<SinglePumpStationHistoryUseCase>().call(
        param: SinglePumpStationHistoryParam(
          page: 0,
          size: 1,
          pumpStationId: widget.pumpId,
        ),
      );

      DateTime? lastStop;
      String? lastUserPhone;
      bool historySuccess = false;
      
      historyResult.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Communication Error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (data) {
          historySuccess = true;
          if (data is PumpStationHistoryResponse && data.historyList.isNotEmpty) {
            final lastItem = data.historyList.first;
            lastStop = lastItem.endedAt;
            lastUserPhone = lastItem.userPhone;
          }
        },
      );

      if (!historySuccess) {
        if (mounted) setState(() => statusMessage = 'Connected');
        return;
      }
      
      // Cooldown applies ONLY to the last user who used the pump
      if (lastStop != null && lastUserPhone == credentials.phone) {
        final nowUtc = DateTime.now().toUtc();
        final stopUtc = lastStop!.toUtc();
        
        final serverElapsed = nowUtc.difference(stopUtc).inSeconds;
        final localWaitElapsed = credentials.getLocalElapsedSeconds(widget.pumpId, lastStop!);
        
        // Use the maximum of what the server says and how long we've been waiting since we first saw it
        final elapsedSeconds = serverElapsed > localWaitElapsed ? serverElapsed : localWaitElapsed;

        if (elapsedSeconds < 30) {
          final remaining = 30 - elapsedSeconds;

          if (mounted) {
            setState(() => statusMessage = 'Connected');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please Wait $remaining Seconds to Start Again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      // Check user balance before starting
      final dartz.Either balanceResult = await serviceLocator<UserCreditUseCase>().call();
      bool hasBalance = false;
      balanceResult.fold(
        (error) => hasBalance = false,
        (data) {
          if (data is UserCreditResponseModel) {
            hasBalance = data.availableCredit > Decimal.zero;
          }
        },
      );

      if (!hasBalance) {
        if (mounted) {
          setState(() => statusMessage = 'Connected');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pump Failed to Start. \nNo Balance."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      if (mounted) setState(() => statusMessage = 'Connected');
    }

    // 2. Only the user who started the pump can stop it
    if (action == 'STOP' && pumpOn) {
      if (startedByPhone != null && 
          startedByPhone != credentials.phone && 
          startedByPhone != 'Physical Device') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only the user who started the pump can stop it'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Create JSON payload for IoT MQTT Panel using logged-in user credentials
    final Map<String, String> payloadMap = {
      "phone": credentials.phone,
      "password": credentials.password,
      "action": action
    };
    final String jsonPayload = jsonEncode(payloadMap);

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonPayload);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: true);
    
    // Update local state immediately
    setState(() {
      pumpOn = (action == 'START');
      if (action == 'START') {
        startedByPhone = credentials.phone;
      } else {
        startedByPhone = null;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump MQTT Control'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: isConnected ? Colors.green : Colors.red, size: 14),
                const SizedBox(width: 8),
                Text(
                  statusMessage,
                  style: TextStyle(
                    color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            
            // Pump Visual State
            Icon(
              Icons.water_drop_rounded,
              size: 100,
              color: pumpOn ? const Color(0xFFEF4444) : Colors.grey.shade400,
            ),
            Text(
              pumpOn ? 'PUMP RUNNING' : 'PUMP STOPPED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: pumpOn ? const Color(0xFFEF4444) : Colors.grey.shade600,
              ),
            ),

            if (pumpOn && startedByPhone != null && startedByPhone != serviceLocator<CredentialsManager>().phone)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Started by: $startedByPhone',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            const SizedBox(height: 60),
            
            ElevatedButton(
              onPressed: isConnected ? () => sendCommand(pumpOn ? 'STOP' : 'START') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: pumpOn ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(pumpOn ? Icons.stop : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(
                    pumpOn ? 'STOP PUMP' : 'START PUMP',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            if (!isConnected)
              TextButton.icon(
                onPressed: connect,
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
              ),
          ],
        ),
      ),
    );
  }
}
