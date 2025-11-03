import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../data/repository/doctor_repository.dart';
import '../data/repository/nurse_repository.dart';
import '../data/repository/administrative_staff_repository.dart';

/// Universal service for managing ALL staff types
/// Provides common CRUD operations, search, and statistics
class StaffService {
  final DoctorRepository _doctorRepo;
  final NurseRepository _nurseRepo;
  final AdministrativeStaffRepository _adminStaffRepo;

  /// Single list containing all staff members (doctors, nurses, admin staff)
  List<Staff> allStaff = [];

  StaffService(
    this._doctorRepo,
    this._nurseRepo,
    this._adminStaffRepo,
  ) {
    // Load all staff into one unified list
    allStaff = [
      ..._doctorRepo.loadAllDoctors(),
      ..._nurseRepo.loadAllNurses(),
      ..._adminStaffRepo.loadAllAdministrativeStaff(),
    ];
  }

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Get staff member by ID (searches all types)
  Staff? getStaffById(String id) {
    try {
      return allStaff.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new staff member (automatically handles type)
  void addStaff(Staff staff) {
    if (getStaffById(staff.id) != null) {
      throw ArgumentError('Staff with ID ${staff.id} already exists');
    }
    allStaff.add(staff);
    _saveStaffByType(staff);
  }

  /// Update existing staff member (automatically handles type)
  void updateStaff(Staff staff) {
    final index = allStaff.indexWhere((s) => s.id == staff.id);
    if (index == -1) {
      throw ArgumentError('Staff with ID ${staff.id} not found');
    }
    allStaff[index] = staff;
    _saveStaffByType(staff);
  }

  /// Remove staff member by ID (automatically handles type)
  void removeStaff(String id) {
    final staff = getStaffById(id);
    if (staff == null) {
      throw ArgumentError('Staff with ID $id not found');
    }
    allStaff.removeWhere((s) => s.id == id);
    _deleteStaffByType(staff);
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  /// Search all staff by name
  List<Staff> searchStaffByName(String query) {
    final lowerQuery = query.toLowerCase();
    return allStaff
        .where((s) =>
            s.firstName.toLowerCase().contains(lowerQuery) ||
            s.lastName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Generic: Get staff matching predicate
  List<T> getWhere<T extends Staff>(bool Function(T) predicate) {
    return allStaff.whereType<T>().where(predicate).toList();
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get count by predicate
  Map<String, int> getCountByPredicate(
      Map<String, bool Function(Staff)> predicates) {
    return predicates.map(
        (key, predicate) => MapEntry(key, allStaff.where(predicate).length));
  }

  /// Get department breakdown (returns Map<StaffDepartment, int>)
  Map<StaffDepartment, int> getDepartmentBreakdown() {
    final breakdown = <StaffDepartment, int>{};
    for (var staff in allStaff) {
      breakdown[staff.department] = (breakdown[staff.department] ?? 0) + 1;
    }
    return breakdown;
  }
  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Save staff to appropriate repository based on type
  void _saveStaffByType(Staff staff) {
    if (staff is Doctor) {
      _doctorRepo.saveAllDoctors(allStaff.whereType<Doctor>().toList());
    } else if (staff is Nurse) {
      _nurseRepo.saveAllNurses(allStaff.whereType<Nurse>().toList());
    } else if (staff is AdministrativeStaff) {
      _adminStaffRepo.saveAllAdministrativeStaff(
          allStaff.whereType<AdministrativeStaff>().toList());
    }
  }

  /// Delete staff from appropriate repository based on type
  void _deleteStaffByType(Staff staff) {
    // After removal from allStaff list, save the updated lists
    _saveStaffByType(staff);
  }
}
