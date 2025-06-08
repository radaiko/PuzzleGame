import 'package:puzzle_game/models/model_3d.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/cupertino.dart';

class Pyramid extends Model3D {
  static int _idCounter = 0;

  /// Constructor for Pyramid with optional parameters
  Pyramid({super.position, super.rotation, super.scale, super.visible = true});

  @override
  String get id => 'pyramid_${_idCounter++}';

  @override
  List<Vector3> get vertices => [
    // Base vertices (square)
    Vector3(-0.5, -0.5, -0.5), // 0
    Vector3(0.5, -0.5, -0.5), // 1
    Vector3(0.5, -0.5, 0.5), // 2
    Vector3(-0.5, -0.5, 0.5), // 3
    // Apex (top of pyramid)
    Vector3(0.0, 0.5, 0.0), // 4
  ];

  @override
  List<int> get indices => [
    // Base (bottom face)
    0, 2, 1, 0, 3, 2,
    // Triangle faces
    0, 1, 4, // Front face
    1, 2, 4, // Right face
    2, 3, 4, // Back face
    3, 0, 4, // Left face
  ];

  @override
  List<Vector3> get normals => [
    // Base normals
    Vector3(0, -1, 0),
    Vector3(0, -1, 0),
    Vector3(0, -1, 0),
    Vector3(0, -1, 0),
    // Apex normal (approximate)
    Vector3(0, 1, 0),
  ];

  @override
  List<Color> get vertexColors => [
    // Base vertices - purple
    CupertinoColors.systemPurple,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPurple,
    // Apex - yellow
    CupertinoColors.systemYellow,
  ];

  @override
  void update(double deltaTime) {
    // Example: Rotate the pyramid slowly around Y-axis
    rotation = Vector3(rotation.x, rotation.y + deltaTime * 0.5, rotation.z);
  }
}
