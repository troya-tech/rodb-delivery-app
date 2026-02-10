import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:developer' as developer;

/// Context for tracking operations across services
/// 
/// Use this to pass correlation IDs between services for request tracing
class LogContext {
  final String breadcrumbId;
  
  LogContext._(this.breadcrumbId);
  
  /// Create a new log context with a unique breadcrumb ID
  factory LogContext.create() {
    final id = _generateBreadcrumbId();
    return LogContext._(id);
  }
  
  /// Create a log context with a specific breadcrumb ID
  factory LogContext.withId(String id) {
    return LogContext._(id);
  }
  
  /// Generate a short, readable breadcrumb ID
  static String _generateBreadcrumbId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');
    return '$timestamp-$randomPart';
  }
  
  @override
  String toString() => breadcrumbId;
}

/// Centralized logging utility for the application
/// 
/// Provides consistent logging format: [ServiceName] [breadcrumb-id] "message"
/// Only logs in debug mode to avoid performance issues in production
class AppLogger {
  final String _serviceName;
  
  /// Create a logger for a specific service/class
  /// 
  /// Example: `final _logger = AppLogger('AuthService');`
  const AppLogger(this._serviceName);
  
  /// Format log prefix with optional breadcrumb ID
  String _formatPrefix([LogContext? context]) {
    if (context != null) {
      return '[RODB] [$_serviceName] [${context.breadcrumbId}]';
    }
    return '[RODB] [$_serviceName]';
  }
  
  /// Log a debug message
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] message
  /// Only logs in debug mode
  void debug(String message, [LogContext? context]) {
    if (kDebugMode) {
      final formatted = '${_formatPrefix(context)} $message';
      debugPrint(formatted);
      developer.log(message, name: _serviceName, level: 500);
    }
  }
  
  /// Log an info message
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] message
  void info(String message, [LogContext? context]) {
    if (kDebugMode) {
      final formatted = '${_formatPrefix(context)} $message';
      debugPrint(formatted);
      developer.log(message, name: _serviceName, level: 800);
    }
  }
  
  /// Log a warning message
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] message
  void warning(String message, [LogContext? context]) {
    if (kDebugMode) {
      final formatted = '${_formatPrefix(context)} $message';
      debugPrint(formatted);
      developer.log(message, name: _serviceName, level: 900);
    }
  }
  
  /// Log an error message
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] message
  /// Logs in both debug and release mode for critical errors
  void error(String message, [Object? error, StackTrace? stackTrace, LogContext? context]) {
    final formatted = '${_formatPrefix(context)} $message';
    debugPrint(formatted);
    developer.log(message, name: _serviceName, level: 1000, error: error, stackTrace: stackTrace);
    
    if (error != null) {
      debugPrint('${_formatPrefix(context)} Error details: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('${_formatPrefix(context)} Stack trace:\n$stackTrace');
    }
  }
  
  /// Log a success message
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] message
  void success(String message, [LogContext? context]) {
    if (kDebugMode) {
      final formatted = '${_formatPrefix(context)} $message';
      debugPrint(formatted);
      developer.log(message, name: _serviceName, level: 800);
    }
  }
  
  /// Log data/object for debugging
  /// 
  /// Format: [RODB] [ServiceName] [breadcrumb-id] label: data
  void data(String label, Object? data, [LogContext? context]) {
    if (kDebugMode) {
      final formatted = '${_formatPrefix(context)} $label: $data';
      debugPrint(formatted);
      developer.log('$label: $data', name: _serviceName, level: 500);
    }
  }
  
  /// Create a new log context for tracing operations
  /// 
  /// Use this at the start of a user action or API call to track
  /// the flow through multiple services
  LogContext createContext() {
    return LogContext.create();
  }
}
