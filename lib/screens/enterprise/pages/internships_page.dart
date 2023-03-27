import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
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

  @override
  void initState() {
    super.initState();

    bool isFirst = true;
    for (final internship
        in widget.enterprise.internships(context, listen: false)) {
      _expanded[internship.id] = isFirst;
      isFirst = false;
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
    final internships = widget.enterprise.internships(context, listen: false);

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Historique des stages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) => setState(
                () => _expanded[internships[panelIndex].id] = !isExpanded),
            children: internships.map(
              (internship) {
                final specialization =
                    widget.enterprise.jobs[internship.jobId].specialization;
                final teacher =
                    TeachersProvider.of(context).fromId(internship.teacherId);
                final student =
                    StudentsProvider.of(context).fromId(internship.studentId);

                return ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _expanded[internship.id]!,
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
                        const SizedBox(height: 8),
                        Text(
                            'Professeur\u00b7e en charge : ${teacher.fullName}'),
                        const SizedBox(height: 10),
                        _dateBuild(internship),
                        const SizedBox(height: 15),
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
