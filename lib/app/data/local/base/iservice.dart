/// Base interface for local storage services
abstract class IService {
  /// Initialize the service
  Future<void> init();

  /// Clear all stored data
  Future<void> clear();
}


