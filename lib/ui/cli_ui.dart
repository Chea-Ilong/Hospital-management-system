import '../service/staff_service.dart';
import '../service/medical_staff_service.dart';
import 'hospital_console.dart';

/// CLI UI Helper - Initializes services and starts the application
class CliUI {
  late final HospitalConsole console;

  CliUI() {
    // Services automatically load data from their repositories
    final staffService = StaffService();
    final medicalStaffService = MedicalStaffService(staffService);

    console = HospitalConsole(
      staffService: staffService,
      medicalStaffService: medicalStaffService,
    );
  }

  /// Start the Hospital Management System
  void start() => console.start();
}
