enum ShiftType {
  DAY(0.0), // 7 AM - 7 PM - No differential (base pay)
  NIGHT(0.20); // 7 PM - 7 AM - 20% differential for disrupted sleep

  final double bonus;
  const ShiftType(this.bonus);
}

enum StaffRole {
  DOCTOR,
  NURSE,
  ADMINISTRATIVE
}

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
