import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/misc/job_data_file_service.dart';
import '/router.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  var nbExpanded = 0;
  final _expanded = <String, bool>{};

  void addStage() async {
    if (widget.enterprise.jobs.fold<int>(
            0, (previousValue, e) => e.positionsRemaining(context)) ==
        0) {
      await showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
                title: Text('Plus de stage disponible'),
                content: Text(
                    'Il n\'y a plus de stage disponible dans cette entreprise'),
              ));
      return;
    }

    GoRouter.of(context).goNamed(
      Screens.internshipEnrollement,
      params: Screens.withId(widget.enterprise.id),
    );
  }

  void _prepareExpander(internships) {
    if (internships.length == 0 || _expanded.length != nbExpanded) {
      for (final internship in internships) {
        _expanded[internship.id] = false;
      }
      nbExpanded = _expanded.length;
    }
  }

  Widget _dateBuild(Internship internship) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Début :'),
            Text(
              '${internship.date.start.year.toString().padLeft(4, '0')}-'
              '${internship.date.start.month.toString().padLeft(2, '0')}-'
              '${internship.date.start.day.toString().padLeft(2, '0')}',
            )
          ],
        ),
        Column(
          children: [
            const Text('Fin :'),
            Text(
              '${internship.date.end.year.toString().padLeft(4, '0')}-'
              '${internship.date.end.month.toString().padLeft(2, '0')}-'
              '${internship.date.end.day.toString().padLeft(2, '0')}',
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final internships = widget.enterprise.internships(context, listen: true);
    _prepareExpander(internships);

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Historique des stages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) => setState(
                () => _expanded[internships[panelIndex].id] = !isExpanded),
            children: internships.map(
              (internship) {
                late Specialization specialization;
                late Teacher teacher;
                late Student student;

                try {
                  specialization =
                      widget.enterprise.jobs[internship.jobId].specialization;
                  teacher =
                      TeachersProvider.of(context).fromId(internship.teacherId);
                  student =
                      StudentsProvider.of(context).fromId(internship.studentId);
                } catch (e) {
                  return ExpansionPanel(
                      headerBuilder: ((context, isExpanded) => Container()),
                      body: Container());
                }

                return ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _expanded[internship.id] ?? false,
                  headerBuilder: (context, isExpanded) => ListTile(
                    leading: Text(internship.date.start.year.toString()),
                    title: Text(specialization.idWithName),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Stagiaire : '),
                            GestureDetector(
                              onTap: () => GoRouter.of(context)
                                  .pushNamed(Screens.student, params: {
                                'id': student.id,
                                'initialPage': '1'
                              }),
                              child: Text(
                                student.fullName,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            Text(' (${student.program.title})'),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              'Professeur\u00b7e en charge : ${teacher.fullName}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                          child: _dateBuild(internship),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
