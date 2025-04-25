
class RegistrationDetails {
  final String fullName;
  final String rollNo;
  final String degree;
  final String degreeName;
  final String regSession;
  final String regSemesterTypeIdCode;
  final String currentStatus;
  final String feesStatus;
  final String creationTime;
  final List<Subject> subjects;
  final String credits;

  RegistrationDetails({
    required this.fullName,
    required this.rollNo,
    required this.degree,
    required this.degreeName,
    required this.regSession,
    required this.regSemesterTypeIdCode,
    required this.currentStatus,
    required this.feesStatus,
    required this.creationTime,
    required this.subjects,
    required this.credits,
  });
  factory RegistrationDetails.fromJson(Map<String, dynamic> json) {
    return RegistrationDetails(
      fullName: json['full_name']?.toString() ?? 'N/A',
      rollNo: json['roll_no']?.toString() ?? 'N/A',
      degree: "N/A",
      degreeName: "N/A",
      regSession: json['reg_session']?.toString() ?? 'N/A',
      regSemesterTypeIdCode: json['reg_semester_type_id_code']?.toString() ?? 'N/A',
      currentStatus: json['current_status']?.toString() ?? 'N/A',
      feesStatus: json['fees_status']?.toString() ?? 'N/A',
      creationTime: json['creation_time']?.toString() ?? 'N/A',
      subjects: List<Subject>.from(json['subjects'].map((subject) => Subject.fromJson(subject))),
      credits: json['credits']?.toString() ?? 'N/A',
    );
  }
}

class Subject {
  final String subjectCode;
  final String subjectName;
  final String componentName;
  final String semesterCode;
  final String subjectTeacher;

  Subject({
    required this.subjectCode,
    required this.subjectName,
    required this.componentName,
    required this.semesterCode,
    required this.subjectTeacher,
  });
  factory Subject.fromJson(Map<String,dynamic> json){
    return Subject(subjectCode: json['subject_code']?.toString() ?? 'N/A', subjectName: json['subname']?.toString() ?? 'N/A', componentName: json['comp_name_sl_no']?.toString() ?? 'N/A', semesterCode: json['code_desc']?.toString() ?? 'N/A', subjectTeacher: json['empname']?.toString() ?? 'N/A');
  }
}