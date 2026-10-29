import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../store/habit_store.dart';
import '../widgets/common.dart';

/// Thống kê tổng quan: ô số liệu, biểu đồ 7 ngày, xếp hạng 30 ngày.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final habits = store.habits;
        final text = Theme.of(context).textTheme;

        if (habits.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thống kê')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Chưa có dữ liệu.\nHãy thêm thói quen hoặc tạo dữ liệu mẫu trong Cài đặt.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final today = dateOnly(DateTime.now());
        final days = List.generate(7, (i) => addDays(today, i - 6));
        final counts =
            days.map((d) => habits.where((h) => h.isDoneOn(d)).length).toList();
        final total = habits.length;
        final best = habits.fold<int>(0, (m, h) => max(m, h.bestStreak));
        final checks = habits.fold<int>(0, (s, h) => s + h.doneDates.length);
        final ranked = [...habits]
          ..sort((a, b) => b.completionRate(30).compareTo(a.completionRate(30)));

        return Scaffold(
          appBar: AppBar(title: const Text('Thống kê')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(
                    child: StatBox(
                        label: 'Thói quen',
                        value: '$total',
                        icon: Icons.list_alt,
                        color: Colors.blue)),
                Expanded(
                    child: StatBox(
                        label: 'Hôm nay',
                        value: '${counts.last}/$total',
                        icon: Icons.today,
                        color: Colors.green)),
              ]),
              Row(children: [
                Expanded(
                    child: StatBox(
                        label: 'Chuỗi dài nhất',
                        value: '$best ngày',
                        icon: Icons.local_fire_department,
                        color: Colors.deepOrange)),
                Expanded(
                    child: StatBox(
                        label: 'Tổng lượt hoàn thành',
                        value: '$checks',
                        icon: Icons.check_circle,
                        color: Colors.purple)),
              ]),
              const SizedBox(height: 16),
              Text('7 ngày gần nhất', style: text.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 180,
                    child: _WeekBars(days: days, counts: counts, total: total),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Xếp hạng 30 ngày', style: text.titleMedium),
              const SizedBox(height: 8),
              ...ranked.map((h) {
                final rate = h.completionRate(30);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: h.color.withAlpha(40),
                      child: Icon(h.icon, color: h.color),
                    ),
                    title: Text(h.name),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: RoundedProgress(value: rate, color: h.color),
                    ),
                    trailing: Text('${(rate * 100).round()}%',
                        style: text.titleMedium),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Biểu đồ cột tự vẽ, không cần thư viện ngoài.
class _WeekBars extends StatelessWidget {
  final List<DateTime> days;
  final List<int> counts;
  final int total;
  const _WeekBars(
      {required this.days, required this.counts, required this.total});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const maxBar = 120.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (i) {
        final h = total == 0 ? 0.0 : maxBar * counts[i] / total;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${counts[i]}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: max(4.0, h),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: i == days.length - 1 ? primary : primary.withAlpha(110),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 6),
              Text(DateFormat.E('vi_VN').format(days[i]),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }
}
