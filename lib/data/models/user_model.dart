class User {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String? profilePicture;
  final String studentId;
  final String department;
  final String degree;
  final String batch;
  final String semester;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final String? alternateEmailId;
  final String enrollmentStatus;
  final String program;
  
  // Personal information
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? nationality;
  final String? bloodGroup;
  final String? motherTongue;
  final String? caste;
  final String? gender;
  
  // ID documents
  final String? aadharNumber;
  final String? passportNumber;
  final String? panNumber;
  final String? abcId;
  final String? voterCard;
  
  // Family information
  final String? fatherName;
  final String? fatherProfession;
  final String? motherName;
  final String? motherProfession;
  final String? parentsAddress;
  final String? parentsPhone;
  final String? parentsEmail;
  
  // Guardian information
  final String? guardianName;
  final String? relationshipWithGuardian;
  final String? guardianAddress;
  final String? guardianPhone;
  final String? guardianEmail;
  
  // Address information
  final String? permanentAddress;
  final String? presentAddress;
  
  // Hostel information
  final String? hostel;
  final String? roomNo;

  User({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.studentId,
    required this.department,
    required this.degree,
    required this.batch,
    required this.semester,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.alternateEmailId,
    required this.enrollmentStatus,
    required this.program,
    this.dateOfBirth,
    this.maritalStatus,
    this.nationality,
    this.bloodGroup,
    this.motherTongue,
    this.caste,
    this.gender,
    this.aadharNumber,
    this.passportNumber,
    this.panNumber,
    this.abcId,
    this.voterCard,
    this.fatherName,
    this.fatherProfession,
    this.motherName,
    this.motherProfession,
    this.parentsAddress,
    this.parentsPhone,
    this.parentsEmail,
    this.guardianName,
    this.relationshipWithGuardian,
    this.guardianAddress,
    this.guardianPhone,
    this.guardianEmail,
    this.permanentAddress,
    this.presentAddress,
    this.hostel,
    this.roomNo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['loginData']?['userInfo']?['studentInfo'][0]?['studentuid'].toString() ?? 'N/A',
      name: json['loginData']?['userInfo']?['studentInfo'][0]?['full_name']?.toString() ?? 'N/A',
      fullName: json['loginData']?['userInfo']?['studentInfo'][0]?['full_name']?.toString() ?? 'N/A',
      email: json['profileData']?['email']?.toString() ?? 'N/A',
      profilePicture: json['profileImageData']?['image'].toString()??"N/A",
      studentId: json['profileData']?['roll_no']?.toString() ?? 'N/A',
      department: json['loginData']?['userInfo']?['departmentNumber']?.toString() ?? 'N/A',
      degree: json['loginData']?['userInfo']?['studentInfo'][0]?['code_desc'].toString() ?? 'N/A',
      batch: json['loginData']?['userInfo']?['studentInfo'][0]?['start_session']?.toString()??"N/A",
      semester: "Semester ${json['resultData']?['data']?['FINAL_CGPA']?.length + 1}",
      phoneNumber: json['profileData']?['phone_number']?.toString(),
      alternatePhoneNumber: json['profileData']?['alternate_phone_no']?.toString(),
      alternateEmailId: json['profileData']?['alternate_email']?.toString(),
      enrollmentStatus: json['enrollment_status']?.toString() ?? 'Active',
      program: json['loginData']?['userInfo']?['departmentNumber']?.toString() ?? 'N/A',
      dateOfBirth: json['loginData']?['userInfo']?['studentInfo'][0]?['dob']?.toString(),
      maritalStatus: json['profileData']?['marital_status']?.toString() ?? 'N/A',
      nationality: json['profileData']?['perm_country']?.toString() ?? "N/A",
      bloodGroup: json['profileData']?['blood_group']?.toString() ?? "N/A",
      motherTongue: json['profileData']?['mother_tongue']?.toString() ?? "N/A",
      caste: json['profileData']?['category']?.toString() ?? "N/A",
      gender: json['profileData']?['gender']?.toString() ?? "N/A",
      aadharNumber: json['profileData']?['aadhar_no']?.toString() ?? "N/A",
      passportNumber: json['passport_no']?.toString() ?? "N/A",
      panNumber: json['profileData']?['pan_no']?.toString() ?? "N/A",
      abcId: json['profileData']?['abc_id']?.toString() ?? "N/A",
      voterCard: json['profileData']?['voter_card_no']?.toString() ?? "N/A",
      fatherName: json['profileData']?['father_name']?.toString() ?? "N/A",
      fatherProfession: json['profileData']?['father_profession']?.toString() ?? "N/A",
      motherName: json['profileData']?['mother_name']?.toString() ?? "N/A",
      motherProfession: json['profileData']?['mother_profession']?.toString() ?? "N/A",
      parentsAddress: json['profileData'] == null ? "N/A" : [
  json['profileData']['parent_addr_line1']?.toString(),
  json['profileData']['parent_addr_line2']?.toString(),
  json['profileData']['parent_city']?.toString(),
  json['profileData']['parent_state']?.toString(),
  json['profileData']['parent_country']?.toString(),
  json['profileData']['parent_pin']?.toString()
].where((part) => part != null && part.isNotEmpty).join(", "),
      parentsPhone: json['profileData']?['parents_phone']?.toString() ?? "N/A",
      parentsEmail: json['profileData']?['parents_email']?.toString() ?? "N/A",
      guardianName: json['profileData']?['guardian_name']?.toString() ?? "N/A",
      relationshipWithGuardian:json['profileData']?['guardian_relation']?.toString() ?? "N/A",
      guardianAddress: json['profileData'] == null ? "N/A" : [
  json['profileData']['guardian_addr_line1']?.toString(),
  json['profileData']['guardian_addr_line2']?.toString(),
  json['profileData']['guardian_city']?.toString(),
  json['profileData']['guardian_state']?.toString(),
  json['profileData']['guardian_country']?.toString(),
  json['profileData']['guardian_pin']?.toString()
].where((part) => part != null && part.isNotEmpty).join(", "),
      guardianPhone: json['profileData']?['guardian_phone_no']?.toString() ?? "N/A",
      guardianEmail: json['profileData']?['guardian_email']?.toString() ?? "N/A",
      permanentAddress: json['profileData'] == null ? "N/A" : [
  json['profileData']['permanent_address']?.toString(),
  json['profileData']['permanent_district']?.toString(),
  json['profileData']['permanent_state']?.toString(),
  json['profileData']['permanent_country']?.toString(),
  json['profileData']['permanent_pin']?.toString()
].where((part) => part != null && part.isNotEmpty).join(", "),
      presentAddress: json['profileData'] == null ? "N/A" : [
  json['profileData']['present_address']?.toString(),
  json['profileData']['present_district']?.toString(),
  json['profileData']['present_state']?.toString(),
  json['profileData']['present_country']?.toString(),
  json['profileData']['present_pin']?.toString()
].where((part) => part != null && part.isNotEmpty).join(", "),
      hostel: json['loginData']?['userInfo']?['studentInfo'][0]?['hostel']?.toString() ?? "N/A",
      roomNo: json['loginData']?['userInfo']?['studentInfo'][0]?['hostel']?.toString() ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'email': email,
      'profile_picture': profilePicture,
      'student_id': studentId,
      'department': department,
      'degree': degree,
      'batch': batch,
      'semester': semester,
      'phone_number': phoneNumber,
      'alternate_phone_number': alternatePhoneNumber,
      'alternate_email_id': alternateEmailId,
      'enrollment_status': enrollmentStatus,
      'program': program,
      'date_of_birth': dateOfBirth,
      'marital_status': maritalStatus,
      'nationality': nationality,
      'blood_group': bloodGroup,
      'mother_tongue': motherTongue,
      'caste': caste,
      'gender': gender,
      'aadhar_number': aadharNumber,
      'passport_number': passportNumber,
      'pan_number': panNumber,
      'abc_id': abcId,
      'voter_card': voterCard,
      'father_name': fatherName,
      'father_profession': fatherProfession,
      'mother_name': motherName,
      'mother_profession': motherProfession,
      'parents_address': parentsAddress,
      'parents_phone': parentsPhone,
      'parents_email': parentsEmail,
      'guardian_name': guardianName,
      'relationship_with_guardian': relationshipWithGuardian,
      'guardian_address': guardianAddress,
      'guardian_phone': guardianPhone,
      'guardian_email': guardianEmail,
      'permanent_address': permanentAddress,
      'present_address': presentAddress,
      'hostel': hostel,
      'room_no': roomNo,
    };
  }

//   // Create a User from the infoConverter output
//   factory User.fromJson(Map<String, dynamic> studentData, {
//     required String id,
//     required String enrollmentStatus,
//     required String program,
//     String batch = '2026',
//   }) {
//     return User(
//       id: id,
//       name: studentData['name'] ?? 'N/A',
//       fullName: studentData['fullName'] ?? 'N/A',
//       email: studentData['emailId'] ?? 'N/A',
//       profilePicture: studentData['profileImage'],
//       studentId: studentData['studentId'] ?? 'N/A',
//       department: studentData['department'] ?? 'N/A',
//       batch: batch,
//       semester: studentData['semester'] ?? 'N/A',
//       phoneNumber: studentData['phoneNumber'],
//       alternatePhoneNumber: studentData['alternatePhoneNumber'],
//       alternateEmailId: studentData['alternateEmailId'],
//       enrollmentStatus: enrollmentStatus,
//       program: program,
//       dateOfBirth: studentData['dateOfBirth'],
//       maritalStatus: studentData['maritalStatus'],
//       nationality: studentData['nationality'],
//       bloodGroup: studentData['bloodGroup'],
//       motherTongue: studentData['motherTongue'],
//       caste: studentData['caste'],
//       gender: studentData['gender'],
//       aadharNumber: studentData['aadharNumber'],
//       passportNumber: studentData['passportNumber'],
//       panNumber: studentData['panNumber'],
//       abcId: studentData['abcId'],
//       voterCard: studentData['voterCard'],
//       fatherName: studentData['fatherName'],
//       fatherProfession: studentData['fatherProfession'],
//       motherName: studentData['motherName'],
//       motherProfession: studentData['motherProfession'],
//       parentsAddress: studentData['parentsAddress'],
//       parentsPhone: studentData['parentsPhone'],
//       parentsEmail: studentData['parentsEmail'],
//       guardianName: studentData['guardianName'],
//       relationshipWithGuardian: studentData['relationshipWithGuardian'],
//       guardianAddress: studentData['guardianAddress'],
//       guardianPhone: studentData['guardianPhone'],
//       guardianEmail: studentData['guardianEmail'],
//       permanentAddress: studentData['permanentAddress'],
//       presentAddress: studentData['presentAddress'],
//       hostel: studentData['hostel'],
//       roomNo: studentData['roomNo'],
//     );
//   }
// }

// Example of how to use the infoConverter with the User model
// User createUserFromRawData(dynamic apiResponse) {
//   // Convert the raw data using the infoConverter
//   Map<String, dynamic> convertedData = infoConverter(apiResponse);
  
//   // Create a User from the converted data
//   return User.fromInfoConverter(
//     convertedData,
//     id: apiResponse?.basicInfo?.userInfo?.uid?.toString() ?? 'N/A',
//     username: apiResponse?.basicInfo?.userInfo?.uid?.toString() ?? 'N/A',
//     enrollmentStatus: 'Active', // Default or extract from API response
//     program: apiResponse?.basicInfo?.userInfo?.program?.toString() ?? 'N/A',
//   );

}