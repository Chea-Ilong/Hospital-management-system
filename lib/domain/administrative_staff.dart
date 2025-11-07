import 'staff.dart';

enum AdministrativePosition {
  HR,
  RECEPTIONIST,
  SYSTEM_ADMIN,
}

class AdministrativeStaff extends Staff {
  AdministrativePosition position;

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
    super.currentShift = ShiftType.DAY,
    required this.position,
  }) : super(role: StaffRole.ADMINISTRATIVE);

  @override
  double get getExperienceBonus => getYearsOfExperience * 100.0;
  
  @override
  double computeSalary() {
    double total = salary;
    total += getExperienceBonus;
    return total;
  }

  @override
  String toString() {
    return '''
${super.toString()}
    Position: ${position.toString().split('.').last}
    Experience Bonus: \$${getExperienceBonus.toStringAsFixed(2)}
    Total Pay:  \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
