import 'dart:io';
import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../service/admin_service.dart';

/// Simplified Console UI for Hospital Management System
class HospitalConsole {
  final AdminService adminService;

  HospitalConsole({
    required this.adminService,
  });

  /// Start the hospital management system
  void start() {
    print('\n╔═══════════════════════════════════════════════════╗');
    print('║   HOSPITAL MANAGEMENT SYSTEM - STAFF MANAGER      ║');
    print('╚═══════════════════════════════════════════════════╝\n');

    // Data is already loaded by AdminService constructor

    while (true) {
      displayMainMenu();
      final choice = getUserInput('\n➤ Enter choice: ');

      if (choice == '0') {
        saveAllData();
        print('\n✅ All data saved!');
        print('👋 Thank you for using Hospital Management System!\n');
        exit(0);
      }

      handleMenuChoice(choice);
    }
  }

  /// Display simplified main menu
  void displayMainMenu() {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('              MAIN MENU');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('1. 👥 View All Staff');
    print('2. 🔍 Search Staff by Name');
    print('3. ➕ Add New Staff');
    print('4. ✏️  Update Staff Info');
    print('5. ❌ Remove Staff');
    print('6. 📊 View Statistics');
    print('7. 🎯 Advanced Queries');
    print('8. 💰 Salary Management');
    print('9. 🔄 Department Transfer');
    print('0. 🚪 Save & Exit');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Handle menu choice
  void handleMenuChoice(String choice) {
    switch (choice) {
      case '1':
        viewAllStaff();
        break;
      case '2':
        searchStaff();
        break;
      case '3':
        addNewStaff();
        break;
      case '4':
        updateStaff();
        break;
      case '5':
        removeStaff();
        break;
      case '6':
        viewStatistics();
        break;
      case '7':
        advancedQueries();
        break;
      case '8':
        salaryManagement();
        break;
      case '9':
        departmentTransfer();
        break;
      default:
        print('\n❌ Invalid choice. Please try again.');
    }

    pauseScreen();
  }

  /// View all staff
  void viewAllStaff() {
    final allStaff = getAllStaff();

    if (allStaff.isEmpty) {
      print('\n📭 No staff members found.');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('         ALL STAFF MEMBERS (${allStaff.length} total)');
    print('═══════════════════════════════════════════════════');

    for (var staff in allStaff) {
      print('\n${staff.toString()}');
      print('─' * 50);
    }
  }

  /// Search staff by name
  void searchStaff() {
    final query = getUserInput('\n🔍 Enter name to search: ');

    if (query.trim().isEmpty) {
      print('\n❌ Please enter a valid name.');
      return;
    }

    final results = searchStaffByName(query);

    if (results.isEmpty) {
      print('\n📭 No staff found with name "$query".');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('         SEARCH RESULTS (${results.length} found)');
    print('═══════════════════════════════════════════════════');

    for (var staff in results) {
      print('\n${staff.toString()}');
      print('─' * 50);
    }
  }

  /// Add new staff - simplified version
  void addNewStaff() {
    print('\n┌────────────────────────────┐');
    print('│   SELECT STAFF ROLE        │');
    print('├────────────────────────────┤');

    // Display role options using enum
    for (var i = 0; i < StaffRole.values.length; i++) {
      final role = StaffRole.values[i];
      final icon = i == 0 ? '�‍⚕️' : (i == 1 ? '👩‍⚕️' : '📋');
      final name = role.toString().split('.').last;
      print(
          '│ ${i + 1}. $icon  ${name.substring(0, 1).toUpperCase()}${name.substring(1).padRight(17)}│');
    }

    print('└────────────────────────────┘');

    final roleIndex =
        getIntInput('\n➤ Select role (1-${StaffRole.values.length}): ') - 1;

    if (roleIndex < 0 || roleIndex >= StaffRole.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final selectedRole = StaffRole.values[roleIndex];

    try {
      switch (selectedRole) {
        case StaffRole.DOCTOR:
          addDoctor();
          break;
        case StaffRole.NURSE:
          addNurse();
          break;
        case StaffRole.ADMINISTRATIVE:
          addAdministrativeStaff();
          break;
      }
    } catch (e) {
      print('\n❌ Error: $e');
    }
  }

  /// Add doctor - simplified
  void addDoctor() {
    print('\n═══════════════════════════════════════');
    print('           ADD NEW DOCTOR');
    print('═══════════════════════════════════════');

    // Basic info
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final experience = getIntInput('Years of Experience: ');
    final salary = getDoubleInput('Salary: \$');

    // Department
    print('\n🏢 Departments:');
    for (var i = 0; i < StaffDepartment.values.length; i++) {
      final dept = StaffDepartment.values[i].name;
      print('${i + 1}. $dept');
    }
    final deptIndex =
        getIntInput('Select (1-${StaffDepartment.values.length}): ') - 1;
    final department = StaffDepartment.values[deptIndex];

    // Specialization
    print('\n🏥 Specializations:');
    for (var i = 0; i < Specialization.values.length; i++) {
      final spec = Specialization.values[i].name;
      print('${i + 1}. $spec');
    }
    final specIndex =
        getIntInput('Select (1-${Specialization.values.length}): ') - 1;
    final specialization = Specialization.values[specIndex];

    // Shift
    print('\n⏰ Shift Types:');
    for (var i = 0; i < ShiftType.values.length; i++) {
      final shift = ShiftType.values[i].name;
      print('${i + 1}. $shift');
    }
    final shiftIndex =
        getIntInput('Select (1-${ShiftType.values.length}): ') - 1;
    final shift = ShiftType.values[shiftIndex];

    // Create doctor
    final doctor = Doctor(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      hireDate: hireDate,
      pastYearsOfExperience: experience,
      department: department,
      salary: salary,
      specialization: specialization,
      currentShift: shift,
    );

    adminService.addStaff(doctor);
    print('\n✅ Doctor added successfully!');
    print('💵 Base salary: \$${doctor.salary} (as per default)');
  }

  /// Add nurse - simplified
  void addNurse() {
    print('\n═══════════════════════════════════════');
    print('           ADD NEW NURSE');
    print('═══════════════════════════════════════');

    // Basic info
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final experience = getIntInput('Years of Experience: ');
    final salary = getDoubleInput('Salary: \$');

    // Department
    print('\n🏢 Departments:');
    for (var i = 0; i < StaffDepartment.values.length; i++) {
      final dept = StaffDepartment.values[i].name;
      print('${i + 1}. $dept');
    }
    final deptIndex =
        getIntInput('Select (1-${StaffDepartment.values.length}): ') - 1;
    final department = StaffDepartment.values[deptIndex];

    // Specialization
    print('\n🩺 Nurse Specializations:');
    for (var i = 0; i < NurseSpecialization.values.length; i++) {
      final spec = NurseSpecialization.values[i].name;
      print('${i + 1}. $spec');
    }
    final specIndex =
        getIntInput('Select (1-${NurseSpecialization.values.length}): ') - 1;
    final specialization = NurseSpecialization.values[specIndex];

    // Shift
    print('\n⏰ Shift Types:');
    for (var i = 0; i < ShiftType.values.length; i++) {
      final shift = ShiftType.values[i].name;
      print('${i + 1}. $shift');
    }
    final shiftIndex =
        getIntInput('Select (1-${ShiftType.values.length}): ') - 1;
    final shift = ShiftType.values[shiftIndex];

    // Create nurse
    final nurse = Nurse(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      hireDate: hireDate,
      pastYearsOfExperience: experience,
      department: department,
      salary: salary,
      specialization: specialization,
      currentShift: shift,
    );

    adminService.addStaff(nurse);
    print('\n✅ Nurse added successfully!');
    print('💵 Base salary: \$${nurse.salary} (as per default)');
  }

  /// Add administrative staff - simplified (always day shift)
  void addAdministrativeStaff() {
    print('\n═══════════════════════════════════════');
    print('      ADD NEW ADMIN STAFF');
    print('═══════════════════════════════════════');

    // Basic info
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final experience = getIntInput('Years of Experience: ');
    final salary = getDoubleInput('Salary: \$');

    // Department
    print('\n🏢 Departments:');
    for (var i = 0; i < StaffDepartment.values.length; i++) {
      final dept = StaffDepartment.values[i].name;
      print('${i + 1}. $dept');
    }
    final deptIndex =
        getIntInput('Select (1-${StaffDepartment.values.length}): ') - 1;
    final department = StaffDepartment.values[deptIndex];

    // Position
    print('\n💼 Administrative Positions:');
    for (var i = 0; i < AdministrativePosition.values.length; i++) {
      final pos = AdministrativePosition.values[i].name;
      print('${i + 1}. $pos');
    }
    final posIndex =
        getIntInput('Select (1-${AdministrativePosition.values.length}): ') - 1;
    final position = AdministrativePosition.values[posIndex];

    // Admin staff works day shift by default
    final admin = AdministrativeStaff(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      hireDate: hireDate,
      pastYearsOfExperience: experience,
      department: department,
      salary: salary,
      position: position,
      currentShift: ShiftType.DAY,
    );

    adminService.addStaff(admin);
    print('\n✅ Admin staff added successfully!');
    print('⏰ Shift: Day shift (default for admin staff)');
  }

  /// Update staff - simplified
  void updateStaff() {
    final id = getUserInput('\n🔍 Enter staff ID: ');
    final staff = getStaffById(id);

    if (staff == null) {
      print('\n❌ Staff not found.');
      return;
    }

    print('\n' + staff.toString());

    print('\n┌──────────────────────────┐');
    print('│   UPDATE OPTIONS         │');
    print('├──────────────────────────┤');
    print('│ 1. Salary                │');
    print('│ 2. Email                 │');
    print('│ 3. Phone                 │');

    // Role-specific options
    if (staff is Doctor) {
      print('│ 4. Record Consultation   │');
      print('│ 5. Update Rating         │');
    } else if (staff is Nurse) {
      print('│ 4. Record Shift          │');
      print('│ 5. Update Rating         │');
    }

    print('└──────────────────────────┘');

    final choice = getUserInput('\n➤ Select: ');

    switch (choice) {
      case '1':
        final newSalary = getDoubleInput('New salary: \$');
        try {
          adminService.modify<Staff>(id, (staff) => staff.salary = newSalary);
          print('\n✅ Salary updated!');
        } catch (e) {
          print('\n❌ Error: $e');
        }
        break;
      case '2':
        final newEmail = getUserInput('New email: ');
        try {
          adminService.modify<Staff>(id, (staff) => staff.email = newEmail);
          print('\n✅ Email updated!');
        } catch (e) {
          print('\n❌ Error: $e');
        }
        break;
      case '3':
        final newPhone = getUserInput('New phone: ');
        try {
          adminService.modify<Staff>(
              id, (staff) => staff.phoneNumber = newPhone);
          print('\n✅ Phone number updated!');
        } catch (e) {
          print('\n❌ Error: $e');
        }
        break;
      case '4':
        if (staff is Doctor) {
          try {
            adminService.modify<Doctor>(
                id, (doctor) => doctor.consultationsThisMonth++);
            // Refresh staff data to get updated count
            final updatedDoctor = adminService.getById<Doctor>(id);
            print(
                '\n✅ Consultation recorded! Total: ${updatedDoctor?.consultationsThisMonth ?? 0}');
          } catch (e) {
            print('\n❌ Error: $e');
          }
        } else if (staff is Nurse) {
          try {
            adminService.modify<Nurse>(id, (nurse) => nurse.shiftsThisMonth++);
            // Refresh staff data to get updated count
            final updatedNurse = adminService.getById<Nurse>(id);
            print(
                '\n✅ Shift recorded! Total: ${updatedNurse?.shiftsThisMonth ?? 0}');
          } catch (e) {
            print('\n❌ Error: $e');
          }
        }
        break;
      case '5':
        // Note: patientRating and performanceRating were removed from domain model
        print('\n⚠️  Rating feature removed from system');
        break;
      default:
        print('\n❌ Invalid option.');
    }
  }

  /// Remove staff - simplified
  void removeStaff() {
    final id = getUserInput('\n🔍 Enter staff ID to remove: ');
    final staff = getStaffById(id);

    if (staff == null) {
      print('\n❌ Staff not found.');
      return;
    }

    print('\n📋 Staff to be removed:');
    print('Name: ${staff.firstName} ${staff.lastName}');
    print('Role: ${staff.role.name}');
    print('Department: ${staff.department.name}');

    final confirm = getUserInput('\n⚠️  Confirm removal? (yes/no): ');

    if (confirm.toLowerCase() == 'yes') {
      removeStaffFromRepository(id);
      print('\n✅ Staff removed successfully!');
    } else {
      print('\n❌ Cancelled.');
    }
  }

  /// View statistics - simplified
  void viewStatistics() {
    final allStaff = getAllStaff();
    final doctors = adminService.getAll<Doctor>();
    final nurses = adminService.getAll<Nurse>();
    final admin = adminService.getAll<AdministrativeStaff>();

    final totalSalary = allStaff.fold<double>(0, (sum, s) => sum + s.salary);
    final avgSalary = allStaff.isEmpty ? 0.0 : totalSalary / allStaff.length;

    print('\n╔════════════════════════════════════════════╗');
    print('║       HOSPITAL STAFF STATISTICS            ║');
    print('╚════════════════════════════════════════════╝');
    print('');
    print('📊 STAFF COUNT:');
    print('   Total: ${allStaff.length}');
    print('   • Doctors: ${doctors.length}');
    print('   • Nurses: ${nurses.length}');
    print('   • Admin Staff: ${admin.length}');
    print('');
    print('💰 SALARY OVERVIEW:');
    print('   Total Payroll: \$${totalSalary.toStringAsFixed(2)}');
    print('   Average Salary: \$${avgSalary.toStringAsFixed(2)}');
    print('');
    print('📈 DEPARTMENT BREAKDOWN:');

    // Group by department
    final deptBreakdown = adminService.getDepartmentStatistics();
    final breakdown = deptBreakdown['breakdown'] as Map<String, int>;

    breakdown.forEach((dept, count) {
      print('   • $dept: $count');
    });
    print('');
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  List<Staff> getAllStaff() {
    return adminService.getAll<Staff>();
  }

  void saveAllData() {
    // Services handle saving automatically via repositories
    print('Data is automatically saved after each operation');
  }

  Staff? getStaffById(String id) {
    return adminService.getById<Staff>(id);
  }

  List<Staff> searchStaffByName(String query) {
    return adminService.searchByName(query);
  }

  void updateStaffInRepository(Staff staff) {
    adminService.updateStaff(staff);
  }

  void removeStaffFromRepository(String id) {
    adminService.removeStaff(id);
  }

  String getUserInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  int getIntInput(String prompt) {
    while (true) {
      try {
        return int.parse(getUserInput(prompt));
      } catch (e) {
        print('❌ Invalid number. Try again.');
      }
    }
  }

  double getDoubleInput(String prompt) {
    while (true) {
      try {
        return double.parse(getUserInput(prompt));
      } catch (e) {
        print('❌ Invalid number. Try again.');
      }
    }
  }

  DateTime getDateInput(String prompt) {
    while (true) {
      try {
        return DateTime.parse(getUserInput(prompt));
      } catch (e) {
        print('❌ Invalid date. Use YYYY-MM-DD format.');
      }
    }
  }

  void pauseScreen() {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Press Enter to continue...');
    stdin.readLineSync();
  }

  // ============================================================================
  // NEW ADMIN METHODS
  // ============================================================================

  /// Advanced Queries Menu
  void advancedQueries() {
    print('\n┌─────────────────────────────────┐');
    print('│     ADVANCED QUERIES            │');
    print('├─────────────────────────────────┤');
    print('│ 1. Doctors by Specialization    │');
    print('│ 2. Nurses by Specialization     │');
    print('│ 3. Admin Staff by Position      │');
    print('│ 4. Staff by Department           │');
    print('│ 5. Performance Report            │');
    print('│ 0. Back to Main Menu             │');
    print('└─────────────────────────────────┘');

    final choice = getUserInput('\n➤ Select: ');

    switch (choice) {
      case '1':
        viewDoctorsBySpecialization();
        break;
      case '2':
        viewNursesBySpecialization();
        break;
      case '3':
        viewAdminStaffByPosition();
        break;
      case '4':
        viewStaffByDepartment();
        break;
      case '5':
        viewPerformanceReport();
        break;
      case '0':
        return;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// View doctors by specialization
  void viewDoctorsBySpecialization() {
    print('\n┌────────────────────────────────┐');
    print('│   SELECT SPECIALIZATION        │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var spec in Specialization.values) {
      print('│ ${index++}. ${spec.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > Specialization.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final specialization = Specialization.values[choice - 1];
    final doctors = adminService.getDoctorsBySpecialization(specialization);

    if (doctors.isEmpty) {
      print(
          '\n📭 No doctors found with specialization: ${specialization.name}');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('  DOCTORS - ${specialization.name} (${doctors.length} total)');
    print('═══════════════════════════════════════════════════');

    for (var doctor in doctors) {
      print('\n${doctor.toString()}');
      print('─' * 50);
    }
  }

  /// View nurses by specialization
  void viewNursesBySpecialization() {
    print('\n┌────────────────────────────────┐');
    print('│   SELECT SPECIALIZATION        │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var spec in NurseSpecialization.values) {
      print('│ ${index++}. ${spec.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > NurseSpecialization.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final specialization = NurseSpecialization.values[choice - 1];
    final nurses = adminService.getNursesBySpecialization(specialization);

    if (nurses.isEmpty) {
      print('\n📭 No nurses found with specialization: ${specialization.name}');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('  NURSES - ${specialization.name} (${nurses.length} total)');
    print('═══════════════════════════════════════════════════');

    for (var nurse in nurses) {
      print('\n${nurse.toString()}');
      print('─' * 50);
    }
  }

  /// View admin staff by position
  void viewAdminStaffByPosition() {
    print('\n┌────────────────────────────────┐');
    print('│   SELECT POSITION              │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var pos in AdministrativePosition.values) {
      print('│ ${index++}. ${pos.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > AdministrativePosition.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final position = AdministrativePosition.values[choice - 1];
    final staff = adminService.getAdminStaffByPosition(position);

    if (staff.isEmpty) {
      print(
          '\n📭 No administrative staff found with position: ${position.name}');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('  ADMIN STAFF - ${position.name} (${staff.length} total)');
    print('═══════════════════════════════════════════════════');

    for (var s in staff) {
      print('\n${s.toString()}');
      print('─' * 50);
    }
  }

  /// View staff by department
  void viewStaffByDepartment() {
    print('\n┌────────────────────────────────┐');
    print('│   SELECT DEPARTMENT            │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var dept in StaffDepartment.values) {
      print('│ ${index++}. ${dept.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > StaffDepartment.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final department = StaffDepartment.values[choice - 1];
    final staff = adminService.getByDepartment<Staff>(department);

    if (staff.isEmpty) {
      print('\n📭 No staff found in department: ${department.name}');
      return;
    }

    print('\n═══════════════════════════════════════════════════');
    print('  DEPARTMENT - ${department.name} (${staff.length} total)');
    print('═══════════════════════════════════════════════════');

    for (var s in staff) {
      print('\n${s.toString()}');
      print('─' * 50);
    }
  }

  /// View performance report
  void viewPerformanceReport() {
    final report = adminService.getPerformanceReport();

    print('\n╔═══════════════════════════════════════════════════╗');
    print('║          HOSPITAL PERFORMANCE REPORT              ║');
    print('╚═══════════════════════════════════════════════════╝');

    print('\n📊 OVERALL STATISTICS:');
    print('─' * 50);
    print('Total Staff: ${report['totalStaff']}');
    print('Doctors: ${report['doctors']}');
    print('Nurses: ${report['nurses']}');
    print('Administrative Staff: ${report['administrativeStaff']}');

    print('\n📈 PERFORMANCE METRICS:');
    print('─' * 50);
    print(
        'Avg Doctor Consultations/Month: ${(report['avgDoctorConsultations'] as double).toStringAsFixed(1)}');
    print(
        'Avg Medical Staff Shifts/Month: ${(report['avgMedicalStaffShifts'] as double).toStringAsFixed(1)}');
    print('Overloaded Staff (>10 patients): ${report['overloadedStaff']}');

    print('\n🏥 DEPARTMENT BREAKDOWN:');
    print('─' * 50);
    final breakdown = report['departmentBreakdown'] as Map<String, dynamic>;
    breakdown.forEach((dept, count) {
      print('${dept.padRight(30)}: $count staff');
    });
  }

  /// Salary Management Menu
  void salaryManagement() {
    print('\n┌─────────────────────────────────┐');
    print('│     SALARY MANAGEMENT           │');
    print('├─────────────────────────────────┤');
    print('│ 1. Bulk Salary Increase (All)   │');
    print('│ 2. Department Salary Increase   │');
    print('│ 0. Back to Main Menu             │');
    print('└─────────────────────────────────┘');

    final choice = getUserInput('\n➤ Select: ');

    switch (choice) {
      case '1':
        applyBulkSalaryIncrease();
        break;
      case '2':
        applyDepartmentSalaryIncrease();
        break;
      case '0':
        return;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// Apply bulk salary increase to all staff
  void applyBulkSalaryIncrease() {
    final percentage =
        getDoubleInput('\n💰 Enter salary increase percentage: ');

    if (percentage <= 0) {
      print('\n❌ Percentage must be positive.');
      return;
    }

    final confirm = getUserInput(
        '\n⚠️  Apply ${percentage}% increase to ALL staff? (yes/no): ');

    if (confirm.toLowerCase() == 'yes') {
      try {
        adminService.applyBulkSalaryIncrease(percentage);
        print(
            '\n✅ Bulk salary increase of ${percentage}% applied to all staff!');
      } catch (e) {
        print('\n❌ Error: $e');
      }
    } else {
      print('\n❌ Cancelled.');
    }
  }

  /// Apply department salary increase
  void applyDepartmentSalaryIncrease() {
    print('\n┌────────────────────────────────┐');
    print('│   SELECT DEPARTMENT            │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var dept in StaffDepartment.values) {
      print('│ ${index++}. ${dept.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > StaffDepartment.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final department = StaffDepartment.values[choice - 1];
    final percentage =
        getDoubleInput('\n💰 Enter salary increase percentage: ');

    if (percentage <= 0) {
      print('\n❌ Percentage must be positive.');
      return;
    }

    final confirm = getUserInput(
        '\n⚠️  Apply ${percentage}% increase to ${department.name} staff? (yes/no): ');

    if (confirm.toLowerCase() == 'yes') {
      try {
        adminService.applyDepartmentSalaryIncrease(department, percentage);
        print(
            '\n✅ Salary increase of ${percentage}% applied to ${department.name} staff!');
      } catch (e) {
        print('\n❌ Error: $e');
      }
    } else {
      print('\n❌ Cancelled.');
    }
  }

  /// Department Transfer
  void departmentTransfer() {
    final id = getUserInput('\n🔍 Enter staff ID to transfer: ');
    final staff = getStaffById(id);

    if (staff == null) {
      print('\n❌ Staff not found.');
      return;
    }

    print('\n📋 Staff Information:');
    print('Name: ${staff.firstName} ${staff.lastName}');
    print('Current Department: ${staff.department.name}');

    print('\n┌────────────────────────────────┐');
    print('│   SELECT NEW DEPARTMENT        │');
    print('├────────────────────────────────┤');
    int index = 1;
    for (var dept in StaffDepartment.values) {
      print('│ ${index++}. ${dept.name.padRight(26)} │');
    }
    print('└────────────────────────────────┘');

    final choice = getIntInput('\n➤ Select: ');
    if (choice < 1 || choice > StaffDepartment.values.length) {
      print('\n❌ Invalid choice.');
      return;
    }

    final newDepartment = StaffDepartment.values[choice - 1];

    if (newDepartment == staff.department) {
      print('\n❌ Staff is already in ${newDepartment.name}.');
      return;
    }

    final confirm = getUserInput(
        '\n⚠️  Transfer ${staff.firstName} ${staff.lastName} from ${staff.department.name} to ${newDepartment.name}? (yes/no): ');

    if (confirm.toLowerCase() == 'yes') {
      try {
        adminService.transferDepartment(id, newDepartment);
        print('\n✅ Successfully transferred to ${newDepartment.name}!');
      } catch (e) {
        print('\n❌ Error: $e');
      }
    } else {
      print('\n❌ Cancelled.');
    }
  }
}
