import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/data/models/water_pricing_response.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/water_pricing/water_pricing_state.dart';
import '../common/bloc/water_pricing/water_pricing_state_cubit.dart';
import '../domain/usecases/water_pricing.dart';
import '../presentation/drawer/drawer_config.dart';

class WaterPricingScreen extends StatefulWidget {
  final User userData;

  const WaterPricingScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<WaterPricingScreen> createState() => _WaterPricingScreenState();
}

class _WaterPricingScreenState extends State<WaterPricingScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Design tokens (consistent with other screens)
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _warning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WaterPricingCubit()
            ..execute(useCase: serviceLocator<WaterPricingUseCase>()),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _bg,
        drawer: RoleBasedDrawer(
          userData: widget.userData,
          initialActiveItem: DrawerMenuItem.ratePerTier,
        ),
        appBar: CustomTopBar(
          title: 'Water Pricing',
          onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        body: BlocBuilder<WaterPricingCubit, WaterPricingState>(
          builder: (context, state) {
            if (state is WaterPricingLoadingState) {
              return const _CenteredLoader();
            }

            if (state is WaterPricingErrorState) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<WaterPricingCubit>().refresh(
                  useCase: serviceLocator<WaterPricingUseCase>(),
                ),
              );
            }

            if (state is WaterPricingLoadedState) {
              return _buildPricingContent(context, state.pricing);
            }

            return const _CenteredLoader();
          },
        ),
      ),
    );
  }

  Widget _buildPricingContent(
    BuildContext context,
    WaterPricingResponse pricing,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WaterPricingCubit>().refresh(
          useCase: serviceLocator<WaterPricingUseCase>(),
        );
      },
      color: _brand,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Water Pricing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rates are automatically applied based on your water usage and official budget allocation',
              style: TextStyle(fontSize: 13, color: _textSecondary),
            ),
            const SizedBox(height: 20),

            // Tier 1 Card
            _AnimatedIn(
              delay: const Duration(milliseconds: 50),
              child: _buildTierCard(
                tierNumber: '1',
                tierName: 'Tier 1',
                rate: pricing.tierOneRate,
                description: 'Base Tier',
                oneLiner: 'Applied to your initial daily water usage',
                accentColor: _brand,
              ),
            ),

            const SizedBox(height: 12),

            // Tier 2 Card
            _AnimatedIn(
              delay: const Duration(milliseconds: 100),
              child: _buildTierCard(
                tierNumber: '2',
                tierName: 'Tier 2',
                rate: pricing.tierTwoRate,
                description: 'Moderate Rate',
                oneLiner:
                    'Automatically applied when basic tier usage is exceeded',
                accentColor: _success,
              ),
            ),

            const SizedBox(height: 12),

            // Tier 3 Card
            _AnimatedIn(
              delay: const Duration(milliseconds: 150),
              child: _buildTierCard(
                tierNumber: '∞',
                tierName: 'Tier 3',
                rate: pricing.tierThreeRate,
                description: 'High Volume Rate',
                oneLiner: 'Applied for high volume consumption beyond Tier 2',
                accentColor: _warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required String tierNumber,
    required String tierName,
    required double rate,
    required String description,
    required String oneLiner,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Tier Number Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  tierNumber,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    height: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier name and description badge
                  Row(
                    children: [
                      Text(
                        tierName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rate - now shown first and prominently
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${rate.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          height: 1,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text(
                          'per liter',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // One-liner - now below rate, taking full width
                  Text(
                    oneLiner,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Water Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.water_drop, color: accentColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable widgets ---

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: _WaterPricingScreenState._brand,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Pricing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _WaterPricingScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _WaterPricingScreenState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _WaterPricingScreenState._brand,
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
