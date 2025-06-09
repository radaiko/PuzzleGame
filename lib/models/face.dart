import 'package:puzzle_game/models/edge.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class BFace {
  List<Vector3> get points;

  BFace();
}

/// Represents a quadrilateral face in 3D space
/// using four edges. This is a specific implementation of BFace.
class QFace implements BFace {
  final Edge _edge1;
  final Edge _edge2;
  final Edge _edge3;
  final Edge _edge4;

  // getters
  List<Vector3> get points => [
    _edge1.start,
    _edge2.start,
    _edge3.start,
    _edge4.start,
  ];
  List<Edge> get edges => [_edge1, _edge2, _edge3, _edge4];

  // constructor
  QFace(this._edge1, this._edge2, this._edge3, this._edge4) {
    if (!_isValid()) {
      throw ArgumentError('Edges do not form a valid quadrilateral face');
    }
  }

  // internal methods
  bool _isValid() {
    return _edge1.start == _edge2.start &&
        _edge2.start == _edge3.start &&
        _edge3.start == _edge4.start &&
        _edge4.start == _edge1.start;
  }
}

/// Represents a triangular face in 3D space
/// using three edges. This is a specific implementation of BFace.
class TFace implements BFace {
  final Edge _edge1;
  final Edge _edge2;
  final Edge _edge3;

  // getters
  List<Vector3> get points => [_edge1.start, _edge2.start, _edge3.start];
  List<Edge> get edges => [_edge1, _edge2, _edge3];

  // constructor
  TFace(this._edge1, this._edge2, this._edge3) {
    if (!_isValid()) {
      throw ArgumentError('Edges do not form a valid triangular face');
    }
  }

  // internal methods
  bool _isValid() {
    return _edge1.start == _edge2.start &&
        _edge2.start == _edge3.start &&
        _edge3.start == _edge1.start;
  }
}
