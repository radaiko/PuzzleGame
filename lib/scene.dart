import 'package:flutter/material.dart';
import 'package:puzzle_game/logic/game_space.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'models/model_3d.dart';
import 'dart:math' as math;

// Simplified 3D renderer using basic Flutter Canvas
class Simple3DRenderer {
  Vector3 _cameraPosition = Vector3(0, 0, 5);
  final Vector3 _target = Vector3.zero();
  final Vector3 _up = Vector3(0, 1, 0);
  double _yaw = 0.0;
  double _pitch = 0.0;
  double _zoom = 5.0;
  Matrix4 _viewMatrix = Matrix4.identity();

  Simple3DRenderer() {
    updateCamera();
  }

  void updateCamera() {
    // Calculate camera position based on spherical coordinates
    _cameraPosition = Vector3(
      _target.x + _zoom * math.sin(_yaw) * math.cos(_pitch),
      _target.y + _zoom * math.sin(_pitch),
      _target.z + _zoom * math.cos(_yaw) * math.cos(_pitch),
    );

    // Create view matrix (look at)
    final forward = (_target - _cameraPosition).normalized();
    final right = forward.cross(_up).normalized();
    final up = right.cross(forward).normalized();

    _viewMatrix = Matrix4.identity();
    _viewMatrix.setColumn(0, Vector4(right.x, up.x, -forward.x, 0));
    _viewMatrix.setColumn(1, Vector4(right.y, up.y, -forward.y, 0));
    _viewMatrix.setColumn(2, Vector4(right.z, up.z, -forward.z, 0));
    _viewMatrix.setColumn(
      3,
      Vector4(
        -right.dot(_cameraPosition),
        -up.dot(_cameraPosition),
        forward.dot(_cameraPosition),
        1,
      ),
    );
  }

  void rotate(double deltaYaw, double deltaPitch) {
    _yaw += deltaYaw;
    _pitch = math.max(-math.pi / 2, math.min(math.pi / 2, _pitch + deltaPitch));
    updateCamera();
  }

  void zoom(double scale) {
    _zoom = math.max(2.0, math.min(10.0, _zoom * scale));
    updateCamera();
  }

  Vector2? projectPoint(Vector3 worldPoint, Size screenSize) {
    // Transform world point to view space
    final viewPoint =
        _viewMatrix * Vector4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0);

    // Perspective projection based on camera distance
    // Use the z-distance from camera for perspective scaling
    final distance = math.max(
      0.1,
      viewPoint.z.abs(),
    ); // Prevent division by zero
    final perspectiveScale =
        math.min(screenSize.width, screenSize.height) * 0.5 / distance;

    final screenX = screenSize.width * 0.5 + viewPoint.x * perspectiveScale;
    final screenY = screenSize.height * 0.5 - viewPoint.y * perspectiveScale;

    return Vector2(screenX, screenY);
  }

  /// Render all models in the scene
  void renderScene(
    Canvas canvas,
    List<Model3D> models,
    Size size,
    double deltaTime,
  ) {
    // Update all models
    for (final model in models) {
      model.update(deltaTime);
    }

    // Collect all triangles from all models with proper depth calculation for filled faces
    final allTriangles = <Map<String, dynamic>>[];

    for (final model in models) {
      if (!model.visible) continue;

      final vertices = model.getTransformedVertices();
      final indices = model.indices;
      final colors = model.vertexColors;

      // Project all vertices to screen space
      final projectedVertices = <Vector2?>[];
      for (final vertex in vertices) {
        projectedVertices.add(projectPoint(vertex, size));
      }

      // Create triangles for this model
      for (int i = 0; i < indices.length; i += 3) {
        final i0 = indices[i];
        final i1 = indices[i + 1];
        final i2 = indices[i + 2];

        final p0 = projectedVertices[i0];
        final p1 = projectedVertices[i1];
        final p2 = projectedVertices[i2];

        // Skip if any vertex projection failed
        if (p0 == null || p1 == null || p2 == null) continue;

        // Calculate triangle center in world space
        final center = Vector3(
          (vertices[i0].x + vertices[i1].x + vertices[i2].x) / 3.0,
          (vertices[i0].y + vertices[i1].y + vertices[i2].y) / 3.0,
          (vertices[i0].z + vertices[i1].z + vertices[i2].z) / 3.0,
        );

        // Calculate actual distance from camera to triangle center
        final distanceToCamera = (center - _cameraPosition).length;

        allTriangles.add({
          'p0': p0,
          'p1': p1,
          'p2': p2,
          'color': colors.isNotEmpty ? colors[i0] : Colors.grey,
          'depth': distanceToCamera,
        });
      }
    }

    // Sort all triangles by distance from camera (far to near)
    allTriangles.sort((a, b) => b['depth'].compareTo(a['depth']));

    // Draw all filled triangles in correct order
    for (final triangle in allTriangles) {
      final p0 = triangle['p0'] as Vector2;
      final p1 = triangle['p1'] as Vector2;
      final p2 = triangle['p2'] as Vector2;
      final color = triangle['color'] as Color;

      // Draw triangle with vertex colors - ensure full opacity
      final paint = Paint()
        ..color = Color.fromARGB(255, color.red, color.green, color.blue)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(p0.x, p0.y)
        ..lineTo(p1.x, p1.y)
        ..lineTo(p2.x, p2.y)
        ..close();

      canvas.drawPath(path, paint);
    }

    // Draw wireframe edges on top of filled faces
    for (final model in models) {
      if (!model.visible) continue;

      final vertices = model.getTransformedVertices();
      final wireframeEdges = model.wireframeEdges;

      // Project all vertices to screen space
      final projectedVertices = <Vector2?>[];
      for (final vertex in vertices) {
        projectedVertices.add(projectPoint(vertex, size));
      }

      // Draw wireframe edges
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final edge in wireframeEdges) {
        if (edge.length != 2) continue;

        final startIdx = edge[0];
        final endIdx = edge[1];

        if (startIdx >= projectedVertices.length ||
            endIdx >= projectedVertices.length)
          continue;

        final start = projectedVertices[startIdx];
        final end = projectedVertices[endIdx];

        if (start != null && end != null) {
          canvas.drawLine(
            Offset(start.x, start.y),
            Offset(end.x, end.y),
            strokePaint,
          );
        }
      }
    }
  }
}

// Flutter widget to display the 3D scene with camera controls
class SceneViewer extends StatefulWidget {
  final GameSpace gameSpace;

  const SceneViewer({required this.gameSpace, super.key});

  @override
  State<SceneViewer> createState() => _SceneViewerState();
}

class _SceneViewerState extends State<SceneViewer> {
  late final Simple3DRenderer _renderer;
  late DateTime _lastFrameTime;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _renderer = Simple3DRenderer();
    _lastFrameTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (details) {
            _previousScale = 1.0;
          },
          onScaleUpdate: (details) {
            // Handle both rotation (when pointers == 1) and zoom (when pointers > 1)
            if (details.pointerCount == 1) {
              // Single finger - handle rotation
              final deltaX = details.focalPointDelta.dx * 0.01;
              final deltaY = details.focalPointDelta.dy * 0.01;
              setState(() {
                _renderer.rotate(-deltaX, deltaY);
              });
            } else {
              // Multiple fingers - handle zoom
              final scaleDelta = details.scale / _previousScale;
              _previousScale = details.scale;
              setState(() {
                _renderer.zoom(1.0 / scaleDelta);
              });
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final now = DateTime.now();
              final deltaTime =
                  now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
              _lastFrameTime = now;

              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _ScenePainter(
                  _renderer,
                  widget.gameSpace.models
                      .where((model) => model.visible)
                      .toList(),
                  deltaTime,
                ),
              );
            },
          ),
        ),
        // Cancel button in top left corner
        Positioned(
          top: 50,
          left: 20,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter to render the scene
class _ScenePainter extends CustomPainter {
  final Simple3DRenderer renderer;
  final List<Model3D> models;
  final double deltaTime;

  _ScenePainter(this.renderer, this.models, this.deltaTime);

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey[900]!,
    );

    // Render all models in the scene
    renderer.renderScene(canvas, models, size, deltaTime);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
