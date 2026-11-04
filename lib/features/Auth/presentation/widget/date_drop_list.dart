import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateDropList extends StatefulWidget {
  ValueChanged<DateTime> onChange;
  DateDropList({super.key, required this.onChange});

  @override
  State<DateDropList> createState() => _DateDropListState();
}

class _DateDropListState extends State<DateDropList> {
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;

  // Days: ["1", "2", "3", ..., "31"]
  List<String> days = [];

  // Months: ["1", "2", "3", ..., "12"]
  final List<String> months = List.generate(
    12,
    (index) => (index + 1).toString(),
  );

  // Years: Dynamically generated from 1950 to the current year (2026)
  // You can adjust the starting year (1950) depending on your needs.
  final List<String> years = List.generate(
    DateTime.now().year - 1950 + 1,
    (index) => (DateTime.now().year - index)
        .toString(), // Descending order (2026, 2025...)
  );

  int _getTotalDays(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateDayList() {
    final int year = int.tryParse(_selectedYear ?? "") ?? DateTime.now().year;
    final int month = int.tryParse(_selectedMonth ?? "") ?? 1;
    final int totalDays = _getTotalDays(month, year);
    setState(() {
      days = List.generate(totalDays, (index) => (index + 1).toString());
    });
    if (_selectedDay != null) {
      final int currentDays = int.parse(_selectedDay!);
      if (currentDays > totalDays) {
        setState(() {
          _selectedDay = totalDays.toString();
        });
      }
    }
    _notifyParent();
  }

  void _notifyParent() {
    if (_selectedDay != null &&
        _selectedMonth != null &&
        _selectedYear != null) {
      final int year = int.parse(_selectedYear!);
      final int month = int.parse(_selectedMonth!);
      final int day = int.parse(_selectedDay!);

      widget.onChange(DateTime(year, month, day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: dateBox(
            dates: months,
            selectedDate: _selectedMonth,
            hint: "Mon",
            onChanged: (val) {
              setState(() {
                _selectedMonth = val;
                _updateDayList();
              });
            },
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: dateBox(
            dates: days,
            selectedDate: _selectedDay,
            hint: "Day",
            onChanged: (val) {
              setState(() {
                _selectedDay = val;
                _notifyParent();
              });
            },
          ),
        ),
        SizedBox(width: 5),

        Expanded(
          child: dateBox(
            dates: years,
            selectedDate: _selectedYear,
            hint: "Year",
            onChanged: (val) {
              setState(() {
                _selectedYear = val;
                _updateDayList();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget dateBox({
    required List<String> dates,
    String? selectedDate,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: selectedDate,
      hint: Text(hint, style: TextStyle(color: Colors.grey)),
      items: dates.map((String date) {
        return DropdownMenuItem(value: date, child: Text(date));
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),

      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
