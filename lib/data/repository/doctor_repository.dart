import 'dart:convert';
import 'dart:io';
import '/domain/doctor.dart';
import '/domain/staff.dart';

class DoctorRepository {
  final String filePath;
  List<Doctor> _doctors = [];

  DoctorRepository(this.filePath);

  /// Load doctors from JSON file
  void loadDoctors() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Doctor data file not found. Creating new file...');
        _doctors = [];
        return;
      }

      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      _doctors = (data['doctors'] as List)
          .map((json) => _doctorFromJson(json))
          .toList();

      print('Successfully loaded ${_doctors.length} doctors');
    } catch (e) {
      print('Error loading doctor data: $e');
      _doctors = [];
    }
  }

  /// Save doctors to JSON file
  void saveDoctors() {
    try {
      final file = File(filePath);

      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final data = {
        'doctors': _doctors.map((doctor) => _doctorToJson(doctor)).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      file.writeAsStringSync(jsonString);

      print('Successfully saved ${_doctors.length} doctors');
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
      'department': doctor.department,
      'salary': doctor.salary,
      'specialization': doctor.specialization.toString().split('.').last,
      'currentShift': doctor.currentShift.toString().split('.').last,
      'certifications': doctor.certifications.toList(),
      'assignedPatients': doctor.assignedPatients.toList(),
      'consultationsThisMonth': doctor.consultationsThisMonth,
      'patientRating': doctor.patientRating,
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
      department: json['department'],
      pastYearsOfExperience: json['pastYearsOfExperience'] ?? 0,
      salary: (json['salary'] ?? 5000).toDouble(),
      specialization: Specialization.values.firstWhere(
        (e) => e.toString().split('.').last == json['specialization'],
      ),
      currentShift: ShiftType.values.firstWhere(
        (e) => e.toString().split('.').last == json['currentShift'],
        orElse: () => ShiftType.day,
      ),
      certifications: List<String>.from(json['certifications'] ?? []),
      assignedPatients: List<String>.from(json['assignedPatients'] ?? []),
      consultationsThisMonth: json['consultationsThisMonth'] ?? 0,
      patientRating: (json['patientRating'] ?? 0.0).toDouble(),
    );
  }

  /// Get all doctors
  List<Doctor> getAllDoctors() => List.unmodifiable(_doctors);

  /// Search doctors by name
  List<Doctor> searchDoctorsByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _doctors
        .where((d) =>
            d.firstName.toLowerCase().contains(lowerQuery) ||
            d.lastName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get doctor by ID
  Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new doctor
  void addDoctor(Doctor doctor) {
    if (getDoctorById(doctor.id) != null) {
      throw ArgumentError('Doctor with ID ${doctor.id} already exists');
    }
    _doctors.add(doctor);
    saveDoctors();
  }

  /// Update doctor
  void updateDoctor(Doctor doctor) {
    final index = _doctors.indexWhere((d) => d.id == doctor.id);
    if (index == -1) {
      throw ArgumentError('Doctor with ID ${doctor.id} not found');
    }
    _doctors[index] = doctor;
    saveDoctors();
  }

  /// Remove doctor
  void removeDoctor(String id) {
    final initialLength = _doctors.length;
    _doctors.removeWhere((doctor) => doctor.id == id);
    if (_doctors.length == initialLength) {
      throw ArgumentError('Doctor with ID $id not found');
    }
    saveDoctors();
  }
}
