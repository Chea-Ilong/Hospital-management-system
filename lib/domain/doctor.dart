import 'staff.dart';
import 'medical_staff.dart';

enum DoctorSpecialization {
  GENERAL_PRACTICE,
  CARDIOLOGY,
  NEUROLOGY,
  PEDIATRICS,
  ORTHOPEDICS,
  DERMATOLOGY,
  PSYCHIATRY,
  SURGERY
}

class Doctor extends MedicalStaff {
  final DoctorSpecialization specialization;
  int consultationsThisMonth;

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
    required super.salary,
    required this.specialization,
    required super.currentShift,
    List<String>? certifications,
    List<String>? assignedPatients,
    super.shiftsThisMonth,
    this.consultationsThisMonth = 0,
  }) : super(
          role: StaffRole.DOCTOR,
          certifications: certifications,
          assignedPatients: assignedPatients,
        );

  @override
  double get getExperienceBonus => getYearsOfExperience * 300;

  @override
  String getSpecializationName() {
    return specialization.toString().split('.').last;
  }

  @override
  String toString() {
    return '''
${super.toString()}
Consultations This Month: $consultationsThisMonth''';
  }
}
