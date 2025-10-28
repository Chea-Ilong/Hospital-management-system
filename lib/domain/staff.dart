enum ShiftType {
  day(0.0), // 7 AM - 7 PM - No differential (base pay)
  night(0.20); // 7 PM - 7 AM - 20% differential for disrupted sleep

  final double bonus;
  const ShiftType(this.bonus);
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
  String department;
  double _salary;

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
    required double salary,
  }) : _salary = salary;

  String getRole();
  double computeSalary();

  double get salary => _salary;

  String get fullName => '$firstName $lastName';

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int get yearsOfService {
    final today = DateTime.now();
    int years = today.year - hireDate.year;
    if (today.month < hireDate.month ||
        (today.month == hireDate.month && today.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  int get yearsOfExperience => yearsOfService + pastYearsOfExperience;

  set salary(double value) {
    if (value < 0) {
      throw ArgumentError('Salary cannot be negative');
    }
    _salary = value;
  }

  @override
  String toString() {
    return '''
    ID: $id
    Name: $fullName
    Role: ${getRole()}
    Email: $email
    Phone: $phoneNumber
    Department: $department
    Years of Experience: $pastYearsOfExperience
    Age: $age years
    Shift: ${currentShift.toString().split('.').last}
    Years of Service: $yearsOfService years in the hospital
    Salary: \$${salary.toStringAsFixed(2)}
    ''';
  }
}
