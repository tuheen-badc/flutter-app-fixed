import 'package:demo_app/presentation/settings/pages/update_password_screen.dart';
import 'package:demo_app/presentation/settings/pages/update_phone_screen.dart';
import 'package:demo_app/presentation/settings/pages/update_profile_picture_screen.dart';
import 'package:flutter/material.dart';

import '../data/models/user_info.dart';
import '../presentation/settings/pages/update_name_screen.dart';

class SettingsPage extends StatelessWidget {
  final User user;

  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Change Name'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateNameScreen(userData: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePasswordScreen(userData: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Change Phone Number'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePhoneScreen(userData: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Change Profile Picture'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdateProfilePictureScreen(userData: user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
//
// class GradientThemeButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final double? width;
//   final double height;
//   final double borderRadius;
//   final TextStyle? textStyle;
//   final IconData? icon;
//   final EdgeInsetsGeometry? padding;
//
//   const GradientThemeButton({
//     Key? key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false,
//     this.width,
//     this.height = 50.0,
//     this.borderRadius = 12.0,
//     this.textStyle,
//     this.icon,
//     this.padding,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: onPressed == null && !isLoading
//               ? [
//             const Color(0xFF667eea).withOpacity(0.5),
//             const Color(0xFF764ba2).withOpacity(0.5),
//           ]
//               : [
//             const Color(0xFF667eea),
//             const Color(0xFF764ba2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: onPressed != null || isLoading
//             ? [
//           BoxShadow(
//             color: const Color(0xFF667eea).withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ]
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(borderRadius),
//           onTap: isLoading ? null : onPressed,
//           child: Container(
//             padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(borderRadius),
//             ),
//             child: Center(
//               child: isLoading
//                   ? _buildLoadingContent()
//                   : _buildNormalContent(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNormalContent() {
//     if (icon != null) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: Colors.white,
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: textStyle ??
//                 const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//         ],
//       );
//     }
//
//     return Text(
//       text,
//       style: textStyle ??
//           const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//     );
//   }
//
//   Widget _buildLoadingContent() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.5,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           'Loading...',
//           style: textStyle ??
//               const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//       ],
//     );
//   }
// }
//
// // Example usage widget to demonstrate both states
// class ButtonExampleScreen extends StatefulWidget {
//   const ButtonExampleScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ButtonExampleScreen> createState() => _ButtonExampleScreenState();
// }
//
// class _ButtonExampleScreenState extends State<ButtonExampleScreen> {
//   bool _isLoading = false;
//
//   void _handleButtonPress() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     // Simulate API call or async operation
//     await Future.delayed(const Duration(seconds: 3));
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Action completed!'),
//           backgroundColor: Color(0xFF667eea),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gradient Theme Buttons'),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//             ),
//           ),
//         ),
//         foregroundColor: Colors.white,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFf8f9fa),
//               Color(0xFFe9ecef),
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 'Button Examples',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF764ba2),
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // Normal button
//               GradientThemeButton(
//                 text: 'Login',
//                 onPressed: _isLoading ? null : _handleButtonPress,
//                 isLoading: _isLoading,
//               ),
//               const SizedBox(height: 16),
//
//               // Button with icon
//               GradientThemeButton(
//                 text: 'Save Profile',
//                 icon: Icons.save,
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Profile saved!'),
//                       backgroundColor: Color(0xFF667eea),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Wider button
//               GradientThemeButton(
//                 text: 'Submit Application',
//                 width: double.infinity,
//                 height: 56,
//                 onPressed: () {
//                   print('Application submitted');
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Disabled button
//               const GradientThemeButton(
//                 text: 'Disabled Button',
//                 onPressed: null,
//               ),
//               const SizedBox(height: 16),
//
//               // Custom styled button
//               GradientThemeButton(
//                 text: 'Custom Style',
//                 onPressed: () {},
//                 borderRadius: 25,
//                 height: 50,
//                 textStyle: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
