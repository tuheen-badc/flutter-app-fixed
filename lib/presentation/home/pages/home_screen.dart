import 'package:demo_app/common/bloc/home/home_state.dart';
import 'package:demo_app/common/bloc/home/home_state_cubit.dart';
import 'package:demo_app/presentation/auth/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import 'admin_home_screen.dart';
import 'super_admin_home_screen.dart';
import 'user_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8F9FA),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          } else if (state is HomeLoadedState) {
            return _buildRoleBasedScreen(state.userInfo.role, state);
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }

  Widget _buildRoleBasedScreen(UserRole role, HomeLoadedState state) {
    switch (role) {
      case UserRole.USER:
        return const UserHomeScreen(); // ← remove state: state
      case UserRole.ADMIN:
        return AdminHomeScreen(state: state); // unchanged
      case UserRole.SUPER_ADMIN:
        return SuperAdminHomeScreen(state: state); // unchanged
    }
  }
}
