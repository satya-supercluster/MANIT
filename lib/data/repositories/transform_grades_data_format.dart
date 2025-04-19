Map<String, dynamic>? transformGradesDataFormat(Map<String, dynamic> resultData) {
  try {
    // Check if semesters data exists
    if (resultData['semester'] == null || resultData['semester'].isEmpty) {
      return null;
    }

    // Extract all subjects from all semesters
    List<Map<String, dynamic>> allSubjects = [];
    
    for (var semester in resultData['semester']) {
      if (semester['courses'] != null) {
        for (var course in semester['courses']) {
          allSubjects.add({
            'code': course['code'],
            'name': course['name'],
            'grade': course['grade'],
            'gradePoint': course['gradePoint'],
            'credits': course['credits'],
            'term': semester['term'] // Adding semester info
          });
        }
      }
    }

    return {
      'subjects': allSubjects
    };
  } catch (e) {
    print('Error transforming result data: $e');
    return null;
  }
}