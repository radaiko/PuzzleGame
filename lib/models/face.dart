import 'package:puzzle_game/models/edge.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class BFace {
  Vector4 get color {
    final result = Vector4.zero();
    Colors.fromHexString('#808080', result);
    return result;
  }

  List<Vector3> get points;
  List<Edge> get edges;

  BFace() {
    if (!_isValid()) {
      throw ArgumentError('Edges do not form a valid face');
    }
  }

  bool _isValid() {
    // Default implementation must be overridden by subclasses
    return false;
  }
}

/// Represents a quadrilateral face in 3D space
/// using four edges. This is a specific implementation of BFace.
class QFace extends BFace {
  final Edge _edge1;
  final Edge _edge2;
  final Edge _edge3;
  final Edge _edge4;

  // getters
  @override
  List<Vector3> get points => [
    _edge1.start,
    _edge2.start,
    _edge3.start,
    _edge4.start,
  ];
  @override
  List<Edge> get edges => [_edge1, _edge2, _edge3, _edge4];

  // constructor
  QFace(this._edge1, this._edge2, this._edge3, this._edge4) : super();
  QFace.fromPoints(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4)
    : _edge1 = Edge(p1, p2),
      _edge2 = Edge(p2, p3),
      _edge3 = Edge(p3, p4),
      _edge4 = Edge(p4, p1),
      super();

  // internal methods
  @override
  bool _isValid() {
    return _edge1.end == _edge2.start &&
        _edge2.end == _edge3.start &&
        _edge3.end == _edge4.start &&
        _edge4.end == _edge1.start;
  }
}

/// Represents a triangular face in 3D space
/// using three edges. This is a specific implementation of BFace.
class TFace extends BFace {
  final Edge _edge1;
  final Edge _edge2;
  final Edge _edge3;

  // getters
  @override
  List<Vector3> get points => [_edge1.start, _edge2.start, _edge3.start];
  @override
  List<Edge> get edges => [_edge1, _edge2, _edge3];

  // constructor
  TFace(this._edge1, this._edge2, this._edge3) : super();

  TFace.fromPoints(Vector3 p1, Vector3 p2, Vector3 p3)
    : _edge1 = Edge(p1, p2),
      _edge2 = Edge(p2, p3),
      _edge3 = Edge(p3, p1),
      super();

  // internal methods
  @override
  bool _isValid() {
    return _edge1.end == _edge2.start &&
        _edge2.end == _edge3.start &&
        _edge3.end == _edge1.start;
  }
}
