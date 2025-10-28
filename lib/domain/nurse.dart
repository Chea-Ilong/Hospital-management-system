import 'staff.dart';

enum NurseSpecialization {
  generalNursing(1.0), // Base rate - routine patient care
  pediatric(1.075), // +7.5% - specialized in child care
  surgical(1.125), // +12.5% - technical skills and operating room training
  emergency(1.15), // +15% - high stress, fast-paced, rapid decision-making
  critical(1.20), // +20% - intensive care, constant monitoring, high risk
  oncology(
      1.125), // +12.5% - emotional and technical demands in cancer treatment
  psychiatric(1.075), // +7.5% - specialized training in mental health care
  geriatric(1.025); // +2.5% - focused on elderly patients

  final double bonus;
  const NurseSpecialization(this.bonus);
}


class Nurse extends Staff {
  final NurseSpecialization specialization;
  final List<String> _assignedPatients;
  final List<String> _certifications;
  int _shiftsThisMonth;
  double _performanceRating;

  Nurse({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.hireDate,
    required super.pastYearsOfExperience,
    required super.department,
    required super.licenseNumber,
    required super.currentShift,
    super.salary = 400,
    required this.specialization,
    List<String> assignedPatients = const [],
    List<String> certifications = const [],
    int shiftsThisMonth = 0,
    double performanceRating = 0.0,
    super.isActive,
  })  : _assignedPatients = List.from(assignedPatients),
        _certifications = List.from(certifications),
        _shiftsThisMonth = shiftsThisMonth,
        _performanceRating = performanceRating;

  // Getters
  List<String> get assignedPatients => List.unmodifiable(_assignedPatients);
  List<String> get certifications => List.unmodifiable(_certifications);
  int get shiftsThisMonth => _shiftsThisMonth;
  double get performanceRating => _performanceRating;
  int get totalPatients => _assignedPatients.length;


  /// Get experience bonus based on years of service
  double get experienceBonus => yearsOfExperience * 150.0;

  /// Get shift bonus based on number of shifts worked this month
  double get shiftBonusAmount => _shiftsThisMonth * 5.0;

  /// Get performance bonus based on performance rating
  double get performanceBonusAmount => _performanceRating * 20.0;

  // double get baseWithExperience => salary + experienceBonus;

  // double get totalMonthlyBonus => shiftBonusAmount + performanceBonusAmount;

  // double get shiftDifferentialAmount =>
  //     baseWithExperience * currentShift.bonus;

  // double get specializationBonusAmount =>
  //     baseWithExperience * (specialization.bonus - 1.0);

  @override
  String getRole() => 'Nurse';

  @override
  String getResponsibilities() {
    return '''
    - Provide patient care in ${_getSpecializationName()}
    - Administer medications and treatments
    - Monitor patient vital signs
    - Assist doctors during procedures
    - Maintain patient records
    - Work ${_getShiftName()} shifts
    - Current patients under care: $totalPatients
    ''';
  }

  @override
  double computeSalary() {
    // Start with base salary
    double total = salary;
    total += experienceBonus;
    total *= specialization.bonus;

    // Add shift differential (applied on salary after specialization)
    double shiftDiff = total * currentShift.bonus;
    total += shiftDiff;

    // Add monthly bonuses
    total += shiftBonusAmount + performanceBonusAmount;

    return total;
  }

  // Nurse-specific methods
  void assignPatient(String patientId) {
    if (!_assignedPatients.contains(patientId)) {
      _assignedPatients.add(patientId);
    }
  }

  void removePatient(String patientId) {
    _assignedPatients.remove(patientId);
  }

  void recordShift() {
    _shiftsThisMonth++;
  }

  void resetMonthlyShifts() {
    _shiftsThisMonth = 0;
  }

  void updatePerformanceRating(double rating) {
    if (rating < 0.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    _performanceRating = rating;
  }

  void addCertification(String certification) {
    if (!_certifications.contains(certification)) {
      _certifications.add(certification);
    }
  }

  void removeCertification(String certification) {
    _certifications.remove(certification);
  }

  String _getSpecializationName() {
    return specialization.toString().split('.').last;
  }

  String _getShiftName() {
    return currentShift.toString().split('.').last;
  }

  bool canAcceptMorePatients({int maxPatients = 10}) {
    return totalPatients < maxPatients && isActive;
  }


  @override
  String toString() {
    // Calculate base with experience
    final baseWithExp = salary + experienceBonus;

    // Apply specialization
    final afterSpec = baseWithExp * specialization.bonus;
    final specializationBonusAmount =
        baseWithExp * (specialization.bonus - 1.0);

    // Calculate shift differential on specialized salary
    final shiftDifferentialAmount = afterSpec * currentShift.bonus;

    // Total all bonuses
    final totalMonthlyBonus = specializationBonusAmount +
        shiftDifferentialAmount +
        this.shiftBonusAmount +
        this.performanceBonusAmount;

    return '''
${super.toString()}
    Specialization: ${_getSpecializationName()} (${((specialization.bonus - 1.0) * 100).toStringAsFixed(1)}% adjustment)
    Current Shift: ${_getShiftName()} (${(currentShift.bonus * 100).toStringAsFixed(1)}% differential)
    Certifications: ${_certifications.isEmpty ? 'None' : _certifications.join(', ')}
    Total Patients: $totalPatients
    Shifts This Month: $_shiftsThisMonth
    Performance Rating: ${_performanceRating.toStringAsFixed(1)}/5.0
    Years of Experience: $yearsOfExperience

    === SALARY BREAKDOWN ===
    Base Salary:              \$${salary.toStringAsFixed(2)}
    Experience Bonus ($yearsOfExperience years): \$${experienceBonus.toStringAsFixed(2)}
    Specialization Bonus:     \$${specializationBonusAmount.toStringAsFixed(2)}
    Shift Differential:        \$${shiftDifferentialAmount.toStringAsFixed(2)}
    Shift Bonus ($_shiftsThisMonth shifts):  \$${shiftBonusAmount.toStringAsFixed(2)}
    Performance Bonus (Rating ${_performanceRating.toStringAsFixed(1)}): \$${performanceBonusAmount.toStringAsFixed(2)}
    -----------------------------------
    Total Monthly Bonus:      \$${totalMonthlyBonus.toStringAsFixed(2)}
    Total Pay:                \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
