import 'dart:math';
import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'history_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() =>
      _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  final TextEditingController controller =
  TextEditingController();

  int targetNumber = 0;
  int attempts = 0;

  String message =
      'Guess a number between 1 and 100';

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  // GENERATE RANDOM NUMBER
  void startNewGame() {
    setState(() {
      targetNumber = Random().nextInt(100) + 1;
      attempts = 0;
      message = 'Guess a number between 1 and 100';
      gameOver = false;
      controller.clear();
    });
  }

  // CHECK USER GUESS
  Future<void> checkGuess() async {
    if (gameOver) return;

    final int? guess = int.tryParse(controller.text.trim());

    // Validate input
    if (guess == null || guess < 1 || guess > 100) {
      setState(() {
        message = 'Enter a valid number from 1 to 100';
      });
      return;
    }

    // Calculate result
    String result;

    if (guess > targetNumber) {
      result = 'Too High';
    } else if (guess < targetNumber) {
      result = 'Too Low';
    } else {
      result = 'Correct';
      gameOver = true;
    }

    // Update UI immediately
    setState(() {
      attempts++;
      message = result;
      controller.clear();
    });

    // Save guess in SQLite
    try {
      await DatabaseHelper.instance.insertGuess({
        'guess': guess,
        'target': targetNumber,
        'result': result,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      debugPrint('SQLite Save Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: $e'),
          ),
        );
      }
    }

    // Show winning dialog
    if (result == 'Correct' && mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(
              'You guessed the correct number '
                  'in $attempts attempts.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  startNewGame();
                },
                child: const Text('New Game'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Guessing Game'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.casino,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              'Guess the Number',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Your Guess',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gameOver ? null : checkGuess,
                child: const Text('CHECK GUESS'),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Attempts: $attempts',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: startNewGame,
              child: const Text('NEW GAME'),
            ),
          ],
        ),
      ),
    );
  }
}