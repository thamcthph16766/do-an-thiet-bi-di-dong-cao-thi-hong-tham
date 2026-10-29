import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/habit.dart';
import '../store/habit_store.dart';
import '../widgets/common.dart';
import 'habit_form_page.dart';

/// Chi tiết một thói quen: thống kê + lịch tháng (table_calendar).
class HabitDetailPage extends StatefulWidget {
  final Habit habit;
  const HabitDetailPage({super.key, required this.habit});

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  DateTime _focused = dateOnly(DateTime.now());

  Future<void> _delete() async {
    final h = widget.habit;
    final ok = await confirmDialog(context,
        title: 'Xoá thói quen?',
        message: 'Xoá "${h.name}" và toàn bộ lịch sử của nó.',
        ok: 'Xoá',
        danger: true);
    if (!ok || !mounted) return;
    store.remove(h);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final h = widget.habit;
        final today = dateOnly(DateTime.now());
        final text = Theme.of(context).textTheme;
        final week = h.doneThisWeek();

        return Scaffold(
          appBar: AppBar(
            title: Text(h.name),
            actions: [
              IconButton(
                tooltip: 'Sửa',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => HabitFormPage(habit: h))),
              ),
              IconButton(
                tooltip: 'Xoá',
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (h.note.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.sticky_note_2_outlined, color: h.color),
                    title: Text(h.note),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: StatBox(
                        label: 'Chuỗi hiện tại',
                        value: '${h.currentStreak()} ngày',
                        icon: Icons.local_fire_department,
                        color: Colors.deepOrange),
                  ),
                  Expanded(
                    child: StatBox(
                        label: 'Chuỗi dài nhất',
                        value: '${h.bestStreak} ngày',
                        icon: Icons.emoji_events,
                        color: Colors.amber.shade700),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: StatBox(
                        label: 'Tổng số ngày',
                        value: '${h.doneDates.length}',
                        icon: Icons.check_circle,
                        color: Colors.green),
                  ),
                  Expanded(
                    child: StatBox(
                        label: 'Tỉ lệ 30 ngày',
                        value: '${(h.completionRate(30) * 100).round()}%',
                        icon: Icons.percent,
                        color: h.color),
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          week >= h.targetPerWeek
                              ? 'Tuần này: $week/${h.targetPerWeek} ngày ✅ Đạt mục tiêu!'
                              : 'Tuần này: $week/${h.targetPerWeek} ngày',
                          style: text.titleSmall),
                      const SizedBox(height: 10),
                      RoundedProgress(
                          value: week / h.targetPerWeek, color: h.color),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TableCalendar(
                    locale: 'vi_VN',
                    firstDay: DateTime(today.year - 1, 1, 1),
                    lastDay: today,
                    focusedDay: _focused.isAfter(today) ? today : _focused,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Tháng'
                    },
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                    onDaySelected: (selected, focused) {
                      // table_calendar trả ngày dạng UTC → đổi về ngày địa phương
                      final day =
                          DateTime(selected.year, selected.month, selected.day);
                      if (day.isAfter(today)) return;
                      store.toggle(h, day);
                      _focused =
                          DateTime(focused.year, focused.month, focused.day);
                    },
                    onPageChanged: (focused) => _focused =
                        DateTime(focused.year, focused.month, focused.day),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) =>
                          h.isDoneOn(day) ? _DayCell(day: day, color: h.color, done: true) : null,
                      todayBuilder: (context, day, focusedDay) => _DayCell(
                          day: day,
                          color: h.color,
                          done: h.isDoneOn(day),
                          isToday: true),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chạm vào một ngày trên lịch để đánh dấu hoặc bỏ đánh dấu.',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final Color color;
  final bool done;
  final bool isToday;
  const _DayCell(
      {required this.day,
      required this.color,
      required this.done,
      this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? color : Colors.transparent,
          border: isToday ? Border.all(color: color, width: 2) : null,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: done ? Colors.white : null,
            fontWeight: done || isToday ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}
