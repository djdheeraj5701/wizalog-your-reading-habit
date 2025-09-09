import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogPagesForm extends StatefulWidget {
  final String bookName;
  final Function(int pages, DateTime timestamp) onLogPages;
  final VoidCallback onFinishBook;

  const LogPagesForm({
    required this.bookName,
    required this.onLogPages,
    required this.onFinishBook,
    super.key,
  });

  @override
  State<LogPagesForm> createState() => _LogPagesFormState();
}

class _LogPagesFormState extends State<LogPagesForm> {
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _timestampController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTimestamp();
  }

  void _updateTimestamp() {
    _timestampController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updateTimestamp();
        });
      }
    }
  }

  void _submitLog() {
    final pages = int.tryParse(_pagesController.text);
    if (pages != null && pages > 0) {
      widget.onLogPages(pages, _selectedDate);
      _pagesController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _updateTimestamp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How many pages did you read?',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.bookName,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pages Read',
                        hintText: 'e.g., 25',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _timestampController,
                      readOnly: true,
                      onTap: () => _selectDateTime(context),
                      decoration: InputDecoration(
                        labelText: 'Timestamp',
                        suffixIcon: Icon(Icons.access_time_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitLog,
                      child: const Text('Log Pages'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: widget.onFinishBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Finish Book'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
