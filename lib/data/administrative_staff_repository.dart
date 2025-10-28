import 'dart:convert';
import 'dart:io';
import '../domain/administrative_staff.dart';

/// Repository for managing administrative staff data
/// Handles CRUD operations and data persistence for administrative staff
class AdministrativeStaffRepository {
  final String filePath;
  List<AdministrativeStaff> _adminStaff = [];

  AdministrativeStaffRepository(this.filePath);

  /// Load administrative staff from JSON file
  void loadAdministrativeStaff() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Administrative staff data file not found. Creating new file...');
        _adminStaff = [];
        return;
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      _adminStaff = (data['administrativeStaff'] as List)
          .map((json) => _administrativeStaffFromJson(json))
          .toList();
      
      print('Successfully loaded ${_adminStaff.length} administrative staff');
    } catch (e) {
      print('Error loading administrative staff data: $e');
      _adminStaff = [];
    }
  }

  /// Save administrative staff to JSON file
  void saveAdministrativeStaff() {
    try {
      final file = File(filePath);
      
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'administrativeStaff': _adminStaff.map((staff) => _administrativeStaffToJson(staff)).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);
      
      print('Successfully saved ${_adminStaff.length} administrative staff');
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
      'department': admin.department,
      'salary': admin.salary,
      'licenseNumber': admin.licenseNumber,
      'isActive': admin.isActive,
      'position': admin.position.toString().split('.').last,
      'officeLocation': admin.officeLocation,
      'responsibilities': admin.responsibilities.toList(),
      'completedProjects': admin.completedProjects.toList(),
      'tasksCompletedThisMonth': admin.tasksCompletedThisMonth,
      'efficiencyRating': admin.efficiencyRating,
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
      department: json['department'],
      pastYearsOfExperience: json['pastYearsOfExperience'] ?? 0,
      licenseNumber: json['licenseNumber'] ?? '',
      salary: json['salary'].toDouble(),
      isActive: json['isActive'] ?? true,
      position: AdministrativePosition.values.firstWhere(
        (e) => e.toString().split('.').last == json['position'],
      ),
      officeLocation: json['officeLocation'],
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      completedProjects: List<String>.from(json['completedProjects'] ?? []),
      tasksCompletedThisMonth: json['tasksCompletedThisMonth'] ?? 0,
      efficiencyRating: (json['efficiencyRating'] ?? 0.0).toDouble(),
    );
  }

  /// Get all administrative staff
  List<AdministrativeStaff> getAllAdministrativeStaff() => List.unmodifiable(_adminStaff);

  /// Get administrative staff by ID
  AdministrativeStaff? getAdministrativeStaffById(String id) {
    try {
      return _adminStaff.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new administrative staff
  void addAdministrativeStaff(AdministrativeStaff staff) {
    if (getAdministrativeStaffById(staff.id) != null) {
      throw ArgumentError('Administrative staff with ID ${staff.id} already exists');
    }
    _adminStaff.add(staff);
    saveAdministrativeStaff();
  }

  /// Update administrative staff
  void updateAdministrativeStaff(AdministrativeStaff staff) {
    final index = _adminStaff.indexWhere((s) => s.id == staff.id);
    if (index == -1) {
      throw ArgumentError('Administrative staff with ID ${staff.id} not found');
    }
    _adminStaff[index] = staff;
    saveAdministrativeStaff();
  }

  /// Remove administrative staff
  void removeAdministrativeStaff(String id) {
    final initialLength = _adminStaff.length;
    _adminStaff.removeWhere((staff) => staff.id == id);
    if (_adminStaff.length == initialLength) {
      throw ArgumentError('Administrative staff with ID $id not found');
    }
    saveAdministrativeStaff();
  }

  /// Get administrative staff by department
  List<AdministrativeStaff> getAdministrativeStaffByDepartment(String department) {
    return _adminStaff.where((s) => s.department == department).toList();
  }

  /// Get administrative staff by position
  List<AdministrativeStaff> getAdministrativeStaffByPosition(AdministrativePosition position) {
    return _adminStaff.where((s) => s.position == position).toList();
  }

  /// Get active administrative staff
  List<AdministrativeStaff> getActiveAdministrativeStaff() {
    return _adminStaff.where((s) => s.isActive).toList();
  }

  /// Search administrative staff by name
  List<AdministrativeStaff> searchAdministrativeStaffByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _adminStaff.where((s) =>
      s.firstName.toLowerCase().contains(lowerQuery) ||
      s.lastName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get top performers
  List<AdministrativeStaff> getTopPerformers({int limit = 10}) {
    final sorted = List<AdministrativeStaff>.from(_adminStaff)
      ..sort((a, b) => b.efficiencyRating.compareTo(a.efficiencyRating));
    return sorted.take(limit).toList();
  }
}
