import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';

/// Generic base class for any 3D object that can be rendered in the scene
abstract class Model3D {
  /// Unique identifier for this model instance
  String get id;

  /// Position of the model in 3D space
  Vector3 position;

  /// Rotation of the model (Euler angles in radians)
  Vector3 rotation;

  /// Scale of the model
  Vector3 scale;

  /// Whether the model is visible
  bool visible;

  /// Constructor with default values
  Model3D({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    this.visible = true,
  }) : position = position ?? Vector3.zero(),
       rotation = rotation ?? Vector3.zero(),
       scale = scale ?? Vector3.all(1.0);

  /// List of vertices for the 3D model (in local space)
  List<Vector3> get vertices;

  /// List of indices for vertex connectivity (for triangles, lines, etc.)
  List<int> get indices => [];

  /// Colors for vertices (if needed)
  List<Color> get vertexColors => [];

  /// Normals for lighting calculations
  List<Vector3> get normals => [];

  /// Method to update model state (e.g., animations)
  void update(double deltaTime) {}

  /// Get the transformation matrix for this model
  Matrix4 getTransformMatrix() {
    final matrix = Matrix4.identity();

    // Apply transformations: scale -> rotate -> translate
    matrix.scale(scale.x, scale.y, scale.z);
    matrix.rotateX(rotation.x);
    matrix.rotateY(rotation.y);
    matrix.rotateZ(rotation.z);
    matrix.translate(position.x, position.y, position.z);

    return matrix;
  }

  /// Helper method to get transformed vertices in world space
  List<Vector3> getTransformedVertices() {
    final transform = getTransformMatrix();
    return vertices.map((vertex) {
      final transformed =
          transform * Vector4(vertex.x, vertex.y, vertex.z, 1.0);
      return Vector3(transformed.x, transformed.y, transformed.z);
    }).toList();
  }
}

/// Legacy alias for backward compatibility
@Deprecated('Use Model3D instead')
typedef Drawable3DModel = Model3D;
