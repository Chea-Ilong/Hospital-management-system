import 'dart:convert';
import 'dart:io';
import '../domain/nurse.dart';
import '../domain/staff.dart';
/// Repository for managing nurse data
/// Handles CRUD operations and data persistence for nurses
class NurseRepository {
  final String filePath;
  List<Nurse> _nurses = [];

  NurseRepository(this.filePath);

  /// Load nurses from JSON file
  void loadNurses() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Nurse data file not found. Creating new file...');
        _nurses = [];
        return;
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      _nurses = (data['nurses'] as List)
          .map((json) => _nurseFromJson(json))
          .toList();
      
      print('Successfully loaded ${_nurses.length} nurses');
    } catch (e) {
      print('Error loading nurse data: $e');
      _nurses = [];
    }
  }

  /// Save nurses to JSON file
  void saveNurses() {
    try {
      final file = File(filePath);
      
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'nurses': _nurses.map((nurse) => _nurseToJson(nurse)).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);
      
      print('Successfully saved ${_nurses.length} nurses');
    } catch (e) {
      print('Error saving nurse data: $e');
    }
  }

  /// Convert Nurse to JSON
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
      'department': nurse.department,
      'salary': nurse.salary,
      'isActive': nurse.isActive,
      'specialization': nurse.specialization.toString().split('.').last,
      'licenseNumber': nurse.licenseNumber,
      'currentShift': nurse.currentShift.toString().split('.').last,
      'assignedPatients': nurse.assignedPatients.toList(),
      'certifications': nurse.certifications.toList(),
      'shiftsThisMonth': nurse.shiftsThisMonth,
      'performanceRating': nurse.performanceRating,
    };
  }

  /// Convert JSON to Nurse
  Nurse _nurseFromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      hireDate: DateTime.parse(json['hireDate']),
      department: json['department'],
      pastYearsOfExperience: json['pastYearsOfExperience'] ?? 0,
      isActive: json['isActive'] ?? true,
      specialization: NurseSpecialization.values.firstWhere(
        (e) => e.toString().split('.').last == json['specialization'],
      ),
      licenseNumber: json['licenseNumber'],
      currentShift: ShiftType.values.firstWhere(
        (e) => e.toString().split('.').last == json['currentShift'],
      ),
      assignedPatients: List<String>.from(json['assignedPatients'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      shiftsThisMonth: json['shiftsThisMonth'] ?? 0,
      performanceRating: (json['performanceRating'] ?? 0.0).toDouble(),
    );
  }

  /// Get all nurses
  List<Nurse> getAllNurses() => List.unmodifiable(_nurses);

  /// Get nurse by ID
  Nurse? getNurseById(String id) {
    try {
      return _nurses.firstWhere((nurse) => nurse.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new nurse
  void addNurse(Nurse nurse) {
    if (getNurseById(nurse.id) != null) {
      throw ArgumentError('Nurse with ID ${nurse.id} already exists');
    }
    _nurses.add(nurse);
    saveNurses();
  }

  /// Update nurse
  void updateNurse(Nurse nurse) {
    final index = _nurses.indexWhere((n) => n.id == nurse.id);
    if (index == -1) {
      throw ArgumentError('Nurse with ID ${nurse.id} not found');
    }
    _nurses[index] = nurse;
    saveNurses();
  }

  /// Remove nurse
  void removeNurse(String id) {
    final initialLength = _nurses.length;
    _nurses.removeWhere((nurse) => nurse.id == id);
    if (_nurses.length == initialLength) {
      throw ArgumentError('Nurse with ID $id not found');
    }
    saveNurses();
  }

  /// Get nurses by department
  List<Nurse> getNursesByDepartment(String department) {
    return _nurses.where((n) => n.department == department).toList();
  }

  /// Get nurses by shift
  List<Nurse> getNursesByShift(ShiftType shift) {
    return _nurses.where((n) => n.currentShift == shift).toList();
  }

  /// Get nurses by specialization
  List<Nurse> getNursesBySpecialization(NurseSpecialization specialization) {
    return _nurses.where((n) => n.specialization == specialization).toList();
  }

  /// Get active nurses
  List<Nurse> getActiveNurses() {
    return _nurses.where((n) => n.isActive).toList();
  }

  /// Search nurses by name
  List<Nurse> searchNursesByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _nurses.where((n) =>
      n.firstName.toLowerCase().contains(lowerQuery) ||
      n.lastName.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
