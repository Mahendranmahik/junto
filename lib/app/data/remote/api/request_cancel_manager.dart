import 'package:dio/dio.dart';

class RequestCancelManager {
  final Map<String, CancelToken> _cancelTokens = {};

  /// Create a cancel token for a request
  CancelToken createCancelToken(String requestId) {
    final token = CancelToken();
    _cancelTokens[requestId] = token;
    return token;
  }

  /// Cancel a specific request
  void cancelRequest(String requestId) {
    _cancelTokens[requestId]?.cancel();
    _cancelTokens.remove(requestId);
  }

  /// Cancel all pending requests
  void cancelAllRequests() {
    for (var token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
  }

  /// Get cancel token for a request
  CancelToken? getCancelToken(String requestId) {
    return _cancelTokens[requestId];
  }
}


