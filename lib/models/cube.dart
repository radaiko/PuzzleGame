import 'dart:math';

import 'package:puzzle_game/models/model_3d.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/cupertino.dart';

class Cube extends Model3D {
  static int _idCounter = 0;
  final SlideDirection _slideDirection;
  SlideDirection get slideDirection => _slideDirection;

  /// Constructor for Cube with optional parameters
  Cube({super.position, super.rotation, super.scale, super.visible = true})
    : _slideDirection =
          SlideDirection.values[Random().nextInt(SlideDirection.values.length)];

  @override
  String get id => 'cube_${_idCounter++}';

  @override
  List<Vector3> get vertices => [
    // Front face
    Vector3(-0.5, -0.5, 0.5), // 0
    Vector3(0.5, -0.5, 0.5), // 1
    Vector3(0.5, 0.5, 0.5), // 2
    Vector3(-0.5, 0.5, 0.5), // 3
    // Back face
    Vector3(-0.5, -0.5, -0.5), // 4
    Vector3(0.5, -0.5, -0.5), // 5
    Vector3(0.5, 0.5, -0.5), // 6
    Vector3(-0.5, 0.5, -0.5), // 7
  ];

  @override
  List<int> get indices => [
    // Front face
    0, 1, 2, 0, 2, 3,
    // Back face
    4, 6, 5, 4, 7, 6,
    // Left face
    4, 0, 3, 4, 3, 7,
    // Right face
    1, 5, 6, 1, 6, 2,
    // Top face
    3, 2, 6, 3, 6, 7,
    // Bottom face
    4, 5, 1, 4, 1, 0,
  ];

  @override
  List<Vector3> get normals => [
    // Approximate normals for each vertex
    Vector3(0, 0, 1), // Front
    Vector3(0, 0, 1),
    Vector3(0, 0, 1),
    Vector3(0, 0, 1),
    Vector3(0, 0, -1), // Back
    Vector3(0, 0, -1),
    Vector3(0, 0, -1),
    Vector3(0, 0, -1),
  ];

  @override
  List<Color> get vertexColors => [
    // Front face - red
    CupertinoColors.systemRed,
    CupertinoColors.systemRed,
    CupertinoColors.systemRed,
    CupertinoColors.systemRed,
    // Back face - blue
    CupertinoColors.systemBlue,
    CupertinoColors.systemBlue,
    CupertinoColors.systemBlue,
    CupertinoColors.systemBlue,
  ];

  @override
  void update(double deltaTime) {
    // Optional: Add animation logic here (e.g., rotation)
    // For example, rotate the cube over time
  }
}

enum SlideDirection { left, right, up, down, forward, backward }
