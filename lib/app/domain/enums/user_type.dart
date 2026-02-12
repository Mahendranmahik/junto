enum UserType {
  customer,
  admin,
  employee,
  guest,
}

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.customer:
        return 'customer';
      case UserType.admin:
        return 'admin';
      case UserType.employee:
        return 'employee';
      case UserType.guest:
        return 'guest';
    }
  }

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserType.customer;
      case 'admin':
        return UserType.admin;
      case 'employee':
        return UserType.employee;
      case 'guest':
        return UserType.guest;
      default:
        return UserType.guest;
    }
  }
}


