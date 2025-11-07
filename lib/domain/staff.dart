enum ShiftType {
  DAY(0.0),
  NIGHT(0.20);

  final double bonus;
  const ShiftType(this.bonus);
}

enum StaffRole { DOCTOR, NURSE, ADMINISTRATIVE }

enum StaffDepartment {
  EMERGENCY_DEPARTMENT,
  INTENSIVE_CARE_UNIT,
  PEDIATRICS,
  CARDIOLOGY,
  NEUROLOGY,
  ORTHOPEDICS,
  SURGERY,
  OPERATING_ROOM,
  HUMAN_RESOURCES,
  FINANCE,
  IT_DEPARTMENT,
  RECEPTION,
  ADMINISTRATION
}

abstract class Staff {
  String id;
  String firstName;
  String lastName;
  String email;
  ShiftType currentShift;
  String phoneNumber;
  DateTime dateOfBirth;
  DateTime hireDate;
  int pastYearsOfExperience;
  StaffDepartment department;
  double salary;
  StaffRole role;

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.pastYearsOfExperience,
    required this.hireDate,
    required this.currentShift,
    required this.department,
    required this.salary,
    required this.role,
  });

  double get getExperienceBonus;
  double computeSalary();

  String get getRoleName => role.name;
  String get getFullName => '$firstName $lastName';
  int get getAge => yearsBetween(dateOfBirth, DateTime.now());
  int get getYearsOfService => yearsBetween(hireDate, DateTime.now());
  int get getYearsOfExperience => getYearsOfService + pastYearsOfExperience;
  String get getShiftType => currentShift.name;

  bool get hasValidEmail {
    if (email.isEmpty || !email.contains('@') || !email.contains('.'))
      return false;
    final parts = email.split('@');
    if (parts.length != 2) return false;
    return parts[0].isNotEmpty && parts[1].isNotEmpty && parts[1].contains('.');
  }

  bool get hasValidPhoneNumber =>
      phoneNumber.isNotEmpty &&
      phoneNumber.replaceAll(RegExp(r'\D'), '').length >= 7;

  bool get hasValidDateOfBirth => dateOfBirth.isBefore(DateTime.now());
  bool get isAdult => getAge >= 18;
  bool get hasValidHireDate =>
      hireDate.isBefore(DateTime.now()) ||
      hireDate.isAtSameMomentAs(DateTime.now());

  bool get hasValidExperience => pastYearsOfExperience >= 0;
  bool get hasValidSalary => salary > 0;

  bool hasSameIdAs(Staff other) => id == other.id;

  int yearsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }
    return years;
  }

  @override
  String toString() {
    return '''
    ID: $id
    Name: $getFullName
    Role: ${getRoleName}
    Email: $email
    Phone: $phoneNumber
    Department: ${department.toString().split('.').last}
    Years of Experience: $pastYearsOfExperience
    Age: $getAge years
    Shift: ${currentShift.toString().split('.').last}
    Years of Service: $getYearsOfService years in the hospital
    Salary: \$${salary.toStringAsFixed(2)}
    ''';
  }
}
