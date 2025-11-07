import 'staff.dart';

abstract class MedicalStaff extends Staff {
  final List<String> certifications;
  final List<String> assignedPatients;
  int shiftsThisMonth;

  MedicalStaff({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.hireDate,
    required super.pastYearsOfExperience,
    required super.department,
    required super.salary,
    required super.currentShift,
    required super.role,
    List<String>? certifications,
    List<String>? assignedPatients,
    this.shiftsThisMonth = 0,
  })  : certifications = certifications ?? [],
        assignedPatients = assignedPatients ?? [];

  double get getShiftDifferentialAmount =>
      (salary + getExperienceBonus) * currentShift.bonus;

  double get getTotalBonus => getExperienceBonus + getShiftDifferentialAmount;

  bool hasPatient(String patientId) => assignedPatients.contains(patientId);
  bool hasCertification(String certification) => certifications.contains(certification);

  bool get hasValidShiftsCount => shiftsThisMonth >= 0 && shiftsThisMonth <= 31;
  bool get isOverloaded => assignedPatients.length > 10 || shiftsThisMonth > 20;
  bool get canTakeMorePatients => assignedPatients.length < 10;

  String  getSpecializationName();

  @override
  double computeSalary() {
    double total = salary;
    total += getExperienceBonus;
    total += getShiftDifferentialAmount;
    return total;
  }

  @override
  String toString() {
    final salaryBreakdown = '''
    Base Salary: \$${salary.toStringAsFixed(2)}
    Experience Bonus: \$${getExperienceBonus.toStringAsFixed(2)} (${getYearsOfExperience} years x rate)
    Shift Differential: \$${getShiftDifferentialAmount.toStringAsFixed(2)} (${currentShift.name} shift x ${currentShift.bonus * 100}%)
    Total Salary: \$${computeSalary().toStringAsFixed(2)}''';

    return '''
${super.toString()}
Specialization: ${getSpecializationName()}
Certifications: ${certifications.isEmpty ? 'None' : certifications.join(', ')}
Assigned Patients: ${assignedPatients.length} patient(s)
Shifts This Month: $shiftsThisMonth
$salaryBreakdown''';
  }
}
