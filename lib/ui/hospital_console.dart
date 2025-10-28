import 'dart:io';
import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '/data/repository/nurse_repository.dart';
import '/data/repository/doctor_repository.dart';
import '/data/repository/administrative_staff_repository.dart';

/// Simplified Console UI for Hospital Management System
class HospitalConsole {
  final NurseRepository nurseRepository;
  final DoctorRepository doctorRepository;
  final AdministrativeStaffRepository adminRepository;

  HospitalConsole({
    required this.nurseRepository,
    required this.doctorRepository,
    required this.adminRepository,
  });

  /// Start the hospital management system
  void start() {
    print('\n╔═══════════════════════════════════════════════════╗');
    print('║   HOSPITAL MANAGEMENT SYSTEM - STAFF MANAGER      ║');
    print('╚═══════════════════════════════════════════════════╝\n');

    // Load all data
    nurseRepository.loadNurses();
    doctorRepository.loadDoctors();
    adminRepository.loadAdministrativeStaff();

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
    print('│   SELECT STAFF TYPE        │');
    print('├────────────────────────────┤');
    print('│ 1. 👨‍⚕️  Doctor              │');
    print('│ 2. 👩‍⚕️  Nurse               │');
    print('│ 3. 📋 Admin Staff          │');
    print('└────────────────────────────┘');

    final choice = getUserInput('\n➤ Enter choice: ');

    try {
      switch (choice) {
        case '1':
          addDoctor();
          break;
        case '2':
          addNurse();
          break;
        case '3':
          addAdministrativeStaff();
          break;
        default:
          print('\n❌ Invalid choice.');
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
    final department = getUserInput('Department: ');

    // Specialization
    print('\n🏥 Specializations:');
    for (var i = 0; i < Specialization.values.length; i++) {
      final spec = Specialization.values[i].toString().split('.').last;
      print('${i + 1}. $spec');
    }
    final specIndex =
        getIntInput('Select (1-${Specialization.values.length}): ') - 1;
    final specialization = Specialization.values[specIndex];

    // Shift
    print('\n⏰ Shift Types:');
    print('1. day (7 AM - 7 PM)');
    print('2. night (7 PM - 7 AM, +20% pay)');
    final shiftIndex = getIntInput('Select (1-2): ') - 1;
    final shift = ShiftType.values[shiftIndex];

    // Create doctor with default salary (5000 as per your design)
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
      specialization: specialization,
      currentShift: shift,
      // salary defaults to 5000 in constructor
    );

    doctorRepository.addDoctor(doctor);
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
    final department = getUserInput('Department: ');

    // Specialization
    print('\n🩺 Nurse Specializations:');
    for (var i = 0; i < NurseSpecialization.values.length; i++) {
      final spec = NurseSpecialization.values[i].toString().split('.').last;
      print('${i + 1}. $spec');
    }
    final specIndex =
        getIntInput('Select (1-${NurseSpecialization.values.length}): ') - 1;
    final specialization = NurseSpecialization.values[specIndex];

    // Shift
    print('\n⏰ Shift Types:');
    print('1. day (7 AM - 7 PM)');
    print('2. night (7 PM - 7 AM, +20% pay)');
    final shiftIndex = getIntInput('Select (1-2): ') - 1;
    final shift = ShiftType.values[shiftIndex];

    // Create nurse with default salary (400 as per your design)
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
      specialization: specialization,
      currentShift: shift,
      // salary defaults to 400 in constructor
    );

    nurseRepository.addNurse(nurse);
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
    final department = getUserInput('Department: ');
    final salary = getDoubleInput('Salary: ');

    // Position
    print('\n💼 Administrative Positions:');
    for (var i = 0; i < AdministrativePosition.values.length; i++) {
      final pos = AdministrativePosition.values[i].toString().split('.').last;
      print('${i + 1}. $pos');
    }
    final posIndex =
        getIntInput('Select (1-${AdministrativePosition.values.length}): ') - 1;
    final position = AdministrativePosition.values[posIndex];

    // Admin staff always works day shift (as per your design)
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
      // currentShift defaults to ShiftType.day in constructor
    );

    adminRepository.addAdministrativeStaff(admin);
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
        staff.salary = newSalary;
        updateStaffInRepository(staff);
        print('\n✅ Salary updated!');
        break;
      case '2':
        final newEmail = getUserInput('New email: ');
        staff.email = newEmail;
        updateStaffInRepository(staff);
        print('\n✅ Email updated!');
        break;
      case '3':
        final newPhone = getUserInput('New phone: ');
        staff.phoneNumber = newPhone;
        updateStaffInRepository(staff);
        print('\n✅ Phone number updated!');
        break;
      case '4':
        if (staff is Doctor) {
          staff.recordConsultation();
          updateStaffInRepository(staff);
          print(
              '\n✅ Consultation recorded! Total: ${staff.consultationsThisMonth}');
        } else if (staff is Nurse) {
          staff.recordShift();
          updateStaffInRepository(staff);
          print('\n✅ Shift recorded! Total: ${staff.shiftsThisMonth}');
        }
        break;
      case '5':
        if (staff is Doctor) {
          final rating = getDoubleInput('New rating (0-5): ');
          staff.updateRating(rating);
          updateStaffInRepository(staff);
          print('\n✅ Rating updated!');
        } else if (staff is Nurse) {
          final rating = getDoubleInput('New rating (0-5): ');
          staff.updatePerformanceRating(rating);
          updateStaffInRepository(staff);
          print('\n✅ Rating updated!');
        }
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
    print('Name: ${staff.fullName}');
    print('Role: ${staff.getRole()}');
    print('Department: ${staff.department}');

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
    final doctors = doctorRepository.getAllDoctors();
    final nurses = nurseRepository.getAllNurses();
    final admin = adminRepository.getAllAdministrativeStaff();

    final totalSalary =
        allStaff.fold<double>(0, (sum, s) => sum + s.computeSalary());
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
    final deptMap = <String, int>{};
    for (var staff in allStaff) {
      deptMap[staff.department] = (deptMap[staff.department] ?? 0) + 1;
    }

    deptMap.forEach((dept, count) {
      print('   • $dept: $count');
    });
    print('');
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  List<Staff> getAllStaff() {
    return [
      ...doctorRepository.getAllDoctors(),
      ...nurseRepository.getAllNurses(),
      ...adminRepository.getAllAdministrativeStaff(),
    ];
  }

  void saveAllData() {
    doctorRepository.saveDoctors();
    nurseRepository.saveNurses();
    adminRepository.saveAdministrativeStaff();
  }

  Staff? getStaffById(String id) {
    return doctorRepository.getDoctorById(id) ??
        nurseRepository.getNurseById(id) ??
        adminRepository.getAdministrativeStaffById(id);
  }

  List<Staff> searchStaffByName(String query) {
    return [
      ...doctorRepository.searchDoctorsByName(query),
      ...nurseRepository.searchNursesByName(query),
      ...adminRepository.searchAdministrativeStaffByName(query),
    ];
  }

  void updateStaffInRepository(Staff staff) {
    if (staff is Doctor) {
      doctorRepository.updateDoctor(staff);
    } else if (staff is Nurse) {
      nurseRepository.updateNurse(staff);
    } else if (staff is AdministrativeStaff) {
      adminRepository.updateAdministrativeStaff(staff);
    }
  }

  void removeStaffFromRepository(String id) {
    try {
      doctorRepository.removeDoctor(id);
      return;
    } catch (_) {}

    try {
      nurseRepository.removeNurse(id);
      return;
    } catch (_) {}

    try {
      adminRepository.removeAdministrativeStaff(id);
    } catch (_) {}
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
}
