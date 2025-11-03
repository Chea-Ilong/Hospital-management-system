import '../domain/staff.dart';
import '../domain/medical_staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import 'staff_service.dart';

/// Unified Admin Service - Single entry point for all hospital management
/// Uses generic algorithms to reduce redundant getters
class AdminService {
  final StaffService _staffService;

  AdminService(this._staffService);

  // ============================================================================
  // SMART GENERIC GETTERS - Replaces 20+ redundant methods
  // ============================================================================

  /// Generic: Get all staff of specific type
  /// Replaces: getAllDoctors(), getAllNurses(), getAllAdministrativeStaff()
  List<T> getAll<T extends Staff>() {
    return _staffService.allStaff.whereType<T>().toList();
  }

  /// Generic: Get staff by ID with type checking
  /// Replaces: getDoctorById(), getNurseById(), getAdministrativeStaffById()
  T? getById<T extends Staff>(String id) {
    final staff = _staffService.getStaffById(id);
    return (staff is T) ? staff : null;
  }

  /// Generic: Get staff by property predicate
  /// Replaces: getDoctorsBySpecialization(), getNursesBySpecialization(), etc.
  List<T> getWhere<T extends Staff>(bool Function(T) predicate) {
    return getAll<T>().where(predicate).toList();
  }

  // ============================================================================
  // SPECIALIZED QUERIES - Built on generic methods
  // ============================================================================

  /// Get doctors by specialization (uses generic getWhere)
  List<Doctor> getDoctorsBySpecialization(Specialization specialization) {
    return getWhere<Doctor>(
        (doctor) => doctor.specialization == specialization);
  }

  /// Get nurses by specialization (uses generic getWhere)
  List<Nurse> getNursesBySpecialization(NurseSpecialization specialization) {
    return getWhere<Nurse>((nurse) => nurse.specialization == specialization);
  }

  /// Get admin staff by position (uses generic getWhere)
  List<AdministrativeStaff> getAdminStaffByPosition(
      AdministrativePosition position) {
    return getWhere<AdministrativeStaff>((staff) => staff.position == position);
  }

  /// Get staff by department (works for ALL staff types)
  List<T> getByDepartment<T extends Staff>(StaffDepartment department) {
    return getWhere<T>((staff) => staff.department == department);
  }

  // ============================================================================
  // GENERIC STAFF OPERATIONS - Replaces 8+ specific methods
  // ============================================================================

  /// Generic modify: Apply operation to staff member (replaces 8 methods)
  /// Usage: modify<Doctor>(id, (d) => d.consultationsThisMonth++)
  void modify<T extends Staff>(String id, void Function(T) operation) {
    final staff = getById<T>(id);
    if (staff == null) {
      throw ArgumentError('${T.toString()} with ID $id not found');
    }
    operation(staff);
    _staffService.updateStaff(staff);
  }

  /// Batch modify: Apply operation to multiple staff members
  void modifyBatch(List<String> ids, void Function(Staff) operation) {
    for (final id in ids) {
      final staff = _staffService.getStaffById(id);
      if (staff != null) {
        operation(staff);
        _staffService.updateStaff(staff);
      }
    }
  }

  // ============================================================================
  // CROSS-STAFF OPERATIONS
  // ============================================================================

  /// Apply bulk salary increase to all staff
  void applyBulkSalaryIncrease(double percentageIncrease) {
    if (percentageIncrease < 0) {
      throw ArgumentError('Percentage increase cannot be negative');
    }
    for (var staff in _staffService.allStaff) {
      staff.salary = staff.salary * (1 + percentageIncrease / 100);
      _staffService.updateStaff(staff);
    }
  }

  /// Apply salary increase to specific department
  void applyDepartmentSalaryIncrease(
      StaffDepartment department, double percentageIncrease) {
    if (percentageIncrease < 0) {
      throw ArgumentError('Percentage increase cannot be negative');
    }
    final departmentStaff = getByDepartment<Staff>(department);
    for (var staff in departmentStaff) {
      staff.salary = staff.salary * (1 + percentageIncrease / 100);
      _staffService.updateStaff(staff);
    }
  }

  /// Transfer staff between departments
  void transferDepartment(String staffId, StaffDepartment newDepartment) {
    modify<Staff>(staffId, (staff) => staff.department = newDepartment);
  }

  /// Get comprehensive performance report
  Map<String, dynamic> getPerformanceReport() {
    final doctors = getAll<Doctor>();
    final medicalStaff = getAll<MedicalStaff>();
    final departmentBreakdown = _staffService.getDepartmentBreakdown();

    return {
      'totalStaff': _staffService.allStaff.length,
      'departmentBreakdown': departmentBreakdown.map(
        (dept, count) => MapEntry(dept.name, count),
      ),
      'doctors': doctors.length,
      'nurses': getAll<Nurse>().length,
      'administrativeStaff': getAll<AdministrativeStaff>().length,
      'avgDoctorConsultations': doctors.isEmpty
          ? 0
          : doctors
                  .map((d) => d.consultationsThisMonth)
                  .reduce((a, b) => a + b) /
              doctors.length,
      'avgMedicalStaffShifts': medicalStaff.isEmpty
          ? 0
          : medicalStaff.map((m) => m.shiftsThisMonth).reduce((a, b) => a + b) /
              medicalStaff.length,
      'overloadedStaff':
          medicalStaff.where((s) => s.assignedPatients.length > 10).length,
    };
  }

  /// Get department statistics
  Map<String, dynamic> getDepartmentStatistics() {
    final breakdown = _staffService.getDepartmentBreakdown();
    return {
      'totalDepartments': breakdown.length,
      'breakdown': breakdown.map((dept, count) => MapEntry(dept.name, count)),
    };
  }

  // ============================================================================
  // STAFF SERVICE DELEGATION - Direct access to base operations
  // ============================================================================

  /// Add any staff type
  void addStaff(Staff staff) => _staffService.addStaff(staff);

  /// Update any staff type
  void updateStaff(Staff staff) => _staffService.updateStaff(staff);

  /// Remove any staff type
  void removeStaff(String id) => _staffService.removeStaff(id);

  /// Search staff by name
  List<Staff> searchByName(String query) =>
      _staffService.searchStaffByName(query);
}
