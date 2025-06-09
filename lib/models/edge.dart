import 'package:vector_math/vector_math_64.dart';

class Edge {
  Vector3 start;
  Vector3 end;

  double get length => (end - start).length;

  Edge(this.start, this.end);
}
