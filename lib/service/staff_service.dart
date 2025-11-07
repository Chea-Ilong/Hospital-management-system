import '../domain/staff.dart';
import '../domain/medical_staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../data/repository/doctor_repository.dart';
import '../data/repository/nurse_repository.dart';
import '../data/repository/administrative_staff_repository.dart';

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

  Staff? getStaffById(String id) {
    try {
      return _allStaff.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  void addStaff(Staff staff) {
    if (getStaffById(staff.id) != null) {
      throw ArgumentError('Staff with ID ${staff.id} already exists');
    }

    _validateStaffData(staff);

    _allStaff.add(staff);
    _saveByType(staff);
  }

  void updateStaff(Staff staff) {
    final index = _allStaff.indexWhere((s) => s.id == staff.id);
    if (index == -1) {
      throw ArgumentError('Staff with ID ${staff.id} not found');
    }

    _validateStaffData(staff);

    _allStaff[index] = staff;
    _saveByType(staff);
  }

  void removeStaff(String id) {
    final staff = getStaffById(id);
    if (staff == null) {
      throw ArgumentError('Staff with ID $id not found');
    }
    _allStaff.removeWhere((s) => s.id == id);
    _saveByType(staff);
  }

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

  List<T> getByDepartment<T extends Staff>(StaffDepartment department) {
    return _getWhere<T>((staff) => staff.department == department);
  }

  void transferDepartment(String staffId, StaffDepartment newDepartment) {
    final staff = getStaffById(staffId);
    if (staff == null) {
      throw ArgumentError('Staff with ID $staffId not found');
    }
    staff.department = newDepartment;
    updateStaff(staff);
  }

  void applyDepartmentSalaryIncrease(
      StaffDepartment department, double percentageIncrease) {
    if (percentageIncrease < 0) {
      throw ArgumentError('Percentage increase cannot be negative');
    }
    final departmentStaff = getByDepartment<Staff>(department);
    for (var staff in departmentStaff) {
      final oldSalary = staff.salary;
      staff.salary *= (1 + percentageIncrease / 100);

      if (!staff.hasValidSalary) {
        staff.salary = oldSalary;
        throw StateError(
          'Salary increase resulted in invalid salary for ${staff.getFullName} '
          '(ID: ${staff.id}). Old: \$${oldSalary.toStringAsFixed(2)}, '
          'New: \$${staff.salary.toStringAsFixed(2)}'
        );
      }

      updateStaff(staff);
    }
  }


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

  Map<String, int> getStaffCountByType() {
    return {
      'doctors': _getCountByType<Doctor>(),
      'nurses': _getCountByType<Nurse>(),
      'administrativeStaff': _getCountByType<AdministrativeStaff>(),
      'total': _allStaff.length,
    };
  }


  List<T> _getWhere<T extends Staff>(bool Function(T) predicate) {
    return _allStaff.whereType<T>().where(predicate).toList();
  }

  void _validateStaffData(Staff staff) {
    final errors = <String>[];

    if (!staff.hasValidEmail) {
      errors.add('Invalid email format: ${staff.email}');
    }
    if (!staff.hasValidPhoneNumber) {
      errors.add('Invalid phone number: ${staff.phoneNumber}');
    }
    if (!staff.hasValidDateOfBirth) {
      errors.add('Date of birth must be in the past');
    }
    if (!staff.isAdult) {
      errors.add('Staff must be at least 18 years old (current age: ${staff.getAge})');
    }
    if (!staff.hasValidHireDate) {
      errors.add('Hire date cannot be in the future');
    }
    if (!staff.hasValidExperience) {
      errors.add('Years of experience cannot be negative');
    }
    if (!staff.hasValidSalary) {
      errors.add('Salary must be greater than 0 (current: \$${staff.salary})');
    }

    if (staff is MedicalStaff) {
      if (!staff.hasValidShiftsCount) {
        errors.add('Invalid shifts count: ${staff.shiftsThisMonth} (must be 0-31)');
      }

      if (staff is Doctor && !staff.hasValidConsultations) {
        errors.add('Consultations count cannot be negative');
      }
    }

    if (errors.isNotEmpty) {
      throw ArgumentError('Staff validation failed:\n  - ${errors.join('\n  - ')}');
    }
  }

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

  int _getCountByType<T extends Staff>() {
    return _allStaff.whereType<T>().length;
  }

  Map<StaffDepartment, int> _getDepartmentBreakdown() {
    final breakdown = <StaffDepartment, int>{};
    for (var staff in _allStaff) {
      breakdown[staff.department] = (breakdown[staff.department] ?? 0) + 1;
    }
    return breakdown;
  }

  double _calculateAverageSalary(List<Staff> staff) {
    if (staff.isEmpty) return 0.0;
    return staff.map((s) => s.salary).reduce((a, b) => a + b) / staff.length;
  }
}
