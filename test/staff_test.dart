import 'dart:io';
import 'package:test/test.dart';
import '../lib/domain/administrative_staff.dart';
import '../lib/domain/staff.dart';
import '../lib/service/staff_service.dart';

void main() {
  group('Hospital Staff Management System Tests', () {
    late StaffService staffService;
    final adminBackupPath = 'lib/data/storage/admin_staff_data_backup.json';
    final doctorsBackupPath = 'lib/data/storage/doctors_data_backup.json';
    final nursesBackupPath = 'lib/data/storage/nurses_data_backup.json';

    setUpAll(() {
      // Backup original data files before all tests
      final adminFile = File('lib/data/storage/admin_staff_data.json');
      final doctorsFile = File('lib/data/storage/doctors_data.json');
      final nursesFile = File('lib/data/storage/nurses_data.json');

      if (adminFile.existsSync()) adminFile.copySync(adminBackupPath);
      if (doctorsFile.existsSync()) doctorsFile.copySync(doctorsBackupPath);
      if (nursesFile.existsSync()) nursesFile.copySync(nursesBackupPath);
    });

    setUp(() {
      staffService = StaffService();
    });

    tearDownAll(() {
      // Restore original data files after all tests
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

    // Test 1: Get Staff by ID
    test('1. Get Staff by ID - Retrieve specific staff member', () {
      // Arrange
      final allStaff = staffService.allStaff;
      expect(allStaff.isNotEmpty, true);
      final targetStaff = allStaff.first;

      // Act
      final retrievedStaff = staffService.getStaffById(targetStaff.id);

      // Assert
      expect(retrievedStaff, isNotNull);
      expect(retrievedStaff?.id, targetStaff.id);
      expect(retrievedStaff?.firstName, targetStaff.firstName);
      expect(retrievedStaff?.email, targetStaff.email);
    });

    // Test 2: Add New Staff
    test('2. Add Staff - Create and add new administrative staff', () {
      // Arrange
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

      // Act
      staffService.addStaff(newAdmin);

      // Assert
      final afterCount =
          staffService.allStaff.whereType<AdministrativeStaff>().length;
      expect(afterCount, initialCount + 1);
      expect(staffService.getStaffById('TEST_ADMIN_001'), isNotNull);

      // Cleanup
      staffService.removeStaff('TEST_ADMIN_001');
    });

    // Test 3: Update Staff
    test('3. Update Staff - Modify existing staff salary', () {
      // Arrange
      final admins =
          staffService.allStaff.whereType<AdministrativeStaff>().toList();
      expect(admins.isNotEmpty, true);
      final testAdmin = admins.first;
      final originalSalary = testAdmin.salary;
      final newSalary = originalSalary + 5000.0;

      // Act
      testAdmin.salary = newSalary;
      staffService.updateStaff(testAdmin);

      // Assert
      final updatedAdmin = staffService.getStaffById(testAdmin.id);
      expect(updatedAdmin?.salary, newSalary);

      // Cleanup
      testAdmin.salary = originalSalary;
      staffService.updateStaff(testAdmin);
    });

    // Test 4: Remove Staff
    test('4. Remove Staff - Delete staff member from system', () {
      // Arrange
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

      // Act
      staffService.removeStaff('TEMP_001');

      // Assert
      final afterCount = staffService.allStaff.length;
      expect(afterCount, beforeCount - 1);
      expect(staffService.getStaffById('TEMP_001'), isNull);
    });

    // Test 5: Search by Name
    test('5. Search Staff - Find staff by partial name match', () {
      // Arrange
      final allStaff = staffService.allStaff;
      expect(allStaff.isNotEmpty, true);
      final targetStaff = allStaff.first;
      final searchQuery = targetStaff.firstName.substring(0, 3);

      // Act
      final results = staffService.searchStaffByName(searchQuery);

      // Assert
      expect(results, isNotEmpty);
      expect(results.any((s) => s.id == targetStaff.id), true);
    });

    // Test 6: Get By Department
    test('6. Get By Department - Retrieve all staff in specific department',
        () {
      // Arrange
      final targetDept = StaffDepartment.HUMAN_RESOURCES;

      // Act
      final deptStaff = staffService.getByDepartment<Staff>(targetDept);

      // Assert
      expect(deptStaff, isNotNull);
      for (var staff in deptStaff) {
        expect(staff.department, targetDept);
      }
    });

    // Test 7: Transfer Department
    test('7. Transfer Department - Move staff to different department', () {
      // Arrange
      final staff = staffService.allStaff.first;
      final originalDept = staff.department;
      final newDept = StaffDepartment.values.firstWhere(
        (d) => d != originalDept,
        orElse: () => StaffDepartment.EMERGENCY_DEPARTMENT,
      );

      // Act
      staffService.transferDepartment(staff.id, newDept);

      // Assert
      final updated = staffService.getStaffById(staff.id);
      expect(updated?.department, newDept);

      // Cleanup
      staffService.transferDepartment(staff.id, originalDept);
    });

    // Test 8: Apply Department Salary Increase
    test('8. Salary Increase - Apply percentage raise to department', () {
      // Arrange
      final dept = StaffDepartment.RECEPTION;
      final deptStaff = staffService.getByDepartment<Staff>(dept);
      final originalSalaries = {for (var s in deptStaff) s.id: s.salary};
      final increasePercent = 5.0;

      // Act
      staffService.applyDepartmentSalaryIncrease(dept, increasePercent);

      // Assert
      for (var staff in deptStaff) {
        final expected =
            originalSalaries[staff.id]! * (1 + increasePercent / 100);
        expect(staff.salary, closeTo(expected, 0.01));
      }

      // Cleanup
      for (var staff in deptStaff) {
        staff.salary = originalSalaries[staff.id]!;
        staffService.updateStaff(staff);
      }
    });

    // Test 9: Get Department Statistics
    test('9. Department Statistics - Calculate metrics for all departments',
        () {
      // Act
      final stats = staffService.getDepartmentStatistics();

      // Assert
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

    // Test 10: Get Staff Count By Type
    test('10. Staff Count - Count staff members by type', () {
      // Act
      final counts = staffService.getStaffCountByType();

      // Assert
      expect(counts, isNotEmpty);
      expect(counts.containsKey('doctors'), true);
      expect(counts.containsKey('nurses'), true);
      expect(counts.containsKey('administrativeStaff'), true);
      expect(counts.containsKey('total'), true);

      expect(counts['total'], staffService.allStaff.length);
      expect(counts['doctors'], greaterThanOrEqualTo(0));
      expect(counts['nurses'], greaterThanOrEqualTo(0));
      expect(counts['administrativeStaff'], greaterThanOrEqualTo(0));
    });
  });
}
