import 'dart:io';

import 'data/repository/nurse_repository.dart';
import 'data/repository/doctor_repository.dart';
import 'data/repository/administrative_staff_repository.dart';
import 'ui/hospital_console.dart';
import 'domain/nurse.dart';
import './domain/staff.dart';
void main() {
  // Get the directory where main.dart is located
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  
  // Paths to staff data files (relative to main.dart location)
  String nursesFilePath = "$scriptDir/data/asset/nurses_data.json";
  String doctorsFilePath = "$scriptDir/data/asset/doctors_data.json";
  String adminFilePath = "$scriptDir/data/asset/admin_staff_data.json";

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
