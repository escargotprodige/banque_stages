import 'package:enhanced_containers/item_serializable.dart';
import 'package:go_router/go_router.dart';

import 'screens/add_enterprise/add_enterprise_screen.dart';
import 'screens/enterprise/enterprise_screen.dart';
import 'screens/enterprises_list/enterprises_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ref_sst/home_sst/home_sst_screen.dart';
import 'screens/ref_sst/job_list_risks_and_skills/job_list_screen.dart';
import 'screens/ref_sst/risks_cards/risks_cards_screen.dart';
import 'screens/ref_sst/sst_cards/sst_cards_screen.dart';
import 'screens/student/student_screen.dart';
import 'screens/students_list/students_list_screen.dart';
import 'screens/visiting_students/visit_students_screen.dart';

abstract class Screens {
  static const home = "home";
  static const login = "login";
  static const visitStudents = "visit-students";

  static const enterprisesList = "enterprises-list";
  static const enterprise = "enterprise";
  static const addEnterprise = "add-enterprise";

  static const studentsList = "students-list";
  static const student = "student";
  static const addStudent = "add-student";

  static const homeSST = "home-sst";
  static const jobSST = "job-sst";
  static const risksCardsSST = "risks-cards-sst";
  static const cardsSST = "cards-sst";

  static Map<String, String> withId(id) {
    if (id is String) {
      return {"id": id};
    } else if (id is ItemSerializable) {
      return {"id": id.id};
    }

    throw TypeError();
  }
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      name: Screens.home,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: "login",
          name: Screens.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: "enterprises",
          name: Screens.enterprisesList,
          builder: (context, state) => const EnterprisesListScreen(),
          routes: [
            GoRoute(
              path: "add",
              name: Screens.addEnterprise,
              builder: (context, state) => const AddEnterpriseScreen(),
            ),
            GoRoute(
              path: ":id",
              name: Screens.enterprise,
              builder: (context, state) =>
                  EnterpriseScreen(id: state.params["id"]!),
            ),
          ],
        ),
        GoRoute(
          path: "students",
          name: Screens.studentsList,
          builder: (context, state) => const StudentsListScreen(),
          routes: [
            GoRoute(
              path: ":id",
              name: Screens.student,
              builder: (context, state) =>
                  StudentScreen(id: state.params["id"]!),
            ),
          ],
        ),
        GoRoute(
          path: "visit-students",
          name: Screens.visitStudents,
          builder: (context, state) => const VisitStudentScreen(),
        ),
        GoRoute(
          path: "sst",
          name: Screens.homeSST,
          builder: (context, state) => const HomeSSTScreen(),
          routes: [
            GoRoute(
              path: "jobs/:id",
              name: Screens.jobSST,
              builder: (context, state) =>
                  JobListScreen(id: state.params["id"]!),
            ),
            GoRoute(
              path: "risks/:id",
              name: Screens.risksCardsSST,
              builder: (context, state) =>
                  RisksCardsScreen(int.parse(state.params["id"]!)),
              redirect: (context, state) {
                if (int.tryParse(state.params["id"] ?? "") == null) {
                  return Screens.homeSST;
                }
                return null;
              },
            ),
            GoRoute(
              name: Screens.cardsSST,
              path: "cards",
              builder: (context, state) => const SSTCardsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
