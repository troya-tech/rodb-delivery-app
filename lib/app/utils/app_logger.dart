class AppLogger {
  final String name;

  const AppLogger(this.name);

  void info(String message, [dynamic context]) {
    print('[INFO] $name: $message');
  }

  void warning(String message, [dynamic context]) {
    print('[WARN] $name: $message');
  }

  void error(String message, [dynamic error, dynamic stackTrace, dynamic context]) {
    print('[ERROR] $name: $message');
    if (error != null) print(error);
    if (stackTrace != null) print(stackTrace);
  }

  void debug(String message, [dynamic context]) {
    print('[DEBUG] $name: $message');
  }

  void success(String message, [dynamic context]) {
    print('[SUCCESS] $name: $message');
  }

  dynamic createContext() {
    return null;
  }
}
