import 'dart:io';
import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../service/staff_service.dart';
import '../service/medical_staff_service.dart';

class HospitalConsole {
  final StaffService staffService;
  final MedicalStaffService medicalStaffService;

  HospitalConsole({
    required this.staffService,
    required this.medicalStaffService,
  });

  void start() {
    _printHeader('HOSPITAL MANAGEMENT SYSTEM');

    while (true) {
      _showMainMenu();
      final choice = _input('➤ Choice: ');
      if (choice == '0') {
        print('\n✅ Data saved. Goodbye!\n');
        exit(0);
      }
      _handleMainMenu(choice);
      _pause();
    }
  }

  // ===== MENUS =====

  void _showMainMenu() {
    print('\n${'=' * 50}\nMAIN MENU\n${'=' * 50}');
    _printOptions([
      '1.👥 View Staff',
      '2.🔍 Search',
      '3.➕ Add',
      '4.✏️ Update',
      '5.❌ Remove',
      '6.🏥 Medical Ops',
      '7.📊 Reports',
      '8.💰 Salary',
      '9.🔄 Transfer',
      '0.🚪 Exit'
    ]);
  }

  void _handleMainMenu(String choice) {
    switch (choice) {
      case '1':
        _viewStaffMenu();
        break;
      case '2':
        _searchStaff();
        break;
      case '3':
        _addStaff();
        break;
      case '4':
        _updateStaff();
        break;
      case '5':
        _removeStaff();
        break;
      case '6':
        _medicalMenu();
        break;
      case '7':
        _reportsMenu();
        break;
      case '8':
        _applySalaryIncrease();
        break;
      case '9':
        _transferDept();
        break;
      default:
        print('❌ Invalid');
    }
  }

  void _viewStaffMenu() {
    _printHeader('VIEW STAFF');
    _printOptions(
        ['1.All', '2.By Dept', '3.Doctors', '4.Nurses', '5.Admin', '0.Back']);
    switch (_input('➤: ')) {
      case '1':
        _displayList(staffService.allStaff, 'ALL STAFF');
        break;
      case '2':
        _viewByDept();
        break;
      case '3':
        _displayList(medicalStaffService.getAllDoctors(), 'DOCTORS');
        break;
      case '4':
        _displayList(medicalStaffService.getAllNurses(), 'NURSES');
        break;
      case '5':
        _displayList(
            staffService.allStaff.whereType<AdministrativeStaff>().toList(),
            'ADMIN');
        break;
    }
  }

  void _medicalMenu() {
    _printHeader('MEDICAL OPERATIONS');
    _printOptions([
      '1.Assign Patient',
      '2.Remove Patient',
      '3.Transfer Patient',
      '4.Record Shift',
      '5.Record Consultation',
      '6.Add Cert',
      '7.Remove Cert',
      '8.Performance Report',
      '9.Reset Counters',
      '0.Back'
    ]);
    final choice = _input('➤: ');
    try {
      switch (choice) {
        case '1':
          medicalStaffService.assignPatient(
              _input('Staff ID: '), _input('Patient ID: '));
          print('✅ Assigned');
          break;
        case '2':
          medicalStaffService.removePatient(
              _input('Staff ID: '), _input('Patient ID: '));
          print('✅ Removed');
          break;
        case '3':
          medicalStaffService.transferPatient(
              _input('From ID: '), _input('To ID: '), _input('Patient ID: '));
          print('✅ Transferred');
          break;
        case '4':
          medicalStaffService.recordShift(_input('Staff ID: '));
          print('✅ Shift recorded');
          break;
        case '5':
          medicalStaffService.recordConsultation(_input('Doctor ID: '));
          print('✅ Consultation recorded');
          break;
        case '6':
          medicalStaffService.addCertification(
              _input('Staff ID: '), _input('Certification: '));
          print('✅ Added');
          break;
        case '7':
          medicalStaffService.removeCertification(
              _input('Staff ID: '), _input('Certification: '));
          print('✅ Removed');
          break;
        case '8':
          _showPerformanceReport();
          break;
        case '9':
          if (_confirm('Reset all counters?')) {
            medicalStaffService.resetAllMonthlyCounters();
            print('✅ Reset');
          }
          break;
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  void _reportsMenu() {
    _printHeader('STATISTICS & REPORTS');
    _printOptions(
        ['1.Staff Count', '2.Dept Stats', '3.Medical Performance', '0.Back']);
    switch (_input('➤: ')) {
      case '1':
        _showMap(staffService.getStaffCountByType(), 'STAFF COUNT');
        break;
      case '2':
        _showDeptStats();
        break;
      case '3':
        _showPerformanceReport();
        break;
    }
  }

  // ===== OPERATIONS =====

  void _searchStaff() {
    final query = _input('🔍 Name: ');
    if (query.isEmpty) return;
    _displayList(staffService.searchStaffByName(query), 'SEARCH: $query');
  }

  void _addStaff() {
    _printOptions(['1.Doctor', '2.Nurse', '3.Admin']);
    switch (_input('➤ Role: ')) {
      case '1':
        _addDoctor();
        break;
      case '2':
        _addNurse();
        break;
      case '3':
        _addAdmin();
        break;
    }
  }

  void _addDoctor() {
    try {
      staffService.addStaff(Doctor(
        id: _input('ID: '),
        firstName: _input('First: '),
        lastName: _input('Last: '),
        email: _input('Email: '),
        phoneNumber: _input('Phone: '),
        dateOfBirth: _inputDate('DOB: '),
        hireDate: _inputDate('Hire: '),
        pastYearsOfExperience: _inputInt('Experience: '),
        salary: _inputDouble('Salary: '),
        department: _selectEnum(StaffDepartment.values, 'Dept'),
        specialization:
            _selectEnum(DoctorSpecialization.values, 'Specialization'),
        currentShift: _selectEnum(ShiftType.values, 'Shift'),
      ));
      print('✅ Doctor added');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  void _addNurse() {
    try {
      staffService.addStaff(Nurse(
        id: _input('ID: '),
        firstName: _input('First: '),
        lastName: _input('Last: '),
        email: _input('Email: '),
        phoneNumber: _input('Phone: '),
        dateOfBirth: _inputDate('DOB: '),
        hireDate: _inputDate('Hire: '),
        pastYearsOfExperience: _inputInt('Experience: '),
        salary: _inputDouble('Salary: '),
        department: _selectEnum(StaffDepartment.values, 'Dept'),
        specialization:
            _selectEnum(NurseSpecialization.values, 'Specialization'),
        currentShift: _selectEnum(ShiftType.values, 'Shift'),
      ));
      print('✅ Nurse added');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  void _addAdmin() {
    try {
      staffService.addStaff(AdministrativeStaff(
        id: _input('ID: '),
        firstName: _input('First: '),
        lastName: _input('Last: '),
        email: _input('Email: '),
        phoneNumber: _input('Phone: '),
        dateOfBirth: _inputDate('DOB: '),
        hireDate: _inputDate('Hire: '),
        pastYearsOfExperience: _inputInt('Experience: '),
        salary: _inputDouble('Salary: '),
        department: _selectEnum(StaffDepartment.values, 'Dept'),
        position: _selectEnum(AdministrativePosition.values, 'Position'),
        currentShift: _selectEnum(ShiftType.values, 'Shift'),
      ));
      print('✅ Admin added');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  void _updateStaff() {
    final staff = staffService.getStaffById(_input('Staff ID: '));
    if (staff == null) return print('❌ Not found');

    print('\nCurrent: ${staff.firstName} ${staff.lastName}');
    _printOptions(['1.Salary', '2.Email', '3.Phone']);

    switch (_input('➤: ')) {
      case '1':
        staff.salary = _inputDouble('New Salary: ');
        print('✅ Updated');
        break;
      case '2':
        staff.email = _input('New Email: ');
        print('✅ Updated');
        break;
      case '3':
        staff.phoneNumber = _input('New Phone: ');
        print('✅ Updated');
        break;
      default:
        return;
    }
    staffService.updateStaff(staff);
  }

  void _removeStaff() {
    final id = _input('Staff ID: ');
    final staff = staffService.getStaffById(id);
    if (staff == null) return print('❌ Not found');

    print('Remove: ${staff.firstName} ${staff.lastName} (${staff.role.name})');
    if (_confirm('Confirm?')) {
      staffService.removeStaff(id);
      print('✅ Removed');
    }
  }

  void _transferDept() {
    final staff = staffService.getStaffById(_input('Staff ID: '));
    if (staff == null) return print('❌ Not found');

    print('Current Dept: ${staff.department.name}');
    final newDept = _selectEnum(StaffDepartment.values, 'New Dept');
    if (newDept == staff.department) return print('❌ Same dept');

    if (_confirm('Transfer?')) {
      staffService.transferDepartment(staff.id, newDept);
      print('✅ Transferred');
    }
  }

  void _applySalaryIncrease() {
    final dept = _selectEnum(StaffDepartment.values, 'Department');
    final pct = _inputDouble('Increase %: ');
    if (pct <= 0) return print('❌ Must be positive');

    if (_confirm('Apply $pct% to ${dept.name}?')) {
      staffService.applyDepartmentSalaryIncrease(dept, pct);
      print('✅ Applied');
    }
  }

  void _viewByDept() {
    final dept = _selectEnum(StaffDepartment.values, 'Department');
    _displayList(staffService.getByDepartment<Staff>(dept), dept.name);
  }

  // ===== REPORTS =====

  void _showPerformanceReport() {
    final r = medicalStaffService.getPerformanceReport();
    print('\n${'=' * 50}\nMEDICAL PERFORMANCE REPORT\n${'=' * 50}');
    print('Total Medical Staff: ${r['totalMedicalStaff']}');
    print(
        'Doctors: ${r['staffBreakdown']['doctors']} | Nurses: ${r['staffBreakdown']['nurses']}');
    final p = r['performance'];
    print(
        '\nAvg Doctor Consultations: ${p['avgDoctorConsultations'].toStringAsFixed(1)}');
    print('Avg Doctor Shifts: ${p['avgDoctorShifts'].toStringAsFixed(1)}');
    print('Avg Nurse Shifts: ${p['avgNurseShifts'].toStringAsFixed(1)}');
    final w = r['workload'];
    print('\nOverloaded (>10 patients): ${w['overloadedStaff']}');
    print('Underutilized (0 patients): ${w['underutilizedStaff']}');
  }

  void _showDeptStats() {
    final stats = staffService.getDepartmentStatistics();
    print('\n${'=' * 50}\nDEPARTMENT STATISTICS\n${'=' * 50}');
    stats.forEach((dept, data) {
      final d = data as Map<String, dynamic>;
      print(
          '$dept: ${d['totalStaff']} staff, Avg Salary: \$${d['avgSalary'].toStringAsFixed(2)}');
    });
  }

  // ===== HELPERS =====

  void _printHeader(String title) =>
      print('\n${'=' * 50}\n$title\n${'=' * 50}');

  void _printOptions(List<String> options) {
    for (var opt in options) print('  $opt');
  }

  void _displayList(List items, String title) {
    print('\n${'=' * 50}\n$title (${items.length})\n${'=' * 50}');
    if (items.isEmpty) {
      print('📭 No items found');
    } else {
      for (var item in items) print('\n$item\n${'-' * 50}');
    }
  }

  void _showMap(Map<String, dynamic> map, String title) {
    print('\n${'=' * 50}\n$title\n${'=' * 50}');
    map.forEach((k, v) => print('$k: $v'));
  }

  T _selectEnum<T>(List<T> values, String label) {
    print('\nSelect $label:');
    for (var i = 0; i < values.length; i++) {
      print('${i + 1}. ${values[i].toString().split('.').last}');
    }
    return values[_inputInt('➤: ') - 1];
  }

  String _input(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync()?.trim() ?? '';
  }

  int _inputInt(String prompt) {
    while (true) {
      try {
        return int.parse(_input(prompt));
      } catch (e) {
        print('❌ Invalid number');
      }
    }
  }

  double _inputDouble(String prompt) {
    while (true) {
      try {
        return double.parse(_input(prompt));
      } catch (e) {
        print('❌ Invalid number');
      }
    }
  }

  DateTime _inputDate(String prompt) {
    while (true) {
      try {
        return DateTime.parse(_input('$prompt(YYYY-MM-DD): '));
      } catch (e) {
        print('❌ Invalid date');
      }
    }
  }

  bool _confirm(String msg) => _input('$msg (yes/no): ').toLowerCase() == 'yes';

  void _pause() {
    print('\n${'=' * 50}\nPress Enter...');
    stdin.readLineSync();
  }
}
