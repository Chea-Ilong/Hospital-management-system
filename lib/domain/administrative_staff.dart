import 'staff.dart';

/// Enum for administrative positions
enum AdministrativePosition {
  receptionist,
  medicalRecordsClerk,
  billingSpecialist,
  hrManager,
  facilityManager,
  itSupport,
  financeOfficer,
  qualityAssurance,
  publicRelations
}

/// Administrative Staff class extending Staff
class AdministrativeStaff extends Staff {
  final AdministrativePosition position;
  final String officeLocation;
  final List<String> _responsibilities;
  final List<String> _completedProjects;
  int _tasksCompletedThisMonth;
  double _efficiencyRating;

  AdministrativeStaff({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.pastYearsOfExperience,
    required super.hireDate,
    required super.department,
    required super.licenseNumber,
    required super.salary,
    super.currentShift = ShiftType.day,
    required this.position,
    required this.officeLocation,
    List<String> responsibilities = const [],
    List<String> completedProjects = const [],
    int tasksCompletedThisMonth = 0,
    double efficiencyRating = 0.0,
    super.isActive,
  })  : _responsibilities = List.from(responsibilities),
        _completedProjects = List.from(completedProjects),
        _tasksCompletedThisMonth = tasksCompletedThisMonth,
        _efficiencyRating = efficiencyRating;

  // Getters
  List<String> get responsibilities => List.unmodifiable(_responsibilities);
  List<String> get completedProjects => List.unmodifiable(_completedProjects);
  int get tasksCompletedThisMonth => _tasksCompletedThisMonth;
  double get efficiencyRating => _efficiencyRating;
  int get totalProjects => _completedProjects.length;

  @override
  String getRole() => 'Administrative Staff';

  @override
  String getResponsibilities() {
    String positionName = _getPositionName();
    String baseResponsibilities = _getPositionResponsibilities();

    return '''
    Position: $positionName
    Office: $officeLocation
    
    Key Responsibilities:
    $baseResponsibilities
    
    Additional Duties:
    ${_responsibilities.isEmpty ? '- None assigned' : _responsibilities.map((r) => '- $r').join('\n    ')}
    
    Tasks completed this month: $_tasksCompletedThisMonth
    ''';
  }

  @override
  double computeSalary() {
    // Administrative staff bonuses based on efficiency and tasks completed
    double baseBonus = salary * 0.07; // 7% base bonus
    double taskBonus = _tasksCompletedThisMonth * 25.0;
    double efficiencyBonus = _efficiencyRating * 700.0;
    double projectBonus = totalProjects * 100.0;

    return baseBonus + taskBonus + efficiencyBonus + projectBonus;
  }

  // Administrative-specific methods
  void addResponsibility(String responsibility) {
    if (!_responsibilities.contains(responsibility)) {
      _responsibilities.add(responsibility);
    }
  }

  void removeResponsibility(String responsibility) {
    _responsibilities.remove(responsibility);
  }

  void recordCompletedTask() {
    _tasksCompletedThisMonth++;
  }

  void resetMonthlyTasks() {
    _tasksCompletedThisMonth = 0;
  }

  void addCompletedProject(String projectName) {
    if (!_completedProjects.contains(projectName)) {
      _completedProjects.add(projectName);
    }
  }

  void updateEfficiencyRating(double rating) {
    if (rating < 0.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    _efficiencyRating = rating;
  }

  String _getPositionName() {
    return position
        .toString()
        .split('.')
        .last
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();
  }

  String _getPositionResponsibilities() {
    switch (position) {
      case AdministrativePosition.receptionist:
        return '''- Greet and assist visitors
    - Answer phone calls and manage appointments
    - Handle patient check-ins and check-outs
    - Maintain front desk organization''';

      case AdministrativePosition.medicalRecordsClerk:
        return '''- Maintain and organize medical records
    - Ensure HIPAA compliance
    - Process record requests
    - Archive and retrieve patient files''';

      case AdministrativePosition.billingSpecialist:
        return '''- Process medical bills and insurance claims
    - Handle patient billing inquiries
    - Coordinate with insurance companies
    - Maintain billing records''';

      case AdministrativePosition.hrManager:
        return '''- Recruit and onboard new staff
    - Manage employee benefits and payroll
    - Handle employee relations
    - Ensure compliance with labor laws''';

      case AdministrativePosition.facilityManager:
        return '''- Oversee facility maintenance
    - Manage building operations
    - Coordinate with vendors
    - Ensure safety compliance''';

      case AdministrativePosition.itSupport:
        return '''- Maintain hospital IT systems
    - Provide technical support
    - Manage network security
    - Implement software updates''';

      case AdministrativePosition.financeOfficer:
        return '''- Manage hospital budget
    - Prepare financial reports
    - Monitor expenses and revenue
    - Oversee financial compliance''';

      case AdministrativePosition.qualityAssurance:
        return '''- Monitor quality standards
    - Conduct audits and inspections
    - Implement quality improvement programs
    - Ensure regulatory compliance''';

      case AdministrativePosition.publicRelations:
        return '''- Manage hospital communications
    - Handle media relations
    - Coordinate community outreach
    - Maintain hospital reputation''';
    }
  }


  @override
  String toString() {
    return '''
${super.toString()}
    Position: ${_getPositionName()}
    Office Location: $officeLocation
    Tasks Completed This Month: $_tasksCompletedThisMonth
    Total Projects Completed: $totalProjects
    Efficiency Rating: ${_efficiencyRating.toStringAsFixed(1)}/5.0
    Bonus: \$${computeSalary().toStringAsFixed(2)}
    ''';
  }
}
