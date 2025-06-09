import 'package:puzzle_game/models/edge.dart';
import 'package:puzzle_game/models/face.dart';
import 'package:vector_math/vector_math_64.dart';

class Mesh {
  final List<BFace> _faces;

  Mesh({required List<BFace> faces}) : _faces = faces;

  List<BFace> get faces => _faces;
  List<Edge> get edges {
    final List<Edge> edges = [];
    for (final face in _faces) {
      if (face is QFace) {
        edges.addAll(face.edges);
      } else if (face is TFace) {
        edges.addAll(face.edges);
      }
    }
    return edges;
  }

  List<Vector3> get vertices {
    final Set<Vector3> vertexSet = {};
    for (final face in _faces) {
      for (final point in face.points) {
        vertexSet.add(point);
      }
    }
    return vertexSet.toList();
  }

  // static basic forms of meshes
  static Mesh cube() {
    return Mesh(
      faces: [
        // Front face
        QFace.fromPoints(
          Vector3(-0.5, -0.5, 0.5),
          Vector3(0.5, -0.5, 0.5),
          Vector3(0.5, 0.5, 0.5),
          Vector3(-0.5, 0.5, 0.5),
        ),
        // Back face
        QFace.fromPoints(
          Vector3(0.5, -0.5, -0.5),
          Vector3(-0.5, -0.5, -0.5),
          Vector3(-0.5, 0.5, -0.5),
          Vector3(0.5, 0.5, -0.5),
        ),
        // Left face
        QFace.fromPoints(
          Vector3(-0.5, -0.5, -0.5),
          Vector3(-0.5, -0.5, 0.5),
          Vector3(-0.5, 0.5, 0.5),
          Vector3(-0.5, 0.5, -0.5),
        ),
        // Right face
        QFace.fromPoints(
          Vector3(0.5, -0.5, 0.5),
          Vector3(0.5, -0.5, -0.5),
          Vector3(0.5, 0.5, -0.5),
          Vector3(0.5, 0.5, 0.5),
        ),
        // Top face
        QFace.fromPoints(
          Vector3(-0.5, 0.5, 0.5),
          Vector3(0.5, 0.5, 0.5),
          Vector3(0.5, 0.5, -0.5),
          Vector3(-0.5, 0.5, -0.5),
        ),
        // Bottom face
        QFace.fromPoints(
          Vector3(-0.5, -0.5, -0.5),
          Vector3(0.5, -0.5, -0.5),
          Vector3(0.5, -0.5, 0.5),
          Vector3(-0.5, -0.5, 0.5),
        ),
      ],
    );
  }
}
