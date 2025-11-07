import 'dart:convert';
import 'dart:io';
import '../../domain/nurse.dart';
import '../../domain/staff.dart';

class NurseRepository {
  final String filePath;

  NurseRepository([String? customPath])
      : filePath = customPath ?? 'lib/data/storage/nurses_data.json';

  List<Nurse> loadAllNurses() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Nurse data file not found. Creating new file...');
        return [];
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final nurses =
          (data['nurses'] as List).map((json) => _nurseFromJson(json)).toList();

      return nurses;
    } catch (e) {
      print('Error loading nurse data: $e');
      return [];
    }
  }

  void saveAllNurses(List<Nurse> nurses) {
    try {
      final file = File(filePath);

      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'nurses': nurses.map((nurse) => _nurseToJson(nurse)).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);
    } catch (e) {
      print('Error saving nurse data: $e');
    }
  }

  Map<String, dynamic> _nurseToJson(Nurse nurse) {
    return {
      'id': nurse.id,
      'firstName': nurse.firstName,
      'lastName': nurse.lastName,
      'email': nurse.email,
      'phoneNumber': nurse.phoneNumber,
      'dateOfBirth': nurse.dateOfBirth.toIso8601String(),
      'hireDate': nurse.hireDate.toIso8601String(),
      'pastYearsOfExperience': nurse.pastYearsOfExperience,
      'department': nurse.department.toString().split('.').last,
      'salary': nurse.salary,
      'specialization': nurse.specialization.toString().split('.').last,
      'currentShift': nurse.currentShift.toString().split('.').last,
      'assignedPatients': nurse.assignedPatients.toList(),
      'certifications': nurse.certifications.toList(),
      'shiftsThisMonth': nurse.shiftsThisMonth,
    };
  }

  Nurse _nurseFromJson(Map<String, dynamic> json) {
    return Nurse(
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
      salary: (json['salary'] ?? 4000).toDouble(),
      specialization: NurseSpecialization.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['specialization'].toString().toUpperCase(),
      ),
      currentShift: ShiftType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['currentShift'].toString().toUpperCase(),
      ),
      assignedPatients: List<String>.from(json['assignedPatients'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      shiftsThisMonth: json['shiftsThisMonth'] ?? 0,
    );
  }
}
