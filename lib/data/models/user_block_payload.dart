// user_block_payload.dart
class UserBlockPayload {
  final int userId;
  final bool blocked;

  UserBlockPayload({required this.userId, required this.blocked});

  Map<String, dynamic> toJson() {
    return {'blocked': blocked};
  }
}
