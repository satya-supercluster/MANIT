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
  final String program;

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
    required this.program
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      profilePicture: json['profile_picture'].toString(),
      studentId: json['student_id'].toString(),
      department: json['department'].toString(),
      batch: 2026,
      semester: 6,
      phoneNumber: json['phone_number'].toString(),
      enrollmentStatus: json['enrollment_status'].toString(),
      program: json['program'].toString(),
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
      'program':program,
    };
  }
}