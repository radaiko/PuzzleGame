import 'package:puzzle_game/logic/game_space.dart';

class Game {
  final int _level;
  int get level => _level;

  final GameSpace _gameSpace;
  GameSpace get gameSpace => _gameSpace;

  Game(this._level) : _gameSpace = GameSpace(_calculateSpaceSize(_level));

  bool tryMoveCube(int x, int y, int z) => _gameSpace.tryMoveCube(x, y, z);

  static int _calculateSpaceSize(int level) => level * 3;
}
