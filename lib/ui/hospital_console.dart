import 'dart:io';
import '../domain/staff.dart';
import '../domain/doctor.dart';
import '../domain/nurse.dart';
import '../domain/administrative_staff.dart';
import '../data/nurse_repository.dart';
import '../data/doctor_repository.dart';
import '../data/administrative_staff_repository.dart';

/// Console-based UI for Hospital Management System
class HospitalConsole {
  final NurseRepository nurseRepository;
  final DoctorRepository doctorRepository;
  final AdministrativeStaffRepository adminRepository;
  
  HospitalConsole({
    required this.nurseRepository,
    required this.doctorRepository,
    required this.adminRepository,
  });

  /// Helper method to get all staff from all repositories
  List<Staff> getAllStaff() {
    return [
      ...doctorRepository.getAllDoctors(),
      ...nurseRepository.getAllNurses(),
      ...adminRepository.getAllAdministrativeStaff(),
    ];
  }

  /// Helper method to save all data
  void saveAllData() {
    nurseRepository.saveNurses();
    doctorRepository.saveDoctors();
    adminRepository.saveAdministrativeStaff();
  }

  /// Helper method to get staff by ID from any repository
  Staff? getStaffById(String id) {
    return doctorRepository.getDoctorById(id) ??
           nurseRepository.getNurseById(id) ??
           adminRepository.getAdministrativeStaffById(id);
  }

  /// Helper method to search staff by name across all repositories
  List<Staff> searchStaffByName(String query) {
    return [
      ...doctorRepository.searchDoctorsByName(query),
      ...nurseRepository.searchNursesByName(query),
      ...adminRepository.searchAdministrativeStaffByName(query),
    ];
  }

  /// Helper method to get staff by department across all repositories
  List<Staff> getStaffByDepartment(String department) {
    return [
      ...doctorRepository.getDoctorsByDepartment(department),
      ...nurseRepository.getNursesByDepartment(department),
      ...adminRepository.getAdministrativeStaffByDepartment(department),
    ];
  }

  /// Helper method to update staff in appropriate repository
  void updateStaffInRepository(Staff staff) {
    if (staff is Doctor) {
      doctorRepository.updateDoctor(staff);
    } else if (staff is Nurse) {
      nurseRepository.updateNurse(staff);
    } else if (staff is AdministrativeStaff) {
      adminRepository.updateAdministrativeStaff(staff);
    }
  }

  /// Helper method to remove staff from appropriate repository
  void removeStaffFromRepository(String id) {
    try {
      doctorRepository.removeDoctor(id);
    } catch (e) {
      try {
        nurseRepository.removeNurse(id);
      } catch (e) {
        adminRepository.removeAdministrativeStaff(id);
      }
    }
  }

  /// Start the hospital management system
  void start() {
    print('\n╔════════════════════════════════════════════════════════╗');
    print('║     HOSPITAL MANAGEMENT SYSTEM - STAFF MANAGEMENT      ║');
    print('╚════════════════════════════════════════════════════════╝\n');
    
    // Load staff data from all repositories
    nurseRepository.loadNurses();
    doctorRepository.loadDoctors();
    adminRepository.loadAdministrativeStaff();
    
    while (true) {
      displayMainMenu();
      final choice = getUserInput('\nEnter your choice: ');
      
      if (choice == '0') {
        print('\n👋 Thank you for using Hospital Management System!');
        print('Goodbye!\n');
        exit(0);
      }
      
      handleMenuChoice(choice);
    }
  }

  /// Display main menu
  void displayMainMenu() {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('                      MAIN MENU                          ');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('1.  👥 View All Staff');
    print('2.  🔍 Search Staff');
    print('3.  ➕ Add New Staff');
    print('4.  ✏️  Update Staff');
    print('5.  ❌ Remove Staff');
    print('6.  👨‍⚕️  Manage Doctors');
    print('7.  👩‍⚕️  Manage Nurses');
    print('8.  📋 Manage Administrative Staff');
    print('9.  📊 View Statistics');
    print('10. 🏆 View Top Performers');
    print('11. 🎂 Upcoming Anniversaries');
    print('12. 💾 Save Data');
    print('0.  🚪 Exit');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
        manageDoctors();
        break;
      case '7':
        manageNurses();
        break;
      case '8':
        manageAdministrativeStaff();
        break;
      case '9':
        viewStatistics();
        break;
      case '10':
        viewTopPerformers();
        break;
      case '11':
        viewUpcomingAnniversaries();
        break;
      case '12':
        saveAllData();
        print('\n✅ Data saved successfully!');
        break;
      default:
        print('\n❌ Invalid choice. Please try again.');
    }
    
    pauseScreen();
  }

  /// View all staff
  void viewAllStaff() {
    final staff = getAllStaff();
    
    if (staff.isEmpty) {
      print('\n📭 No staff members found.');
      return;
    }
    
    print('\n═══════════════════════════════════════════════════════════');
    print('              ALL STAFF MEMBERS (${staff.length})');
    print('═══════════════════════════════════════════════════════════');
    
    for (var s in staff) {
      print('\n${s.toString()}');
      print('   Department: ${s.department}');
      print('   Status: ${s.isActive ? "✅ Active" : "⛔ Inactive"}');
      print('   Salary: \$${s.salary.toStringAsFixed(2)}');
    }
  }

  /// Search staff
  void searchStaff() {
    print('\n┌─────────────────────────────────────┐');
    print('│         STAFF SEARCH MENU           │');
    print('├─────────────────────────────────────┤');
    print('│ 1. Search by Name                   │');
    print('│ 2. Search by ID                     │');
    print('│ 3. Search by Department             │');
    print('│ 4. View by Role Type                │');
    print('└─────────────────────────────────────┘');
    
    final choice = getUserInput('\nEnter your choice: ');
    
    switch (choice) {
      case '1':
        final query = getUserInput('\nEnter name to search: ');
        final results = searchStaffByName(query);
        displaySearchResults(results);
        break;
      case '2':
        final id = getUserInput('\nEnter staff ID: ');
        final staff = getStaffById(id);
        if (staff != null) {
          print('\n$staff');
        } else {
          print('\n❌ Staff member with ID "$id" not found.');
        }
        break;
      case '3':
        final dept = getUserInput('\nEnter department name: ');
        final results = getStaffByDepartment(dept);
        displaySearchResults(results);
        break;
      case '4':
        viewByRoleType();
        break;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// Display search results
  void displaySearchResults(List<Staff> results) {
    if (results.isEmpty) {
      print('\n📭 No results found.');
      return;
    }
    
    print('\n═══════════════════════════════════════════════════════════');
    print('              SEARCH RESULTS (${results.length})');
    print('═══════════════════════════════════════════════════════════');
    
    for (var staff in results) {
      print('\n${staff.toString()}');
      print('─' * 60);
    }
  }

  /// View by role type
  void viewByRoleType() {
    print('\n┌──────────────────────┐');
    print('│ 1. Doctors           │');
    print('│ 2. Nurses            │');
    print('│ 3. Administrative    │');
    print('└──────────────────────┘');
    
    final choice = getUserInput('\nSelect role type: ');
    List<Staff> results = [];
    
    switch (choice) {
      case '1':
        results = doctorRepository.getAllDoctors();
        break;
      case '2':
        results = nurseRepository.getAllNurses();
        break;
      case '3':
        results = adminRepository.getAllAdministrativeStaff();
        break;
      default:
        print('\n❌ Invalid choice.');
        return;
    }
    
    displaySearchResults(results);
  }

  /// Add new staff
  void addNewStaff() {
    print('\n┌──────────────────────────────┐');
    print('│    SELECT STAFF TYPE         │');
    print('├──────────────────────────────┤');
    print('│ 1. Doctor                    │');
    print('│ 2. Nurse                     │');
    print('│ 3. Administrative Staff      │');
    print('└──────────────────────────────┘');
    
    final choice = getUserInput('\nEnter your choice: ');
    
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
      print('\n❌ Error adding staff: $e');
    }
  }

  /// Add doctor
  void addDoctor() {
    print('\n═══════════════════════════════════════');
    print('           ADD NEW DOCTOR              ');
    print('═══════════════════════════════════════');
    
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone Number: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final department = getUserInput('Department: ');
    final salary = getDoubleInput('Salary: ');
    final licenseNumber = getUserInput('License Number: ');
    
    print('\nSpecializations:');
    for (var i = 0; i < Specialization.values.length; i++) {
      print('${i + 1}. ${Specialization.values[i].toString().split('.').last}');
    }
    final specIndex = getIntInput('Select specialization (1-${Specialization.values.length}): ') - 1;
    final specialization = Specialization.values[specIndex];
    
    print('\nShift Types:');
    for (var i = 0; i < ShiftType.values.length; i++) {
      print('${i + 1}. ${ShiftType.values[i].toString().split('.').last}');
    }
    final shiftIndex = getIntInput('Select shift (1-${ShiftType.values.length}): ') - 1;
    final shift = ShiftType.values[shiftIndex];
    
    final doctor = Doctor(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      pastYearsOfExperience: 0,
      hireDate: hireDate,
      department: department,
      salary: salary,
      specialization: specialization,
      currentShift: shift,
      licenseNumber: licenseNumber,
    );
    
    doctorRepository.addDoctor(doctor);
    print('\n✅ Doctor added successfully!');
  }

  /// Add nurse
  void addNurse() {
    print('\n═══════════════════════════════════════');
    print('           ADD NEW NURSE               ');
    print('═══════════════════════════════════════');
    
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone Number: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final department = getUserInput('Department: ');
    final salary = getDoubleInput('Salary: ');
    final licenseNumber = getUserInput('License Number: ');
    
    print('\nNurse Specializations:');
    for (var i = 0; i < NurseSpecialization.values.length; i++) {
      print('${i + 1}. ${NurseSpecialization.values[i].toString().split('.').last}');
    }
    final specIndex = getIntInput('Select specialization (1-${NurseSpecialization.values.length}): ') - 1;
    final specialization = NurseSpecialization.values[specIndex];
    
    print('\nShift Types:');
    for (var i = 0; i < ShiftType.values.length; i++) {
      print('${i + 1}. ${ShiftType.values[i].toString().split('.').last}');
    }
    final shiftIndex = getIntInput('Select shift (1-${ShiftType.values.length}): ') - 1;
    final shift = ShiftType.values[shiftIndex];
    
    final nurse = Nurse(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      pastYearsOfExperience: 0,
      hireDate: hireDate,
      department: department,
      salary: salary,
      specialization: specialization,
      licenseNumber: licenseNumber,
      currentShift: shift,
    );
    
    nurseRepository.addNurse(nurse);
    print('\n✅ Nurse added successfully!');
  }

  /// Add administrative staff
  void addAdministrativeStaff() {
    print('\n═══════════════════════════════════════');
    print('      ADD NEW ADMINISTRATIVE STAFF     ');
    print('═══════════════════════════════════════');
    
    final id = getUserInput('ID: ');
    final firstName = getUserInput('First Name: ');
    final lastName = getUserInput('Last Name: ');
    final email = getUserInput('Email: ');
    final phone = getUserInput('Phone Number: ');
    final dob = getDateInput('Date of Birth (YYYY-MM-DD): ');
    final hireDate = getDateInput('Hire Date (YYYY-MM-DD): ');
    final department = getUserInput('Department: ');
    final salary = getDoubleInput('Salary: ');
    final officeLocation = getUserInput('Office Location: ');
    
    print('\nAdministrative Positions:');
    for (var i = 0; i < AdministrativePosition.values.length; i++) {
      print('${i + 1}. ${AdministrativePosition.values[i].toString().split('.').last}');
    }
    final posIndex = getIntInput('Select position (1-${AdministrativePosition.values.length}): ') - 1;
    final position = AdministrativePosition.values[posIndex];
    
    final admin = AdministrativeStaff(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      pastYearsOfExperience: 0,
      hireDate: hireDate,
      department: department,
      salary: salary,
      licenseNumber: '',
      position: position,
      officeLocation: officeLocation,
    );
    
    adminRepository.addAdministrativeStaff(admin);
    print('\n✅ Administrative staff added successfully!');
  }

  /// Update staff
  void updateStaff() {
    final id = getUserInput('\nEnter staff ID to update: ');
    final staff = getStaffById(id);
    
    if (staff == null) {
      print('\n❌ Staff member not found.');
      return;
    }

    print('\n${staff.toString()}');

    print('\n┌──────────────────────────────┐');
    print('│      UPDATE OPTIONS          │');
    print('├──────────────────────────────┤');
    print('│ 1. Update Salary             │');
    print('│ 2. Activate/Deactivate       │');
    print('│ 3. Update Email              │');
    print('│ 4. Update Phone              │');
    print('└──────────────────────────────┘');
    
    final choice = getUserInput('\nSelect option: ');
    
    switch (choice) {
      case '1':
        final newSalary = getDoubleInput('Enter new salary: ');
        staff.salary = newSalary;
        updateStaffInRepository(staff);
        print('\n✅ Salary updated successfully!');
        break;
      case '2':
        if (staff.isActive) {
          staff.deactivate();
          print('\n✅ Staff deactivated.');
        } else {
          staff.activate();
          print('\n✅ Staff activated.');
        }
        updateStaffInRepository(staff);
        break;
      default:
        print('\n❌ Invalid option.');
    }
  }

  /// Remove staff
  void removeStaff() {
    final id = getUserInput('\nEnter staff ID to remove: ');
    final staff = getStaffById(id);
    
    if (staff == null) {
      print('\n❌ Staff member not found.');
      return;
    }
    
    print('\n${staff.toString()}');
    final confirm = getUserInput('Are you sure you want to remove this staff member? (yes/no): ');
    
    if (confirm.toLowerCase() == 'yes') {
      removeStaffFromRepository(id);
      print('\n✅ Staff member removed successfully!');
    } else {
      print('\n❌ Operation cancelled.');
    }
  }

  /// Manage doctors
  void manageDoctors() {
    print('\n┌──────────────────────────────────────┐');
    print('│        DOCTOR MANAGEMENT             │');
    print('├──────────────────────────────────────┤');
    print('│ 1. View All Doctors                  │');
    print('│ 2. View by Specialization            │');
    print('│ 3. Assign Patient to Doctor          │');
    print('│ 4. Record Consultation               │');
    print('│ 5. Update Patient Rating             │');
    print('└──────────────────────────────────────┘');
    
    final choice = getUserInput('\nEnter your choice: ');
    
    switch (choice) {
      case '1':
        displaySearchResults(doctorRepository.getAllDoctors());
        break;
      case '2':
        viewDoctorsBySpecialization();
        break;
      case '3':
        assignPatientToDoctor();
        break;
      case '4':
        recordConsultation();
        break;
      case '5':
        updateDoctorRating();
        break;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// View doctors by specialization
  void viewDoctorsBySpecialization() {
    print('\nSpecializations:');
    for (var i = 0; i < Specialization.values.length; i++) {
      print('${i + 1}. ${Specialization.values[i].toString().split('.').last}');
    }
    
    final index = getIntInput('Select specialization: ') - 1;
    if (index < 0 || index >= Specialization.values.length) {
      print('\n❌ Invalid selection.');
      return;
    }
    
    final specialization = Specialization.values[index];
    final doctors = doctorRepository.getDoctorsBySpecialization(specialization);
    displaySearchResults(doctors);
  }

  /// Assign patient to doctor
  void assignPatientToDoctor() {
    final doctorId = getUserInput('\nEnter Doctor ID: ');
    final staff = getStaffById(doctorId);
    
    if (staff is! Doctor) {
      print('\n❌ Doctor not found.');
      return;
    }
    
    final patientId = getUserInput('Enter patient ID: ');
    staff.assignPatient(patientId);
    updateStaffInRepository(staff);
    print('\n✅ Patient assigned successfully!');
  }

  /// Record consultation
  void recordConsultation() {
    final doctorId = getUserInput('Enter doctor ID: ');
    final staff = getStaffById(doctorId);
    
    if (staff is! Doctor) {
      print('\n❌ Doctor not found.');
      return;
    }
    
    staff.recordConsultation();
    updateStaffInRepository(staff);
    print('\n✅ Consultation recorded! Total: ${staff.consultationsThisMonth}');
  }

  /// Update doctor rating
  void updateDoctorRating() {
    final doctorId = getUserInput('Enter doctor ID: ');
    final staff = getStaffById(doctorId);
    
    if (staff is! Doctor) {
      print('\n❌ Doctor not found.');
      return;
    }
    
    final rating = getDoubleInput('Enter new rating (0.0-5.0): ');
    staff.updateRating(rating);
    updateStaffInRepository(staff);
    print('\n✅ Rating updated successfully!');
  }

  /// Manage nurses
  void manageNurses() {
    print('\n┌──────────────────────────────────────┐');
    print('│         NURSE MANAGEMENT             │');
    print('├──────────────────────────────────────┤');
    print('│ 1. View All Nurses                   │');
    print('│ 2. View by Shift                     │');
    print('│ 3. Record Shift                      │');
    print('│ 4. Update Performance Rating         │');
    print('└──────────────────────────────────────┘');
    
    final choice = getUserInput('\nEnter your choice: ');
    
    switch (choice) {
      case '1':
        displaySearchResults(nurseRepository.getAllNurses());
        break;
      case '2':
        viewNursesByShift();
        break;
      case '3':
        recordNurseShift();
        break;
      case '4':
        updateNurseRating();
        break;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// View nurses by shift
  void viewNursesByShift() {
    print('\nShift Types:');
    for (var i = 0; i < ShiftType.values.length; i++) {
      print('${i + 1}. ${ShiftType.values[i].toString().split('.').last}');
    }
    
    final index = getIntInput('Select shift: ') - 1;
    if (index < 0 || index >= ShiftType.values.length) {
      print('\n❌ Invalid selection.');
      return;
    }
    
    final shift = ShiftType.values[index];
    final nurses = nurseRepository.getNursesByShift(shift);
    displaySearchResults(nurses);
  }

  /// Record nurse shift
  void recordNurseShift() {
    final nurseId = getUserInput('Enter nurse ID: ');
    final staff = getStaffById(nurseId);
    
    if (staff is! Nurse) {
      print('\n❌ Nurse not found.');
      return;
    }
    
    staff.recordShift();
    updateStaffInRepository(staff);
    print('\n✅ Shift recorded! Total shifts: ${staff.shiftsThisMonth}');
  }

  /// Update nurse rating
  void updateNurseRating() {
    final nurseId = getUserInput('Enter nurse ID: ');
    final staff = getStaffById(nurseId);
    
    if (staff is! Nurse) {
      print('\n❌ Nurse not found.');
      return;
    }
    
    final rating = getDoubleInput('Enter new rating (0.0-5.0): ');
    staff.updatePerformanceRating(rating);
    updateStaffInRepository(staff);
    print('\n✅ Rating updated successfully!');
  }

  /// Manage administrative staff
  void manageAdministrativeStaff() {
    print('\n┌──────────────────────────────────────┐');
    print('│   ADMINISTRATIVE STAFF MANAGEMENT    │');
    print('├──────────────────────────────────────┤');
    print('│ 1. View All Administrative Staff     │');
    print('│ 2. View by Position                  │');
    print('│ 3. Record Completed Task             │');
    print('│ 4. Update Efficiency Rating          │');
    print('└──────────────────────────────────────┘');
    
    final choice = getUserInput('\nEnter your choice: ');
    
    switch (choice) {
      case '1':
        displaySearchResults(adminRepository.getAllAdministrativeStaff());
        break;
      case '2':
        viewAdminByPosition();
        break;
      case '3':
        recordCompletedTask();
        break;
      case '4':
        updateAdminRating();
        break;
      default:
        print('\n❌ Invalid choice.');
    }
  }

  /// View administrative staff by position
  void viewAdminByPosition() {
    print('\nAdministrative Positions:');
    for (var i = 0; i < AdministrativePosition.values.length; i++) {
      print('${i + 1}. ${AdministrativePosition.values[i].toString().split('.').last}');
    }
    
    final index = getIntInput('Select position: ') - 1;
    if (index < 0 || index >= AdministrativePosition.values.length) {
      print('\n❌ Invalid selection.');
      return;
    }
    
    final position = AdministrativePosition.values[index];
    final staff = adminRepository.getAdministrativeStaffByPosition(position);
    displaySearchResults(staff);
  }

  /// Record completed task
  void recordCompletedTask() {
    final staffId = getUserInput('Enter staff ID: ');
    final staff = getStaffById(staffId);
    
    if (staff is! AdministrativeStaff) {
      print('\n❌ Administrative staff not found.');
      return;
    }
    
    staff.recordCompletedTask();
    updateStaffInRepository(staff);
    print('\n✅ Task recorded! Total tasks: ${staff.tasksCompletedThisMonth}');
  }

  /// Update admin rating
  void updateAdminRating() {
    final staffId = getUserInput('Enter staff ID: ');
    final staff = getStaffById(staffId);
    
    if (staff is! AdministrativeStaff) {
      print('\n❌ Administrative staff not found.');
      return;
    }
    
    final rating = getDoubleInput('Enter new rating (0.0-5.0): ');
    staff.updateEfficiencyRating(rating);
    updateStaffInRepository(staff);
    print('\n✅ Rating updated successfully!');
  }

  /// View statistics
  void viewStatistics() {
    final allStaff = getAllStaff();
    final activeStaff = allStaff.where((s) => s.isActive).length;
    final totalSalaries = allStaff.fold<double>(0, (sum, s) => sum + s.salary);
    
    print('\n╔════════════════════════════════════════════════════════╗');
    print('║              HOSPITAL STAFF STATISTICS                 ║');
    print('╚════════════════════════════════════════════════════════╝');
    print('');
    print('📊 STAFF OVERVIEW:');
    print('   Total Staff: ${allStaff.length}');
    print('   Active Staff: $activeStaff');
    print('   Inactive Staff: ${allStaff.length - activeStaff}');
    print('');
    print('👥 BY ROLE:');
    print('   Doctors: ${doctorRepository.getAllDoctors().length}');
    print('   Nurses: ${nurseRepository.getAllNurses().length}');
    print('   Administrative Staff: ${adminRepository.getAllAdministrativeStaff().length}');
    print('');
    print('💰 FINANCIAL OVERVIEW:');
    print('   Total Salaries: \$${totalSalaries.toStringAsFixed(2)}');
    print('   Average Salary: \$${allStaff.isEmpty ? 0 : (totalSalaries / allStaff.length).toStringAsFixed(2)}');
    print('');
  }

  /// View top performers
  void viewTopPerformers() {
    final limit = getIntInput('How many top performers to display? (default 10): ');
    final allStaff = getAllStaff();
    final sorted = allStaff..sort((a, b) => b.salary.compareTo(a.salary));
    final topPerformers = sorted.take(limit).toList();
    
    print('\n╔════════════════════════════════════════════════════════╗');
    print('║           TOP PERFORMERS (BY SALARY)                   ║');
    print('╚════════════════════════════════════════════════════════╝\n');
    
    for (var i = 0; i < topPerformers.length; i++) {
      final staff = topPerformers[i];
      print('${i + 1}. ${staff.fullName} (${staff.getRole()})');
      print('   Salary: \$${staff.salary.toStringAsFixed(2)}');
      print('   Department: ${staff.department}');
      print('');
    }
  }

  /// View upcoming anniversaries
  void viewUpcomingAnniversaries() {
    final allStaff = getAllStaff();
    final now = DateTime.now();
    final in30Days = now.add(Duration(days: 30));
    
    final anniversaries = allStaff.where((staff) {
      final nextAnniversary = DateTime(
        now.year,
        staff.hireDate.month,
        staff.hireDate.day,
      );
      return nextAnniversary.isAfter(now) && nextAnniversary.isBefore(in30Days);
    }).toList();
    
    if (anniversaries.isEmpty) {
      print('\n📭 No upcoming anniversaries in the next 30 days.');
      return;
    }
    
    print('\n╔════════════════════════════════════════════════════════╗');
    print('║         UPCOMING WORK ANNIVERSARIES (30 DAYS)          ║');
    print('╚════════════════════════════════════════════════════════╝\n');
    
    for (var staff in anniversaries) {
      print('🎂 ${staff.fullName}');
      print('   ${staff.yearsOfService + 1} years - ${staff.department}');
      print('   Hire Date: ${staff.hireDate.toString().split(' ')[0]}');
      print('');
    }
  }

  /// Helper: Get user input
  String getUserInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  /// Helper: Get integer input
  int getIntInput(String prompt) {
    while (true) {
      try {
        return int.parse(getUserInput(prompt));
      } catch (e) {
        print('❌ Invalid number. Please try again.');
      }
    }
  }

  /// Helper: Get double input
  double getDoubleInput(String prompt) {
    while (true) {
      try {
        return double.parse(getUserInput(prompt));
      } catch (e) {
        print('❌ Invalid number. Please try again.');
      }
    }
  }

  /// Helper: Get date input
  DateTime getDateInput(String prompt) {
    while (true) {
      try {
        final input = getUserInput(prompt);
        return DateTime.parse(input);
      } catch (e) {
        print('❌ Invalid date format. Use YYYY-MM-DD.');
      }
    }
  }

  /// Helper: Pause screen
  void pauseScreen() {
    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}
