import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StoryPuzzleApp3());
}

class StoryPuzzleApp3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.orange),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jumbled Story Game',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LevelSelectionScreen()),
            );
          },
          child: Text('Start Game', style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    );
  }
}

class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  bool isLevel2Unlocked = false;

  @override
  void initState() {
    super.initState();
    _loadLevelProgress();
  }

  Future<void> _loadLevelProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLevel2Unlocked = prefs.getBool('level2Unlocked') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLevelButton(context, 'Level 1', 1, true),
          SizedBox(height: 20),
          _buildLevelButton(context, 'Level 2', 2, isLevel2Unlocked),
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String text, int level, bool isUnlocked) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        backgroundColor: isUnlocked ? Colors.green : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoryScreen(level: level)),
              );
            }
          : null,
      child: Text(text, style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final int level;
  StoryScreen({required this.level});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentStory = 0;

  List<List<String>> level1Stories = [
    ["A little boy was holding a red balloon.", "Suddenly, the wind blew it away.", "He ran after it as fast as he could.", "Finally, a kind stranger caught it for him."],
    ["A squirrel was looking for food.", "It found a big nut under a tree.", "Happily, it carried the nut back to its home.", "Then, it ate the nut and fell asleep."],
    ["Dark clouds filled the sky.", "Soon, it started to rain heavily.", "The children ran outside to play in the puddles.", "They laughed and splashed in the water."],
  ];

  List<List<String>> level2Stories = [
    ["A fire broke out in a tall building.", "A firefighter rushed to the scene.", "He saved a little kitten stuck inside.", "Everyone cheered for the brave firefighter."],
    ["The students went on a school picnic.", "They played games and ate tasty food.", "A butterfly landed on a girl’s hand.", "She smiled as it fluttered away."],
    ["A boy found a magic paintbrush.", "Whatever he painted came to life.", "He painted a golden castle and a flying horse.", "He rode the horse and lived happily in the castle."],
  ];


  late List<List<String>> stories;
  late List<String> shuffledSentences;

  @override
  void initState() {
    super.initState();
    stories = widget.level == 1 ? level1Stories : level2Stories;
    shuffledSentences = List.from(stories[currentStory])..shuffle();
  }

  void checkOrder() async {
    if (shuffledSentences.join(" ") == stories[currentStory].join(" ")) {
      setState(() => score += 10);
      await flutterTts.speak(stories[currentStory].join(" "));
      if (currentStory < stories.length - 1) {
        setState(() {
          currentStory++;
          shuffledSentences = List.from(stories[currentStory])..shuffle();
        });
      } else {
        if (widget.level == 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('level2Unlocked', true);
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => CompletionScreen(score: score)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect order! Try again.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.level == 1 ? 'assets/background6.png' : 'assets/background7.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Score: $score', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
            Expanded(
              child: ReorderableListView(
                children: shuffledSentences.map((sentence) =>
                  Card(
                    color: Colors.yellowAccent,
                    key: ValueKey(sentence),
                    child: ListTile(title: Text(sentence, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), leading: Icon(Icons.drag_handle, color: Colors.orange)),
                  ),
                ).toList(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = shuffledSentences.removeAt(oldIndex);
                    shuffledSentences.insert(newIndex, item);
                  });
                },
              ),
            ),
            ElevatedButton(onPressed: checkOrder, child: Text('Check Answer')),
          ],
        ),
      ),
    );
  }
}

class CompletionScreen extends StatelessWidget {
  final int score;

  CompletionScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level Completed!'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your Score: $score',
              style: TextStyle(fontSize: 20, color: Colors.deepPurple),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}