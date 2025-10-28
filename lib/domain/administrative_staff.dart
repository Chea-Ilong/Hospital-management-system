import 'staff.dart';

/// Enum for administrative positions
enum AdministrativePosition {
  systemsAdministrator,
  hrManager,
  receptionist;
}

/// Administrative Staff class extending Staff
class AdministrativeStaff extends Staff {
  final AdministrativePosition position;

  AdministrativeStaff({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.pastYearsOfExperience,
    required super.hireDate,
    required super.department,
    required super.salary,
    super.currentShift = ShiftType.day,
    required this.position,
  });

  double get experienceBonus => yearsOfExperience * 100.0;

  @override
  String getRole() => 'Administrative Staff';

  @override
  double computeSalary() {
    double total = salary;
    total += experienceBonus;
    return total;
  }

  String _getPositionName() {
    return position.toString().split('.').last;
  }

  @override
  String toString() {

    return '''
${super.toString()}
    Position: ${_getPositionName()}
    Experience Bonus: \$${experienceBonus.toStringAsFixed(2)}
    Total Pay:                \$${computeSalary().toStringAsFixed(2)}
    ''';  }
}
