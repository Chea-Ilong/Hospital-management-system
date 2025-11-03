import 'dart:convert';
import 'dart:io';
import '/domain/doctor.dart';
import '/domain/staff.dart';

class DoctorRepository {
  final String filePath;

  DoctorRepository(this.filePath);

  /// Load all doctors from JSON file
  List<Doctor> loadAllDoctors() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Doctor data file not found. Creating new file...');
        return [];
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final doctors = (data['doctors'] as List)
          .map((json) => _doctorFromJson(json))
          .toList();

      print('Successfully loaded ${doctors.length} doctors');
      return doctors;
    } catch (e) {
      print('Error loading doctor data: $e');
      return [];
    }
  }

  /// Save all doctors to JSON file
  void saveAllDoctors(List<Doctor> doctors) {
    try {
      final file = File(filePath);

      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'doctors': doctors.map((doctor) => _doctorToJson(doctor)).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);

      print('Successfully saved ${doctors.length} doctors');
    } catch (e) {
      print('Error saving doctor data: $e');
    }
  }

  /// Convert Doctor to JSON
  Map<String, dynamic> _doctorToJson(Doctor doctor) {
    return {
      'id': doctor.id,
      'firstName': doctor.firstName,
      'lastName': doctor.lastName,
      'email': doctor.email,
      'phoneNumber': doctor.phoneNumber,
      'dateOfBirth': doctor.dateOfBirth.toIso8601String(),
      'hireDate': doctor.hireDate.toIso8601String(),
      'pastYearsOfExperience': doctor.pastYearsOfExperience,
      'department': doctor.department.toString().split('.').last,
      'salary': doctor.salary,
      'specialization': doctor.specialization.toString().split('.').last,
      'currentShift': doctor.currentShift.toString().split('.').last,
      'certifications': doctor.certifications.toList(),
      'assignedPatients': doctor.assignedPatients.toList(),
      'consultationsThisMonth': doctor.consultationsThisMonth,
      'shiftsThisMonth': doctor.shiftsThisMonth,
    };
  }

  /// Convert JSON to Doctor
  Doctor _doctorFromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      hireDate: DateTime.parse(json['hireDate']),
      department: StaffDepartment.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['department'].toString().toUpperCase(),
      ),
      pastYearsOfExperience: json['pastYearsOfExperience'] ?? 0,
      salary: (json['salary'] ?? 5000).toDouble(),
      specialization: Specialization.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['specialization'].toString().toUpperCase(),
      ),
      currentShift: ShiftType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['currentShift'].toString().toUpperCase(),
        orElse: () => ShiftType.DAY,
      ),
      certifications: List<String>.from(json['certifications'] ?? []),
      assignedPatients: List<String>.from(json['assignedPatients'] ?? []),
      shiftsThisMonth: json['shiftsThisMonth'] ?? 0,
      consultationsThisMonth: json['consultationsThisMonth'] ?? 0,
    );
  }
}
