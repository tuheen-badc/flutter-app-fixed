import 'package:flutter/material.dart';

import '../../screens/transaction_history_common.dart';

class UserTransactionsTab extends StatelessWidget {
  final int userId;

  const UserTransactionsTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TransactionHistoryContent(userId: userId);
  }
}
