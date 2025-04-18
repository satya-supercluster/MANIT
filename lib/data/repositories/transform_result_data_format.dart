
  Map<String, dynamic>? transformResultDataFormat(Map<String, dynamic> webApiData) {
    try {
      // Check if required data exists
      if (webApiData['data'] == null ||
          webApiData['data']['Basic_Details'] == null ||
          webApiData['data']['Semester_Data'] == null ||
          webApiData['data']['FINAL_CGPA'] == null) {
        return null;
      }

      final List<dynamic> basicDetails = webApiData['data']['Basic_Details'];
      final List<dynamic> semesterData = webApiData['data']['Semester_Data'];
      final List<dynamic> finalCgpa = webApiData['data']['FINAL_CGPA'];

      // Create an array to hold semester information
      final List<Map<String, dynamic>> semesters = [];

      for (int i = 0; i < basicDetails.length; i++) {
        // Extract and format courses from subjects
        final List<Map<String, dynamic>> courses = [];
        
        if (semesterData[i]['data'] != null && 
            semesterData[i]['data']['subjects'] != null) {
          
          for (final subject in semesterData[i]['data']['subjects']) {
            courses.add({
              'code': subject['subject_code'] ?? '',
              'name': subject['subname'] ?? '',
              'grade': subject['grade'] ?? '',
              'gradePoint': subject['gradePoint'] ?? 0,
              'credits': subject['credit'] ?? 0,
            });
          }
        }

        // Add semester info
        semesters.add({
          'term': basicDetails[i]['semester_term_description'] ?? '',
          'gpa': semesterData[i]['data']['grand_total']['sgpa'] ?? 0,
          'cgpa': finalCgpa[i] ?? 0,
          'totalCredits': semesterData[i]['data']['grand_total']['total_credits'] ?? 0,
          'examType': semesterData[i]['data']['grand_total']['exam_type'] ?? '',
          'result': semesterData[i]['data']['grand_total']['pass_or_fail'] ?? '',
          'courses': courses,
          // Keep original data structure for PDF generation
          'originalDetails': {
            'details': semesterData[i],
            'cgpa': finalCgpa[i],
            'basicDetails': basicDetails[i],
          }
        });
      }

      // Create new data structure for mobile app
      return {
        'semesters': semesters,
        // Preserve original data for compatibility with the PDF generator
        'data': webApiData['data']
      };
    } catch (e) {
      print('Error transforming result data: $e');
      return null;
    }
  }