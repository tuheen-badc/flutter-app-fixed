import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/user_tier/user_tier_state.dart';
import '../common/bloc/user_tier/user_tier_state_cubit.dart';
import '../data/models/fixed_zone_tier_bar.dart';
import '../data/models/user_tier_list.dart';
import '../domain/usecases/user_tier.dart';
import '../presentation/pump_tabs/tab_design_tokens.dart';
import '../service_locator.dart';

class UserTierContent extends StatelessWidget {
  final int userId;
  final int? pumpStationId;

  const UserTierContent({Key? key, required this.userId, this.pumpStationId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TierInfoCubit()
        ..loadTierInfo(
          useCase: serviceLocator<UserTierUseCase>(),
          targetPumpStationId: pumpStationId,
          userId: userId,
        ),
      child: BlocBuilder<TierInfoCubit, TierInfoState>(
        builder: (context, state) {
          if (state is TierInfoLoadingState) {
            return const _CenteredLoader();
          }
          if (state is TierInfoEmptyState) {
            return _EmptyTierView(
              onRetry: () => context.read<TierInfoCubit>().refreshTierInfo(
                useCase: serviceLocator<UserTierUseCase>(),
                targetPumpStationId: pumpStationId,
                userId: userId,
              ),
            );
          }
          if (state is TierInfoErrorState) {
            return _ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<TierInfoCubit>().refreshTierInfo(
                useCase: serviceLocator<UserTierUseCase>(),
                targetPumpStationId: pumpStationId,
                userId: userId,
              ),
            );
          }
          if (state is TierInfoLoadedState) {
            return _TierContentBody(state: state);
          }
          return const _CenteredLoader();
        },
      ),
    );
  }
}

// ── Tier content body ─────────────────────────────────────────────────────────

class _TierContentBody extends StatelessWidget {
  final TierInfoLoadedState state;

  const _TierContentBody({required this.state});

  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _warning = Color(0xFFF59E0B);
  static const _danger = Color(0xFFEF4444);
  static const _info = Color(0xFF3182CE);
  static const _accent = Color(0xFF805AD5);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pump station selector
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.water_damage, color: _brand, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Select Pump Station',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: state.selectedIndex,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _brand, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: List.generate(state.tierList.length, (index) {
                    final tier = state.tierList[index];
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        '${tier.pumpStationId} - ${tier.pumpStationName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<TierInfoCubit>().selectPumpStation(value);
                    }
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: _brand),
                  isExpanded: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tier information card
          _AnimatedIn(
            delay: const Duration(milliseconds: 100),
            child: _buildTierInfoCard(state.selectedTier),
          ),

          const SizedBox(height: 20),

          // Usage / progress card — uses the shared FixedZoneTierBar
          if (state.selectedTier.isTierSet) ...[
            _AnimatedIn(
              delay: const Duration(milliseconds: 200),
              child: _buildUsageCard(state.selectedTier),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTierInfoCard(PumpStationTierInfo tier) {
    final pricing = state.waterPricingResponse;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tier.isTierSet
                      ? const Color(0xFFEBF8FF)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: tier.isTierSet
                        ? _info.withOpacity(0.3)
                        : _warning.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  tier.isTierSet ? Icons.verified : Icons.info_outline,
                  color: tier.isTierSet ? _info : _warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      tier.userTier.toString().split('.').last,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: tier.isTierSet ? _info : _warning,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!tier.isTierSet) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: _warning),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No budget allocation found for the user. Therefore, determining the tier is not possible. The base rate will be applied if the tier is not set.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          // Tier limits with pricing
          Row(
            children: [
              Expanded(
                child: _PricingInfoTile(
                  icon: Icons.water_drop,
                  label: 'Tier 1',
                  limit: tier.isTierSet
                      ? '${tier.baseTierLimit!.toStringAsFixed(2)} L'
                      : '∞',
                  rate: pricing.tierOneRate != null
                      ? '৳${pricing.tierOneRate!.toStringAsFixed(2)}/L'
                      : 'N/A',
                  color: _success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PricingInfoTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Tier 2',
                  limit: tier.isTierSet && tier.tierTwoLimit != null
                      ? '${tier.tierTwoLimit!.toStringAsFixed(2)} L'
                      : '∞',
                  rate: pricing.tierTwoRate != null
                      ? '৳${pricing.tierTwoRate!.toStringAsFixed(2)}/L'
                      : 'N/A',
                  color: _warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.trending_up,
                  label: 'Used',
                  value: tier.tierUsed != null
                      ? '${tier.tierUsed!.toStringAsFixed(2)} L'
                      : '0.00 L',
                  color: _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PricingInfoTile(
                  icon: Icons.all_inclusive,
                  label: 'Tier 3',
                  limit: 'Unlimited',
                  rate: pricing.tierThreeRate != null
                      ? '৳${pricing.tierThreeRate!.toStringAsFixed(2)}/L'
                      : 'N/A',
                  color: _danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(PumpStationTierInfo tier) {
    final tierUsed = tier.tierUsed ?? 0.0;
    final baseTierLimit = tier.baseTierLimit ?? 0.0;
    final tierTwoLimit = tier.tierTwoLimit ?? baseTierLimit * 1.15;

    // Determine which zone the user is in for the status banner
    final String currentZoneLabel;
    final Color statusColor;
    final String statusMessage;

    if (tierUsed <= baseTierLimit) {
      currentZoneLabel = 'Base Tier (Green Zone)';
      statusColor = _success;
      statusMessage = 'You are within the base tier limit';
    } else if (tierUsed <= tierTwoLimit) {
      currentZoneLabel = 'Tier 2 (Yellow Zone)';
      statusColor = _warning;
      statusMessage = 'You have exceeded base tier. Tier 2 rates apply';
    } else {
      currentZoneLabel = 'Tier 3 (Red Zone)';
      statusColor = _danger;
      statusMessage = 'You have exceeded Tier 2. Tier 3 rates apply';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          const Row(
            children: [
              Icon(Icons.analytics, size: 20, color: _brand),
              SizedBox(width: 12),
              Text(
                'Usage Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Shared fixed-zone bar (no more _ThreeTierProgressBar) ──────────
          FixedZoneTierBar(
            tierUsed: tierUsed,
            baseTierLimit: baseTierLimit,
            tierTwoLimit: tierTwoLimit,
            tierColor: statusColor,
            isLive: false,
          ),

          const SizedBox(height: 20),

          // Status banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  tierUsed <= baseTierLimit
                      ? Icons.check_circle_outline
                      : tierUsed <= tierTwoLimit
                      ? Icons.warning_amber
                      : Icons.error_outline,
                  size: 20,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentZoneLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusMessage,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration get _cardDecoration => BoxDecoration(
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

// ── Pricing info tile ─────────────────────────────────────────────────────────

class _PricingInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String limit;
  final String rate;
  final Color color;

  const _PricingInfoTile({
    required this.icon,
    required this.label,
    required this.limit,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            limit,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rate,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 20),
          // matches _PricingInfoTile rate badge height
        ],
      ),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: DesignTokens.brand,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _EmptyTierView extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyTierView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: DesignTokens.brand),
            const SizedBox(height: 16),
            const Text(
              'No Tier Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data will be available after pump usages or budget allocation from office.',
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.brand,
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
                'Refresh',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Tier Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.brand,
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

class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedIn({required this.child, this.delay = Duration.zero});

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
