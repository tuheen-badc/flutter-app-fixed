import 'dart:async';
import 'dart:convert';
import 'package:demo_app/core/session/credentials_manager.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttControlScreen extends StatefulWidget {
  final bool initialPumpOn;
  const MqttControlScreen({super.key, this.initialPumpOn = false});

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
  final String topic = 'pump/control';

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
    
    if (c[0].topic.contains(topic)) {
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
        // Fallback for raw strings (only if JSON fails or doesn't match)
        final upper = cleanPayload.toUpperCase();
        if (upper.contains('STOP') || upper.contains('OFF')) isStarting = false;
        else if (upper.contains('START')) isStarting = true;
      }

      if (isStarting != null && mounted) {
        setState(() {
          pumpOn = isStarting!;
          startedByPhone = isStarting! 
              ? ((pNum != null && pNum != "0") ? pNum : 'Physical Device')
              : null;
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

  void sendCommand(String action) {
    if (!isConnected) return;

    final credentials = serviceLocator<CredentialsManager>();

    // 1. If pump is already running and someone tries to START it
    if (action == 'START' && pumpOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pump Is Running By Other User'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Only the user who started the pump can stop it
    if (action == 'STOP' && pumpOn) {
      if (startedByPhone != null && startedByPhone != credentials.phone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only the user who started the pump can stop it'),
            backgroundColor: Colors.red,
          ),
        );
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
              color: pumpOn ? Colors.blue : Colors.grey.shade400,
            ),
            Text(
              pumpOn ? 'PUMP ON' : 'PUMP OFF',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: pumpOn ? Colors.blue.shade800 : Colors.grey.shade600,
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
