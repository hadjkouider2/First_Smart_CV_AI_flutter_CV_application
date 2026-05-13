import 'package:flutter/material.dart';
import 'models/cv_model.dart';
import 'models/template_model.dart';
import 'data/templates_data.dart';
import 'services/pdf_export_service.dart';
import 'services/persistence_service.dart';
import 'widgets/ai_magic_button.dart';
import 'screens/template_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCV AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MobileCVBuilder(),
    );
  }
}

class MobileCVBuilder extends StatefulWidget {
  const MobileCVBuilder({super.key});

  @override
  State<MobileCVBuilder> createState() => _MobileCVBuilderState();
}

class _MobileCVBuilderState extends State<MobileCVBuilder> {
  final CVProfile _cv = CVProfile();
  
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  
  int _currentStep = 0;
  late TemplateModel _selectedTemplate;
  bool _isImproving = false;
  bool _isSaving = false;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = TemplatesData.getTemplates().first;
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 1. Tenter de charger les données sauvegardées
    final savedCv = await PersistenceService.loadCV();
    
    if (savedCv != null) {
      setState(() {
        _nameCtrl.text = savedCv.fullName;
        _titleCtrl.text = savedCv.jobTitle;
        _emailCtrl.text = savedCv.email;
        _phoneCtrl.text = savedCv.phone;
        _locationCtrl.text = savedCv.location;
        _summaryCtrl.text = savedCv.summary;
        _expCtrl.text = savedCv.experience;
        _skillsCtrl.text = savedCv.skills;
        
        _cv.fullName = savedCv.fullName;
        _cv.jobTitle = savedCv.jobTitle;
        _cv.email = savedCv.email;
        _cv.phone = savedCv.phone;
        _cv.location = savedCv.location;
        _cv.summary = savedCv.summary;
        _cv.experience = savedCv.experience;
        _cv.skills = savedCv.skills;
      });
    } else {
      // 2. Initialisation avec des données par défaut si rien n'est sauvegardé
      _nameCtrl.text = "Jean Dupont";
      _titleCtrl.text = "Orthophoniste";
      _emailCtrl.text = "jean.dupont@email.com";
      _phoneCtrl.text = "+33 6 12 34 56 78";
      _locationCtrl.text = "Paris, France";
      _summaryCtrl.text = "Orthophoniste passionnée spécialisée en neuro-linguistique. Expertise dans l'évaluation et la rééducation des troubles du langage, de la communication et de la déglutition chez l'adulte et l'enfant.";
      _expCtrl.text = "Stages en orthophonie en milieu hospitalier et en cabinet privé\n6 mois en milieu hospitalier (Hôpital Mustapha Bacha, Hôpital Azur Plage)\nPrise en charge de troubles du langage, de la communication et de la déglutition\nÉvaluation clinique et mise en place de plans de rééducation\nTravail en équipe pluridisciplinaire\n9 mois en cabinet privé avec suivi individualisé\nAutonomie dans la gestion des séances et adaptation des prises en charge\nRelation thérapeutique basée sur l’écoute et la confiance";
      _skillsCtrl.text = "Évaluation clinique des troubles du langage\nRééducation neuro-linguistique\nPrise en charge de la déglutition\nÉcoute active et observation clinique\nCollaboration pluridisciplinaire\nAutonomie professionnelle\nSens de l'organisation et rigueur";

      _cv.fullName = _nameCtrl.text;
      _cv.jobTitle = _titleCtrl.text;
      _cv.email = _emailCtrl.text;
      _cv.phone = _phoneCtrl.text;
      _cv.location = _locationCtrl.text;
      _cv.summary = _summaryCtrl.text;
      _cv.experience = _expCtrl.text;
      _cv.skills = _skillsCtrl.text;
    }

    // Listeners pour les modifications futures avec sauvegarde automatique
    _nameCtrl.addListener(() => _updateAndSave());
    _titleCtrl.addListener(() => _updateAndSave());
    _emailCtrl.addListener(() => _updateAndSave());
    _phoneCtrl.addListener(() => _updateAndSave());
    _locationCtrl.addListener(() => _updateAndSave());
    _summaryCtrl.addListener(() => _updateAndSave());
    _expCtrl.addListener(() => _updateAndSave());
    _skillsCtrl.addListener(() => _updateAndSave());
  }

  void _updateAndSave() {
    setState(() {
      _cv.fullName = _nameCtrl.text;
      _cv.jobTitle = _titleCtrl.text;
      _cv.email = _emailCtrl.text;
      _cv.phone = _phoneCtrl.text;
      _cv.location = _locationCtrl.text;
      _cv.summary = _summaryCtrl.text;
      _cv.experience = _expCtrl.text;
      _cv.skills = _skillsCtrl.text;
      _isSaving = true;
    });
    
    PersistenceService.saveCV(_cv).then((_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _lastSaved = DateTime.now();
        });
      }
    });
  }

  Future<void> _manualSave() async {
    setState(() => _isSaving = true);
    await PersistenceService.saveCV(_cv);
    setState(() {
      _isSaving = false;
      _lastSaved = DateTime.now();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('💾 Sauvegardé avec succès !'), duration: Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _summaryCtrl.dispose();
    _expCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _improveText(String text, String type) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✏️ Écrivez d\'abord du texte')),
      );
      return;
    }
    
    setState(() => _isImproving = true);
    await Future.delayed(const Duration(seconds: 2));
    
    String improved = text.trim();
    if (!improved.endsWith('.')) improved += '.';
    improved = improved[0].toUpperCase() + improved.substring(1);
    
    if (type == 'summary') {
      _summaryCtrl.text = improved;
      _cv.summary = improved;
    } else if (type == 'experience' || type == 'skills') {
      // Pour les expériences et compétences, on s'assure d'avoir des retours à la ligne pour les bullets
      if (!improved.contains('\n') && improved.contains(',')) {
        improved = improved.split(',').map((e) => e.trim()).join('\n');
      }
      if (type == 'experience') {
        _expCtrl.text = improved;
        _cv.experience = improved;
      } else {
        _skillsCtrl.text = improved;
        _cv.skills = improved;
      }
    }
    
    setState(() => _isImproving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✨ Texte amélioré !'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCV AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateSelectionScreen(
                    cv: _cv,
                    currentSelectedModel: _selectedTemplate,
                    onSelected: (model) => setState(() => _selectedTemplate = model),
                  ),
                ),
              );
            },
            tooltip: 'Aperçu',
          ),
          IconButton(
            icon: Icon(_isSaving ? Icons.sync : Icons.save),
            onPressed: _manualSave,
            tooltip: 'Sauvegarder',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PdfExportService.printCV(_cv, _selectedTemplate),
            tooltip: 'Imprimer',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => PdfExportService.shareCV(_cv, _selectedTemplate),
            tooltip: 'Partager le CV',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastSaved != null || _isSaving)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              color: Colors.green.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isSaving ? Icons.sync : Icons.check_circle, size: 12, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    _isSaving ? 'Sauvegarde...' : 'Dernière sauvegarde : ${_lastSaved!.hour}:${_lastSaved!.minute}:${_lastSaved!.second}',
                    style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildEditMode()),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        // Template selector compact
        // Template selector banner
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TemplateSelectionScreen(
                  cv: _cv,
                  currentSelectedModel: _selectedTemplate,
                  onSelected: (model) => setState(() => _selectedTemplate = model),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dashboard_customize, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modèle de CV',
                        style: TextStyle(color: Colors.indigo.shade50, fontSize: 12),
                      ),
                      Text(
                        _selectedTemplate.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Changer',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 12, color: Colors.indigo.withValues(alpha: 0.2)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                           // Petit délai pour simuler un clic séparé
                           Future.delayed(Duration.zero, () => PdfExportService.shareCV(_cv, _selectedTemplate));
                        },
                        child: const Icon(Icons.share, color: Colors.indigo, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Stepper compact
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildMobileStep(0, '📝', _currentStep >= 0),
              Expanded(child: Container(height: 2, color: _currentStep > 0 ? Colors.indigo : Colors.grey.shade300)),
              _buildMobileStep(1, '📄', _currentStep >= 1),
              Expanded(child: Container(height: 2, color: _currentStep > 1 ? Colors.indigo : Colors.grey.shade300)),
              _buildMobileStep(2, '💼', _currentStep >= 2),
              Expanded(child: Container(height: 2, color: _currentStep > 2 ? Colors.indigo : Colors.grey.shade300)),
              _buildMobileStep(3, '⚡', _currentStep >= 3),
            ],
          ),
        ),
        // Formulaire
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStepContent(),
          ),
        ),
        // Boutons navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Retour'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentStep < 3) {
                      setState(() => _currentStep++);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateSelectionScreen(
                            cv: _cv,
                            currentSelectedModel: _selectedTemplate,
                            onSelected: (model) => setState(() => _selectedTemplate = model),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(_currentStep == 3 ? Icons.visibility : Icons.arrow_forward, size: 18),
                  label: Text(_currentStep == 3 ? 'Voir' : 'Suite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildMobileStep(int step, String emoji, bool active) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.indigo : Colors.grey.shade200,
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 18, color: active ? Colors.white : Colors.grey.shade500)),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(children: [
          _buildMobileTextField(_nameCtrl, 'Nom complet', Icons.person_outline),
          const SizedBox(height: 12),
          _buildMobileTextField(_titleCtrl, 'Titre', Icons.work_outline),
          const SizedBox(height: 12),
          _buildMobileTextField(_emailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildMobileTextField(_phoneCtrl, 'Téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildMobileTextField(_locationCtrl, 'Localisation', Icons.location_on_outlined),
        ]);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildMobileTextField(_summaryCtrl, 'Résumé', Icons.description_outlined, maxLines: 5),
          const SizedBox(height: 12),
          AiMagicButton(
            onPressed: () => _improveText(_summaryCtrl.text, 'summary'),
            isLoading: _isImproving,
            label: '✨ Améliorer',
          ),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildMobileTextField(_expCtrl, 'Expériences', Icons.work_history, maxLines: 6),
          const SizedBox(height: 12),
          AiMagicButton(
            onPressed: () => _improveText(_expCtrl.text, 'experience'),
            isLoading: _isImproving,
            label: '✨ Améliorer',
          ),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildMobileTextField(_skillsCtrl, 'Compétences', Icons.code, maxLines: 3),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AiMagicButton(
                onPressed: () => _improveText(_skillsCtrl.text, 'skills'),
                isLoading: _isImproving,
                label: '✨ Améliorer',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AiMagicButton(
                onPressed: () async {
                  if (_cv.jobTitle.isNotEmpty && _cv.skills.isNotEmpty) {
                    setState(() => _isImproving = true);
                    await Future.delayed(const Duration(seconds: 2));
                    _summaryCtrl.text = "Professionnel en ${_cv.jobTitle} avec expertise en ${_cv.skills}. Passionné par l'innovation et la résolution de problèmes.";
                    _cv.summary = _summaryCtrl.text;
                    setState(() => _isImproving = false);
                    setState(() => _currentStep = 1);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Résumé généré !')),
                    );
                  }
                },
                isLoading: _isImproving,
                label: '🎯 Générer',
              ),
            ),
          ]),
        ]);
    }
  }

  Widget _buildMobileTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

}
