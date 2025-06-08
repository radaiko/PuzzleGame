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
    // Front face (counter-clockwise when viewed from outside)
    0, 1, 2, 0, 2, 3,
    // Back face (counter-clockwise when viewed from outside)
    5, 4, 7, 5, 7, 6,
    // Left face (counter-clockwise when viewed from outside)
    4, 0, 3, 4, 3, 7,
    // Right face (counter-clockwise when viewed from outside)
    1, 5, 6, 1, 6, 2,
    // Top face (counter-clockwise when viewed from outside)
    3, 2, 6, 3, 6, 7,
    // Bottom face (counter-clockwise when viewed from outside)
    0, 4, 5, 0, 5, 1,
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
    const Color(0xFF808080), // Solid grey
    const Color(0xFF808080),
    const Color(0xFF808080),
    const Color(0xFF808080),
    const Color(0xFF808080),
    const Color(0xFF808080),
    const Color(0xFF808080),
    const Color(0xFF808080),
  ];

  /// Get wireframe edges for drawing cube outline
  List<List<int>> get wireframeEdges => [
    // Front face edges
    [0, 1], [1, 2], [2, 3], [3, 0],
    // Back face edges
    [4, 5], [5, 6], [6, 7], [7, 4],
    // Connecting edges between front and back
    [0, 4], [1, 5], [2, 6], [3, 7],
  ];

  @override
  void update(double deltaTime) {
    // Optional: Add animation logic here (e.g., rotation)
    // For example, rotate the cube over time
  }
}

enum SlideDirection { left, right, up, down, forward, backward }
