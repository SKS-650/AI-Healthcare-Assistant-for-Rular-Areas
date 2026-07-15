import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/symptom_check_request.dart';
import '../../services/symptom_checker_service.dart';
import 'symptom_selection_page.dart';
import 'results_page.dart';
import '../../../../config/api_config.dart';
import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';

class SymptomCheckerPage extends ConsumerStatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  ConsumerState<SymptomCheckerPage> createState() =>
      _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends ConsumerState<SymptomCheckerPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;

  // Patient data
  List<String> _selectedSymptoms = [];
  int _age = 25;
  String _gender = 'male';
  double? _weight;
  double? _height;
  int _duration = 3;
  int _severity = 2;
  final List<String> _existingDiseases = [];
  final List<String> _medications = [];
  final List<String> _allergies = [];
  bool _isPregnant = false;

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _medCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  late final AnimationController _stepAnim;
  late final Animation<double> _fadeAnim;
  late final PageController _pageCtrl;

  static const _primaryColor = Color(0xFF6C63FF);
  static const _accentColor = Color(0xFF48CAE4);
  static const _bgColor = Color(0xFFF8F7FF);
  static const _cardColor = Colors.white;

  static const List<Map<String, dynamic>> _steps = [
    {'icon': Icons.search_rounded, 'title': 'Symptoms', 'subtitle': 'What are you feeling?'},
    {'icon': Icons.person_rounded, 'title': 'Patient Info', 'subtitle': 'Tell us about yourself'},
    {'icon': Icons.tune_rounded, 'title': 'Details', 'subtitle': 'Duration & severity'},
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _stepAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _stepAnim, curve: Curves.easeInOut);
    _stepAnim.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _stepAnim.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _conditionCtrl.dispose();
    _medCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _stepAnim.reset();
    _stepAnim.forward();
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSymptomStep(),
                _buildPatientInfoStep(),
                _buildDetailsStep(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, Color(0xFF8B83FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'AI Symptom Checker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, Color(0xFF8B83FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIndex = i ~/ 2;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: stepIndex < _currentStep
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              final isCompleted = stepIndex < _currentStep;
              final isActive = stepIndex == _currentStep;
              return _buildStepDot(stepIndex, isCompleted, isActive);
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _steps[_currentStep]['subtitle'] as String,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, bool isCompleted, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 40 : 32,
      height: isActive ? 40 : 32,
      decoration: BoxDecoration(
        color: isCompleted || isActive ? Colors.white : Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: _primaryColor, size: 18)
            : Icon(
                _steps[index]['icon'] as IconData,
                color: isActive ? _primaryColor : Colors.white.withValues(alpha: 0.6),
                size: isActive ? 20 : 16,
              ),
      ),
    );
  }

  // ─── STEP 1: Symptoms ────────────────────────────────────────────────────
  Widget _buildSymptomStep() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.search_rounded,
              title: 'Select Your Symptoms',
              subtitle: 'Choose all symptoms you are currently experiencing',
            ),
            const SizedBox(height: 20),
            if (_selectedSymptoms.isEmpty)
              _buildEmptySymptomState()
            else
              _buildSelectedSymptomsList(),
            const SizedBox(height: 16),
            _buildAddSymptomsButton(),
            const SizedBox(height: 24),
            _buildInfoBanner(
              icon: Icons.info_outline_rounded,
              text: 'Our AI model analyzes 230+ symptoms across 800+ diseases using 96,000 training samples.',
              color: _primaryColor.withValues(alpha: 0.08),
              iconColor: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySymptomState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: _primaryColor.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_circle_outline_rounded, color: _primaryColor, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No symptoms selected',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333360)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add Symptoms" below to search\nfrom 230+ medical symptoms',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSymptomsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _primaryColor.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedSymptoms.length} selected',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedSymptoms.clear()),
                child: Text('Clear all', style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSymptoms.map((s) {
              final display = _toDisplayName(s);
              return AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryColor, Color(0xFF8B83FF)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: _primaryColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(display, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _selectedSymptoms.remove(s)),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSymptomsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _openSymptomSelection,
        icon: const Icon(Icons.add_rounded, color: _primaryColor),
        label: Text(
          _selectedSymptoms.isEmpty ? 'Add Symptoms' : 'Edit Symptoms',
          style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _openSymptomSelection() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomSelectionPage(initialSymptoms: _selectedSymptoms),
      ),
    );
    if (result != null) setState(() => _selectedSymptoms = result);
  }

  // ─── STEP 2: Patient Info ─────────────────────────────────────────────────
  Widget _buildPatientInfoStep() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.person_rounded,
              title: 'Patient Information',
              subtitle: 'Help the AI provide a more accurate assessment',
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Age'),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _primaryColor,
                            thumbColor: _primaryColor,
                            overlayColor: _primaryColor.withValues(alpha: 0.1),
                            inactiveTrackColor: _primaryColor.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _age.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99,
                            onChanged: (v) => setState(() => _age = v.round()),
                          ),
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_age yr',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Biological Sex'),
                  const SizedBox(height: 10),
                  _buildGenderSelector(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Physical Measurements (Optional)'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _weightCtrl, label: 'Weight (kg)', icon: Icons.monitor_weight_rounded,
                        onChanged: (v) => _weight = double.tryParse(v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _heightCtrl, label: 'Height (cm)', icon: Icons.straighten_rounded,
                        onChanged: (v) => _height = double.tryParse(v))),
                    ],
                  ),
                  if (_gender == 'female') ...[
                    const SizedBox(height: 16),
                    _buildCheckboxTile(
                      label: 'Currently Pregnant',
                      icon: Icons.pregnant_woman_rounded,
                      value: _isPregnant,
                      onChanged: (v) => setState(() => _isPregnant = v ?? false),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['male', 'female', 'other'].map((g) {
        final icons = {'male': Icons.male_rounded, 'female': Icons.female_rounded, 'other': Icons.person_rounded};
        final isSelected = _gender == g;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() { _gender = g; if (g != 'female') _isPregnant = false; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : _primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? _primaryColor : Colors.transparent),
                  boxShadow: isSelected ? [BoxShadow(color: _primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Column(
                  children: [
                    Icon(icons[g]!, color: isSelected ? Colors.white : _primaryColor.withValues(alpha: 0.6), size: 22),
                    const SizedBox(height: 4),
                    Text(
                      g[0].toUpperCase() + g.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── STEP 3: Details ─────────────────────────────────────────────────────
  Widget _buildDetailsStep() {
    final severityLabels = ['Mild', 'Moderate', 'Severe', 'Critical'];
    final severityColors = [Colors.green, Colors.orange, Colors.deepOrange, Colors.red];
    final severityIcons = [Icons.sentiment_satisfied_rounded, Icons.sentiment_neutral_rounded,
        Icons.sentiment_dissatisfied_rounded, Icons.sentiment_very_dissatisfied_rounded];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.tune_rounded,
              title: 'Additional Details',
              subtitle: 'Duration and severity help refine the diagnosis',
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('How long have you had these symptoms?'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _accentColor,
                            thumbColor: _accentColor,
                            overlayColor: _accentColor.withValues(alpha: 0.1),
                            inactiveTrackColor: _accentColor.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _duration.toDouble(),
                            min: 1,
                            max: 60,
                            divisions: 59,
                            onChanged: (v) => setState(() => _duration = v.round()),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_duration\ndays',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                  _buildDurationLabel(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('How severe are your symptoms?'),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(4, (i) {
                      final isSelected = _severity == i + 1;
                      final color = severityColors[i];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => setState(() => _severity = i + 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? color : color.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? color : Colors.transparent),
                                boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(severityIcons[i], color: isSelected ? Colors.white : color, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    severityLabels[i],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : color,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Existing Conditions (Optional)'),
                  const SizedBox(height: 10),
                  _buildTagInput(
                    controller: _conditionCtrl,
                    hint: 'e.g. Diabetes, Hypertension...',
                    tags: _existingDiseases,
                    color: Colors.purple,
                    onAdd: (v) => setState(() => _existingDiseases.add(v)),
                    onRemove: (v) => setState(() => _existingDiseases.remove(v)),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Current Medications (Optional)'),
                  const SizedBox(height: 10),
                  _buildTagInput(
                    controller: _medCtrl,
                    hint: 'e.g. Aspirin, Metformin...',
                    tags: _medications,
                    color: Colors.blue,
                    onAdd: (v) => setState(() => _medications.add(v)),
                    onRemove: (v) => setState(() => _medications.remove(v)),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Known Allergies (Optional)'),
                  const SizedBox(height: 10),
                  _buildTagInput(
                    controller: _allergyCtrl,
                    hint: 'e.g. Penicillin, Peanuts...',
                    tags: _allergies,
                    color: Colors.red,
                    onAdd: (v) => setState(() => _allergies.add(v)),
                    onRemove: (v) => setState(() => _allergies.remove(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoBanner(
              icon: Icons.shield_outlined,
              text: 'Your data is only used for this analysis and is not stored on our servers.',
              color: Colors.green.withValues(alpha: 0.07),
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationLabel() {
    String label;
    Color color;
    if (_duration <= 3) { label = 'Acute (just started)'; color = Colors.green; }
    else if (_duration <= 7) { label = 'Short-term'; color = Colors.orange; }
    else if (_duration <= 30) { label = 'Sub-acute'; color = Colors.deepOrange; }
    else { label = 'Chronic (long-term)'; color = Colors.red; }
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final isLast = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => _goToStep(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Back', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: isLast ? 1 : (_currentStep > 0 ? 2 : 1),
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? Colors.green : _primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                shadowColor: (isLast ? Colors.green : _primaryColor).withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isLast ? Icons.science_rounded : Icons.arrow_forward_ios_rounded,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isLast ? 'Analyze Symptoms' : 'Continue',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    if (_currentStep == 0) {
      if (_selectedSymptoms.isEmpty) {
        _showSnackBar('Please select at least one symptom to continue.', isError: true);
        return;
      }
    }
    if (_currentStep < 2) {
      _goToStep(_currentStep + 1);
    } else {
      _submitSymptomCheck();
    }
  }

  Future<void> _submitSymptomCheck() async {
    _showAnalyzingDialog();
    try {
      // Access the token through the concrete implementation's getter.
      // This avoids a risky type-cast in the presentation layer by reading
      // the repo as its concrete type from the provider directly.
      final authRepo = ref.read(authRepositoryProvider);
      String? token;
      if (authRepo is AuthenticationRepositoryImpl) {
        // Try to refresh the token silently before submitting so we don't
        // hit a 401 mid-analysis if the access token just expired.
        if (authRepo.accessToken == null) {
          await authRepo.refreshAccessToken();
        }
        token = authRepo.accessToken;
      }
      final service = SymptomCheckerService(baseUrl: ApiConfig.baseUrl, authToken: token);
      final request = SymptomCheckRequest(
        symptoms: _selectedSymptoms,
        age: _age,
        gender: _gender,
        weight: _weight,
        height: _height,
        duration: _duration,
        severity: _severity,
        existingDiseases: _existingDiseases.isEmpty ? null : _existingDiseases,
        medications: _medications.isEmpty ? null : _medications,
        allergies: _allergies.isEmpty ? null : _allergies,
        pregnancyStatus: _isPregnant,
      );
      final response = await service.checkSymptoms(request);
      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsPage(response: response)));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showAnalyzingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryColor, Color(0xFF8B83FF)]),
                  shape: BoxShape.circle,
                ),
                child: const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
              ),
              const SizedBox(height: 20),
              const Text('Analyzing Symptoms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
              const SizedBox(height: 8),
              Text('Our AI model is processing\nyour symptoms...', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionTitle({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_primaryColor, Color(0xFF8B83FF)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555580)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: _primaryColor, size: 18),
        filled: true,
        fillColor: _bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? Colors.pink.withValues(alpha: 0.08) : _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? Colors.pink.shade200 : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? Colors.pink : Colors.grey.shade400, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(color: value ? Colors.pink.shade700 : Colors.grey.shade600, fontWeight: FontWeight.w500))),
            Checkbox(value: value, onChanged: onChanged, activeColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildTagInput({
    required TextEditingController controller,
    required String hint,
    required List<String> tags,
    required Color color,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: _bgColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) { onAdd(v.trim()); controller.clear(); }
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (controller.text.trim().isNotEmpty) { onAdd(controller.text.trim()); controller.clear(); }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add_rounded, color: color, size: 20),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                GestureDetector(onTap: () => onRemove(t), child: Icon(Icons.close_rounded, size: 14, color: color)),
              ]),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoBanner({required IconData icon, required String text, required Color color, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: iconColor, height: 1.4))),
        ],
      ),
    );
  }

  String _toDisplayName(String modelName) {
    return modelName.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}
