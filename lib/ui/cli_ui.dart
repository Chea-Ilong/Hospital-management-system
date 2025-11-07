import '../service/staff_service.dart';
import '../service/medical_staff_service.dart';
import 'hospital_console.dart';

class CliUI {
  late final HospitalConsole console;

  CliUI() {

    final staffService = StaffService();
    final medicalStaffService = MedicalStaffService(staffService);

    console = HospitalConsole(
      staffService: staffService,
      medicalStaffService: medicalStaffService,
    );
  }

  void start() => console.start();
}
