import '../domain/medical_staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import 'staff_service.dart';

/// Medical Staff Service - Clinical operations for Doctors & Nurses
/// Handles: Patient assignment, Shifts, Consultations, Certifications
class MedicalStaffService {
  final StaffService _staffService;

  MedicalStaffService(this._staffService);

  // ============================================================================
  // MEDICAL STAFF QUERIES (3 methods)
  // ============================================================================

  /// Get all medical staff
  List<MedicalStaff> getAllMedicalStaff() {
    return _staffService.allStaff.whereType<MedicalStaff>().toList();
  }

  /// Get all doctors
  List<Doctor> getAllDoctors() {
    return _staffService.allStaff.whereType<Doctor>().toList();
  }

  /// Get all nurses
  List<Nurse> getAllNurses() {
    return _staffService.allStaff.whereType<Nurse>().toList();
  }

  // ============================================================================
  // PATIENT MANAGEMENT (3 methods)
  // ============================================================================

  /// Assign patient to medical staff
  void assignPatient(String staffId, String patientId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    if (!medicalStaff.assignedPatients.contains(patientId)) {
      medicalStaff.assignedPatients.add(patientId);
      _staffService.updateStaff(medicalStaff);
    }
  }

  /// Remove patient from medical staff
  void removePatient(String staffId, String patientId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    medicalStaff.assignedPatients.remove(patientId);
    _staffService.updateStaff(medicalStaff);
  }

  /// Transfer patient between medical staff
  void transferPatient(String fromStaffId, String toStaffId, String patientId) {
    removePatient(fromStaffId, patientId);
    assignPatient(toStaffId, patientId);
  }

  // ============================================================================
  // SHIFT MANAGEMENT (1 method)
  // ============================================================================

  /// Record shift for medical staff
  void recordShift(String staffId) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    medicalStaff.shiftsThisMonth++;
    _staffService.updateStaff(medicalStaff);
  }

  // ============================================================================
  // DOCTOR-SPECIFIC OPERATIONS (1 method)
  // ============================================================================

  /// Record doctor consultation
  void recordConsultation(String doctorId) {
    final doctor = _getDoctorById(doctorId);
    if (doctor == null) {
      throw ArgumentError('Doctor with ID $doctorId not found');
    }
    doctor.consultationsThisMonth++;
    _staffService.updateStaff(doctor);
  }

  // ============================================================================
  // CERTIFICATION MANAGEMENT (2 methods)
  // ============================================================================

  /// Add certification to medical staff
  void addCertification(String staffId, String certification) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    if (!medicalStaff.certifications.contains(certification)) {
      medicalStaff.certifications.add(certification);
      _staffService.updateStaff(medicalStaff);
    }
  }

  /// Remove certification from medical staff
  void removeCertification(String staffId, String certification) {
    final medicalStaff = _getMedicalStaffById(staffId);
    if (medicalStaff == null) {
      throw ArgumentError('Medical staff with ID $staffId not found');
    }
    medicalStaff.certifications.remove(certification);
    _staffService.updateStaff(medicalStaff);
  }

  // ============================================================================
  // REPORTS & ANALYTICS (1 method)
  // ============================================================================

  /// Get comprehensive performance report
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
        'overloadedStaff':
            medicalStaff.where((s) => s.assignedPatients.length > 10).length,
        'underutilizedStaff':
            medicalStaff.where((s) => s.assignedPatients.isEmpty).length,
        'overloaded': medicalStaff
            .where(
                (s) => s.assignedPatients.length > 10 || s.shiftsThisMonth > 20)
            .map((s) => _formatStaffWorkload(s))
            .toList(),
        'underutilized': medicalStaff
            .where((s) => s.assignedPatients.isEmpty && s.shiftsThisMonth < 5)
            .map((s) => _formatStaffWorkload(s))
            .toList(),
      },
    };
  }

  // ============================================================================
  // BATCH OPERATIONS (1 method)
  // ============================================================================

  /// Reset all monthly counters for all medical staff
  void resetAllMonthlyCounters() {
    for (var staff in getAllMedicalStaff()) {
      staff.shiftsThisMonth = 0;
      if (staff is Doctor) {
        staff.consultationsThisMonth = 0;
      }
      _staffService.updateStaff(staff);
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - Internal support methods (3 methods)
  // ============================================================================

  /// Get medical staff by ID (private helper)
  MedicalStaff? _getMedicalStaffById(String id) {
    final staff = _staffService.getStaffById(id);
    return (staff is MedicalStaff) ? staff : null;
  }

  /// Get doctor by ID (private helper)
  Doctor? _getDoctorById(String id) {
    final staff = _staffService.getStaffById(id);
    return (staff is Doctor) ? staff : null;
  }

  /// Format staff workload info for reports (private helper)
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
