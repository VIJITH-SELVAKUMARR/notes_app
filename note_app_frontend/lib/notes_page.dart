import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<dynamic> _notes = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _error = '';
  bool _isLoading = false;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    final token = await getToken();
    final url = Uri.parse('http://127.0.0.1:8000/api/notes/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _notes = json.decode(response.body);
        _error = '';
      });
    } else {
      setState(() {
        _error = 'Failed to load notes';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> createNote() async {
    final token = await getToken();
    final url = Uri.parse('http://127.0.0.1:8000/api/notes/');
    final body = json.encode({
      'title': _titleController.text,
      'content': _contentController.text,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      _titleController.clear();
      _contentController.clear();
      fetchNotes(); // refresh list
    } else {
      setState(() {
        _error = 'Failed to create note';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_error.isNotEmpty)
                    Text(_error, style: const TextStyle(color: Colors.red)),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: createNote,
                    child: const Text('Add Note'),
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return ListTile(
                          title: Text(note['title']),
                          subtitle: Text(note['content']),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
