import 'package:puzzle_game/math/vector3.dart';
import 'package:puzzle_game/models/edge.dart';
import 'package:puzzle_game/models/face.dart';
import 'package:puzzle_game/models/mesh.dart';

class Model {
  /// Unique identifier for the model
  String _id;

  /// Position, rotation, and scale of the model in 3D space
  Vector3 _position;

  /// Rotation of the model in radians (Euler angles)
  Vector3 _rotation;

  /// Scale of the model in 3D space
  Vector3 _scale;

  /// Whether the model is visible in the scene
  bool _isVisible;

  /// The mesh that defines the geometry of this model
  Mesh _mesh;

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
}
