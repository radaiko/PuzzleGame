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

    // Simple orthographic projection - just use x,y coordinates
    // Scale and center the coordinates
    final scale = math.min(screenSize.width, screenSize.height) * 0.1;
    final screenX = screenSize.width * 0.5 + viewPoint.x * scale;
    final screenY = screenSize.height * 0.5 - viewPoint.y * scale;

    return Vector2(screenX, screenY);
  }

  void renderModel(Canvas canvas, Model3D model, Size size) {
    // Skip invisible models
    if (!model.visible) return;

    final vertices = model.getTransformedVertices();
    final indices = model.indices;
    final colors = model.vertexColors;

    // Project all vertices to screen space
    final projectedVertices = <Vector2?>[];
    for (final vertex in vertices) {
      projectedVertices.add(projectPoint(vertex, size));
    }

    // Draw triangles
    for (int i = 0; i < indices.length; i += 3) {
      final i0 = indices[i];
      final i1 = indices[i + 1];
      final i2 = indices[i + 2];

      final p0 = projectedVertices[i0];
      final p1 = projectedVertices[i1];
      final p2 = projectedVertices[i2];

      // Skip if any vertex projection failed
      if (p0 == null || p1 == null || p2 == null) continue;

      // Simple back-face culling (check if triangle is clockwise)
      final cross =
          (p1.x - p0.x) * (p2.y - p0.y) - (p1.y - p0.y) * (p2.x - p0.x);
      if (cross < 0) continue; // Back-facing triangle

      // Draw triangle
      final paint = Paint()
        ..color = colors.isNotEmpty ? colors[i0] : Colors.blue
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(p0.x, p0.y)
        ..lineTo(p1.x, p1.y)
        ..lineTo(p2.x, p2.y)
        ..close();

      canvas.drawPath(path, paint);

      // Draw wireframe
      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawPath(path, strokePaint);
    }
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

    // Render all models
    for (final model in models) {
      renderModel(canvas, model, size);
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
          onScaleUpdate: (details) {
            // Handle both rotation (when pointers == 1) and zoom (when pointers > 1)
            if (details.pointerCount == 1) {
              // Single finger - handle rotation
              final deltaX = details.focalPointDelta.dx * 0.01;
              final deltaY = details.focalPointDelta.dy * 0.01;
              setState(() {
                _renderer.rotate(-deltaX, -deltaY);
              });
            } else {
              // Multiple fingers - handle zoom
              setState(() {
                _renderer.zoom(1.0 / details.scale);
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
