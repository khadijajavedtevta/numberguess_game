import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {

  late Future<List<Map<String, dynamic>>> history;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() {
    history = DatabaseHelper.instance.getGuesses();
  }

  // DELETE HISTORY
  Future<void> clearHistory() async {

    await DatabaseHelper.instance.deleteAllGuesses();

    setState(() {
      loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess History'),

        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearHistory,
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: history,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No History Available'),
            );
          }

          final guesses = snapshot.data!;

          return ListView.builder(
            itemCount: guesses.length,

            itemBuilder: (context, index) {

              final item = guesses[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: CircleAvatar(
                    child: Text(
                      '${item['guess']}',
                    ),
                  ),

                  title: Text(
                    item['result'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Target Number: ${item['target']}\n'
                        'Date: ${item['created_at']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}