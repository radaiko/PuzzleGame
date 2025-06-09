import 'dart:ui';
import 'package:puzzle_game/models/edge.dart';
import 'package:puzzle_game/models/face.dart';
import 'package:puzzle_game/models/mesh.dart';
import 'package:vector_math/vector_math_64.dart';

class Model {
  /// Unique identifier for the model
  final String _id;

  /// Position, rotation, and scale of the model in 3D space
  final Vector3 _position;

  /// Rotation of the model in radians (Euler angles)
  final Vector3 _rotation;

  /// Scale of the model in 3D space
  final Vector3 _scale;

  /// Whether the model is visible in the scene
  final bool _isVisible;

  /// The mesh that defines the geometry of this model
  final Mesh _mesh;

  /// Creates a new model with the given mesh and optional position, rotation, scale, and visibility.
  Model({required String id, required Mesh mesh, required Vector3 position})
    : _id = id,
      _mesh = mesh,
      _position = position,
      _rotation = Vector3.zero(),
      _scale = Vector3.all(1.0),
      _isVisible = true;

  // getters
  String get id => _id;
  Vector3 get position => _position;
  Vector3 get rotation => _rotation;
  Vector3 get scale => _scale;
  bool get isVisible => _isVisible;
  Mesh get mesh => _mesh;
  List<Vector3> get vertices => _mesh.vertices;
  List<BFace> get faces => _mesh.faces;
  List<Edge> get edges => _mesh.edges;

  /// Get triangulated indices for rendering
  List<int> get indices {
    final List<int> triangleIndices = [];
    final vertices = this.vertices;

    for (final face in faces) {
      if (face is QFace) {
        // Triangulate quadrilateral face (split into 2 triangles)
        final points = face.points;
        final indices = points.map((point) => vertices.indexOf(point)).toList();

        // First triangle: 0, 1, 2
        triangleIndices.addAll([indices[0], indices[1], indices[2]]);
        // Second triangle: 0, 2, 3
        triangleIndices.addAll([indices[0], indices[2], indices[3]]);
      } else if (face is TFace) {
        // Triangular face is already a triangle
        final points = face.points;
        final indices = points.map((point) => vertices.indexOf(point)).toList();
        triangleIndices.addAll(indices);
      }
    }

    return triangleIndices;
  }

  /// Get vertex colors for rendering
  List<Color> get vertexColors {
    final List<Color> colors = [];
    final vertices = this.vertices;

    for (final vertex in vertices) {
      // Find which face this vertex belongs to and use its color
      Color vertexColor = const Color(0xFF808080); // Default gray color

      for (final face in faces) {
        if (face.points.contains(vertex)) {
          final faceColor = face.color;
          vertexColor = Color.fromARGB(
            (faceColor.a * 255).round(),
            (faceColor.r * 255).round(),
            (faceColor.g * 255).round(),
            (faceColor.b * 255).round(),
          );
          break;
        }
      }
      colors.add(vertexColor);
    }

    return colors;
  }

  // public methods

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
