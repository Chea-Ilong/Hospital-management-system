import 'staff.dart';

/// Enum for medical specializations with salary multipliers
enum Specialization {
  generalPractice(1.00), // $5,000 - Baseline general outpatient care
  pediatrics(1.05), // $5,250 - Slightly higher; specialized in child health
  dermatology(1.10), // $5,500 - Specialized but usually lower stress
  psychiatry(1.15), // $5,750 - Specialized field, fewer practitioners
  emergency(1.20), // $6,000 - High stress, irregular hours
  orthopedics(1.30), // $6,500 - Surgical, high skill demand
  anesthesiology(1.35), // $6,750 - Highly skilled, critical role in surgeries
  surgery(1.40), // $7,000 - Major surgical work, high risk and expertise
  radiology(1.45), // $7,250 - Specialized equipment and diagnostics
  cardiology(1.50), // $7,500 - Complex specialization, long training
  neurology(1.55), // $7,750 - High expertise, complex diagnostics
  oncology(1.60); // $8,000 - Specialized, emotionally demanding field

  final double salaryMultiplier;
  const Specialization(this.salaryMultiplier);
}

/// Doctor class extending Staff
class Doctor extends Staff {
  final Specialization specialization;
  final List<String> _certifications;
  final List<String> _assignedPatients;
  int _consultationsThisMonth;
  double _patientRating;

  Doctor({
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
    super.salary = 5000,
    required this.specialization,
    required super.currentShift,
    List<String> certifications = const [],
    List<String> assignedPatients = const [],
    int consultationsThisMonth = 0,
    double patientRating = 0.0,
    super.isActive,
  })  : _certifications = List.from(certifications),
        _assignedPatients = List.from(assignedPatients),
        _consultationsThisMonth = consultationsThisMonth,
        _patientRating = patientRating;

  // Getters
  List<String> get certifications => List.unmodifiable(_certifications);
  List<String> get assignedPatients => List.unmodifiable(_assignedPatients);
  int get consultationsThisMonth => _consultationsThisMonth;
  double get patientRating => _patientRating;
  int get totalPatients => _assignedPatients.length;


  /// Get experience bonus based on years of service
  double get experienceBonus => yearsOfExperience * 300;

  /// Get consultation bonus
  double get consultationBonus => _consultationsThisMonth * 50.0;

  /// Get patient rating bonus
  double get ratingBonus => _patientRating * 100.0;

  @override
  String getRole() => 'Doctor';

  @override
  String getResponsibilities() {
    return '''
    - Diagnose and treat patients in ${_getSpecializationName()}
    - Perform medical examinations and consultations
    - Prescribe medications and treatments
    - Maintain accurate medical records
    - Consult with other medical professionals
    - Current patients under care: $totalPatients
    ''';
  }

  @override
  double computeSalary() {
    // Start with base salary
    double total = salary;

    // Add experience bonus
    total += experienceBonus;

    // Apply specialization multiplier
    total *= specialization.salaryMultiplier;

    // Add shift differential
    total += total * currentShift.bonus;
    // Add performance bonuses
    total += consultationBonus + ratingBonus;

    return total;
  }

  // Doctor-specific methods
  void addCertification(String certification) {
    if (!_certifications.contains(certification)) {
      _certifications.add(certification);
    }
  }

  void removeCertification(String certification) {
    _certifications.remove(certification);
  }

  void assignPatient(String patientId) {
    if (!_assignedPatients.contains(patientId)) {
      _assignedPatients.add(patientId);
    }
  }

  void removePatient(String patientId) {
    _assignedPatients.remove(patientId);
  }

  void recordConsultation() {
    _consultationsThisMonth++;
  }

  void resetMonthlyConsultations() {
    _consultationsThisMonth = 0;
  }

  void updateRating(double newRating) {
    if (newRating < 0.0 || newRating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    _patientRating = newRating;
  }

  String _getSpecializationName() {
    return specialization.toString().split('.').last;
  }

  bool canAcceptMorePatients({int maxPatients = 50}) {
    return totalPatients < maxPatients && isActive;
  }

  @override
  String toString() {
    // Calculate components
    final baseWithExp = salary + experienceBonus;
    final specializationBonusAmount = baseWithExp * (specialization.salaryMultiplier - 1.0);
    final withSpecialization = baseWithExp * specialization.salaryMultiplier;
    final shiftDifferentialAmount = withSpecialization * currentShift.bonus;
    final totalBonus = consultationBonus + ratingBonus;

    return '''
${super.toString()}
    Specialization: ${_getSpecializationName()} (${((specialization.salaryMultiplier - 1.0) * 100).toStringAsFixed(1)}% adjustment)
    Current Shift: ${currentShift.name} (${(currentShift.bonus * 100).toStringAsFixed(1)}% differential)
    Certifications: ${_certifications.isEmpty ? 'None' : _certifications.join(', ')}
    Total Patients: $totalPatients
    Consultations This Month: $_consultationsThisMonth
    Patient Rating: ${_patientRating.toStringAsFixed(1)}/5.0
    Years of Experience: $yearsOfExperience

    === SALARY BREAKDOWN ===
    Base Salary:              \$${salary.toStringAsFixed(2)}
    Experience Bonus ($yearsOfExperience years): \$${experienceBonus.toStringAsFixed(2)}
    Specialization Bonus:     \$${specializationBonusAmount.toStringAsFixed(2)}
    Shift Differential (${currentShift.name}): \$${shiftDifferentialAmount.toStringAsFixed(2)}
    Consultation Bonus ($_consultationsThisMonth consultations): \$${consultationBonus.toStringAsFixed(2)}
    Patient Rating Bonus (${_patientRating.toStringAsFixed(1)}/5.0): \$${ratingBonus.toStringAsFixed(2)}
    -----------------------------------
    Total Monthly Bonus:      \$${totalBonus.toStringAsFixed(2)}
    Total Pay:                \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
