import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/schedule.dart';
import '/common/widgets/sub_title.dart';
import '/misc/form_service.dart';

class ScheduleStep extends StatefulWidget {
  const ScheduleStep({super.key});

  @override
  State<ScheduleStep> createState() => ScheduleStepState();
}

class ScheduleStepState extends State<ScheduleStep> {
  final formKey = GlobalKey<FormState>();

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 1)),
  );

  int intershipLength = 0;
  final TimeOfDay defaultStart = const TimeOfDay(hour: 9, minute: 0);
  final TimeOfDay defaultEnd = const TimeOfDay(hour: 15, minute: 0);
  late List<WeeklySchedule> weeklySchedules = [_fillNewScheduleList()];

  WeeklySchedule _fillNewScheduleList() {
    return WeeklySchedule(schedule: [
      DailySchedule(
          dayOfWeek: Day.monday, start: defaultStart, end: defaultEnd),
      DailySchedule(
          dayOfWeek: Day.tuesday, start: defaultStart, end: defaultEnd),
      DailySchedule(
          dayOfWeek: Day.wednesday, start: defaultStart, end: defaultEnd),
      DailySchedule(
          dayOfWeek: Day.thursday, start: defaultStart, end: defaultEnd),
      DailySchedule(
          dayOfWeek: Day.friday, start: defaultStart, end: defaultEnd),
    ], period: dateRange);
  }

  void _promptDateRange() async {
    final range = await showDateRangePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: dateRange,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (range == null) return;

    dateRange = range;
    setState(() {});
  }

  void _onRemovedWeeklySchedule(int weeklyIndex) async {
    weeklySchedules.removeAt(weeklyIndex);
    setState(() {});
  }

  void _onAddedTime(int weeklyIndex) async {
    final day = await _promptDay();
    if (day == null) return;
    final start =
        await _promptTime(title: 'Heure de début', initial: defaultStart);
    if (start == null) return;
    final end = await _promptTime(title: 'Heure de fin', initial: defaultEnd);
    if (end == null) return;

    weeklySchedules[weeklyIndex]
        .schedule
        .add(DailySchedule(dayOfWeek: day, start: start, end: end));
    setState(() {});
  }

  void _onUpdatedTime(int weeklyIndex, int i) async {
    final start = await _promptTime(
        title: 'Heure de début',
        initial: weeklySchedules[weeklyIndex].schedule[i].start);
    if (start == null) return;
    final end = await _promptTime(
        title: 'Heure de fin',
        initial: weeklySchedules[weeklyIndex].schedule[i].end);
    if (end == null) return;

    weeklySchedules[weeklyIndex].schedule[i] = weeklySchedules[weeklyIndex]
        .schedule[i]
        .copyWith(start: start, end: end);
    setState(() {});
  }

  void _onRemovedTime(int weeklyIndex, int index) async {
    weeklySchedules[weeklyIndex].schedule.removeAt(index);
    setState(() {});
  }

  void _onPromptChangeWeeks(int weeklyIndex) async {
    final range = await showDateRangePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: weeklySchedules[weeklyIndex].period,
      firstDate: DateTime(weeklySchedules[weeklyIndex].period.start.year - 1),
      lastDate: DateTime(weeklySchedules[weeklyIndex].period.start.year + 2),
    );
    if (range == null) return;

    weeklySchedules[weeklyIndex] =
        weeklySchedules[weeklyIndex].copyWith(period: range);

    setState(() {});
  }

  Future<Day?> _promptDay() async {
    final choice = (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Sélectionner la journée'),
          content: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: Day.values
                  .map((day) => GestureDetector(
                      onTap: () => Navigator.of(context).pop(day),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(day.name),
                      )))
                  .toList(),
            ),
          )),
    ));
    return choice;
  }

  Future<TimeOfDay?> _promptTime(
      {required TimeOfDay initial, String? title}) async {
    final time = await showTimePicker(
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      helpText: title,
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? Container(),
      ),
    );
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRange(dateRange: dateRange, promptDateRange: _promptDateRange),
            _Hours(onSaved: (value) => intershipLength = int.parse(value!)),
            _buildSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Horaire', left: 0),
        ...weeklySchedules
            .asMap()
            .keys
            .map<Widget>((i) => _Schedule(
                  periodName:
                      weeklySchedules.length > 1 ? 'Période ${i + 1}' : null,
                  weeklySchedule: weeklySchedules[i],
                  onPeriodRemove: weeklySchedules.length > 1
                      ? () => _onRemovedWeeklySchedule(i)
                      : null,
                  onAddTime: () => _onAddedTime(i),
                  onChangedTime: (index) => _onUpdatedTime(i, index),
                  onDeleteTime: (index) => _onRemovedTime(i, index),
                  promptChangeWeeks: () => _onPromptChangeWeeks(i),
                ))
            .toList(),
        TextButton(
          onPressed: () =>
              setState(() => weeklySchedules.add(_fillNewScheduleList())),
          style: Theme.of(context).textButtonTheme.style!.copyWith(
              backgroundColor:
                  Theme.of(context).elevatedButtonTheme.style!.backgroundColor),
          child: const Text('Ajouter une période'),
        ),
      ],
    );
  }
}

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.dateRange,
    required this.promptDateRange,
  });

  final DateTimeRange dateRange;
  final Function() promptDateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Dates', top: 0, left: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          labelText: '* Date de début du stage',
                          border: InputBorder.none),
                      controller: TextEditingController(
                          text: DateFormat.yMMMEd().format(dateRange.start)),
                      enabled: false,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: '* Date de fin du stage',
                          border: InputBorder.none),
                      controller: TextEditingController(
                          text: DateFormat.yMMMEd().format(dateRange.end)),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.blue,
              ),
              onPressed: promptDateRange,
            )
          ],
        ),
      ],
    );
  }
}

class _Hours extends StatelessWidget {
  const _Hours({required this.onSaved});

  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: TextFormField(
        decoration:
            const InputDecoration(labelText: '* Nombre d\'heures de stage'),
        validator: FormService.textNotEmptyValidator,
        keyboardType: TextInputType.number,
        onSaved: onSaved,
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule(
      {required this.periodName,
      required this.weeklySchedule,
      required this.onPeriodRemove,
      required this.onAddTime,
      required this.onChangedTime,
      required this.onDeleteTime,
      required this.promptChangeWeeks});

  final String? periodName;
  final WeeklySchedule weeklySchedule;
  final Function()? onPeriodRemove;
  final Function() onAddTime;
  final Function(int) onChangedTime;
  final Function(int) onDeleteTime;
  final Function() promptChangeWeeks;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (periodName != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, left: 10.0),
              child: Text(
                periodName!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: onPeriodRemove,
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
      if (periodName != null)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 10.0),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    const Text('* Date de début'),
                    Text(
                        DateFormat.yMMMEd().format(weeklySchedule.period.start))
                  ]),
                  Column(children: [
                    const Text('* Date de fin'),
                    Text(DateFormat.yMMMEd().format(weeklySchedule.period.end))
                  ]),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                ),
                onPressed: promptChangeWeeks,
              )
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('* Sélectionner les jours et les horaires de stage'),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                ...weeklySchedule.schedule.asMap().keys.map(
                      (i) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              weeklySchedule.schedule[i].dayOfWeek.name,
                            ),
                          ),
                          Container(),
                          Text(
                              weeklySchedule.schedule[i].start.format(context)),
                          Text(weeklySchedule.schedule[i].end.format(context)),
                          GestureDetector(
                            onTap: () => onChangedTime(i),
                            child: const Icon(Icons.access_time,
                                color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () => onDeleteTime(i),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                TableRow(children: [
                  Container(),
                  Container(),
                  Container(),
                  Container(),
                  GestureDetector(
                    onTap: onAddTime,
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  Container(),
                ]),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
