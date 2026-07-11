class CredentialsManager {
  static final CredentialsManager _instance = CredentialsManager._internal();
  factory CredentialsManager() => _instance;
  CredentialsManager._internal();

  String? _phone;
  String? _password;

  // Track the first time we saw a specific pump stop to handle clock drift persistently
  final Map<int, DateTime> _lastStopTimes = {};
  final Map<int, DateTime> _firstFetchTimes = {};

  void saveCredentials(String phone, String password) {
    _phone = phone;
    _password = password;
  }

  String get phone => _phone ?? "0";
  String get password => _password ?? "0";

  /// Returns how many seconds have elapsed since we first saw this pump stopped.
  /// This persists even if the user changes screens.
  int getLocalElapsedSeconds(int pumpId, DateTime currentStopFromServer) {
    final now = DateTime.now();
    
    // If this is a new stop event we haven't seen before, reset tracking
    if (_lastStopTimes[pumpId] != currentStopFromServer) {
      _lastStopTimes[pumpId] = currentStopFromServer;
      _firstFetchTimes[pumpId] = now;
      return 0;
    }

    // Return seconds since we first started tracking this specific stop event
    return now.difference(_firstFetchTimes[pumpId]!).inSeconds;
  }

  void clear() {
    _phone = null;
    _password = null;
    _lastStopTimes.clear();
    _firstFetchTimes.clear();
  }
}
