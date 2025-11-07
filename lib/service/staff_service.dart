import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../data/repository/doctor_repository.dart';
import '../data/repository/nurse_repository.dart';
import '../data/repository/administrative_staff_repository.dart';

/// Universal Staff Service - Manages ALL staff types
/// Handles: CRUD, Search, Department, Salary, Reports
class StaffService {
  final DoctorRepository _doctorRepo;
  final NurseRepository _nurseRepo;
  final AdministrativeStaffRepository _adminStaffRepo;

  final List<Staff> _allStaff = [];
  List<Staff> get allStaff => List.unmodifiable(_allStaff);

  StaffService()
      : _doctorRepo = DoctorRepository(),
        _nurseRepo = NurseRepository(),
        _adminStaffRepo = AdministrativeStaffRepository() {
    _allStaff.addAll([
      ..._doctorRepo.loadAllDoctors(),
      ..._nurseRepo.loadAllNurses(),
      ..._adminStaffRepo.loadAllAdministrativeStaff(),
    ]);
  }

  // ============================================================================
  // CRUD OPERATIONS (4 methods)
  // ============================================================================

  /// Get staff by ID
  Staff? getStaffById(String id) {
    try {
      return _allStaff.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new staff
  void addStaff(Staff staff) {
    if (getStaffById(staff.id) != null) {
      throw ArgumentError('Staff with ID ${staff.id} already exists');
    }
    _allStaff.add(staff);
    _saveByType(staff);
  }

  /// Update existing staff
  void updateStaff(Staff staff) {
    final index = _allStaff.indexWhere((s) => s.id == staff.id);
    if (index == -1) {
      throw ArgumentError('Staff with ID ${staff.id} not found');
    }
    _allStaff[index] = staff;
    _saveByType(staff);
  }

  /// Remove staff
  void removeStaff(String id) {
    final staff = getStaffById(id);
    if (staff == null) {
      throw ArgumentError('Staff with ID $id not found');
    }
    _allStaff.removeWhere((s) => s.id == id);
    _saveByType(staff);
  }

  // ============================================================================
  // SEARCH & FILTER (1 method)
  // ============================================================================

  /// Search staff by name
  List<Staff> searchStaffByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _allStaff
        .where((s) =>
            s.firstName.toLowerCase().contains(lowerQuery) ||
            s.lastName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<AdministrativeStaff> getAllAdministrativeStaff() {
    return _allStaff.whereType<AdministrativeStaff>().toList();
  }
  // ============================================================================
  // SPECIALIZED QUERIES (1 method)
  // ============================================================================

  /// Get staff by department (works for all types)
  List<T> getByDepartment<T extends Staff>(StaffDepartment department) {
    return _getWhere<T>((staff) => staff.department == department);
  }

  // ============================================================================
  // DEPARTMENT MANAGEMENT (1 method)
  // ============================================================================

  /// Transfer staff to different department
  void transferDepartment(String staffId, StaffDepartment newDepartment) {
    final staff = getStaffById(staffId);
    if (staff == null) {
      throw ArgumentError('Staff with ID $staffId not found');
    }
    staff.department = newDepartment;
    updateStaff(staff);
  }

  // ============================================================================
  // SALARY MANAGEMENT (1 method)
  // ============================================================================

  /// Apply salary increase to specific department
  void applyDepartmentSalaryIncrease(
      StaffDepartment department, double percentageIncrease) {
    if (percentageIncrease < 0) {
      throw ArgumentError('Percentage increase cannot be negative');
    }
    final departmentStaff = getByDepartment<Staff>(department);
    for (var staff in departmentStaff) {
      staff.salary *= (1 + percentageIncrease / 100);
      updateStaff(staff);
    }
  }

  // ============================================================================
  // REPORTS & ANALYTICS (2 methods)
  // ============================================================================

  /// Get department statistics with salary analysis
  Map<String, dynamic> getDepartmentStatistics() {
    final breakdown = _getDepartmentBreakdown();

    return {
      'totalDepartments': breakdown.length,
      'breakdown': breakdown.map((dept, count) => MapEntry(dept.name, count)),
      'details': StaffDepartment.values.map((dept) {
        final deptStaff = getByDepartment<Staff>(dept);

        return {
          'department': dept.name,
          'totalStaff': deptStaff.length,
          'doctors': deptStaff.whereType<Doctor>().length,
          'nurses': deptStaff.whereType<Nurse>().length,
          'adminStaff': deptStaff.whereType<AdministrativeStaff>().length,
          'avgSalary': _calculateAverageSalary(deptStaff),
          'totalSalaryExpense': deptStaff.isEmpty
              ? 0.0
              : deptStaff.map((s) => s.salary).reduce((a, b) => a + b),
        };
      }).toList(),
    };
  }

  /// Get staff count by type
  Map<String, int> getStaffCountByType() {
    return {
      'doctors': _getCountByType<Doctor>(),
      'nurses': _getCountByType<Nurse>(),
      'administrativeStaff': _getCountByType<AdministrativeStaff>(),
      'total': _allStaff.length,
    };
  }

  // ============================================================================
  // PRIVATE HELPERS - Internal support methods
  // ============================================================================

  /// Generic filter with predicate (private - used internally)
  List<T> _getWhere<T extends Staff>(bool Function(T) predicate) {
    return _allStaff.whereType<T>().where(predicate).toList();
  }

  /// Save staff to appropriate repository based on type
  void _saveByType(Staff staff) {
    if (staff is Doctor) {
      _doctorRepo.saveAllDoctors(_allStaff.whereType<Doctor>().toList());
    } else if (staff is Nurse) {
      _nurseRepo.saveAllNurses(_allStaff.whereType<Nurse>().toList());
    } else if (staff is AdministrativeStaff) {
      _adminStaffRepo.saveAllAdministrativeStaff(
          _allStaff.whereType<AdministrativeStaff>().toList());
    }
  }

  /// Get count of staff by type
  int _getCountByType<T extends Staff>() {
    return _allStaff.whereType<T>().length;
  }

  /// Get department breakdown (count per department)
  Map<StaffDepartment, int> _getDepartmentBreakdown() {
    final breakdown = <StaffDepartment, int>{};
    for (var staff in _allStaff) {
      breakdown[staff.department] = (breakdown[staff.department] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Calculate average salary for a list of staff
  double _calculateAverageSalary(List<Staff> staff) {
    if (staff.isEmpty) return 0.0;
    return staff.map((s) => s.salary).reduce((a, b) => a + b) / staff.length;
  }
}
