import 'dart:math';

import 'package:puzzle_game/models/model.dart';
import 'package:puzzle_game/models/mesh.dart';

class Cube extends Model {
  static int _idCounter = 0;
  final SlideDirection _slideDirection;
  SlideDirection get slideDirection => _slideDirection;

  Cube({required super.position})
    : _slideDirection =
          SlideDirection.values[Random().nextInt(SlideDirection.values.length)],
      super(id: 'cube_${_idCounter++}', mesh: Mesh.cube());
}

enum SlideDirection { left, right, up, down, forward, backward }
