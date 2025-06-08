import 'package:puzzle_game/models/cube.dart';
import 'package:puzzle_game/models/model_3d.dart';
import 'package:vector_math/vector_math_64.dart';

class GameSpace {
  // 3D space represented as a 3D list of cubes
  List<List<List<Cube?>>> _space = List.generate(
    0,
    (_) => List.generate(0, (_) => List.generate(0, (_) => null)),
  );

  int get remainingCubes {
    int count = 0;
    for (var layer in _space) {
      for (var row in layer) {
        for (var cube in row) {
          if (cube != null) count++;
        }
      }
    }
    return count;
  }

  int _width;
  int _height;
  int _depth;

  GameSpace(int width) : this._(width, width, width);

  GameSpace._(this._width, this._height, this._depth)
    : _space = List.generate(
        _width,
        (_) =>
            List.generate(_height, (_) => List.generate(_depth, (_) => null)),
      ) {
    _generateGameField();
  }

  void _generateGameField() {
    int maxCubes = _width * _height * _depth;

    for (int i = 0; i < maxCubes; i++) {
      int x = i % _width;
      int y = (i ~/ _width) % _height;
      int z = i ~/ (_width * _height);
      if (x < _width && y < _height && z < _depth) {
        _space[x][y][z] = Cube(
          position: Vector3(x.toDouble(), y.toDouble(), z.toDouble()),
          rotation: Vector3.zero(),
          scale: Vector3.all(1.0),
          visible: true,
        );
      }
    }
  }

  bool tryMoveCube(int x, int y, int z) {
    if (x < 0 || x >= _width || y < 0 || y >= _height || z < 0 || z >= _depth) {
      return false; // Out of bounds
    }

    Cube? cube = _space[x][y][z];
    if (cube == null) {
      return false; // No cube to move
    }

    // Get the slide direction from the cube
    var slideDirection = cube.slideDirection;

    // Calculate direction vector based on slide direction
    int dx = 0, dy = 0, dz = 0;
    switch (slideDirection) {
      case SlideDirection.left:
        dx = -1;
        break;
      case SlideDirection.right:
        dx = 1;
        break;
      case SlideDirection.up:
        dy = -1;
        break;
      case SlideDirection.down:
        dy = 1;
        break;
      case SlideDirection.forward:
        dz = -1;
        break;
      case SlideDirection.backward:
        dz = 1;
        break;
    }

    // Check if path is clear in the slide direction until it hits the edge of the game space
    int nextX = x + dx;
    int nextY = y + dy;
    int nextZ = z + dz;

    while (nextX >= 0 &&
        nextX < _width &&
        nextY >= 0 &&
        nextY < _height &&
        nextZ >= 0 &&
        nextZ < _depth) {
      if (_space[nextX][nextY][nextZ] != null) {
        return false; // Path blocked
      }
      nextX += dx;
      nextY += dy;
      nextZ += dz;
    }

    // Path is clear, remove the cube
    _space[x][y][z] = null;
    return true;
    // TODO: redraw new state of the game
  }

  List<Model3D> get models {
    List<Model3D> models = [];
    for (var layer in _space) {
      for (var row in layer) {
        for (var cube in row) {
          if (cube != null) {
            models.add(cube);
          }
        }
      }
    }
    return models;
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln(
      'GameSpace(width: $_width, height: $_height, depth: $_depth, cubes: ${_space.length})',
    );

    for (int z = 0; z < _depth; z++) {
      sb.writeln('Layer $z:');
      for (int y = 0; y < _height; y++) {
        for (int x = 0; x < _width; x++) {
          Cube? cube = _space[x][y][z];
          sb.write(cube != null ? cube.slideDirection.toString() : 'null');
          sb.write(' ');
        }
        sb.writeln();
      }
      sb.writeln();
    }
    sb.writeln('Remaining cubes: $remainingCubes');
    sb.writeln('Total cubes: ${_width * _height * _depth}');

    return sb.toString();
  }
}
