import 'package:flutter/cupertino.dart';

import '../../screens/user_tier_screen_common.dart';

class UserTierTab extends StatelessWidget {
  final int userId;
  final int? pumpStationId;

  const UserTierTab({
    Key? key,
    required this.userId,
    this.pumpStationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserTierContent(
      userId: userId,
      pumpStationId: pumpStationId,
    );
  }
}