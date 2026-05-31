// screens/update_profile_picture_screen.dart
import 'dart:io';

import 'package:demo_app/common/bloc/update_profile_picture/update_profile_picture_state.dart';
import 'package:demo_app/common/bloc/update_profile_picture/update_profile_picture_state_cubit.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/domain/usecases/update_profile_picture.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/common_top_bar.dart';
import '../../../service_locator.dart';
import '../../drawer/drawer_config.dart';
import '../../home/pages/home_screen.dart';

class UpdateProfilePictureScreen extends StatefulWidget {
  final User userData;

  const UpdateProfilePictureScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<UpdateProfilePictureScreen> createState() =>
      _UpdateProfilePictureScreenState();
}

Future<String?> _loadToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

class _UpdateProfilePictureScreenState
    extends State<UpdateProfilePictureScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String? _validationError;

  // Allowed image types
  final List<String> _allowedTypes = [
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
  ];

  // Max file size (2MB in bytes)
  final int _maxFileSize = 2 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
  }

  String _getMimeTypeFromExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'unknown';
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Print MIME type for debugging
        print('Selected image MIME type: ${pickedFile.mimeType}');
        print('Selected image name: ${pickedFile.name}');
        print('Selected image path: ${pickedFile.path}');

        // Validate file type
        if (pickedFile.mimeType != null) {
          if (!_allowedTypes.contains(pickedFile.mimeType)) {
            print(
              'MIME type validation failed. Expected one of: $_allowedTypes',
            );
            setState(() {
              _validationError =
                  'Invalid image format: ${pickedFile.mimeType}\nPlease select a valid image format (JPEG, PNG, WebP)';
              _selectedImage = null;
            });
            return;
          }
        } else {
          if (!_allowedTypes.contains(
            _getMimeTypeFromExtension(pickedFile.name),
          )) {
            print(
              'MIME type validation failed. Expected one of: $_allowedTypes',
            );
            setState(() {
              _validationError =
                  'Invalid image format: ${pickedFile.mimeType}\nPlease select a valid image format (JPEG, PNG, WebP)';
              _selectedImage = null;
            });
            return;
          }
        }

        // Validate file size
        final int fileSize = await pickedFile.length();
        print(
          'Selected image file size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
        );

        if (fileSize > _maxFileSize) {
          setState(() {
            _validationError =
                'File size must be less than 2MB. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB';
            _selectedImage = null;
          });
          return;
        }

        // If validation passes, set the selected image
        setState(() {
          _selectedImage = pickedFile;
          _validationError = null;
        });

        print('Image validation passed successfully');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error selecting image: $e');
      setState(() {
        _validationError = 'Error selecting image. Please try again.';
        _selectedImage = null;
      });
    }
  }

  Widget _buildProfileImageWidget() {
    const double imageSize = 150;

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3182CE), width: 3),
      ),
      child: ClipOval(
        child: _selectedImage != null
            ? Image.file(
                File(_selectedImage!.path),
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(),
              )
            : _buildInitialProfileImage(imageSize),
      ),
    );
  }

  Widget _buildInitialProfileImage(double imageSize) {
    return FutureBuilder<String?>(
      future: _loadToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        final hasToken =
            snapshot.connectionState == ConnectionState.done &&
            token != null &&
            token.isNotEmpty;

        if (!hasToken) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildPlaceholderAvatar();
        }

        final ImageProvider imageProvider = NetworkImage(
          ApiUrls.loggedInUserImage,
          headers: {'Authorization': 'Bearer $token'},
        );

        return Image(
          image: imageProvider,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Profile image error: $error');
            return _buildPlaceholderAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }

  void _updateProfilePicture(BuildContext ctx) {
    if (_selectedImage == null) {
      setState(() {
        _validationError = 'Please select an image';
      });
      return;
    }

    ctx.read<UpdateProfilePictureButtonStateCubit>().updateProfilePicture(
      useCase: serviceLocator<UpdateProfilePictureUseCase>(),
      params: _selectedImage!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateProfilePictureButtonStateCubit(),
      child: BlocListener<UpdateProfilePictureButtonStateCubit, UpdateProfilePictureButtonState>(
        listener: (context, state) {
          if (state is UpdateProfilePictureButtonSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to previous screen or HomeScreen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state is UpdateProfilePictureButtonFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FA),
          drawer: RoleBasedDrawer(
            userData: widget.userData,
            initialActiveItem: DrawerMenuItem.userManagement,
          ),
          appBar: CustomTopBar(
            title: 'Update Profile Picture',
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'Update Your Profile Picture',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a new profile picture from gallery (Max 2MB, JPEG/PNG/WebP)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Profile Image Display
                        Center(
                          child: Stack(
                            children: [
                              _buildProfileImageWidget(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImageFromGallery,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3182CE),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.photo_library,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_validationError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validationError!,
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),

                        // if (_selectedImage != null)
                        //   Container(
                        //     padding: const EdgeInsets.all(16),
                        //     decoration: BoxDecoration(
                        //       color: Colors.green[50],
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(color: Colors.green[200]!),
                        //     ),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Row(
                        //           children: [
                        //             Icon(
                        //               Icons.check_circle,
                        //               color: Colors.green[600],
                        //               size: 20,
                        //             ),
                        //             const SizedBox(width: 8),
                        //             const Text(
                        //               'Selected Image:',
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: 14,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         const SizedBox(height: 8),
                        //         Text(
                        //           'Name: ${_selectedImage!.name}',
                        //           style: const TextStyle(fontSize: 12),
                        //         ),
                        //         Text(
                        //           'Type: ${_selectedImage!.mimeType ?? 'Unknown'}',
                        //           style: const TextStyle(fontSize: 12),
                        //         ),
                        //         FutureBuilder<int>(
                        //           future: _selectedImage!.length(),
                        //           builder: (context, snapshot) {
                        //             if (snapshot.hasData) {
                        //               final sizeInMB =
                        //                   (snapshot.data! / 1024 / 1024);
                        //               return Text(
                        //                 'Size: ${sizeInMB.toStringAsFixed(2)} MB',
                        //                 style: const TextStyle(
                        //                   fontSize: 12,
                        //                 ),
                        //               );
                        //             }
                        //             return const Text(
                        //               'Size: Calculating...',
                        //               style: TextStyle(fontSize: 12),
                        //             );
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        const SizedBox(height: 10),

                        // Buttons
                        BlocBuilder<
                          UpdateProfilePictureButtonStateCubit,
                          UpdateProfilePictureButtonState
                        >(
                          builder: (context, buttonState) {
                            final isLoading =
                                buttonState
                                    is UpdateProfilePictureButtonLoadingState;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _updateProfilePicture(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: const Color(0xFF3182CE),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Updating...'),
                                      ],
                                    )
                                  : const Text(
                                      'Update Profile Picture',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
