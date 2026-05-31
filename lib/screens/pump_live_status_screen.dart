// pump_live_status_screen.dart
import 'dart:async';

import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/user_pump_live_status/user_pump_live_status_state.dart';
import '../common/bloc/user_pump_live_status/user_pump_live_status_state_cubit.dart';
import '../data/models/fixed_zone_tier_bar.dart';
import '../data/models/pump_live_status_model.dart';
import '../data/models/user_tier_type.dart';
import '../domain/usecases/pump_live_status.dart';

const double _flowRateLitersPerHour = 200.0;

class PumpLiveStatusScreen extends StatefulWidget {
  final User userData;

  const PumpLiveStatusScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<PumpLiveStatusScreen> createState() => _PumpLiveStatusScreenState();
}

class _PumpLiveStatusScreenState extends State<PumpLiveStatusScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFFF8F9FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  BuildContext? _providerContext;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _load() {
    _providerContext?.read<PumpLiveStatusCubit>().loadLiveStatus(
      useCase: serviceLocator<PumpLiveStatusUseCase>(),
      userId: widget.userData.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PumpLiveStatusCubit()
        ..loadLiveStatus(
          useCase: serviceLocator<PumpLiveStatusUseCase>(),
          userId: widget.userData.id,
        ),
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;
          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Pump Live Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              actions: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Opacity(
                    opacity: _pulseAnim.value,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFF68D391),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Color(0xFF68D391),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: BlocBuilder<PumpLiveStatusCubit, PumpLiveStatusState>(
              builder: (context, state) {
                if (state is PumpLiveStatusLoadingState ||
                    state is PumpLiveStatusInitialState) {
                  return const _CenteredLoader();
                }
                if (state is PumpLiveStatusErrorState) {
                  return _ErrorView(
                    message: state.errorMessage,
                    onRetry: _load,
                  );
                }
                if (state is PumpLiveStatusLoadedState) {
                  if (!state.data.running) return const _NotRunningView();
                  return _LiveView(data: state.data);
                }
                return const _CenteredLoader();
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Live view ─────────────────────────────────────────────────────────────────

class _LiveView extends StatefulWidget {
  final PumpLiveStatusResponse data;

  const _LiveView({required this.data});

  @override
  State<_LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends State<_LiveView> {
  Timer? _ticker;
  bool _frozen = false;

  late final DateTime _mountTime;
  late final double _creditAtMount;
  late final double _tierUsedAtMount;

  double _currentBalance = 0;
  double _sessionCost = 0;
  double _waterUsed = 0;
  double _tierUsedNow = 0;
  Duration _elapsed = Duration.zero;
  String _currentTierLabel = 'Tier 1';
  double _currentRate = 0;

  static const _surface = Color(0xFFFFFFFF);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _mountTime = widget.data.startTime ?? DateTime.now();
    _creditAtMount = widget.data.availableCredit ?? 0.0;
    _tierUsedAtMount = widget.data.userTier?.tierUsed ?? 0.0;
    _currentRate = _rateFor(_tierUsedAtMount);
    _currentBalance = _creditAtMount;

    _tick();
    _ticker = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (mounted) _tick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Tier logic ────────────────────────────────────────────────────────────

  double _rateFor(double tierUsed) {
    final tier = widget.data.userTier;
    final p = widget.data.waterPricing;
    if (tier == null || p == null || !tier.isTierSet)
      return p?.tierOneRate ?? 0.0;
    final base = tier.baseTierLimit!;
    if (tierUsed < base) return p.tierOneRate;
    if (tierUsed < base * 1.15) return p.tierTwoRate;
    return p.tierThreeRate;
  }

  String _labelFor(double tierUsed) {
    final tier = widget.data.userTier;
    if (tier == null || !tier.isTierSet)
      return UserTier.TIER_NOT_SET.displayName;
    final base = tier.baseTierLimit!;
    if (tierUsed < base) return UserTier.TIER_1.displayName;
    if (tierUsed < base * 1.15) return UserTier.TIER_2.displayName;
    return UserTier.TIER_3.displayName;
  }

  Color _colorFor(String label) {
    if (label == UserTier.TIER_2.displayName) return _warning;
    if (label == UserTier.TIER_3.displayName) return _danger;
    return _success;
  }

  double _costWithTiers(double totalSeconds) {
    final tier = widget.data.userTier;
    final p = widget.data.waterPricing;
    if (tier == null || p == null || !tier.isTierSet) {
      return totalSeconds * (p?.tierOneRate ?? 0.0) / 3600.0;
    }
    final base = tier.baseTierLimit!;
    final tierTwoEnd = base * 1.15;
    double cost = 0.0;
    double remaining = totalSeconds;
    double currentUsed = _tierUsedAtMount;

    double secsForVol(double vol) => vol / _flowRateLitersPerHour * 3600.0;

    if (currentUsed < base) {
      final secs = secsForVol(base - currentUsed).clamp(0.0, remaining);
      cost += secs * p.tierOneRate / 3600.0;
      remaining -= secs;
      currentUsed += secs * _flowRateLitersPerHour / 3600.0;
    }
    if (remaining <= 0) return cost;

    if (currentUsed < tierTwoEnd) {
      final secs = secsForVol(tierTwoEnd - currentUsed).clamp(0.0, remaining);
      cost += secs * p.tierTwoRate / 3600.0;
      remaining -= secs;
    }
    if (remaining <= 0) return cost;

    cost += remaining * p.tierThreeRate / 3600.0;
    return cost;
  }

  // ── Tick ──────────────────────────────────────────────────────────────────

  void _tick() {
    if (_frozen) return;

    final secs = (DateTime.now().difference(_mountTime).inMilliseconds / 1000.0)
        .clamp(0.0, double.infinity);

    final tierUsedNow =
        _tierUsedAtMount + (secs * _flowRateLitersPerHour / 3600.0);
    final cost = _costWithTiers(secs).clamp(0.0, _creditAtMount);
    final newBalance = _creditAtMount - cost;

    if (newBalance <= 0) {
      _ticker?.cancel();
      _ticker = null;
      setState(() {
        _frozen = true;
        _elapsed = Duration(milliseconds: (secs * 1000).round());
        _sessionCost = _creditAtMount;
        _currentBalance = 0;
        _waterUsed = secs * _flowRateLitersPerHour / 3600.0;
        _tierUsedNow = tierUsedNow;
        _currentRate = _rateFor(tierUsedNow);
        _currentTierLabel = _labelFor(tierUsedNow);
      });
      return;
    }

    setState(() {
      _elapsed = Duration(milliseconds: (secs * 1000).round());
      _sessionCost = cost;
      _currentBalance = newBalance;
      _waterUsed = secs * _flowRateLitersPerHour / 3600.0;
      _tierUsedNow = tierUsedNow;
      _currentRate = _rateFor(tierUsedNow);
      _currentTierLabel = _labelFor(tierUsedNow);
    });
  }

  // ── Formatters ────────────────────────────────────────────────────────────

  String get _elapsedStr {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _fmt(double v) =>
      NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(v);

  String _fmtL(double v) => '${v.toStringAsFixed(2)} L';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tierColor = _colorFor(_currentTierLabel);
    final balanceColor = _currentBalance <= 0 ? _danger : _success;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _timerCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Current Balance',
                  value: _fmt(_currentBalance),
                  color: balanceColor,
                  sub: _currentBalance <= 0 ? 'Exhausted' : 'Available',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  icon: Icons.payments_outlined,
                  label: 'Session Cost',
                  value: _fmt(_sessionCost),
                  color: _brand,
                  sub: 'This session',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.military_tech_outlined,
                  label: 'Current Tier',
                  value: _currentTierLabel,
                  color: tierColor,
                  sub: widget.data.userTier?.isTierSet ?? false
                      ? 'Based on usage'
                      : 'Tier not configured',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  icon: Icons.speed_outlined,
                  label: 'Rate',
                  value: '${_fmt(_currentRate)}/hr',
                  color: tierColor,
                  sub: 'Current charge rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Water Supplied',
                  value: _fmtL(_waterUsed),
                  color: const Color(0xFF0EA5E9),
                  sub: 'This session (est.)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  icon: Icons.history_outlined,
                  label: 'Total Tier Used',
                  value: _fmtL(_tierUsedNow),
                  color: tierColor,
                  sub: widget.data.userTier?.isTierSet ?? false
                      ? 'of ${_fmtL(widget.data.userTier!.baseTierLimit!)} base'
                      : 'Tier not configured',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.data.userTier?.isTierSet ?? false) ...[
            _tierProgressCard(tierColor),
            const SizedBox(height: 12),
          ],
          _startTimeCard(),
          const SizedBox(height: 12),
          _pricingCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _timerCard() {
    final stationName = widget.data.userTier?.pumpStationName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B6CB0), Color(0xFF3182CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _brand.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'PUMP RUNNING FOR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _elapsedStr,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _elapsed.inHours > 0
                ? '${_elapsed.inHours}h ${_elapsed.inMinutes.remainder(60)}m ${_elapsed.inSeconds.remainder(60)}s'
                : '${_elapsed.inMinutes}m ${_elapsed.inSeconds.remainder(60)}s elapsed',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (stationName != null && stationName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    size: 12,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stationName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _tierProgressCard(Color tierColor) {
    final base = widget.data.userTier!.baseTierLimit!;
    final tierTwoLimit = base * 1.15;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.stacked_bar_chart,
                  size: 16,
                  color: tierColor,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tier Usage Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentTierLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FixedZoneTierBar(
            tierUsed: _tierUsedNow,
            baseTierLimit: base,
            tierTwoLimit: tierTwoLimit,
            tierColor: tierColor,
            isLive: true,
          ),
        ],
      ),
    );
  }

  Widget _startTimeCard() {
    final startTime = widget.data.startTime;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: _success,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pump started at',
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                startTime != null
                    ? DateFormat(
                        'MMM dd, yyyy • hh:mm:ss a',
                      ).format(startTime.toLocal())
                    : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingCard() {
    final p = widget.data.waterPricing;
    if (p == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: _textSecondary),
              SizedBox(width: 8),
              Text(
                'Pricing Reference',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _priceChip('Tier 1', p.tierOneRate, _success),
              const SizedBox(width: 8),
              _priceChip('Tier 2', p.tierTwoRate, _warning),
              const SizedBox(width: 8),
              _priceChip('Tier 3', p.tierThreeRate, _danger),
            ],
          ),
          if (!(widget.data.userTier?.isTierSet ?? false)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _warning.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined, size: 14, color: _warning),
                  SizedBox(width: 6),
                  Text(
                    'Tier not configured — Tier 1 rate applies',
                    style: TextStyle(
                      fontSize: 12,
                      color: _warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceChip(String label, double rate, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '৳${rate.toStringAsFixed(0)}/hr',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration get _card => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _NotRunningView extends StatelessWidget {
  const _NotRunningView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_damage_outlined,
                size: 64,
                color: Color(0xFFA0AEC0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Pump Running',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Live status is only available\nwhen a pump is active.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF718096),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: Color(0xFF3182CE),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
