// firmware_upload_tab.dart
import 'dart:io';

import 'package:demo_app/common/bloc/firmware_upload/firmware_upload_state.dart';
import 'package:demo_app/data/models/firmware_upload_request.dart';
import 'package:demo_app/service_locator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/firmware_upload/firmware_upload_state_cubit.dart';
import '../../domain/usecases/firmware_upload.dart';

class FirmwareUploadTab extends StatefulWidget {
  const FirmwareUploadTab({super.key});

  @override
  State<FirmwareUploadTab> createState() => _FirmwareUploadTabState();
}

class _FirmwareUploadTabState extends State<FirmwareUploadTab> {
  final TextEditingController versionController = TextEditingController();
  File? selectedFile;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);

  @override
  void dispose() {
    versionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _uploadFirmware(BuildContext context) {
    if (versionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a version number'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a firmware file'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final request = FirmwareUploadRequest(
      version: versionController.text.trim(),
      file: selectedFile!,
    );

    context.read<FirmwareUploadCubit>().uploadFirmware(
      useCase: serviceLocator<FirmwareUploadUseCase>(),
      params: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FirmwareUploadCubit(),
      child: BlocListener<FirmwareUploadCubit, FirmwareUploadState>(
        listener: (context, state) {
          if (state is FirmwareUploadSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Clear form
            setState(() {
              versionController.clear();
              selectedFile = null;
            });
            context.read<FirmwareUploadCubit>().resetState();
          } else if (state is FirmwareUploadErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: _danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<FirmwareUploadCubit>().resetState();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF8FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: _brand,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Firmware',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Only .bin files are supported',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Version Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: versionController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 1.0.1',
                        prefixIcon: const Icon(Icons.tag, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _brand, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // File Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firmware File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _border,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.upload_file,
                                color: _brand,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedFile == null
                                        ? 'Select .bin file'
                                        : selectedFile!.path.split('/').last,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selectedFile == null
                                          ? _textSecondary
                                          : _textPrimary,
                                    ),
                                  ),
                                  if (selectedFile != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatFileSize(
                                        selectedFile!.lengthSync(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: _textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upload Button
              BlocBuilder<FirmwareUploadCubit, FirmwareUploadState>(
                builder: (context, state) {
                  final isLoading = state is FirmwareUploadLoadingState;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _uploadFirmware(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Firmware',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static BoxDecoration get _cardDecoration => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
