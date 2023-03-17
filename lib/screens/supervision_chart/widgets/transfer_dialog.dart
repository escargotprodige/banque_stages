import 'package:flutter/material.dart';

import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/internships_provider.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({
    super.key,
    required this.students,
    required this.teachers,
  });

  final List<Student> students;
  final List<Teacher> teachers;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  late String _choiceStudent = widget.students[0].id;
  late String? _choiceTeacher = _getCurrentSupervisorId();

  String? _getCurrentSupervisorId() {
    final internships = InternshipsProvider.of(context, listen: false);
    final internship = internships.byStudentId(_choiceStudent);
    if (internship.isEmpty) {
      return null;
    }
    return internships.byStudentId(_choiceStudent).last.teacherId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transférer un\u00b7e étudiant\u00b7e'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Étudiant\u00b7e'),
          DropdownButton<String>(
            value: _choiceStudent,
            icon: const Icon(Icons.expand_more),
            onChanged: (String? newValue) {
              _choiceStudent = newValue!;
              _choiceTeacher = _getCurrentSupervisorId();
              setState(() {});
            },
            items: widget.students
                .map<DropdownMenuItem<String>>(
                    (student) => DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.fullName),
                        ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Superviseur\u00b7e',
          ),
          if (_choiceTeacher == null)
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Aucun stage pour cet.te étudiant.e',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          if (_choiceTeacher != null)
            DropdownButton<String>(
              value: _choiceTeacher,
              icon: const Icon(Icons.expand_more),
              onChanged: (String? newValue) =>
                  setState(() => _choiceTeacher = newValue!),
              items: widget.teachers
                  .map<DropdownMenuItem<String>>(
                      (student) => DropdownMenuItem<String>(
                            value: student.id,
                            child: Text(student.fullName),
                          ))
                  .toList(),
            ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(
                context,
                _choiceTeacher == null
                    ? null
                    : [_choiceStudent, _choiceTeacher!]);
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
