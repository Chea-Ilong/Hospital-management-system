
enum ShiftType {
  day(0.0), // 7 AM - 7 PM - No differential (base pay)
  night(0.20); // 7 PM - 7 AM - 20% differential for disrupted sleep

  final double bonus;
  const ShiftType(this.bonus);
}

abstract class Staff {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final DateTime hireDate;
  final int pastYearsOfExperience;
  final String department;
  final ShiftType currentShift;
  final String licenseNumber;
  double _salary;
  bool _isActive;

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.pastYearsOfExperience,
    required this.hireDate,
    required this.department,
    required this.currentShift,
    required this.licenseNumber,
    required double salary,
    bool isActive = true,
  })  : _salary = salary,
        _isActive = isActive;

  // Abstract methods - must be implemented by subclasses
  String getRole();
  String getResponsibilities();
  double computeSalary();

  double get salary => _salary;

  bool get isActive => _isActive;

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

  // Setters with validation
  set salary(double value) {
    if (value < 0) {
      throw ArgumentError('Salary cannot be negative');
    }
    _salary = value;
  }

  set isActive(bool value) {
    _isActive = value;
  }

  void activate() {
    _isActive = true;
  }

  void deactivate() {
    _isActive = false;
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
    Year of Expereience: $pastYearsOfExperience
    Age: $age years
    Years of Service: $yearsOfService years in the hospital
    Salary: \$${salary.toStringAsFixed(2)}
    License Number: $licenseNumber
    Status: ${isActive ? 'Active' : 'Inactive'}
    ''';
  }
}
