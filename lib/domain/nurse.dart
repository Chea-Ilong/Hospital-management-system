import 'staff.dart';
import 'medical_staff.dart';

enum NurseSpecialization {
  GENERAL_NURSING,
  PEDIATRIC,
  SURGICAL,
  EMERGENCY,
  CRITICAL,
  ONCOLOGY,
  PSYCHIATRIC,
  GERIATRIC
}

class Nurse extends MedicalStaff {
  final NurseSpecialization specialization;

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
    required super.salary,
    required this.specialization,
    List<String>? assignedPatients,
    List<String>? certifications,
    super.shiftsThisMonth,
  }) : super(
          role: StaffRole.NURSE,
          certifications: certifications,
          assignedPatients: assignedPatients,
        );

  @override
  double get getExperienceBonus => getYearsOfExperience * 150.0;

  @override
  String getSpecializationName() {
    return specialization.toString().split('.').last;
  }

  @override
  String toString() {
    return '''${super.toString()}
Specialization: ${getSpecializationName()}''';  
  }
}
