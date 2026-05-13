// lib/models/template_model.dart

class TemplateModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String description;
  final int popularity;
  final List<String> colors;
  final int atsScore;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.popularity,
    required this.colors,
    required this.atsScore,
  });

  /// Primary accent color of the template
  String get primaryColor => colors.isNotEmpty ? colors[0] : '#1A1A2E';

  /// Secondary accent color
  String get secondaryColor => colors.length > 1 ? colors[1] : '#16213E';

  /// Utility: convert hex string to Flutter Color int value
  int get primaryColorValue {
    final hex = primaryColor.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  int get secondaryColorValue {
    final hex = secondaryColor.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }
}
