/// Base interface for all local entities
abstract class IEntity {
  /// Converts entity to JSON map
  Map<String, dynamic> toJson();

  /// Creates entity from JSON map
  IEntity fromJson(Map<String, dynamic> json);
}


