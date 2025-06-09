import 'package:puzzle_game/models/edge.dart';
import 'package:puzzle_game/models/face.dart';
import 'package:vector_math/vector_math_64.dart';

class Mesh {
  List<BFace> _faces;

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
}
