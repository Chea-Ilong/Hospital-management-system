import 'package:test/test.dart';
import '../lib/domain/doctor.dart';
import '../lib/domain/nurse.dart';
import '../lib/domain/administrative_staff.dart';
import '../lib/domain/staff.dart'; // Import ShiftType
import 'dart:io';

void main() {
  group('Doctor Tests', () {
    late Doctor doctor;

    setUp(() {
      doctor = Doctor(
        id: 'D001',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@hospital.com',
        phoneNumber: '+1-555-1234',
        dateOfBirth: DateTime(1980, 5, 15),
        hireDate: DateTime(2015, 3, 20),
        pastYearsOfExperience: 7,
        department: 'Cardiology',
        salary: 250000.0,
        specialization: Specialization.cardiology,
        currentShift: ShiftType.day,
        licenseNumber: 'MD-12345',
      );
    });

    test('Doctor should have correct role', () {
      expect(doctor.getRole(), equals('Doctor'));
    });

    test('Doctor can assign and remove patients', () {
      doctor.assignPatient('P001');
      doctor.assignPatient('P002');
      expect(doctor.totalPatients, equals(2));

      doctor.removePatient('P001');
      expect(doctor.totalPatients, equals(1));
    });

    test('Doctor can record consultations', () {
      expect(doctor.consultationsThisMonth, equals(0));
      doctor.recordConsultation();
      doctor.recordConsultation();
      expect(doctor.consultationsThisMonth, equals(2));
    });

    test('Doctor can update patient rating', () {
      doctor.updateRating(4.5);
      expect(doctor.patientRating, equals(4.5));

      expect(() => doctor.updateRating(6.0), throwsArgumentError);
      expect(() => doctor.updateRating(-1.0), throwsArgumentError);
    });

    test('Doctor can add and remove certifications', () {
      doctor.addCertification('Board Certified');
      expect(doctor.certifications.length, equals(1));

      doctor.addCertification('Board Certified'); // Duplicate
      expect(
          doctor.certifications.length, equals(1)); // Should not add duplicate

      doctor.removeCertification('Board Certified');
      expect(doctor.certifications.length, equals(0));
    });

    test('Doctor bonus calculation is correct', () {
      doctor.updateRating(4.8);
      doctor.recordConsultation();
      doctor.recordConsultation();

      final bonus = doctor.computeSalary();
      expect(bonus, greaterThan(0));
    });

    test('Doctor can check if they can accept more patients', () {
      expect(doctor.canAcceptMorePatients(maxPatients: 5), isTrue);

      // Assign 6 patients
      for (int i = 0; i < 6; i++) {
        doctor.assignPatient('P00$i');
      }

      expect(doctor.canAcceptMorePatients(maxPatients: 5), isFalse);
    });

    // TODO: toJson/fromJson moved to data layer repositories
    // test('Doctor toJson and fromJson work correctly', () {
    //   final json = doctor.toJson();
    //   final reconstructedDoctor = Doctor.fromJson(json);
    //   expect(reconstructedDoctor.id, equals(doctor.id));
    //   expect(reconstructedDoctor.fullName, equals(doctor.fullName));
    //   expect(reconstructedDoctor.specialization, equals(doctor.specialization));
    // });
  });

  group('Nurse Tests', () {
    late Nurse nurse;

    setUp(() {
      nurse = Nurse(
        id: 'N001',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane.doe@hospital.com',
        phoneNumber: '+1-555-5678',
        dateOfBirth: DateTime(1990, 8, 20),
        pastYearsOfExperience: 4,
        hireDate: DateTime(2018, 6, 15),
        department: 'Emergency',
        salary: 75000.0,
        specialization: NurseSpecialization.emergency,
        licenseNumber: 'RN-11111',
        currentShift: ShiftType.night,
      );
    });

    test('Nurse should have correct role', () {
      expect(nurse.getRole(), equals('Nurse'));
    });

    test('Nurse can record shifts', () {
      expect(nurse.shiftsThisMonth, equals(0));
      nurse.recordShift();
      nurse.recordShift();
      expect(nurse.shiftsThisMonth, equals(2));
    });

    test('Nurse can update performance rating', () {
      nurse.updatePerformanceRating(4.2);
      expect(nurse.performanceRating, equals(4.2));

      expect(() => nurse.updatePerformanceRating(5.5), throwsArgumentError);
    });

    test('Night shift nurse gets shift differential pay', () {
      final differential = nurse.currentShift.bonus;
      // Night shift gets 25% differential
      expect(differential, greaterThan(0));
    });

    test('Day shift nurse gets no shift differential', () {
      final dayNurse = Nurse(
        id: 'N002',
        firstName: 'Bob',
        lastName: 'Wilson',
        email: 'bob@hospital.com',
        phoneNumber: '+1-555-9999',
        dateOfBirth: DateTime(1985, 3, 10),
        hireDate: DateTime(2016, 1, 1),
        pastYearsOfExperience: 7,
        department: 'ICU',
        salary: 80000.0,
        specialization: NurseSpecialization.critical,
        licenseNumber: 'RN-22222',
        currentShift: ShiftType.day,
      );

      expect(dayNurse.currentShift.bonus, equals(0.0));
    });

    test('Nurse bonus includes night shift bonus', () {
      nurse.updatePerformanceRating(4.5);
      nurse.recordShift();

      final bonus = nurse.computeSalary();
      expect(bonus, greaterThan(500.0)); // Should include night shift bonus
    });

    // TODO: toJson/fromJson moved to data layer repositories
    // test('Nurse toJson and fromJson work correctly', () {
    //   final json = nurse.toJson();
    //   final reconstructedNurse = Nurse.fromJson(json);
    //   expect(reconstructedNurse.id, equals(nurse.id));
    //   expect(reconstructedNurse.currentShift, equals(nurse.currentShift));
    // });
  });

  group('Administrative Staff Tests', () {
    late AdministrativeStaff admin;

    setUp(() {
      admin = AdministrativeStaff(
        id: 'A001',
        firstName: 'Alice',
        lastName: 'Brown',
        email: 'alice.brown@hospital.com',
        phoneNumber: '+1-555-7777',
        dateOfBirth: DateTime(1985, 12, 5),
        pastYearsOfExperience: 9,
        hireDate: DateTime(2012, 9, 1),
        department: 'Human Resources',
        salary: 85000.0,
        licenseNumber: 'ADM-001',
        position: AdministrativePosition.hrManager,
        officeLocation: 'Building A, Floor 2',
      );
    });

    test('Administrative staff should have correct role', () {
      expect(admin.getRole(), equals('Administrative Staff'));
    });

    test('Admin can record completed tasks', () {
      expect(admin.tasksCompletedThisMonth, equals(0));
      admin.recordCompletedTask();
      admin.recordCompletedTask();
      admin.recordCompletedTask();
      expect(admin.tasksCompletedThisMonth, equals(3));
    });

    test('Admin can add and remove responsibilities', () {
      admin.addResponsibility('Conduct interviews');
      expect(admin.responsibilities.length, equals(1));

      admin.removeResponsibility('Conduct interviews');
      expect(admin.responsibilities.length, equals(0));
    });

    test('Admin can add completed projects', () {
      admin.addCompletedProject('Q1 Training Program');
      admin.addCompletedProject('Benefits Review');
      expect(admin.totalProjects, equals(2));
    });

    test('Admin can update efficiency rating', () {
      admin.updateEfficiencyRating(4.7);
      expect(admin.efficiencyRating, equals(4.7));
    });

    // TODO: toJson/fromJson moved to data layer repositories
    // test('Admin toJson and fromJson work correctly', () {
    //   final json = admin.toJson();
    //   final reconstructedAdmin = AdministrativeStaff.fromJson(json);
    //   expect(reconstructedAdmin.id, equals(admin.id));
    //   expect(reconstructedAdmin.position, equals(admin.position));
    // });
  });

  group('Staff Base Class Tests', () {
    late Doctor staff;

    setUp(() {
      staff = Doctor(
        id: 'D999',
        firstName: 'Test',
        lastName: 'Doctor',
        email: 'test@hospital.com',
        pastYearsOfExperience: 20,
        phoneNumber: '+1-555-0000',
        dateOfBirth: DateTime(1975, 1, 1),
        hireDate: DateTime(2010, 1, 1),
        department: 'General',
        salary: 200000.0,
        specialization: Specialization.generalPractice,
        currentShift: ShiftType.day,
        licenseNumber: 'MD-99999',
      );
    });

    test('Staff age calculation is correct', () {
      final expectedAge = DateTime.now().year - 1975;
      expect(staff.age, lessThanOrEqualTo(expectedAge));
      expect(staff.age, greaterThanOrEqualTo(expectedAge - 1));
    });

    test('Staff years of service calculation is correct', () {
      final expectedYears = DateTime.now().year - 2010;
      expect(staff.yearsOfService, lessThanOrEqualTo(expectedYears));
      expect(staff.yearsOfService, greaterThanOrEqualTo(expectedYears - 1));
    });

    test('Staff can be activated and deactivated', () {
      expect(staff.isActive, isTrue);

      staff.deactivate();
      expect(staff.isActive, isFalse);

      staff.activate();
      expect(staff.isActive, isTrue);
    });

    test('Staff salary can be updated', () {
      staff.salary = 250000.0;
      expect(staff.salary, equals(250000.0));
    });

    test('Staff salary cannot be negative', () {
      expect(() => staff.salary = -1000.0, throwsArgumentError);
    });

    test('Staff full name is correct', () {
      expect(staff.fullName, equals('Test Doctor'));
    });
  });

  // TODO: Repository tests need to be rewritten for separate repositories
  // (NurseRepository, DoctorRepository, AdministrativeStaffRepository)
  /*
  group('StaffRepository Tests', () {
    late StaffRepository repository;
    final testFilePath = './test/test_staff_data.json';

    setUp(() {
      repository = StaffRepository(testFilePath);

      // Add sample data
      repository.addStaff(Doctor(
        id: 'D001',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john@hospital.com',
        phoneNumber: '+1-555-1111',
        dateOfBirth: DateTime(1980, 5, 15),
        hireDate: DateTime(2015, 3, 20),
        pastYearsOfExperience: 7,
        department: 'Cardiology',
        salary: 250000.0,
        specialization: Specialization.cardiology,
        licenseNumber: 'MD-001',
      ));

      repository.addStaff(Nurse(
        id: 'N001',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@hospital.com',
        phoneNumber: '+1-555-2222',
        dateOfBirth: DateTime(1990, 8, 20),
        hireDate: DateTime(2018, 6, 15),
                pastYearsOfExperience: 7,

        department: 'Emergency',
        salary: 75000.0,
        specialization: NurseSpecialization.emergency,
        licenseNumber: 'RN-001',
        currentShift: ShiftType.night,
      ));

      repository.addStaff(AdministrativeStaff(
        id: 'A001',
        firstName: 'Alice',
        lastName: 'Brown',
        email: 'alice@hospital.com',
        phoneNumber: '+1-555-3333',
        dateOfBirth: DateTime(1985, 12, 5),
        hireDate: DateTime(2012, 9, 1),
        pastYearsOfExperience: 7,
        department: 'HR',
        salary: 85000.0,
        position: AdministrativePosition.hrManager,
        officeLocation: 'Building A',
      ));
    });

    tearDown(() {
      // Clean up test file
      final file = File(testFilePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('Repository can add staff', () {
      expect(repository.count, equals(3));
    });

    test('Repository cannot add duplicate staff', () {
      expect(
        () => repository.addStaff(Doctor(
          id: 'D001',
          firstName: 'Duplicate',
          lastName: 'Doctor',
          email: 'dup@hospital.com',
          phoneNumber: '+1-555-0000',
          dateOfBirth: DateTime(1980, 1, 1),
          hireDate: DateTime(2015, 1, 1),
                  pastYearsOfExperience: 7,
          department: 'Test',
          salary: 100000.0,
          specialization: Specialization.generalPractice,
          licenseNumber: 'MD-DUP',
        )),
        throwsArgumentError,
      );
    });

    test('Repository can retrieve staff by ID', () {
      final staff = repository.getStaffById('D001');
      expect(staff, isNotNull);
      expect(staff!.id, equals('D001'));
    });

    test('Repository returns null for non-existent ID', () {
      final staff = repository.getStaffById('INVALID');
      expect(staff, isNull);
    });

    test('Repository can get all doctors', () {
      final doctors = repository.getAllDoctors();
      expect(doctors.length, equals(1));
    });

    test('Repository can get all nurses', () {
      final nurses = repository.getAllNurses();
      expect(nurses.length, equals(1));
    });

    test('Repository can get all administrative staff', () {
      final admins = repository.getAllAdministrativeStaff();
      expect(admins.length, equals(1));
    });

    test('Repository can search staff by name', () {
      final results = repository.searchStaffByName('John');
      expect(results.length, equals(1));
      expect(results[0].firstName, equals('John'));
    });

    test('Repository can get staff by department', () {
      final results = repository.getStaffByDepartment('Cardiology');
      expect(results.length, equals(1));
    });

    test('Repository can get active staff', () {
      final activeStaff = repository.getActiveStaff();
      expect(activeStaff.length, equals(3));
    });

    test('Repository can remove staff', () {
      repository.removeStaff('D001');
      expect(repository.count, equals(2));
    });

    test('Repository can update staff', () {
      var staff = repository.getStaffById('D001')!;
      staff.salary = 300000.0;
      repository.updateStaff(staff);

      staff = repository.getStaffById('D001')!;
      expect(staff.salary, equals(300000.0));
    });

    test('Repository can get statistics', () {
      final stats = repository.getStatistics();
      expect(stats['totalStaff'], equals(3));
      expect(stats['doctors'], equals(1));
      expect(stats['nurses'], equals(1));
      expect(stats['administrativeStaff'], equals(1));
      expect(stats['totalSalaries'], greaterThan(0));
    });

    test('Repository can get top performers', () {
      final topPerformers = repository.getTopPerformers(limit: 2);
      expect(topPerformers.length, lessThanOrEqualTo(2));
    });

    test('Repository can save and load data', () {
      repository.saveStaff();

      final newRepository = StaffRepository(testFilePath);
      newRepository.loadStaff();

      expect(newRepository.count, equals(3));
    });
  });
  */
}
