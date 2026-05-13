import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cv_model.dart';
import '../models/template_model.dart';

class PdfExportService {
  // SVG Icons for professional look
  static const String _svgEmail = '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>';
  static const String _svgPhone = '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/></svg>';
  static const String _svgLocation = '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>';

  // Génère les bytes du PDF pour la prévisualisation et l'export
  static Future<Uint8List> generateCVPdfBytes(CVProfile cv, TemplateModel model) async {
    final pdf = pw.Document();
    
    // Chargement de polices premium
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    
    pw.Widget content;
    final id = model.id;
    
    // On mappe l'ID du modèle vers l'un des 12 layouts (9 anciens + 3 nouveaux)
    if (id.startsWith('mod_')) {
      if (id == 'mod_004') {
        content = _buildMinimalistTemplate(cv, model);
      } else if (id == 'mod_007') {
        content = _buildMinimalChicTemplate(cv, model);
      } else if (id == 'mod_006') {
        content = _buildTechInnovatorTemplate(cv, model);
      } else if (id == 'mod_010' || id == 'pro_019') {
        content = _buildMedicalTemplate(cv, model);
      } else if (id == 'mod_003' || id == 'mod_009') {
        content = _buildClassicTemplate(cv, model);
      } else {
        content = _buildModernTemplate(cv, model);
      }
    } else if (id.startsWith('pro_')) {
      if (id == 'pro_011') {
        content = _buildDarkElegantTemplate(cv, model);
      } else if (id == 'pro_012' || id == 'pro_020') {
        content = _buildColumnsTemplate(cv, model);
      } else if (id == 'pro_018' || id == 'pro_015') {
        content = _buildClassicTemplate(cv, model);
      } else {
        content = _buildCorporateTemplate(cv, model);
      }
    } else if (id.startsWith('cre_')) {
      if (id == 'cre_028') {
        content = _buildGradientTemplate(cv, model);
      } else if (id == 'cre_029') {
        content = _buildSidebarTemplate(cv, model);
      } else if (id == 'cre_025' || id == 'cre_027') {
        content = _buildClassicTemplate(cv, model);
      } else {
        content = _buildCreativeTemplate(cv, model);
      }
    } else {
      content = _buildClassicTemplate(cv, model);
    }
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (context) => [content],
      ),
    );
    
    return await pdf.save();
  }

  // Partage social (WhatsApp, Facebook, etc.)
  static Future<void> shareCV(CVProfile cv, TemplateModel model) async {
    final bytes = await generateCVPdfBytes(cv, model);
    final tempDir = await getTemporaryDirectory();
    final fileName = 'CV_${cv.fullName.replaceAll(' ', '_')}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Regardez mon CV généré avec SmartCV AI',
      subject: 'Mon CV Professionnel',
    );
  }

  // Exporte / Partage le PDF (méthode de secours via printing)
  static Future<void> exportCV(CVProfile cv, TemplateModel model) async {
    final bytes = await generateCVPdfBytes(cv, model);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'CV_${cv.fullName.replaceAll(' ', '_')}.pdf',
    );
  }

  // Impression directe
  static Future<void> printCV(CVProfile cv, TemplateModel model) async {
    final bytes = await generateCVPdfBytes(cv, model);
    await Printing.layoutPdf(
      onLayout: (format) => bytes,
      name: 'CV_${cv.fullName.replaceAll(' ', '_')}',
    );
  }

  // --- HELPERS POUR LES COULEURS ---
  static PdfColor _primary(TemplateModel model) => PdfColor.fromInt(model.primaryColorValue);
  static PdfColor _secondary(TemplateModel model) => PdfColor.fromInt(model.secondaryColorValue);
  static PdfColor _withOpacity(PdfColor color, double opacity) => 
      PdfColor(color.red, color.green, color.blue, opacity);

  // Template 1: MODERNE
  static pw.Widget _buildModernTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: _primary(model),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(30),
                bottomRight: pw.Radius.circular(30),
              ),
            ),
            child: pw.Column(
              children: [
                pw.Text(cv.fullName.isEmpty ? 'NOM COMPLET' : cv.fullName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 8),
                pw.Text(cv.jobTitle.isEmpty ? 'Titre' : cv.jobTitle,
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.white)),
                pw.SizedBox(height: 12),
                pw.Wrap(
                  alignment: pw.WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 5,
                  children: [
                    if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.white),
                    if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.white),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          if (cv.summary.isNotEmpty) _buildSectionModern('À propos', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionModern('Expériences', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionModern('Compétences', cv.skills, model),
        ],
      ),
    );
  }

  // Template 2: MINIMALISTE
  static pw.Widget _buildMinimalistTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(50),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(cv.fullName.isEmpty ? 'Nom' : cv.fullName,
              style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.normal, letterSpacing: 3, color: _primary(model))),
          pw.SizedBox(height: 4),
          pw.Text(cv.jobTitle.isEmpty ? 'Titre' : cv.jobTitle,
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
               if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.grey700),
               if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.grey700),
               if (cv.location.isNotEmpty) _buildHeaderContactItem(_svgLocation, cv.location, PdfColors.grey700),
            ]
          ),
          pw.Divider(thickness: 1, color: _secondary(model)),
          pw.SizedBox(height: 32),
          if (cv.summary.isNotEmpty) _buildSectionMinimal('Profil', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionMinimal('Expérience', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionMinimal('Compétences', cv.skills, model),
        ],
      ),
    );
  }

  // Template 3: CORPORATE
  static pw.Widget _buildCorporateTemplate(CVProfile cv, TemplateModel model) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            color: _primary(model),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Text(cv.fullName.isEmpty ? 'NOM' : cv.fullName,
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 16),
                if (cv.email.isNotEmpty) _buildContactItem(_svgEmail, cv.email, PdfColors.white),
                if (cv.phone.isNotEmpty) _buildContactItem(_svgPhone, cv.phone, PdfColors.white),
                if (cv.location.isNotEmpty) _buildContactItem(_svgLocation, cv.location, PdfColors.white),
              ],
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (cv.summary.isNotEmpty) _buildSectionCorporate('Résumé', cv.summary, model, withBullets: false),
                if (cv.experience.isNotEmpty) _buildSectionCorporate('Expériences', cv.experience, model),
                if (cv.skills.isNotEmpty) _buildSectionCorporate('Compétences', cv.skills, model),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCreativeTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(cv.fullName.isEmpty ? 'CREATIVE' : cv.fullName.toUpperCase(),
              style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: _primary(model))),
          pw.Text(cv.jobTitle.isEmpty ? 'Designer' : cv.jobTitle,
              style: pw.TextStyle(fontSize: 18, color: _secondary(model))),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 15,
            runSpacing: 5,
            children: [
               if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, _primary(model)),
               if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, _primary(model)),
            ]
          ),
          pw.SizedBox(height: 24),
          if (cv.summary.isNotEmpty) _buildSectionCreative('Bio', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionCreative('Work', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionCreative('Skills', cv.skills, model),
        ],
      ),
    );
  }

  // Template 5: DARK ELEGANT
  static pw.Widget _buildDarkElegantTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      color: _primary(model),
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _secondary(model), width: 2)),
            ),
            child: pw.Column(
              children: [
                pw.Text(cv.fullName.isEmpty ? 'ELEGANCE' : cv.fullName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: _secondary(model))),
                pw.SizedBox(height: 8),
                pw.Text(cv.jobTitle.isEmpty ? 'Executive' : cv.jobTitle,
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.white)),
                pw.SizedBox(height: 12),
                pw.Wrap(
                  alignment: pw.WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 5,
                  children: [
                     if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.white),
                     if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.white),
                  ]
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          if (cv.summary.isNotEmpty) _buildSectionDark('Profile', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionDark('Experience', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionDark('Expertise', cv.skills, model),
        ],
      ),
    );
  }

  // Template 6: GRADIENT
  static pw.Widget _buildGradientTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [_primary(model), _secondary(model)],
        ),
      ),
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        children: [
          pw.Text(cv.fullName.isEmpty ? 'GRADIENT' : cv.fullName,
              style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          pw.SizedBox(height: 8),
          pw.Text(cv.jobTitle.isEmpty ? 'Professional' : cv.jobTitle,
              style: const pw.TextStyle(fontSize: 18, color: PdfColors.white)),
          pw.SizedBox(height: 12),
          pw.Wrap(
            alignment: pw.WrapAlignment.center,
            spacing: 20,
            runSpacing: 5,
            children: [
               if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.white),
               if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.white),
            ]
          ),
          pw.SizedBox(height: 30),
          if (cv.summary.isNotEmpty) _buildSectionGradient('About', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionGradient('Experience', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionGradient('Skills', cv.skills, model),
        ],
      ),
    );
  }

  // Template 7: SIDEBAR
  static pw.Widget _buildSidebarTemplate(CVProfile cv, TemplateModel model) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            color: _primary(model),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Container(
                  width: 80, height: 80,
                  decoration: const pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColors.white,
                  ),
                  child: pw.Center(
                    child: pw.Text(cv.fullName.isNotEmpty ? cv.fullName[0] : '?',
                        style: pw.TextStyle(fontSize: 40, color: _primary(model))),
                  ),
                ),
                pw.SizedBox(height: 20),
                if (cv.email.isNotEmpty) _buildSidebarItem(_svgEmail, cv.email),
                if (cv.phone.isNotEmpty) _buildSidebarItem(_svgPhone, cv.phone),
                if (cv.location.isNotEmpty) _buildSidebarItem(_svgLocation, cv.location),
              ],
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(cv.fullName.isEmpty ? 'Nom' : cv.fullName,
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.Text(cv.jobTitle.isEmpty ? 'Titre' : cv.jobTitle,
                    style: pw.TextStyle(fontSize: 14, color: _primary(model))),
                pw.SizedBox(height: 20),
                if (cv.summary.isNotEmpty) _buildSectionSidebar('Profil', cv.summary, model, withBullets: false),
                if (cv.experience.isNotEmpty) _buildSectionSidebar('Expérience', cv.experience, model),
                if (cv.skills.isNotEmpty) _buildSectionSidebar('Compétences', cv.skills, model),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Template 8: MINIMAL CHIC
  static pw.Widget _buildMinimalChicTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(45),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(cv.fullName.isEmpty ? 'MINIMAL' : cv.fullName,
                      style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.normal, color: _primary(model))),
                  pw.Text(cv.jobTitle.isEmpty ? 'Design' : cv.jobTitle,
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                  pw.SizedBox(height: 8),
                  if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.grey600),
                  if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.grey600),
                ],
              ),
              pw.Container(
                width: 70, height: 70,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: _withOpacity(_secondary(model), 0.1),
                ),
                child: pw.Center(child: pw.Text('CV', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _primary(model)))),
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          if (cv.summary.isNotEmpty) _buildSectionChic('Bio', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionChic('Work', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionChic('Skills', cv.skills, model),
        ],
      ),
    );
  }

  // Template 9: TECH INNOVATOR
  static pw.Widget _buildTechInnovatorTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: _primary(model), width: 5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(cv.fullName.isEmpty ? 'INNOVATOR' : cv.fullName,
                        style: pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold, color: _primary(model))),
                    pw.Text(cv.jobTitle.isEmpty ? 'Tech Lead' : cv.jobTitle,
                        style: pw.TextStyle(fontSize: 16, color: _secondary(model))),
                  ],
                ),
                pw.Wrap(
                  alignment: pw.WrapAlignment.end,
                  direction: pw.Axis.vertical,
                  children: [
                    if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, _primary(model)),
                    if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, _primary(model)),
                  ]
                )
              ]
            ),
          ),
          pw.SizedBox(height: 30),
          if (cv.summary.isNotEmpty) _buildSectionTech('Mission', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionTech('Achievements', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionTech('Stack', cv.skills, model),
        ],
      ),
    );
  }

  // --- HELPERS ---

  static pw.Widget _buildHeaderContactItem(String svg, String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SvgImage(svg: svg, width: 8, height: 8, colorFilter: color),
          pw.SizedBox(width: 4),
          pw.Text(text, style: pw.TextStyle(fontSize: 8, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildContactItem(String svg, String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(children: [
        pw.SvgImage(svg: svg, width: 10, height: 10, colorFilter: color),
        pw.SizedBox(width: 8), 
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color)))
      ]),
    );
  }

  static pw.Widget _buildSidebarItem(String svg, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(children: [
        pw.SvgImage(svg: svg, width: 10, height: 10, colorFilter: PdfColors.white),
        pw.SizedBox(width: 8), 
        pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)))
      ]),
    );
  }

  // Sections helpers
  static pw.Widget _buildSectionContent(String content, pw.TextStyle style, {PdfColor? bulletColor, bool withBullets = true}) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length <= 1 || !withBullets) {
      return pw.Text(content, style: style);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        String cleanLine = line.trim();
        // Remove existing bullet symbols if present to avoid double bullets
        if (cleanLine.startsWith('•') || cleanLine.startsWith('-') || cleanLine.startsWith('*')) {
          cleanLine = cleanLine.substring(1).trim();
        }
        
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3, right: 8),
                child: pw.Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: pw.BoxDecoration(
                    color: bulletColor ?? style.color ?? PdfColors.black,
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(cleanLine, style: style),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildSectionModern(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primary(model))),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 11), bulletColor: _secondary(model), withBullets: withBullets),
      pw.SizedBox(height: 16),
    ]);
  }

  static pw.Widget _buildSectionMinimal(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2, color: _primary(model))),
      pw.SizedBox(height: 6),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 10), withBullets: withBullets),
      pw.SizedBox(height: 20),
    ]);
  }

  static pw.Widget _buildSectionCorporate(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary(model))),
      pw.SizedBox(height: 6),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 10), withBullets: withBullets),
      pw.SizedBox(height: 12),
    ]);
  }

  static pw.Widget _buildSectionCreative(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _primary(model))),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 11), withBullets: withBullets),
      pw.SizedBox(height: 16),
    ]);
  }

  static pw.Widget _buildSectionDark(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _secondary(model))),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 11, color: PdfColors.white), bulletColor: _secondary(model), withBullets: withBullets),
      pw.SizedBox(height: 16),
    ]);
  }

  static pw.Widget _buildSectionGradient(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 11, color: PdfColors.white), bulletColor: PdfColors.white, withBullets: withBullets),
      pw.SizedBox(height: 16),
    ]);
  }

  static pw.Widget _buildSectionSidebar(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary(model))),
      pw.SizedBox(height: 6),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 10), withBullets: withBullets),
      pw.SizedBox(height: 12),
    ]);
  }

  static pw.Widget _buildSectionChic(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 3, color: _primary(model))),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 10), withBullets: withBullets),
      pw.SizedBox(height: 20),
    ]);
  }

  static pw.Widget _buildSectionTech(String title, String content, TemplateModel model, {bool withBullets = true}) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary(model))),
      pw.SizedBox(height: 8),
      _buildSectionContent(content, const pw.TextStyle(fontSize: 10), bulletColor: _secondary(model), withBullets: withBullets),
      pw.SizedBox(height: 16),
    ]);
  }

  // Template 10: MEDICAL (Optimized for healthcare/orthophony)
  static pw.Widget _buildMedicalTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(35),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: _primary(model), width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(cv.fullName.isEmpty ? 'NOM DU CANDIDAT' : cv.fullName.toUpperCase(),
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _primary(model))),
                      pw.Text(cv.jobTitle.isEmpty ? 'Praticien' : cv.jobTitle,
                          style: pw.TextStyle(fontSize: 14, color: _secondary(model))),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.grey700),
                    if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.grey700),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          if (cv.summary.isNotEmpty) _buildSectionTech('Missions & Objectifs', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionTech('Parcours Clinique', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionTech('Expertises Médicales', cv.skills, model),
        ],
      ),
    );
  }

  // Template 11: CLASSIC
  static pw.Widget _buildClassicTemplate(CVProfile cv, TemplateModel model) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(50),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(child: pw.Text(cv.fullName.isEmpty ? 'CLASSIC' : cv.fullName.toUpperCase(),
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.Center(child: pw.Text(cv.jobTitle.isEmpty ? 'Professionnel' : cv.jobTitle,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700))),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (cv.email.isNotEmpty) _buildHeaderContactItem(_svgEmail, cv.email, PdfColors.black),
                if (cv.phone.isNotEmpty) _buildHeaderContactItem(_svgPhone, cv.phone, PdfColors.black),
                if (cv.location.isNotEmpty) _buildHeaderContactItem(_svgLocation, cv.location, PdfColors.black),
              ],
            ),
          ),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 20),
          if (cv.summary.isNotEmpty) _buildSectionCorporate('Profil Professionnel', cv.summary, model, withBullets: false),
          if (cv.experience.isNotEmpty) _buildSectionCorporate('Expériences', cv.experience, model),
          if (cv.skills.isNotEmpty) _buildSectionCorporate('Compétences', cv.skills, model),
        ],
      ),
    );
  }

  // Template 12: COLUMNS
  static pw.Widget _buildColumnsTemplate(CVProfile cv, TemplateModel model) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(cv.fullName.isEmpty ? 'COLUMNS' : cv.fullName,
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: _primary(model))),
                pw.Text(cv.jobTitle.isEmpty ? 'Expert' : cv.jobTitle,
                    style: pw.TextStyle(fontSize: 14, color: _secondary(model))),
                pw.SizedBox(height: 24),
                if (cv.summary.isNotEmpty) _buildSectionModern('Résumé', cv.summary, model, withBullets: false),
                if (cv.experience.isNotEmpty) _buildSectionModern('Expériences', cv.experience, model),
              ],
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            color: PdfColors.grey100,
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (cv.email.isNotEmpty) _buildContactItem(_svgEmail, cv.email, PdfColors.black),
                if (cv.phone.isNotEmpty) _buildContactItem(_svgPhone, cv.phone, PdfColors.black),
                pw.SizedBox(height: 30),
                if (cv.skills.isNotEmpty) _buildSectionMinimal('Skills', cv.skills, model),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
