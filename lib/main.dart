import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'Screens/login_page.dart';
import 'Screens/MainScreen/main_screen.dart';
import 'Screens/MainScreen/Tests/test_selection_screen.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/topicwise_test_interface_screen.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/topic_wise_test.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/physics_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/chemistry_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/biology_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/chapter/math_chapter.dart';
import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/select_topicwise_difficulty.dart';
// import 'Screens/MainScreen/Tests/TestType/TopicWiseTest/select_topic_wise_test.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subject.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subjectwise_difficulty.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/select_subjectwise_test.dart';
import 'Screens/MainScreen/Tests/TestType/SubjectWiseTest/subjectwise_test_interface.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/select_flt.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/Mock/select_flt_test.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/Mock/flt_test_interface.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/MHT CET/select_year.dart';
import 'Screens/MainScreen/Tests/TestType/FullLengthTest/MHT CET/mht_cet_test.dart';
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

// Main function
void main() {
  runApp(const StudentDashboardApp());
}

class StudentDashboardApp extends StatelessWidget {
  const StudentDashboardApp({super.key});

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
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/testSelection': (context) => TestSelectionScreen(),
          '/testInterface': (context) => TestInterfaceScreen(),
          '/detailedanalysis': (context) => DetailedAnalysisScreen(),

          // Topic Wise
          '/topicWiseTest': (context) => TopicWiseTestScreen(),
          '/physicsTopics': (context) => PhysicsChapterScreen(),
          '/chemistryTopics': (context) => ChemistryChapterScreen(),
          '/biologyTopics': (context) => BiologyChapterScreen(),
          '/mathTopics': (context) => MathChapterScreen(),
          '/selectDifficulty': (context) => SelectTopicWiseDifficultyScreen(),
          // '/selectTopicWiseTest': (context) => SelectTopicWiseTest(),
          '/testanalysis': (context) => TestAnalysisScreen(),

          // Subject Wise
          '/subjectWise': (context) => SubjectWiseTest(),
          '/selectSubjectWiseDifficulty': (context) => SelectSubjectWiseDifficultyScreen(),
          '/selectSubjectWiseTest': (context) => SelectSubjectWiseTest(),
          '/subjectwisetestinterface': (context) => SubjectWiseTestInterfaceScreen(),

          // Full Length Test
          '/fullSyllabus': (context) => SelectFLTScreen(),
          '/mockflt': (context) => SelectMockFltTest(),
          '/mockflttestinterface': (context) => FltTestInterfaceScreen(),

          // MHT CET
          '/selectcetyear': (context) => SelectCETyear(),
          '/mhtcettestinterface': (context) => MHTCETtestinterface(),

          // Performance Analysis
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
          '/grievances': (context) => GrievancePortal(),
          '/managegrievance': (context) => ManageGrievanceScreen(),
          '/newgrievance': (context) => NewGrievanceScreen(),

          '/forgotpassword': (context) => ForgotPasswordPage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}
