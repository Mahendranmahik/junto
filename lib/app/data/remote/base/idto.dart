/// Base interface for all Data Transfer Objects
abstract class IDto {
  /// Converts DTO to JSON map
  Map<String, dynamic> toJson();

  /// Creates DTO from JSON map
  IDto fromJson(Map<String, dynamic> json);
}


