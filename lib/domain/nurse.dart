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
  final List<String> assignedPatients;
  final List<String> certifications;
  int shiftsThisMonth;
  double performanceRating;

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
    required super.currentShift,
    super.salary = 400,
    required this.specialization,
    List<String>? assignedPatients,
    List<String>? certifications,
    this.shiftsThisMonth = 0,
    this.performanceRating = 0.0,
  })  : assignedPatients = assignedPatients ?? [],
        certifications = certifications ?? [];

  double get experienceBonus => yearsOfExperience * 150.0;

  double get shiftBonusAmount => shiftsThisMonth * 5.0;

  double get performanceBonusAmount => performanceRating * 20.0;

  @override
  String getRole() => 'Nurse';

  @override
  double computeSalary() {
    double total = salary;
    total += experienceBonus;
    total *= specialization.bonus;

    double shiftDiff = total * currentShift.bonus;
    total += shiftDiff;

    total += shiftBonusAmount + performanceBonusAmount;

    return total;
  }

  void assignPatient(String patientId) {
    if (!assignedPatients.contains(patientId)) {
      assignedPatients.add(patientId);
    }
  }

  void removePatient(String patientId) {
    assignedPatients.remove(patientId);
  }

  void recordShift() {
    shiftsThisMonth++;
  }

  void resetMonthlyShifts() {
    shiftsThisMonth = 0;
  }

  void updatePerformanceRating(double rating) {
    if (rating < 0.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    performanceRating = rating;
  }

  void addCertification(String certification) {
    if (!certifications.contains(certification)) {
      certifications.add(certification);
    }
  }

  void removeCertification(String certification) {
    certifications.remove(certification);
  }

  String _getSpecializationName() {
    return specialization.toString().split('.').last;
  }

  String _getShiftName() {
    return currentShift.toString().split('.').last;
  }


  @override
  String toString() {
    final baseWithExp = salary + experienceBonus;
    final afterSpec = baseWithExp * specialization.bonus;
    final specializationBonusAmount = baseWithExp * (specialization.bonus - 1.0);
    final shiftDifferentialAmount = afterSpec * currentShift.bonus;
    final totalMonthlyBonus = specializationBonusAmount + shiftDifferentialAmount + shiftBonusAmount + performanceBonusAmount;

    return '''
${super.toString()}
    Specialization: ${_getSpecializationName()} (${((specialization.bonus - 1.0) * 100).toStringAsFixed(1)}% adjustment)
    Current Shift: ${_getShiftName()} (${(currentShift.bonus * 100).toStringAsFixed(1)}% differential)
    Certifications: ${certifications.isEmpty ? 'None' : certifications.join(', ')}
    Total Patients: ${assignedPatients.length}
    Shifts This Month: $shiftsThisMonth
    Performance Rating: ${performanceRating.toStringAsFixed(1)}/5.0
    Years of Experience: $yearsOfExperience

    === SALARY BREAKDOWN ===
    Base Salary:              \$${salary.toStringAsFixed(2)}
    Experience Bonus ($yearsOfExperience years): \$${experienceBonus.toStringAsFixed(2)}
    Specialization Bonus:     \$${specializationBonusAmount.toStringAsFixed(2)}
    Shift Differential:        \$${shiftDifferentialAmount.toStringAsFixed(2)}
    Shift Bonus ($shiftsThisMonth shifts):  \$${shiftBonusAmount.toStringAsFixed(2)}
    Performance Bonus (Rating ${performanceRating.toStringAsFixed(1)}): \$${performanceBonusAmount.toStringAsFixed(2)}
    -----------------------------------
    Total Monthly Bonus:      \$${totalMonthlyBonus.toStringAsFixed(2)}
    Total Pay:                \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
