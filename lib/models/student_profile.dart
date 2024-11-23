class StudentProfile {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String currentClass;
  final String? gap;

  StudentProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.currentClass,
    this.gap,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['UserID'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      email: json['Email'],
      phoneNumber: json['PhoneNumber'],
      currentClass: json['CurrentClass'],
      gap: json['Gap'],
    );
  }

  String get fullName => '$firstName $lastName';
}
