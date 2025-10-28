import 'dart:io';
import 'package:hospital_management_system/domain/staff.dart';

import 'data/nurse_repository.dart';
import 'data/doctor_repository.dart';
import 'data/administrative_staff_repository.dart';
import 'ui/hospital_console.dart';
import 'domain/nurse.dart';

/// Main entry point for the Hospital Management System
/// Demonstrates layered architecture: Domain -> Data -> UI
void main() {
  // Get the directory where main.dart is located
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  
  // Paths to staff data files (relative to main.dart location)
  String nursesFilePath = "$scriptDir/data/nurses_data.json";
  String doctorsFilePath = "$scriptDir/data/doctors_data.json";
  String adminFilePath = "$scriptDir/data/admin_staff_data.json";

  // Create a sample nurse to demonstrate the salary calculation
  final sampleNurse = Nurse(
    id: 'N999',
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@hospital.com',
    phoneNumber: '+1-555-5678',
    dateOfBirth: DateTime(1990, 8, 20),
    hireDate: DateTime(2018, 6, 15),
    pastYearsOfExperience: 0,
    department: 'Emergency',
    specialization: NurseSpecialization.emergency,
    licenseNumber: 'RN-11111',
    currentShift: ShiftType.night,
    shiftsThisMonth: 22,
    performanceRating: 4.0,
  );

  print('\n=== SAMPLE NURSE DETAILS ===\n');
  print(sampleNurse);
  print('\n' + '=' * 50 + '\n');

  // Initialize repositories (Data Layer)
  NurseRepository nurseRepository = NurseRepository(nursesFilePath);
  DoctorRepository doctorRepository = DoctorRepository(doctorsFilePath);
  AdministrativeStaffRepository adminRepository = AdministrativeStaffRepository(adminFilePath);

  // Initialize console UI (UI Layer)
  HospitalConsole console = HospitalConsole(
    nurseRepository: nurseRepository,
    doctorRepository: doctorRepository,
    adminRepository: adminRepository,
  );

  // Start the application
  console.start();
}
