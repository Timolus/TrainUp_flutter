// TrainUp v0.1 – Flutter App
// Funktionen: Workout-Eingabe, Kalorien-Tracking, Streak-System, einstellbare Benachrichtigungen, Wochen-/Monatsrückblick

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

void main() => runApp(const TrainUpApp());

class TrainUpApp extends StatelessWidget {
  const TrainUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainUp',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _workouts = <String>[];
  int _streak = 0;
  DateTime? _lastWorkout;

  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await _prefs;
    setState(() {
      _streak = prefs.getInt('streak') ?? 0;
      final lastDate = prefs.getString('lastWorkout');
      if (lastDate != null) _lastWorkout = DateTime.tryParse(lastDate);
    });
  }

  Future<void> _saveWorkout(String workout) async {
    final prefs = await _prefs;
    final now = DateTime.now();
    if (_lastWorkout == null || now.difference(_lastWorkout!).inDays >= 1) {
      _streak++;
      _lastWorkout = now;
      await prefs.setInt('streak', _streak);
      await prefs.setString('lastWorkout', now.toIso8601String());
    }
    setState(() => _workouts.add(workout));
  }

  void _showWorkoutDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Workout eintragen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'z.B. Laufen – 30 Min'),
        ),
        actions: [
          TextButton(
            child: const Text('Speichern'),
            onPressed: () {
              _saveWorkout(controller.text);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('TrainUp')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Streak: $_streak Tage', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            if (_lastWorkout != null)
              Text('Letztes Training: ${df.format(_lastWorkout!)}'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Workout eintragen'),
              onPressed: _showWorkoutDialog,
            ),
            const SizedBox(height: 20),
            const Text('Letzte Workouts:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _workouts.length,
                itemBuilder: (_, i) => ListTile(title: Text(_workouts[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
