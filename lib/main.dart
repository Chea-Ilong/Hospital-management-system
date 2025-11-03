import 'dart:io';

import 'data/repository/nurse_repository.dart';
import 'data/repository/doctor_repository.dart';
import 'data/repository/administrative_staff_repository.dart';
import 'service/staff_service.dart';
import 'service/admin_service.dart';
import 'ui/hospital_console.dart';

void main() {
  // Get the directory where main.dart is located
  final scriptDir = File(Platform.script.toFilePath()).parent.path;

  // Paths to staff data files (relative to main.dart location)
  String nursesFilePath = "$scriptDir/data/asset/nurses_data.json";
  String doctorsFilePath = "$scriptDir/data/asset/doctors_data.json";
  String adminFilePath = "$scriptDir/data/asset/admin_staff_data.json";

  // Initialize repositories (Data Layer)
  NurseRepository nurseRepository = NurseRepository(nursesFilePath);
  DoctorRepository doctorRepository = DoctorRepository(doctorsFilePath);
  AdministrativeStaffRepository adminRepository =
      AdministrativeStaffRepository(adminFilePath);

  // Initialize service layer
  // 1. StaffService - Base CRUD operations for all staff
  StaffService staffService = StaffService(
    doctorRepository,
    nurseRepository,
    adminRepository,
  );

  // 2. AdminService - Single entry point for all hospital management
  AdminService adminService = AdminService(staffService);

  // Initialize console UI (UI Layer)
  HospitalConsole console = HospitalConsole(
    adminService: adminService,
  );

  // Start the application
  console.start();
}
