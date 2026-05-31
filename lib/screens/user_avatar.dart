import 'package:demo_app/core/constants/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAvatar extends StatelessWidget {
  final double radius;

  const UserAvatar({super.key, required this.radius});

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadToken(),
      builder: (context, snap) {
        final token = snap.data;
        final hasToken =
            snap.connectionState == ConnectionState.done &&
            token != null &&
            token.isNotEmpty;

        final ImageProvider? img = hasToken
            ? NetworkImage(
                ApiUrls.loggedInUserImage,
                headers: {'Authorization': 'Bearer $token'},
              )
            : null;

        if (img == null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(Icons.person, color: Colors.white),
          );
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white.withOpacity(0.3),
          foregroundImage: img,
          onForegroundImageError: (e, st) => debugPrint('Avatar error: $e'),
          child: const Icon(Icons.person, color: Colors.white),
        );
      },
    );
  }
}
