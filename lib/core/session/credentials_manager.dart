class CredentialsManager {
  static final CredentialsManager _instance = CredentialsManager._internal();
  factory CredentialsManager() => _instance;
  CredentialsManager._internal();

  String? _phone;
  String? _password;

  void saveCredentials(String phone, String password) {
    _phone = phone;
    _password = password;
  }

  String get phone => _phone ?? "0";
  String get password => _password ?? "0";

  void clear() {
    _phone = null;
    _password = null;
  }
}
