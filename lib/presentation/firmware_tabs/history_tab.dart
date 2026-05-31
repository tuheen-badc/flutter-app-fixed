// firmware_history_tab.dart
import 'package:demo_app/common/bloc/firmware_history/firmware_history_state.dart';
import 'package:demo_app/data/models/firmware_history_item.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/firmware_history/firmware_history_state_cubit.dart';
import '../../domain/usecases/firmware_history.dart';

class FirmwareHistoryTab extends StatelessWidget {
  const FirmwareHistoryTab({Key? key}) : super(key: key);

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FirmwareHistoryCubit()
        ..loadFirmwareHistory(
          useCase: serviceLocator<FirmwareHistoryUseCase>(),
        ),
      child: Builder(
        builder: (providerContext) {
          return BlocBuilder<FirmwareHistoryCubit, FirmwareHistoryState>(
            builder: (context, state) {
              if (state is FirmwareHistoryLoadingState) {
                return const _CenteredLoader();
              }

              if (state is FirmwareHistoryErrorState) {
                return _ErrorView(
                  message: state.errorMessage,
                  onRetry: () {
                    context.read<FirmwareHistoryCubit>().loadFirmwareHistory(
                      useCase: serviceLocator<FirmwareHistoryUseCase>(),
                    );
                  },
                );
              }

              if (state is FirmwareHistoryLoadedState) {
                if (state.historyList.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FirmwareHistoryCubit>().loadFirmwareHistory(
                      useCase: serviceLocator<FirmwareHistoryUseCase>(),
                    );
                  },
                  color: _brand,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.historyList.length,
                    itemBuilder: (context, index) {
                      final item = state.historyList[index];
                      return _AnimatedIn(
                        delay: Duration(milliseconds: 40 * (index + 1)),
                        child: _buildHistoryCard(item),
                      );
                    },
                  ),
                );
              }

              return const _CenteredLoader();
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(FirmwareHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _success.withOpacity(0.3)),
              ),
              child: const Icon(Icons.check_circle, color: _success, size: 24),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version ${item.version}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(item.uploadedAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Uploaded',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _success,
                ),
              ),
            ),
          ],
        ),
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

// --- Reusable Widgets ---

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: FirmwareHistoryTab._brand,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Firmware History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FirmwareHistoryTab._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your first firmware to see history',
              style: TextStyle(
                fontSize: 14,
                color: FirmwareHistoryTab._textSecondary,
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
              'Error Loading History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FirmwareHistoryTab._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: FirmwareHistoryTab._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: FirmwareHistoryTab._brand,
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
