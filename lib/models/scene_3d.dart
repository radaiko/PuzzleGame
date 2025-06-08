import 'package:puzzle_game/models/model_3d.dart';

/// A container class to manage multiple 3D models in a scene
class Scene3D {
  final List<Model3D> _models = [];

  /// Add a model to the scene
  void addModel(Model3D model) {
    _models.add(model);
  }

  /// Remove a model from the scene
  void removeModel(Model3D model) {
    _models.remove(model);
  }

  /// Remove a model by its ID
  void removeModelById(String id) {
    _models.removeWhere((model) => model.id == id);
  }

  /// Get a model by its ID
  Model3D? getModelById(String id) {
    try {
      return _models.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all models in the scene
  List<Model3D> get models => List.unmodifiable(_models);

  /// Get only visible models
  List<Model3D> get visibleModels =>
      _models.where((model) => model.visible).toList();

  /// Clear all models from the scene
  void clear() {
    _models.clear();
  }

  /// Update all models in the scene
  void update(double deltaTime) {
    for (final model in _models) {
      model.update(deltaTime);
    }
  }

  /// Get the number of models in the scene
  int get modelCount => _models.length;

  /// Check if the scene is empty
  bool get isEmpty => _models.isEmpty;

  /// Check if the scene has any models
  bool get isNotEmpty => _models.isNotEmpty;
}
