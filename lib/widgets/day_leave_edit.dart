import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class DayLeaveEditor extends StatefulWidget {
  final DateTime leaveDate;
  final bool isHalfDay;
  final Function(DateTime, bool) onSave;

  const DayLeaveEditor({
    required this.leaveDate,
    required this.isHalfDay,
    required this.onSave,
    super.key,
  });

  @override
  State<DayLeaveEditor> createState() => _DayLeaveEditorState();
}

class _DayLeaveEditorState extends State<DayLeaveEditor> {
  late bool isHalfDay;

  @override
  void initState() {
    super.initState();
    isHalfDay = widget.isHalfDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${DateFormat('dd MMM yyyy').format(widget.leaveDate)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Mark as Half Day'),
            value: isHalfDay,
            onChanged: (value) {
              setState(() => isHalfDay = value ?? false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(widget.leaveDate, isHalfDay);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}