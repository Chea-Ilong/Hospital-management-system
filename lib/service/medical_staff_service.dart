import '../domain/medical_staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import 'staff_service.dart';

class MedicalStaffService {
  final StaffService _staffService;

  MedicalStaffService(this._staffService);

  List<MedicalStaff> getAllMedicalStaff() {
    return _staffService.allStaff.whereType<MedicalStaff>().toList();
  }

  List<Doctor> getAllDoctors() {
    return _staffService.allStaff.whereType<Doctor>().toList();
  }

  List<Nurse> getAllNurses() {
    return _staffService.allStaff.whereType<Nurse>().toList();
  }

  void assignPatient(String staffId, String patientId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }

    if (medicalStaff.hasPatient(patientId)) {
      return;
    }

    if (!medicalStaff.canTakeMorePatients) {
      throw StateError(
          'Cannot assign patient to ${medicalStaff.getFullName} (ID: $staffId): '
          'Staff is at capacity with ${medicalStaff.assignedPatients.length} patients. '
          'Maximum allowed is 10 patients.');
    }

    if (medicalStaff.isOverloaded) {
      print('WARNING: ${medicalStaff.getFullName} is overloaded '
          '(${medicalStaff.assignedPatients.length} patients, '
          '${medicalStaff.shiftsThisMonth} shifts)');
    }

    medicalStaff.assignedPatients.add(patientId);
    _staffService.updateStaff(medicalStaff);
  }

  void removePatient(String staffId, String patientId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    medicalStaff.assignedPatients.remove(patientId);
    _staffService.updateStaff(medicalStaff);
  }

  void transferPatient(String fromStaffId, String toStaffId, String patientId) {
    final fromStaff = _getMedicalStaffById(fromStaffId);
    if (fromStaff == null) {
      throw ArgumentError(
          'Source medical staff with ID $fromStaffId not found');
    }

    final toStaff = _getMedicalStaffById(toStaffId);
    if (toStaff == null) {
      throw ArgumentError(
          'Destination medical staff with ID $toStaffId not found');
    }

    if (!toStaff.canTakeMorePatients && !toStaff.hasPatient(patientId)) {
      throw StateError('Cannot transfer patient to ${toStaff.getFullName}: '
          'Staff is at capacity with ${toStaff.assignedPatients.length} patients');
    }

    removePatient(fromStaffId, patientId);
    assignPatient(toStaffId, patientId);
  }

  void recordShift(String staffId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }

    medicalStaff.shiftsThisMonth++;

    if (!medicalStaff.hasValidShiftsCount) {
      medicalStaff.shiftsThisMonth--;
      throw StateError('Cannot record shift for ${medicalStaff.getFullName}: '
          'Shift count would exceed maximum (current: ${medicalStaff.shiftsThisMonth}, '
          'maximum: 31 shifts per month)');
    }

    if (medicalStaff.isOverloaded) {
      print('WARNING: ${medicalStaff.getFullName} is now overloaded '
          '(${medicalStaff.shiftsThisMonth} shifts)');
    }

    _staffService.updateStaff(medicalStaff);
  }

  void recordConsultation(String doctorId) {
    final doctor = _getDoctorById(doctorId);
    if (doctor == null) {
      throw ArgumentError('Doctor with ID $doctorId not found');
    }

    doctor.consultationsThisMonth++;

    if (!doctor.hasValidConsultations) {
      doctor.consultationsThisMonth--;
      throw StateError('Cannot record consultation for ${doctor.getFullName}: '
          'Invalid consultation count');
    }

    _staffService.updateStaff(doctor);
  }

  void addCertification(String staffId, String certification) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    if (!medicalStaff.hasCertification(certification)) {
      medicalStaff.certifications.add(certification);
      _staffService.updateStaff(medicalStaff);
    }
  }

  void removeCertification(String staffId, String certification) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    medicalStaff.certifications.remove(certification);
    _staffService.updateStaff(medicalStaff);
  }

  Map<String, dynamic> getPerformanceReport() {
    final doctors = getAllDoctors();
    final nurses = getAllNurses();
    final medicalStaff = getAllMedicalStaff();

    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'totalMedicalStaff': medicalStaff.length,
      'staffBreakdown': {
        'doctors': doctors.length,
        'nurses': nurses.length,
      },
      'performance': {
        'avgDoctorConsultations': doctors.isEmpty
            ? 0.0
            : doctors
                    .map((d) => d.consultationsThisMonth)
                    .reduce((a, b) => a + b) /
                doctors.length,
        'avgDoctorShifts': doctors.isEmpty
            ? 0.0
            : doctors.map((d) => d.shiftsThisMonth).reduce((a, b) => a + b) /
                doctors.length,
        'avgNurseShifts': nurses.isEmpty
            ? 0.0
            : nurses.map((n) => n.shiftsThisMonth).reduce((a, b) => a + b) /
                nurses.length,
      },
      'workload': {
        'overloadedStaff': medicalStaff.where((s) => s.isOverloaded).length,
        'underutilizedStaff':
            medicalStaff.where((s) => s.assignedPatients.isEmpty).length,
        'overloaded': medicalStaff
            .where((s) => s.isOverloaded)
            .map((s) => _formatStaffWorkload(s))
            .toList(),
        'underutilized': medicalStaff
            .where((s) => s.assignedPatients.isEmpty && s.shiftsThisMonth < 5)
            .map((s) => _formatStaffWorkload(s))
            .toList(),
      },
    };
  }

  void resetAllMonthlyCounters() {
    for (var staff in getAllMedicalStaff()) {
      staff.shiftsThisMonth = 0;
      if (staff is Doctor) {
        staff.consultationsThisMonth = 0;
      }
      _staffService.updateStaff(staff);
    }
  }

  MedicalStaff? _getMedicalStaffById(String id) {
    final staff = _staffService.getStaffById(id);
    return (staff is MedicalStaff) ? staff : null;
  }

  Doctor? _getDoctorById(String id) {
    final staff = _staffService.getStaffById(id);
    return (staff is Doctor) ? staff : null;
  }

  Map<String, dynamic> _formatStaffWorkload(MedicalStaff staff) {
    final info = {
      'id': staff.id,
      'name': '${staff.firstName} ${staff.lastName}',
      'role': staff.role.name,
      'department': staff.department.name,
      'patients': staff.assignedPatients.length,
      'shifts': staff.shiftsThisMonth,
    };

    if (staff is Doctor) {
      info['consultations'] = staff.consultationsThisMonth;
      info['specialization'] = staff.specialization.name;
    } else if (staff is Nurse) {
      info['specialization'] = staff.specialization.name;
    }

    return info;
  }
}
