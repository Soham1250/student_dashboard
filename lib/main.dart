import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'Screens/login_page.dart';
import 'Screens/MainScreen/main_screen.dart';
import 'Screens/MainScreen/Tests/test_selection_screen.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/UniversalTestInterface.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/topic_wise_test.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/physics_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/chemistry_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/biology_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/math_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/select_topicwise_difficulty.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subject.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subjectwise_difficulty.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subjectwise_test.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/select_flt.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/Mock/select_flt_test.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/MHT CET/select_year.dart';
import 'Screens/MainScreen/Grievance/grievance.dart';
import 'Screens/MainScreen/Grievance/manage_grievance.dart';
import 'Screens/MainScreen/Grievance/new_greivance.dart';
import 'Screens/MainScreen/Feedback/feedback.dart';
import 'Screens/MainScreen/Learn/learn.dart';
import 'Screens/MainScreen/Learn/learn_subject.dart';
import 'Screens/MainScreen/Learn/learn_chapter.dart';
import 'Screens/MainScreen/Satistics/satistics.dart';
import 'Screens/MainScreen/Satistics/subject_review.dart';
import 'Screens/MainScreen/test_analysis.dart';
import 'Screens/MainScreen/detailed_analysis_screen.dart';
import 'Screens/MainScreen/Performance/performance.dart';
import 'Screens/forgot_password.dart';
import 'Screens/register.dart';

// Providers
import 'providers/auth_provider.dart';

// Services
import 'services/auth_storage_service.dart';

// Main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for stored credentials
  final authStorage = AuthStorageService();
  bool isLoggedIn = false;

  try {
    isLoggedIn = await authStorage.validateStoredCredentials();
  } catch (e) {
    debugPrint('Error checking credentials: $e');
  }

  runApp(StudentDashboardApp(isLoggedIn: isLoggedIn));
}

class StudentDashboardApp extends StatelessWidget {
  final bool isLoggedIn;

  const StudentDashboardApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: 'Student Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        // Handling dynamic routes
        onGenerateRoute: (settings) {
          if (settings.name == '/main') {
            return MaterialPageRoute(
              builder: (context) {
                return MainScreen(); // Pass the username to MainScreen
              },
            );
          }
          // Other routes
          return null;
        },
        initialRoute: isLoggedIn ? '/main' : '/',
        routes: {
          '/': (context) => LoginPage(),
          '/main': (context) => MainScreen(),
          '/testSelection': (context) => TestSelectionScreen(),
          '/testInterface': (context) => UniversalTestInterface(),
          '/detailedanalysis': (context) => DetailedAnalysisScreen(),

          // Topic Wise
          '/topicWiseTest': (context) => TopicWiseTestScreen(),
          '/physicsTopics': (context) => PhysicsChapterScreen(),
          '/chemistryTopics': (context) => ChemistryChapterScreen(),
          '/biologyTopics': (context) => BiologyChapterScreen(),
          '/mathTopics': (context) => MathChapterScreen(),
          '/selectDifficulty': (context) => SelectTopicWiseDifficultyScreen(),

          // Subject Wise
          '/subjectWise': (context) => SubjectWiseTest(),
          '/selectSubjectWiseDifficulty': (context) =>
              SelectSubjectWiseDifficultyScreen(),
          '/selectSubjectWiseTest': (context) => SelectSubjectWiseTest(),
          '/subjectwisetestinterface': (context) => UniversalTestInterface(),

          // Full Length Test
          '/fullSyllabus': (context) => SelectFLTScreen(),
          '/selectFLTTest': (context) => SelectMockFltTest(),
          '/selectcetyear': (context) => SelectCETyear(),

          // Performance and Analysis
          '/testAnalysis': (context) => TestAnalysisScreen(),
          '/performance': (context) => PerformanceScreen(),

          // Statistics
          '/statistics': (context) => StatisticsScreen(),
          '/subjectreview': (context) => SubjectReviewScreen(),

          // Learn
          '/learn': (context) => LearnScreen(),
          '/learnsubject': (context) => LearnSubjectScreen(),
          '/learnchapter': (context) => LearnChapterScreen(),

          // Feedback
          '/feedback': (context) => FeedbackScreen(),

          // Grievances
          '/grievance': (context) => GrievancePortal(),
          '/manageGrievance': (context) => ManageGrievanceScreen(),
          '/newGrievance': (context) => NewGrievanceScreen(),

          // Auth
          // '/forgotPassword': (context) => ForgotPasswordScreen(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}
