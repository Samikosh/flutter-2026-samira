import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';

class BookFormScreen extends StatefulWidget {
  final Book? initialBook;
  const BookFormScreen({super.key, this.initialBook});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _limitController;
  BookCategory? _category;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialBook?.title ?? '');
    _limitController = TextEditingController(text: widget.initialBook?.limit.toString() ?? '10');
    _category = widget.initialBook?.category;
    _date = widget.initialBook?.when;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick date')));
      return;
    }

    final newBook = Book(
      id: DateTime.now().toString(),
      title: _titleController.text,
      category: _category!,
      when: _date!,
      limit: int.parse(_limitController.text),
      readers: [],
      mode: false,
      description: null,
      favourite: false,
    );
    Navigator.pop(context, newBook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Book')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => (v ?? '').length < 3 ? 'Too short' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BookCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: [for (final c in BookCategory.values) DropdownMenuItem(value: c, child: Text(c.label))],
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(labelText: 'Limit', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => int.tryParse(v ?? '') == null ? 'Enter number' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _date = d);
              },
              child: Text(_date == null ? 'Pick Date' : _date.toString().substring(0, 10)),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}