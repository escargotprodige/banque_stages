import 'package:flutter/widgets.dart';

import '/common/models/internship.dart';
import '/common/models/internship_evaluation_skill.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/misc/job_data_file_service.dart';

class SkillEvaluationFormController {
  static const _formVersion = '1.0.0';

  SkillEvaluationFormController({required this.internshipId});
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  factory SkillEvaluationFormController.fromInternshipId(
    context, {
    required String internshipId,
    required int evaluationIndex,
  }) {
    Internship internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    InternshipEvaluationSkill evaluation =
        internship.skillEvaluations[evaluationIndex];

    final controller =
        SkillEvaluationFormController(internshipId: internshipId);

    controller.evaluationDate = evaluation.date;
    for (final present in evaluation.presentAtEvaluation) {
      if (controller.wereAtMeeting.keys.contains(present)) {
        controller.wereAtMeeting[present] = true;
      } else {
        controller.othersAtMeetingController.text = present;
      }
    }

    // Fill skill to evaluated as if it was none
    final enterprise =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId];
    final specialization = enterprise.jobs[internship.jobId].specialization;
    for (final skill in specialization.skills) {
      controller.skillsToEvaluate[skill] = false;
    }
    for (final extraSpecializationId in internship.extraSpecializationsId) {
      for (final skill
          in ActivitySectorsService.specialization(extraSpecializationId)
              .skills) {
        controller.skillsToEvaluate[skill] = false;
        controller.skillsAreFromSpecializationId[skill] = extraSpecializationId;
      }
    }

    // Now fill the structures
    for (final skillEvaluation in evaluation.skills) {
      final skill = controller.skillsToEvaluate.keys.firstWhere(
          (element) => element.idWithName == skillEvaluation.skillName);
      controller.skillsToEvaluate[skill] = true;

      controller.taskCompleted[skill] = {};
      for (final task in skill.tasks) {
        controller.taskCompleted[skill]![task] =
            skillEvaluation.tasks.contains(task);
      }

      controller.appreciations[skill] = skillEvaluation.appreciation;
    }

    controller.commentsController.text = evaluation.comments;

    return controller;
  }

  InternshipEvaluationSkill toInternshipEvaluation() {
    final List<String> wereAtMeetingTp = [];
    for (final person in wereAtMeeting.keys) {
      if (wereAtMeeting[person]!) {
        wereAtMeetingTp.add(person);
      }
    }
    if (withOtherAtMeeting) {
      wereAtMeetingTp.add(othersAtMeetingController.text);
    }

    final List<SkillEvaluation> skillEvaluation = [];
    for (final skill in taskCompleted.keys) {
      final List<String> tasks = [];
      for (final task in taskCompleted[skill]!.keys) {
        if (taskCompleted[skill]![task]!) {
          tasks.add(task);
        }
      }

      skillEvaluation.add(SkillEvaluation(
        specializationId: skillsAreFromSpecializationId[skill]!,
        skillName: skill.idWithName,
        tasks: tasks,
        appreciation: appreciations[skill]!,
      ));
    }
    return InternshipEvaluationSkill(
      date: evaluationDate,
      presentAtEvaluation: wereAtMeetingTp,
      skills: skillEvaluation,
      comments: commentsController.text,
      formVersion: _formVersion,
    );
  }

  DateTime evaluationDate = DateTime.now();

  final Map<String, bool> wereAtMeeting = {
    'L\'enseignant\u2022e superviseur\u2022e': true,
    'La ou le stagiaire': false,
    'La ou le responsable dans le milieu de stage': false,
  };
  bool _withOtherAtMeeting = false;
  bool get withOtherAtMeeting => _withOtherAtMeeting;
  TextEditingController othersAtMeetingController = TextEditingController();
  set withOtherAtMeeting(bool value) {
    _withOtherAtMeeting = value;
    if (!value) othersAtMeetingController.text = '';
  }

  Map<Skill, bool> skillsToEvaluate = {};
  final Map<Skill, String> skillsAreFromSpecializationId = {};
  Map<Skill, Map<String, bool>> taskCompleted = {};
  void prepareTaskCompleted() {
    taskCompleted.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      Map<String, bool> tp = {};
      for (final task in skill.tasks) {
        tp[task] = false;
      }
      taskCompleted[skill] = tp;
    }
  }

  Map<Skill, SkillAppreciation> appreciations = {};
  bool get allAppreciationsAreDone {
    for (final skill in appreciations.keys) {
      if (appreciations[skill] == SkillAppreciation.notEvaluated) return false;
    }
    return true;
  }

  void prepareAppreciation() {
    appreciations.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      appreciations[skill] = SkillAppreciation.notEvaluated;
    }
  }

  TextEditingController commentsController = TextEditingController();
}