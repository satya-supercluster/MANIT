class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? profilePicture;
  final String studentId;
  final String department;
  final int batch;
  final int semester;
  final String? phoneNumber;
  final String enrollmentStatus;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.studentId,
    required this.department,
    required this.batch,
    required this.semester,
    this.phoneNumber,
    required this.enrollmentStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      studentId: json['student_id'],
      department: json['department'],
      batch: json['batch'],
      semester: json['semester'],
      phoneNumber: json['phone_number'],
      enrollmentStatus: json['enrollment_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'student_id': studentId,
      'department': department,
      'batch': batch,
      'semester': semester,
      'phone_number': phoneNumber,
      'enrollment_status': enrollmentStatus,
    };
  }
}