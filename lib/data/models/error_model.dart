class ErrorModel {
  final int code;
  final String message;
  final String? errorKey;
  final List<String>? args;

  ErrorModel({
    required this.code,
    required this.message,
    this.errorKey,
    this.args,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      code: json['code'] as int,
      message: json['message'] as String,
      errorKey: json['errorKey'] as String?,
      args: json['args'] != null
          ? List<String>.from(json['args'] as List)
          : null,
    );
  }
}
