// lib/screens/complaint_management_screen.dart

import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/all_complaint/all_complaint_state.dart';
import '../common/bloc/all_complaint/all_complaint_state_cubit.dart';
import '../common/bloc/all_complaint/update_complaint_state.dart';
import '../common/bloc/all_complaint/update_complaint_state_cubit.dart';
import '../data/models/complaint.dart';
import '../domain/usecases/all_complaints.dart';
import '../domain/usecases/update_complaint.dart';

class ComplaintManagementScreen extends StatefulWidget {
  final User userData;

  const ComplaintManagementScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPage = 0;
  final int pageSize = 20;

  // Filter state
  ComplaintStatus? filterStatus;
  String? filterPhone;
  DateTime? filterFromDate;
  DateTime? filterToDate;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _info = Color(0xFF3182CE);

  BuildContext? _providerContext;

  void _loadComplaints() {
    if (_providerContext == null) return;

    final criteria = ComplaintCriteria(
      page: currentPage,
      size: pageSize,
      status: filterStatus,
      phone: filterPhone,
      fromDate: filterFromDate,
      toDate: filterToDate,
    );

    _providerContext!.read<ComplaintListCubit>().loadComplaints(
      useCase: serviceLocator<GetAllComplaintsUseCase>(),
      params: criteria,
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;

    final scaffoldContext = _providerContext!;

    ComplaintStatus? tempStatus = filterStatus;
    String? tempPhone = filterPhone;
    DateTime? tempFromDate = filterFromDate;
    DateTime? tempToDate = filterToDate;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter Feedbacks',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Filter
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ComplaintStatus>(
                        value: tempStatus,
                        decoration: InputDecoration(
                          hintText: 'Select Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...ComplaintStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone Filter
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: tempPhone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          tempPhone = value.isEmpty ? null : value;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Date Range
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickerField(
                              label: 'From',
                              selectedDate: tempFromDate,
                              onDateSelected: (date) {
                                setDialogState(() {
                                  tempFromDate = date;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DatePickerField(
                              label: 'To',
                              selectedDate: tempToDate,
                              onDateSelected: (date) {
                                setDialogState(() {
                                  tempToDate = date;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                _GhostButton(
                  label: 'Clear',
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      filterStatus = null;
                      filterPhone = null;
                      filterFromDate = null;
                      filterToDate = null;
                      currentPage = 0;
                    });
                    _loadComplaints();
                  },
                ),
                _GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(builderContext).pop(),
                ),
                _BrandButton(
                  label: 'Apply',
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      filterStatus = tempStatus;
                      filterPhone = tempPhone;
                      filterFromDate = tempFromDate;
                      filterToDate = tempToDate;
                      currentPage = 0;
                    });
                    _loadComplaints();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateDialog(ComplaintItem complaint) {
    ComplaintStatus selectedStatus = complaint.status;
    final TextEditingController remarksController = TextEditingController(
      text: complaint.finalRemarks ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Update Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ComplaintStatus>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: ComplaintStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Final Remarks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter final remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                _GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(builderContext).pop(),
                ),
                _BrandButton(
                  label: 'Update',
                  onPressed: () {
                    if (remarksController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter final remarks'),
                          backgroundColor: _danger,
                        ),
                      );
                      return;
                    }

                    Navigator.of(builderContext).pop();

                    final updateModel = ComplaintUpdateModel(
                      status: selectedStatus,
                      finalRemarks: remarksController.text.trim(),
                    );

                    _providerContext!
                        .read<ComplaintUpdateCubit>()
                        .updateComplaint(
                          useCase: serviceLocator<UpdateComplaintUseCase>(),
                          complaintId: complaint.id,
                          params: UpdateComplaintParams(
                            complaintId: complaint.id,
                            updateModel: updateModel,
                          ),
                        );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
    _loadComplaints();
  }

  String _getFilterSummary() {
    List<String> parts = [];

    if (filterStatus != null) {
      parts.add(filterStatus!.displayName);
    }
    if (filterPhone != null && filterPhone!.isNotEmpty) {
      parts.add(filterPhone!);
    }
    if (filterFromDate != null || filterToDate != null) {
      String dateRange = '';
      if (filterFromDate != null) {
        dateRange = DateFormat('MMM dd').format(filterFromDate!);
      }
      if (filterToDate != null) {
        dateRange += ' - ${DateFormat('MMM dd').format(filterToDate!)}';
      }
      parts.add(dateRange);
    }

    return parts.isEmpty ? 'All Feedbacks' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ComplaintListCubit()
            ..loadComplaints(
              useCase: serviceLocator<GetAllComplaintsUseCase>(),
              params: ComplaintCriteria(page: currentPage, size: pageSize),
            ),
        ),
        BlocProvider(create: (_) => ComplaintUpdateCubit()),
      ],
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return MultiBlocListener(
            listeners: [
              BlocListener<ComplaintUpdateCubit, ComplaintUpdateState>(
                listener: (context, state) {
                  if (state is ComplaintUpdateSuccessState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback updated successfully!'),
                        backgroundColor: _success,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    context.read<ComplaintUpdateCubit>().resetState();
                    _loadComplaints();
                  } else if (state is ComplaintUpdateFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: _danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    context.read<ComplaintUpdateCubit>().resetState();
                  }
                },
              ),
            ],
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: _bg,
              drawer: RoleBasedDrawer(userData: widget.userData),
              appBar: CustomTopBar(
                title: 'Feedback Management',
                onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              body: Column(
                children: [
                  // Filter Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: _cardDecoration,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: _textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getFilterSummary(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        _BrandButton(
                          label: 'Filter',
                          onPressed: () => _showFilterDialog(),
                          dense: true,
                        ),
                      ],
                    ),
                  ),

                  // Complaints List
                  Expanded(
                    child: BlocBuilder<ComplaintListCubit, ComplaintListState>(
                      builder: (context, state) {
                        if (state is ComplaintListLoadingState) {
                          return const _CenteredLoader();
                        }

                        if (state is ComplaintListErrorState) {
                          return _ErrorView(
                            message: state.errorMessage,
                            onRetry: () => _loadComplaints(),
                          );
                        }

                        if (state is ComplaintListLoadedState) {
                          if (state.complaints.isEmpty) {
                            return const _EmptyView();
                          }

                          return Column(
                            children: [
                              // List Items
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: state.complaints.length,
                                  itemBuilder: (context, index) {
                                    final complaint = state.complaints[index];
                                    return _AnimatedIn(
                                      delay: Duration(
                                        milliseconds: 40 * (index + 1),
                                      ),
                                      child: _buildComplaintCard(
                                        context,
                                        complaint,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Pagination Controls
                              if (state.totalPages > 1)
                                _PaginationBar(
                                  current: state.currentPage + 1,
                                  total: state.totalPages,
                                  onPrev: state.currentPage > 0
                                      ? () => _goToPage(state.currentPage - 1)
                                      : null,
                                  onNext:
                                      state.currentPage < state.totalPages - 1
                                      ? () => _goToPage(state.currentPage + 1)
                                      : null,
                                ),
                            ],
                          );
                        }

                        return const _CenteredLoader();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintItem complaint) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (complaint.status) {
      case ComplaintStatus.NEW:
        statusColor = _info;
        statusBgColor = const Color(0xFFEBF8FF);
        statusIcon = Icons.new_releases;
        break;
      case ComplaintStatus.IN_PROGRESS:
        statusColor = _warning;
        statusBgColor = const Color(0xFFFFF4E6);
        statusIcon = Icons.pending;
        break;
      case ComplaintStatus.CLOSED:
        statusColor = _success;
        statusBgColor = const Color(0xFFD1FAE5);
        statusIcon = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Status Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 16),

                // Complaint Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feedback #${complaint.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          complaint.status.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Update Button
                if (complaint.status != ComplaintStatus.CLOSED)
                  IconButton(
                    onPressed: () => _showUpdateDialog(complaint),
                    icon: const Icon(Icons.edit, color: _brand),
                    tooltip: 'Update Complaint',
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 16),

            // User Info
            _InfoRow(icon: Icons.person, label: 'Name', value: complaint.name),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone, label: 'Phone', value: complaint.phone),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.badge, label: 'Role', value: complaint.role),

            const SizedBox(height: 16),

            // Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.message, size: 16, color: _textSecondary),
                      SizedBox(width: 8),
                      Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.message,
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                  ),
                ],
              ),
            ),

            // Final Remarks (if exists)
            if (complaint.finalRemarks != null &&
                complaint.finalRemarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 16, color: statusColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Final Remarks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.finalRemarks!,
                      style: const TextStyle(fontSize: 14, color: _textPrimary),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Status Changed Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.update, size: 16, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Updated',
                          style: TextStyle(fontSize: 11, color: _textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          complaint.statusChangedAt != null
                              ? DateFormat(
                                  'MMM dd, yyyy • hh:mm a',
                                ).format(complaint.statusChangedAt!.toLocal())
                              : 'Not updated yet',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        if (complaint.statusChangedBy != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'by ${complaint.statusChangedBy}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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

// --- Reusable widgets ---

class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dense;

  const _BrandButton({required this.label, this.onPressed, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: _ComplaintManagementScreenState._brand,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 16 : 20,
              vertical: dense ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => Colors.white.withOpacity(
                states.contains(WidgetState.pressed) ? 0.08 : 0.04,
              ),
            ),
          ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GhostButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style:
          TextButton.styleFrom(
            foregroundColor: _ComplaintManagementScreenState._textSecondary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.black.withOpacity(0.04),
            ),
          ),
      child: Text(label),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _ComplaintManagementScreenState._textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: _ComplaintManagementScreenState._textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ComplaintManagementScreenState._textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: selectedDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onDateSelected(null),
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM dd, yyyy').format(selectedDate!)
              : 'Select date',
          style: TextStyle(
            fontSize: 13,
            color: selectedDate != null
                ? _ComplaintManagementScreenState._textPrimary
                : _ComplaintManagementScreenState._textSecondary,
          ),
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
          color: _ComplaintManagementScreenState._brand,
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Complaints Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ComplaintManagementScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No complaints match your filter criteria',
              style: TextStyle(
                fontSize: 14,
                color: _ComplaintManagementScreenState._textSecondary,
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
              'Error Loading Complaints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ComplaintManagementScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _ComplaintManagementScreenState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ComplaintManagementScreenState._brand,
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

class _PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ComplaintManagementScreenState._surface,
        border: const Border(
          top: BorderSide(color: _ComplaintManagementScreenState._border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BrandButton(label: 'Previous', onPressed: onPrev),
          Text(
            'Page $current of $total',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _ComplaintManagementScreenState._textPrimary,
            ),
          ),
          _BrandButton(label: 'Next', onPressed: onNext),
        ],
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
