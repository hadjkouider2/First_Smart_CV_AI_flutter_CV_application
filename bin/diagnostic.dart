import 'package:flutter_cv_application/data/templates_data.dart';
import 'package:flutter_cv_application/models/template_model.dart';

void main() {
  final templates = TemplatesData.getTemplates();
  print('Total templates: ${templates.length}');
  for (var i = 0; i < templates.length; i++) {
    print('$i: ${templates[i].id} - ${templates[i].name}');
  }
}
