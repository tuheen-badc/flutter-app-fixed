import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/complaint_submission/complaint_state.dart';
import '../common/bloc/complaint_submission/complaint_state_cubit.dart';
import '../data/models/ComplaintCreationModel.dart';
import '../domain/usecases/complaint_submission.dart';
import '../presentation/drawer/drawer_config.dart';
import '../presentation/home/pages/home_screen.dart';

class ComplaintSubmissionScreen extends StatefulWidget {
  final User userData;

  const ComplaintSubmissionScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<ComplaintSubmissionScreen> createState() =>
      _ComplaintSubmissionScreenState();
}

class _ComplaintSubmissionScreenState extends State<ComplaintSubmissionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  // Design tokens
  static const _bg = Color(0xFFF5F7FA);
  static const _textPrimary = Color(0xFF1A202C);
  static const _textSecondary = Color(0xFF718096);
  static const _accentGradient = [Color(0xFF667eea), Color(0xFF764ba2)];

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController!.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _messageFocusNode.requestFocus(); // ← Add this
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController?.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintCubit(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _bg,
        drawer: RoleBasedDrawer(
          userData: widget.userData,
          initialActiveItem: DrawerMenuItem.helpSupport,
        ),
        appBar: CustomTopBar(
          title: 'Submit Feedback',
          onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        body: BlocConsumer<ComplaintCubit, ComplaintState>(
          listener: (context, state) {
            if (state is ComplaintSubmittedState) {
              // Clear the text field
              _messageController.clear();
            }
          },
          builder: (context, state) {
            if (state is ComplaintSubmittedState) {
              return _buildSuccessView(context);
            }

            return _buildComplaintForm(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildComplaintForm(BuildContext context, ComplaintState state) {
    final isSubmitting = state is ComplaintSubmittingState;

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(
        position: _slideAnimation!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AnimatedIn(
                  delay: const Duration(milliseconds: 100),
                  child: _buildMessageField(isSubmitting),
                ),
                const SizedBox(height: 24),
                _AnimatedIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSubmitButton(context, isSubmitting),
                ),
                if (state is ComplaintErrorState) ...[
                  const SizedBox(height: 16),
                  _AnimatedIn(
                    delay: const Duration(milliseconds: 300),
                    child: _buildErrorMessage(state.errorMessage),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageField(bool isSubmitting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: _accentGradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Your Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'We value your feedback',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _bg),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextFormField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              enabled: !isSubmitting,
              maxLines: 8,
              style: const TextStyle(
                fontSize: 15,
                color: _textPrimary,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Please describe your issue or feedback...',
                hintStyle: TextStyle(
                  color: _textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _bg),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _bg),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667eea),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  context.read<ComplaintCubit>().submitComplaint(
                    useCase: serviceLocator<SubmitComplaintUseCase>(),
                    params: ComplaintCreationModel(
                      message: _messageController.text.trim(),
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Complaint Received!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have received your complaint. Someone from support will contact and resolve your issue as soon as possible.',
                style: TextStyle(
                  fontSize: 15,
                  color: _textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ComplaintCubit>().reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Another Complaint',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Animation widget ---

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
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

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
