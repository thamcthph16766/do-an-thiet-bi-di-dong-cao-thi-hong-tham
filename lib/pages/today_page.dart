import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../store/habit_store.dart';
import '../widgets/common.dart';
import 'habit_detail_page.dart';

/// Màn hình chính: chọn ngày trong tuần, xem tiến độ và tick thói quen.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime _selected = dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final habits = store.habits;
        final total = habits.length;
        final done = habits.where((h) => h.isDoneOn(_selected)).length;
        final isToday = _selected == dateOnly(DateTime.now());
        final title = isToday
            ? 'Hôm nay'
            : DateFormat('EEEE, dd/MM', 'vi_VN').format(_selected);

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              _WeekStrip(
                selected: _selected,
                onSelect: (d) => setState(() => _selected = d),
              ),
              const SizedBox(height: 12),
              _ProgressCard(done: done, total: total),
              const SizedBox(height: 12),
              if (habits.isEmpty)
                const _EmptyState()
              else
                ...habits.map((h) => _HabitTile(habit: h, day: _selected)),
            ],
          ),
        );
      },
    );
  }
}

/// Dải 7 ngày gần nhất để chọn ngày cần đánh dấu.
class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const _WeekStrip({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = dateOnly(DateTime.now());
    final days = List.generate(7, (i) => addDays(today, i - 6));

    return Row(
      children: days.map((d) {
        final isSel = d == selected;
        final allDone = store.habits.isNotEmpty &&
            store.habits.every((h) => h.isDoneOn(d));
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? scheme.primary : scheme.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(DateFormat.E('vi_VN').format(d),
                        style: TextStyle(
                            fontSize: 12,
                            color: isSel ? scheme.onPrimary : null)),
                    const SizedBox(height: 4),
                    Text('${d.day}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSel ? scheme.onPrimary : null)),
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: allDone
                            ? (isSel ? scheme.onPrimary : Colors.green)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final value = total == 0 ? 0.0 : done / total;
    final message = total == 0
        ? 'Hãy thêm thói quen đầu tiên của bạn'
        : done == total
            ? 'Tuyệt vời! Bạn đã hoàn thành tất cả 🎉'
            : 'Còn ${total - done} thói quen nữa, cố lên!';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('$done/$total',
                    style: text.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text('hoàn thành'),
                const Spacer(),
                Text('${(value * 100).round()}%', style: text.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            RoundedProgress(value: value, height: 10),
            const SizedBox(height: 10),
            Text(message, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final DateTime day;
  const _HabitTile({required this.habit, required this.day});

  @override
  Widget build(BuildContext context) {
    final h = habit;
    final done = h.isDoneOn(day);

    return Dismissible(
      key: ValueKey(h.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDialog(context,
          title: 'Xoá thói quen?',
          message: 'Xoá "${h.name}" và toàn bộ lịch sử của nó.',
          ok: 'Xoá',
          danger: true),
      onDismissed: (_) {
        final index = store.habits.indexOf(h);
        store.remove(h);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Đã xoá "${h.name}"'),
            action: SnackBarAction(
                label: 'Hoàn tác', onPressed: () => store.insertAt(index, h)),
          ));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          leading: CircleAvatar(
            backgroundColor: h.color.withAlpha(40),
            child: Icon(h.icon, color: h.color),
          ),
          title: Text(
            h.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
              '🔥 ${h.currentStreak()} ngày liên tiếp · '
              'tuần này ${h.doneThisWeek()}/${h.targetPerWeek}'),
          trailing: _CheckButton(
            done: done,
            color: h.color,
            onTap: () {
              HapticFeedback.lightImpact();
              store.toggle(h, day);
            },
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => HabitDetailPage(habit: h))),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final bool done;
  final Color color;
  final VoidCallback onTap;
  const _CheckButton(
      {required this.done, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
        ),
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 22)
            : null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.eco_outlined,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Chưa có thói quen nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Bấm nút "Thêm" để tạo thói quen,\nhoặc vào Cài đặt → Tạo dữ liệu mẫu.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
