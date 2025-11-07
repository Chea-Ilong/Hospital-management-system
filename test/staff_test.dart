import 'dart:io';
import 'package:test/test.dart';
import '../lib/domain/administrative_staff.dart';
import '../lib/domain/doctor.dart';
import '../lib/domain/nurse.dart';
import '../lib/domain/staff.dart';
import '../lib/service/staff_service.dart';
import '../lib/service/medical_staff_service.dart';

void main() {
  group('Hospital Staff Management System Tests', () {
    late StaffService staffService;
    late MedicalStaffService medicalStaffService;
    final adminBackupPath = 'lib/data/storage/admin_staff_data_backup.json';
    final doctorsBackupPath = 'lib/data/storage/doctors_data_backup.json';
    final nursesBackupPath = 'lib/data/storage/nurses_data_backup.json';

    setUpAll(() {

      final adminFile = File('lib/data/storage/admin_staff_data.json');
      final doctorsFile = File('lib/data/storage/doctors_data.json');
      final nursesFile = File('lib/data/storage/nurses_data.json');

      if (adminFile.existsSync()) adminFile.copySync(adminBackupPath);
      if (doctorsFile.existsSync()) doctorsFile.copySync(doctorsBackupPath);
      if (nursesFile.existsSync()) nursesFile.copySync(nursesBackupPath);
    });

    setUp(() {
      staffService = StaffService();
      medicalStaffService = MedicalStaffService(staffService);
    });

    tearDownAll(() {

      final adminBackup = File(adminBackupPath);
      final doctorsBackup = File(doctorsBackupPath);
      final nursesBackup = File(nursesBackupPath);

      if (adminBackup.existsSync()) {
        adminBackup.copySync('lib/data/storage/admin_staff_data.json');
        adminBackup.deleteSync();
      }
      if (doctorsBackup.existsSync()) {
        doctorsBackup.copySync('lib/data/storage/doctors_data.json');
        doctorsBackup.deleteSync();
      }
      if (nursesBackup.existsSync()) {
        nursesBackup.copySync('lib/data/storage/nurses_data.json');
        nursesBackup.deleteSync();
      }

      print('\n✅ Test data reset to original state');
    });

    test('1. Get Staff by ID - Retrieve specific staff member', () {
      final allStaff = staffService.allStaff;
      expect(allStaff.isNotEmpty, true);
      final targetStaff = allStaff.first;

      final retrievedStaff = staffService.getStaffById(targetStaff.id);

      expect(retrievedStaff, isNotNull);
      expect(retrievedStaff?.id, targetStaff.id);
      expect(retrievedStaff?.firstName, targetStaff.firstName);
      expect(retrievedStaff?.email, targetStaff.email);
    });

    test('2. Add Staff - Create and add new administrative staff', () {
      final newAdmin = AdministrativeStaff(
        id: 'TEST_ADMIN_001',
        firstName: 'Test',
        lastName: 'Admin',
        email: 'test.admin@hospital.com',
        phoneNumber: '555-0100',
        dateOfBirth: DateTime(1990, 1, 1),
        hireDate: DateTime.now(),
        pastYearsOfExperience: 5,
        salary: 55000.0,
        department: StaffDepartment.ADMINISTRATION,
        position: AdministrativePosition.HR,
        currentShift: ShiftType.DAY,
      );
      final initialCount =
          staffService.allStaff.whereType<AdministrativeStaff>().length;

      staffService.addStaff(newAdmin);

      final afterCount =
          staffService.allStaff.whereType<AdministrativeStaff>().length;
      expect(afterCount, initialCount + 1);
      expect(staffService.getStaffById('TEST_ADMIN_001'), isNotNull);

      staffService.removeStaff('TEST_ADMIN_001');
    });

    test('3. Update Staff - Modify existing staff salary', () {
      final admins =
          staffService.allStaff.whereType<AdministrativeStaff>().toList();
      expect(admins.isNotEmpty, true);
      final testAdmin = admins.first;
      final originalSalary = testAdmin.salary;
      final newSalary = originalSalary + 5000.0;

      testAdmin.salary = newSalary;
      staffService.updateStaff(testAdmin);

      final updatedAdmin = staffService.getStaffById(testAdmin.id);
      expect(updatedAdmin?.salary, newSalary);

      testAdmin.salary = originalSalary;
      staffService.updateStaff(testAdmin);
    });

    test('4. Remove Staff - Delete staff member from system', () {
      final newStaff = AdministrativeStaff(
        id: 'TEMP_001',
        firstName: 'Temp',
        lastName: 'Staff',
        email: 'temp@hospital.com',
        phoneNumber: '555-9999',
        dateOfBirth: DateTime(1995, 1, 1),
        hireDate: DateTime.now(),
        pastYearsOfExperience: 2,
        salary: 40000.0,
        department: StaffDepartment.RECEPTION,
        position: AdministrativePosition.RECEPTIONIST,
        currentShift: ShiftType.DAY,
      );
      staffService.addStaff(newStaff);
      final beforeCount = staffService.allStaff.length;

      staffService.removeStaff('TEMP_001');

      final afterCount = staffService.allStaff.length;
      expect(afterCount, beforeCount - 1);
      expect(staffService.getStaffById('TEMP_001'), isNull);
    });

    test('5. Search Staff - Find staff by partial name match', () {
      final allStaff = staffService.allStaff;
      expect(allStaff.isNotEmpty, true);
      final targetStaff = allStaff.first;
      final searchQuery = targetStaff.firstName.substring(0, 3);

      final results = staffService.searchStaffByName(searchQuery);

      expect(results, isNotEmpty);
      expect(results.any((s) => s.id == targetStaff.id), true);
    });

    test('6. Get By Department - Retrieve all staff in specific department',
        () {
      final targetDept = StaffDepartment.HUMAN_RESOURCES;

      final deptStaff = staffService.getByDepartment<Staff>(targetDept);

      expect(deptStaff, isNotNull);
      for (var staff in deptStaff) {
        expect(staff.department, targetDept);
      }
    });

    test('7. Transfer Department - Move staff to different department', () {
      final staff = staffService.allStaff.first;
      final originalDept = staff.department;
      final newDept = StaffDepartment.values.firstWhere(
        (d) => d != originalDept,
        orElse: () => StaffDepartment.EMERGENCY_DEPARTMENT,
      );

      staffService.transferDepartment(staff.id, newDept);

      final updated = staffService.getStaffById(staff.id);
      expect(updated?.department, newDept);

      staffService.transferDepartment(staff.id, originalDept);
    });

    test('8. Salary Increase - Apply percentage raise to department', () {
      final dept = StaffDepartment.RECEPTION;
      final deptStaff = staffService.getByDepartment<Staff>(dept);
      final originalSalaries = {for (var s in deptStaff) s.id: s.salary};
      final increasePercent = 5.0;

      staffService.applyDepartmentSalaryIncrease(dept, increasePercent);

      for (var staff in deptStaff) {
        final expected =
            originalSalaries[staff.id]! * (1 + increasePercent / 100);
        expect(staff.salary, closeTo(expected, 0.01));
      }

      for (var staff in deptStaff) {
        staff.salary = originalSalaries[staff.id]!;
        staffService.updateStaff(staff);
      }
    });

    test('9. Department Statistics - Calculate metrics for all departments',
        () {
      final stats = staffService.getDepartmentStatistics();

      expect(stats, isNotEmpty);
      expect(stats['totalDepartments'], greaterThan(0));
      expect(stats.containsKey('details'), true);

      final details = stats['details'] as List;
      expect(details, isNotEmpty);

      for (var dept in details) {
        final deptData = dept as Map<String, dynamic>;
        expect(deptData.containsKey('department'), true);
        expect(deptData.containsKey('totalStaff'), true);
        expect(deptData.containsKey('avgSalary'), true);
      }
    });

    test('10. Email Validation - Reject invalid email formats', () {
      final invalidEmails = [
        'nodomain',
        'test@',
        '@test.com',
        'test@testcom',
        '',
      ];

      for (var invalidEmail in invalidEmails) {
        final testAdmin = AdministrativeStaff(
          id: 'TEST_EMAIL_${invalidEmails.indexOf(invalidEmail)}',
          firstName: 'Test',
          lastName: 'Email',
          email: invalidEmail,
          phoneNumber: '5551234567',
          dateOfBirth: DateTime(1990, 1, 1),
          hireDate: DateTime.now(),
          pastYearsOfExperience: 5,
          salary: 50000.0,
          department: StaffDepartment.ADMINISTRATION,
          position: AdministrativePosition.HR,
        );

        expect(testAdmin.hasValidEmail, false,
            reason: 'Email "$invalidEmail" should be invalid');
      }
    });

    test('11. Age Boundary - Test isAdult with exact 18-year boundary', () {
      final now = DateTime.now();

      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
      final seventeenYearsAgo = DateTime(now.year - 17, now.month, now.day);

      final adultStaff = AdministrativeStaff(
        id: 'ADULT_TEST',
        firstName: 'Adult',
        lastName: 'Staff',
        email: 'adult@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: eighteenYearsAgo,
        hireDate: DateTime.now(),
        pastYearsOfExperience: 0,
        salary: 40000.0,
        department: StaffDepartment.ADMINISTRATION,
        position: AdministrativePosition.RECEPTIONIST,
      );

      final childStaff = AdministrativeStaff(
        id: 'CHILD_TEST',
        firstName: 'Young',
        lastName: 'Staff',
        email: 'young@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: seventeenYearsAgo,
        hireDate: DateTime.now(),
        pastYearsOfExperience: 0,
        salary: 40000.0,
        department: StaffDepartment.ADMINISTRATION,
        position: AdministrativePosition.RECEPTIONIST,
      );

      expect(adultStaff.isAdult, true, reason: 'Should be 18+');
      expect(childStaff.isAdult, false, reason: 'Should be under 18');
    });

    test('12. Overload Detection - Identify overloaded medical staff', () {
      final doctor = Doctor(
        id: 'DOC_OVERLOAD',
        firstName: 'Busy',
        lastName: 'Doctor',
        email: 'busy@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1985, 1, 1),
        hireDate: DateTime(2020, 1, 1),
        pastYearsOfExperience: 5,
        salary: 120000.0,
        specialization: DoctorSpecialization.CARDIOLOGY,
        department: StaffDepartment.CARDIOLOGY,
        currentShift: ShiftType.DAY,
      );

      for (int i = 0; i < 11; i++) {
        doctor.assignedPatients.add('patient_$i');
      }
      expect(doctor.isOverloaded, true, reason: 'Should be overloaded at 11 patients');

      doctor.assignedPatients.clear();
      doctor.shiftsThisMonth = 21;
      expect(doctor.isOverloaded, true, reason: 'Should be overloaded at 21 shifts');

      doctor.assignedPatients.clear();
      for (int i = 0; i < 9; i++) {
        doctor.assignedPatients.add('patient_$i');
      }
      doctor.shiftsThisMonth = 5;
      expect(doctor.isOverloaded, false, reason: 'Should not be overloaded');
    });

    test('13. Capacity Check - Test canTakeMorePatients at boundaries', () {
      final nurse = Nurse(
        id: 'NURSE_CAPACITY',
        firstName: 'Capacity',
        lastName: 'Test',
        email: 'capacity@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1990, 1, 1),
        hireDate: DateTime(2020, 1, 1),
        pastYearsOfExperience: 3,
        salary: 80000.0,
        specialization: NurseSpecialization.GENERAL_NURSING,
        department: StaffDepartment.INTENSIVE_CARE_UNIT,
        currentShift: ShiftType.DAY,
      );

      for (int i = 0; i < 9; i++) {
        nurse.assignedPatients.add('patient_$i');
      }
      expect(nurse.canTakeMorePatients, true, reason: 'Should accept at 9 patients');

      nurse.assignedPatients.add('patient_9');
      expect(nurse.canTakeMorePatients, false, reason: 'Should reject at 10 patients');
    });

    test('14. Shift Validation - Test hasValidShiftsCount at boundaries', () {
      final doctor = Doctor(
        id: 'DOC_SHIFTS',
        firstName: 'Shift',
        lastName: 'Test',
        email: 'shift@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1985, 1, 1),
        hireDate: DateTime(2020, 1, 1),
        pastYearsOfExperience: 5,
        salary: 120000.0,
        specialization: DoctorSpecialization.SURGERY,
        department: StaffDepartment.SURGERY,
        currentShift: ShiftType.DAY,
      );

      doctor.shiftsThisMonth = 0;
      expect(doctor.hasValidShiftsCount, true, reason: 'Should accept 0 shifts');

      doctor.shiftsThisMonth = 31;
      expect(doctor.hasValidShiftsCount, true, reason: 'Should accept 31 shifts');

      doctor.shiftsThisMonth = 32;
      expect(doctor.hasValidShiftsCount, false, reason: 'Should reject 32 shifts');

      doctor.shiftsThisMonth = -1;
      expect(doctor.hasValidShiftsCount, false, reason: 'Should reject -1 shifts');
    });

    test('15. Multiple Validations - Catch all validation failures at once', () {
      final now = DateTime.now();
      final invalidStaff = AdministrativeStaff(
        id: 'INVALID_MULTI',
        firstName: 'Multi',
        lastName: 'Invalid',
        email: 'invalidemail',
        phoneNumber: '123',
        dateOfBirth: now.add(Duration(days: 1)),
        hireDate: now.subtract(Duration(days: 365)),
        pastYearsOfExperience: -5,
        salary: 50000.0,
        department: StaffDepartment.ADMINISTRATION,
        position: AdministrativePosition.HR,
      );

      expect(() => staffService.addStaff(invalidStaff), throwsArgumentError);
    });

    test('16. Patient Capacity - Reject assignment when at capacity', () {
      final nurse = Nurse(
        id: 'NURSE_FULL',
        firstName: 'Full',
        lastName: 'Nurse',
        email: 'full@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1990, 1, 1),
        hireDate: DateTime(2020, 1, 1),
        pastYearsOfExperience: 3,
        salary: 80000.0,
        specialization: NurseSpecialization.SURGICAL,
        department: StaffDepartment.SURGERY,
        currentShift: ShiftType.DAY,
      );

      for (int i = 0; i < 10; i++) {
        nurse.assignedPatients.add('patient_$i');
      }

      staffService.addStaff(nurse);

      expect(
        () => medicalStaffService.assignPatient('NURSE_FULL', 'patient_10'),
        throwsStateError,
      );

      final updatedNurse = staffService.getStaffById('NURSE_FULL') as Nurse;
      expect(updatedNurse.assignedPatients.length, 10, reason: 'Should still have 10 patients');

      staffService.removeStaff('NURSE_FULL');
    });



    test('17. Salary Validation - Ensure validation prevents invalid increases',
        () {
      final admin = AdministrativeStaff(
        id: 'ADMIN_SALARY_TEST',
        firstName: 'Salary',
        lastName: 'Test',
        email: 'salary.test@hospital.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1990, 1, 1),
        hireDate: DateTime(2020, 1, 1),
        pastYearsOfExperience: 5,
        salary: 50000.0,
        department: StaffDepartment.HUMAN_RESOURCES,
        position: AdministrativePosition.HR,
      );

      staffService.addStaff(admin);
      final originalSalary = admin.salary;

      expect(
        () => staffService.applyDepartmentSalaryIncrease(
            StaffDepartment.HUMAN_RESOURCES, -10.0),
        throwsArgumentError,
      );

      final unchanged = staffService.getStaffById('ADMIN_SALARY_TEST')!;
      expect(unchanged.salary, originalSalary, reason: 'Salary should not change on error');

      staffService.removeStaff('ADMIN_SALARY_TEST');
    });
  });
}
