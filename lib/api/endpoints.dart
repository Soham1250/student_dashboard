// api/endpoints.dart

const String baseUrl = 'http://192.168.29.165:4000/api';

// Authentication
const String emailOtpEndpoint = '$baseUrl/emailotp';
const String verifyOtpEndpoint = '$baseUrl/verifyotp';
const String loginEndpoint = '$baseUrl/login';
const String registerEndpoint = '$baseUrl/register';

// Subjects
final String getSubjectsEndpoint = '$baseUrl/getsubjects';
String getSubjectByIdEndpoint(String subjectId) => '$baseUrl/getsubject/$subjectId';
final String addSubjectEndpoint = '$baseUrl/addsubject';
String deleteSubjectEndpoint(String subjectId) => '$baseUrl/deletesubject/$subjectId';
String updateSubjectEndpoint(String subjectId) => '$baseUrl/updatesubject/$subjectId';

// Chapters
final String getChaptersEndpoint = '$baseUrl/getchapters';
String getChapterByIdEndpoint(String chapterId) => '$baseUrl/getchapter/$chapterId';
String getSubjectChaptersEndpoint(String subjectId) => '$baseUrl/getsubjectchapters/$subjectId';
final String addChapterEndpoint = '$baseUrl/addchapter';
String deleteChapterEndpoint(String chapterId) => '$baseUrl/deletechapter/$chapterId';
String updateChapterEndpoint(String chapterId) => '$baseUrl/updatechapter/$chapterId';

// Notes
final String getNotesEndpoint = '$baseUrl/getnotes';
String getNoteByIdEndpoint(String noteId) => '$baseUrl/getnote/$noteId';
String getSubjectNotesEndpoint(String subjectId) => '$baseUrl/getsubjectnotes/$subjectId';
final String addNoteEndpoint = '$baseUrl/addnote';
String deleteNoteEndpoint(String noteId) => '$baseUrl/deletenote/$noteId';
String updateNoteEndpoint(String noteId) => '$baseUrl/updatenote/$noteId';

// Questions
final String getQuestionsEndpoint = '$baseUrl/getquestions';
String getQuestionByIdEndpoint(String questionId) => '$baseUrl/getquestion/$questionId';
String getSubjectQuestionsEndpoint(String subjectId) => '$baseUrl/getsubjectquestions/$subjectId';
String getChapterQuestionsEndpoint(String chapterId) => '$baseUrl/getchapterquestions/$chapterId';
final String addQuestionEndpoint = '$baseUrl/addquestion';
String deleteQuestionEndpoint(String questionId) => '$baseUrl/deletequestion/$questionId';
String updateQuestionEndpoint(String questionId) => '$baseUrl/updatequestion/$questionId';

// Question Papers
final String getQuestionPapersEndpoint = '$baseUrl/getquestionpapers';
String getQuestionPaperByIdEndpoint(String questionPaperId) => '$baseUrl/getquestionpaper/$questionPaperId';
String getStudentQuestionPapersEndpoint(String userId) => '$baseUrl/getstudentquestionpapers/$userId';
final String addQuestionPaperEndpoint = '$baseUrl/addquestionpaper';
String updateQuestionPaperEndpoint(String questionPaperId) => '$baseUrl/updatequestionpaper/$questionPaperId';

// Faculty and Students
String getFacultyByIdEndpoint(String userId) => '$baseUrl/getfaculty/$userId';
String getStudentByIdEndpoint(String userId) => '$baseUrl/getstudent/$userId';
String deleteFacultyEndpoint(String userId) => '$baseUrl/deletefaculty/$userId';
String deleteStudentEndpoint(String userId) => '$baseUrl/deletestudent/$userId';
String updateFacultyEndpoint(String userId) => '$baseUrl/updatefaculty/$userId';
String updateStudentEndpoint(String userId) => '$baseUrl/updatestudent/$userId';
