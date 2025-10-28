import 'staff.dart';

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

class Doctor extends Staff {
  final Specialization specialization;
  final List<String> certifications;
  final List<String> assignedPatients;
  int consultationsThisMonth;
  double patientRating;

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
    super.salary = 5000,
    required this.specialization,
    required super.currentShift,
    List<String>? certifications,
    List<String>? assignedPatients,
    this.consultationsThisMonth = 0,
    this.patientRating = 0.0,
  })  : certifications = certifications ?? [],
        assignedPatients = assignedPatients ?? [];

  double get experienceBonus => yearsOfExperience * 300;

  double get consultationBonus => consultationsThisMonth * 50.0;

  double get ratingBonus => patientRating * 100.0;

  @override
  String getRole() => 'Doctor';

  @override
  double computeSalary() {
    double total = salary;

    total += experienceBonus;

    total *= specialization.salaryMultiplier;

    total += total * currentShift.bonus;
    total += consultationBonus + ratingBonus;

    return total;
  }

  void addCertification(String certification) {
    if (!certifications.contains(certification)) {
      certifications.add(certification);
    }
  }

  void removeCertification(String certification) {
    certifications.remove(certification);
  }

  void assignPatient(String patientId) {
    if (!assignedPatients.contains(patientId)) {
      assignedPatients.add(patientId);
    }
  }

  void removePatient(String patientId) {
    assignedPatients.remove(patientId);
  }

  void recordConsultation() {
    consultationsThisMonth++;
  }

  void resetMonthlyConsultations() {
    consultationsThisMonth = 0;
  }

  void updateRating(double newRating) {
    if (newRating < 0.0 || newRating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    patientRating = newRating;
  }

  String _getSpecializationName() {
    return specialization.toString().split('.').last;
  }


  @override
  String toString() {

    final baseWithExp = salary + experienceBonus;
    final specializationBonusAmount = baseWithExp * (specialization.salaryMultiplier - 1.0);
    final withSpecialization = baseWithExp * specialization.salaryMultiplier;
    final shiftDifferentialAmount = withSpecialization * currentShift.bonus;
    final totalBonus = consultationBonus + ratingBonus;

    return '''
${super.toString()}
    Specialization: ${_getSpecializationName()} (${((specialization.salaryMultiplier - 1.0) * 100).toStringAsFixed(1)}% adjustment)
    Current Shift: ${currentShift.name} (${(currentShift.bonus * 100).toStringAsFixed(1)}% differential)
    Certifications: ${certifications.isEmpty ? 'None' : certifications.join(', ')}
    Total Patients: ${assignedPatients.length}
    Consultations This Month: $consultationsThisMonth
    Patient Rating: ${patientRating.toStringAsFixed(1)}/5.0
    Years of Experience: $yearsOfExperience

    === SALARY BREAKDOWN ===
    Base Salary:              \$${salary.toStringAsFixed(2)}
    Experience Bonus ($yearsOfExperience years): \$${experienceBonus.toStringAsFixed(2)}
    Specialization Bonus:     \$${specializationBonusAmount.toStringAsFixed(2)}
    Shift Differential (${currentShift.name}): \$${shiftDifferentialAmount.toStringAsFixed(2)}
    Consultation Bonus ($consultationsThisMonth consultations): \$${consultationBonus.toStringAsFixed(2)}
    Patient Rating Bonus (${patientRating.toStringAsFixed(1)}/5.0): \$${ratingBonus.toStringAsFixed(2)}
    -----------------------------------
    Total Monthly Bonus:      \$${totalBonus.toStringAsFixed(2)}
    Total Pay:                \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
