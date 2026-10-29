import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../store/habit_store.dart';

/// Thêm mới hoặc sửa thói quen. Dùng Slider để chọn mục tiêu ngày/tuần.
class HabitFormPage extends StatefulWidget {
  final Habit? habit;
  const HabitFormPage({super.key, this.habit});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late int _icon;
  late int _color;
  late double _target;

  bool get _editing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.name ?? '');
    _note = TextEditingController(text: h?.note ?? '');
    _icon = h?.iconIndex ?? 0;
    _color = h?.colorIndex ?? 0;
    _target = (h?.targetPerWeek ?? 7).toDouble();
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final h = widget.habit;
    if (h != null) {
      h
        ..name = _name.text.trim()
        ..note = _note.text.trim()
        ..iconIndex = _icon
        ..colorIndex = _color
        ..targetPerWeek = _target.round();
      store.update(h);
    } else {
      store.add(Habit(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        note: _note.text.trim(),
        iconIndex: _icon,
        colorIndex: _color,
        targetPerWeek: _target.round(),
      ));
    }
    Navigator.of(context).pop();
  }

  String get _targetLabel {
    final t = _target.round();
    if (t == 7) return 'Mỗi ngày';
    return '$t ngày mỗi tuần';
  }

  @override
  Widget build(BuildContext context) {
    final color = HabitStyle.colors[_color];
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Sửa thói quen' : 'Thói quen mới')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Xem trước
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: color.withAlpha(40),
                child: Icon(HabitStyle.icons[_icon], color: color, size: 36),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tên thói quen',
                hintText: 'VD: Uống 2 lít nước',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập tên thói quen'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Biểu tượng', style: text.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(HabitStyle.icons.length, (i) {
                final sel = i == _icon;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _icon = i),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sel ? color.withAlpha(50) : Colors.grey.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? color : Colors.transparent, width: 2),
                    ),
                    child: Icon(HabitStyle.icons[i], color: sel ? color : null),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text('Màu sắc', style: text.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(HabitStyle.colors.length, (i) {
                final c = HabitStyle.colors[i];
                return GestureDetector(
                  onTap: () => setState(() => _color = i),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: c,
                    child: i == _color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Mục tiêu', style: text.titleMedium),
                const Spacer(),
                Text(_targetLabel,
                    style: text.titleMedium?.copyWith(color: color)),
              ],
            ),
            Slider(
              value: _target,
              min: 1,
              max: 7,
              divisions: 6,
              label: '${_target.round()} ngày',
              activeColor: color,
              onChanged: (v) => setState(() => _target = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(_editing ? 'Lưu thay đổi' : 'Tạo thói quen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
