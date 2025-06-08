import 'package:flutter/cupertino.dart';
import 'package:puzzle_game/logic/game_space.dart';
import 'services/service_locator.dart';
import 'scene.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initializeServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(title: 'Cube Game', home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // First third - Level text
            Expanded(
              child: Center(
                child: FutureBuilder<int>(
                  future: settings.getLevel(),
                  builder: (context, snapshot) {
                    String text;
                    if (snapshot.hasData) {
                      text = 'Level ${snapshot.data}';
                    } else {
                      text = 'Level --'; // Loading state
                    }
                    return Text(
                      text,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Second third - Start button
            Expanded(
              child: Center(
                child: CupertinoButton(
                  onPressed: () async {
                    final level = await settings.getLevel();
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => CupertinoPageScaffold(
                          child: SceneViewer(
                            gameSpace: GameSpace(_calculateSpaceSize(level)),
                          ),
                        ),
                      ),
                    );
                  },
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Third third - Empty space
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  static int _calculateSpaceSize(int level) => level * 3;
}
