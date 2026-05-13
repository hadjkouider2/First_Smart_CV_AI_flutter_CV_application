import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../data/templates_data.dart';
import '../models/template_model.dart';
import '../models/cv_model.dart';
import '../services/pdf_export_service.dart';

class TemplateSelectionScreen extends StatefulWidget {
  final CVProfile cv;
  final TemplateModel currentSelectedModel;
  final Function(TemplateModel) onSelected;

  const TemplateSelectionScreen({
    super.key,
    required this.cv,
    required this.currentSelectedModel,
    required this.onSelected,
  });

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  String _selectedCategory = 'All';
  late List<TemplateModel> _filteredTemplates;
  late TemplateModel _currentSelectedModel;

  @override
  void initState() {
    super.initState();
    _filteredTemplates = TemplatesData.getTemplates();
    _currentSelectedModel = widget.currentSelectedModel;
  }

  void _filterTemplates(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredTemplates = TemplatesData.filterByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = TemplatesData.getCategories();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Template Preview', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () => PdfExportService.shareCV(widget.cv, _currentSelectedModel),
            icon: const Icon(Icons.share, size: 20, color: Color(0xFF1E293B)),
            tooltip: 'Partager',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () => PdfExportService.printCV(widget.cv, _currentSelectedModel),
              icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.white),
              label: const Text('Export PDF', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B), // Dark blueish black
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _filterTemplates(cat),
                    selectedColor: const Color(0xFF3730A3), // Deep indigo
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? const Color(0xFF3730A3) : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 12),

          // 2. Templates Grid List
          SizedBox(
            height: 220, // Taller area for grid
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredTemplates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 items per row for better overview
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final template = _filteredTemplates[index];
                return _buildTemplateItem(template);
              },
            ),
          ),

          // 3. Info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${_currentSelectedModel.name}" — ${_currentSelectedModel.category}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Dark background for ATS score
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ATS ${_currentSelectedModel.atsScore}%',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              ]
            )
          ),

          // 4. PDF Preview (Expanded)
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: PdfPreview(
                build: (format) => PdfExportService.generateCVPdfBytes(widget.cv, _currentSelectedModel),
                allowPrinting: true,
                allowSharing: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                useActions: false, // Disables standard controls to match designs
                initialPageFormat: PdfPageFormat.a4,
                padding: const EdgeInsets.all(16),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ElevatedButton.icon(
            onPressed: () {
               widget.onSelected(_currentSelectedModel);
               Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text(
              'Utiliser "${_currentSelectedModel.name}"', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            )
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateItem(TemplateModel template) {
    final isSelected = _currentSelectedModel.id == template.id;
    final words = template.name.split(' ');
    final initials = words.take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedModel = template;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Icon Box
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(template.primaryColorValue), Color(template.secondaryColorValue)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3730A3) : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: const Color(0xFF3730A3).withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              template.category,
              style: TextStyle(
                fontSize: 9,
                color: Color(template.primaryColorValue),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

