import 'package:flutter/material.dart';
import 'package:ey/database_helper.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper.instance.getEntries();
    setState(() {
      _entries.addAll(entries);
    });
  }

  final List<JournalEntry> _entries = [];
  final TextEditingController _entryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Format French-style date
  String _formatDate(DateTime date) {
    const monthNames = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFc3cde6),
            title: const Text(

              'Mon Journal',
              style: TextStyle(fontFamily: 'Poppins',color: Colors.white),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(),
        backgroundColor: const Color(0xFFc3cde6),
        child: const Icon(Icons.add),
      ),
      body:
      _entries.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Commencez votre journal',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder:
            (context, index) => _buildEntryCard(_entries[index]),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey[600]),
                  onPressed: () => _deleteEntry(entry.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(entry.content),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog() {
    setState(() => _selectedDate = DateTime.now());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Nouvelle entrée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _entryController,
              maxLines: 5,
              autofocus: true, // Auto-focus enhancement
              decoration: InputDecoration(
                hintText: 'Écrivez vos pensées...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Changer'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFc3cde6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_entryController.text.trim().isNotEmpty) {
                _addEntry();
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addEntry() async {
    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      content: _entryController.text.trim(),
    );

    await DatabaseHelper.instance.insertEntry(newEntry);

    setState(() {
      _entries.insert(0, newEntry); // insert at top
      _entryController.clear();
    });
  }

  void _deleteEntry(String id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

}

class JournalEntry {
  final String id;
  final DateTime date;
  final String content;

  JournalEntry({required this.id, required this.date, required this.content});
}
