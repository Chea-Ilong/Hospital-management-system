import 'package:test/test.dart';
import '../lib/domain/doctor.dart';
import '../lib/domain/nurse.dart';
import '../lib/domain/administrative_staff.dart';
import '../lib/domain/staff.dart';

void main() {
  group('Doctor Domain Tests', () {
    // One doctor object for all tests
    final doctor = Doctor(
      id: 'D001',
      firstName: 'John',
      lastName: 'Smith',
      email: 'john.smith@hospital.com',
      phoneNumber: '+1-555-1001',
      dateOfBirth: DateTime(1980, 5, 15),
      hireDate: DateTime(2015, 1, 10),
      pastYearsOfExperience: 5,
      department: 'Cardiology',
      currentShift: ShiftType.day,
      specialization: Specialization.cardiology,
    );

    test('Salary computation with experience and specialization', () {
      // Years of service: 2025-2015=10, Past:5, Total:15
      // Base: 5000, Experience: 15*300=4500, Specialization: 1.5x
      // (5000 + 4500) * 1.5 = 14250
      expect(doctor.computeSalary(), equals(14250.0));
    });

    test('Night shift increases salary by 20%', () {
      doctor.currentShift = ShiftType.night;
      // 14250 + (14250 * 0.20) = 17100
      expect(doctor.computeSalary(), equals(17100.0));
      doctor.currentShift = ShiftType.day; // Reset
    });

    test('Consultation and rating bonuses work', () {
      doctor.recordConsultation();
      doctor.updateRating(4.0);
      // Base: 14250 + Consultation: 50 + Rating: 400 = 14700
      // But wait - the object carries state from previous test!
      // After resetting to day: 14250 + 50 + 400 = 14700
      expect(doctor.computeSalary(), closeTo(14700.0, 10));
    });

    test('Invalid rating throws error', () {
      expect(() => doctor.updateRating(6.0), throwsArgumentError);
    });
  });

  group('Nurse Domain Tests', () {
    // One nurse object for all tests
    final nurse = Nurse(
      id: 'N001',
      firstName: 'Sarah',
      lastName: 'Williams',
      email: 'sarah.w@hospital.com',
      phoneNumber: '+1-555-3001',
      dateOfBirth: DateTime(1990, 8, 22),
      hireDate: DateTime(2018, 3, 1),
      pastYearsOfExperience: 3,
      department: 'Emergency',
      currentShift: ShiftType.night,
      specialization: NurseSpecialization.emergency,
    );

    test('Salary computation with experience and specialization', () {
      // Years of service: 2025-2018=7, Past:3, Total:10
      // Base: 400, Experience: 10*150=1500, Specialization: 1.15x, Night: 20%
      // (400 + 1500) * 1.15 = 2185, 2185 + (2185 * 0.20) = 2622
      expect(nurse.computeSalary(), equals(2622.0));
    });

    test('Shift and performance bonuses work', () {
      nurse.recordShift();
      nurse.recordShift();
      nurse.updatePerformanceRating(4.5);
      // Base: 2622 + Shifts: 10 + Performance: 90 = 2722
      expect(nurse.computeSalary(), equals(2722.0));
    });

    test('Invalid performance rating throws error', () {
      expect(() => nurse.updatePerformanceRating(6.0), throwsArgumentError);
    });
  });

  group('Administrative Staff Tests', () {
    // One admin object for all tests
    final admin = AdministrativeStaff(
      id: 'A001',
      firstName: 'Robert',
      lastName: 'Anderson',
      email: 'robert.a@hospital.com',
      phoneNumber: '+1-555-2001',
      dateOfBirth: DateTime(1985, 9, 10),
      hireDate: DateTime(2016, 5, 1),
      pastYearsOfExperience: 4,
      department: 'IT Department',
      salary: 4000.0,
      position: AdministrativePosition.systemsAdministrator,
    );

    test('Admin always uses day shift', () {
      expect(admin.currentShift, equals(ShiftType.day));
    });

    test('Salary computation with experience bonus', () {
      // Years of service: 2025-2016=9, Past:4, Total:13
      // Base: 4000, Experience: 13*100=1300 = 5300
      expect(admin.computeSalary(), equals(5300.0));
    });
  });

  group('Staff Base Class Tests', () {
    // Use doctor as example of staff
    final staff = Doctor(
      id: 'S001',
      firstName: 'Test',
      lastName: 'Person',
      email: 'test@hospital.com',
      phoneNumber: '+1-555-0001',
      dateOfBirth: DateTime(1990, 1, 1),
      hireDate: DateTime(2020, 1, 1),
      pastYearsOfExperience: 0,
      department: 'Testing',
      currentShift: ShiftType.day,
      specialization: Specialization.generalPractice,
    );

    test('Negative salary throws error', () {
      expect(() => staff.salary = -100, throwsArgumentError);
    });

    test('Years of experience calculated correctly', () {
      expect(staff.yearsOfService, equals(5));
      expect(staff.yearsOfExperience, equals(5));
    });

    test('Full name property works', () {
      expect(staff.fullName, equals('Test Person'));
    });
  });
}
