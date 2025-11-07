import 'dart:convert';
import 'dart:io';
import '../../domain/administrative_staff.dart';
import '../../domain/staff.dart';

class AdministrativeStaffRepository {
  final String filePath;

  AdministrativeStaffRepository([String? customPath])
      : filePath = customPath ?? 'lib/data/storage/admin_staff_data.json';

  /// Load all administrative staff from JSON file
  List<AdministrativeStaff> loadAllAdministrativeStaff() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Administrative staff data file not found. Creating new file...');
        return [];
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final adminStaff = (data['administrativeStaff'] as List)
          .map((json) => _administrativeStaffFromJson(json))
          .toList();

      return adminStaff;
    } catch (e) {
      print('Error loading administrative staff data: $e');
      return [];
    }
  }

  /// Save all administrative staff to JSON file
  void saveAllAdministrativeStaff(List<AdministrativeStaff> adminStaff) {
    try {
      final file = File(filePath);

      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'administrativeStaff': adminStaff
            .map((staff) => _administrativeStaffToJson(staff))
            .toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);
    } catch (e) {
      print('Error saving administrative staff data: $e');
    }
  }

  /// Convert AdministrativeStaff to JSON
  Map<String, dynamic> _administrativeStaffToJson(AdministrativeStaff admin) {
    return {
      'id': admin.id,
      'firstName': admin.firstName,
      'lastName': admin.lastName,
      'email': admin.email,
      'phoneNumber': admin.phoneNumber,
      'dateOfBirth': admin.dateOfBirth.toIso8601String(),
      'hireDate': admin.hireDate.toIso8601String(),
      'pastYearsOfExperience': admin.pastYearsOfExperience,
      'department': admin.department.toString().split('.').last,
      'salary': admin.salary,
      'currentShift': admin.currentShift.toString().split('.').last,
      'position': admin.position.toString().split('.').last,
    };
  }

  /// Convert JSON to AdministrativeStaff
  AdministrativeStaff _administrativeStaffFromJson(Map<String, dynamic> json) {
    return AdministrativeStaff(
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
            json['department'].toString().replaceAll(' ', '_').toUpperCase(),
      ),
      pastYearsOfExperience: json['pastYearsOfExperience'] ?? 0,
      salary: (json['salary'] ?? 3000).toDouble(),
      currentShift: ShiftType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['currentShift'].toString().toUpperCase(),
        orElse: () => ShiftType.DAY,
      ),
      position: AdministrativePosition.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['position'].toString().toUpperCase(),
      ),
    );
  }
}
