import 'package:flutter/material.dart';

class NewBookForm extends StatefulWidget {
  final Function(String) onStartReading;

  const NewBookForm({
    super.key,
    required this.onStartReading,
  });

  @override
  State<NewBookForm> createState() => _NewBookFormState();
}

class _NewBookFormState extends State<NewBookForm> {
  final TextEditingController _bookNameController = TextEditingController();

  void _submit() {
    if (_bookNameController.text.isNotEmpty) {
      widget.onStartReading(_bookNameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Started a new book?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bookNameController,
              decoration: InputDecoration(
                labelText: 'Book Title',
                hintText: 'Enter Book Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Start Reading'),
            ),
          ],
        ),
      ),
    );
  }
}
