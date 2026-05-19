import 'package:flutter/material.dart';
import 'package:odontologia_app/models/ficha_clinica.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/fichas_provider.dart';
import 'package:odontologia_app/services/fichas_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FichaDetalleScreen extends StatefulWidget {
  const FichaDetalleScreen({required this.fichaId, this.paciente, super.key});

  final int fichaId;
  final Paciente? paciente;

  @override
  State<FichaDetalleScreen> createState() => _FichaDetalleScreenState();
}

class _FichaDetalleScreenState extends State<FichaDetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _edadController = TextEditingController();
  final _sexoController = TextEditingController();
  final _procedenciaController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _presionController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _pulsoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _enfermedadController = TextEditingController();
  final _anamnesisController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _medicamentoController = TextEditingController();
  final _otrasPatologiasController = TextEditingController();
  final _examenClinicoController = TextEditingController();
  final _examenRadiograficoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _anestesiaController = TextEditingController();
  final _evolucionController = TextEditingController();

  bool _loaded = false;
  bool _hemorragia = false;
  bool _diabetes = false;
  bool _hipertension = false;
  bool _epilepsia = false;
  bool _problemasCardiovasculares = false;
  bool _lipotimias = false;
  bool _tratamientoMedicoActual = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    final cached = context.read<FichasProvider>().fichaPorId(widget.fichaId);
    if (cached != null) {
      _fill(cached);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ficha = await context.read<FichasProvider>().obtenerFicha(
        widget.fichaId,
      );
      if (mounted && ficha != null) {
        _fill(ficha);
      }
    });
  }

  @override
  void dispose() {
    _edadController.dispose();
    _sexoController.dispose();
    _procedenciaController.dispose();
    _ocupacionController.dispose();
    _presionController.dispose();
    _temperaturaController.dispose();
    _pulsoController.dispose();
    _motivoController.dispose();
    _enfermedadController.dispose();
    _anamnesisController.dispose();
    _alergiasController.dispose();
    _medicamentoController.dispose();
    _otrasPatologiasController.dispose();
    _examenClinicoController.dispose();
    _examenRadiograficoController.dispose();
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    _anestesiaController.dispose();
    _evolucionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FichasProvider>();
    final ficha = provider.fichaPorId(widget.fichaId);
    final paciente = widget.paciente ?? ficha?.paciente;

    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.inverted,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ficha clinica'),
            if (paciente != null)
              Text(
                paciente.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: provider.isLoading && ficha == null
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    _SectionCard(
                      title: 'Datos generales',
                      icon: Icons.assignment_ind_outlined,
                      children: [
                        _NumberField(
                          controller: _edadController,
                          label: 'Edad',
                        ),
                        _TextField(controller: _sexoController, label: 'Sexo'),
                        _TextField(
                          controller: _procedenciaController,
                          label: 'Procedencia',
                        ),
                        _TextField(
                          controller: _ocupacionController,
                          label: 'Ocupacion',
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'Signos vitales',
                      icon: Icons.monitor_heart_outlined,
                      children: [
                        _TextField(
                          controller: _presionController,
                          label: 'Presion arterial',
                        ),
                        _DecimalField(
                          controller: _temperaturaController,
                          label: 'Temperatura',
                        ),
                        _NumberField(
                          controller: _pulsoController,
                          label: 'Pulso',
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'Anamnesis',
                      icon: Icons.forum_outlined,
                      children: [
                        _TextField(
                          controller: _motivoController,
                          label: 'Motivo de consulta',
                          maxLines: 3,
                        ),
                        _TextField(
                          controller: _enfermedadController,
                          label: 'Enfermedad actual',
                          maxLines: 4,
                        ),
                        _TextField(
                          controller: _anamnesisController,
                          label: 'Anamnesis',
                          maxLines: 4,
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'Antecedentes patologicos',
                      icon: Icons.health_and_safety_outlined,
                      children: [
                        _SwitchTile(
                          title: 'Hemorragia',
                          value: _hemorragia,
                          onChanged: (value) =>
                              setState(() => _hemorragia = value),
                        ),
                        _SwitchTile(
                          title: 'Diabetes',
                          value: _diabetes,
                          onChanged: (value) =>
                              setState(() => _diabetes = value),
                        ),
                        _SwitchTile(
                          title: 'Hipertension',
                          value: _hipertension,
                          onChanged: (value) =>
                              setState(() => _hipertension = value),
                        ),
                        _SwitchTile(
                          title: 'Epilepsia',
                          value: _epilepsia,
                          onChanged: (value) =>
                              setState(() => _epilepsia = value),
                        ),
                        _SwitchTile(
                          title: 'Problemas cardiovasculares',
                          value: _problemasCardiovasculares,
                          onChanged: (value) => setState(
                            () => _problemasCardiovasculares = value,
                          ),
                        ),
                        _SwitchTile(
                          title: 'Lipotimias',
                          value: _lipotimias,
                          onChanged: (value) =>
                              setState(() => _lipotimias = value),
                        ),
                        _SwitchTile(
                          title: 'Tratamiento medico actual',
                          value: _tratamientoMedicoActual,
                          onChanged: (value) =>
                              setState(() => _tratamientoMedicoActual = value),
                        ),
                        _TextField(
                          controller: _alergiasController,
                          label: 'Alergias',
                          maxLines: 3,
                        ),
                        _TextField(
                          controller: _medicamentoController,
                          label: 'Medicamento actual',
                          maxLines: 3,
                        ),
                        _TextField(
                          controller: _otrasPatologiasController,
                          label: 'Otras patologias',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    _SectionCard(
                      title: 'Evaluacion odontologica',
                      icon: Icons.medical_information_outlined,
                      initiallyExpanded: false,
                      children: [
                        _TextField(
                          controller: _examenClinicoController,
                          label: 'Examen clinico',
                          maxLines: 4,
                        ),
                        _TextField(
                          controller: _examenRadiograficoController,
                          label: 'Examen radiografico',
                          maxLines: 4,
                        ),
                        _TextField(
                          controller: _diagnosticoController,
                          label: 'Diagnostico',
                          maxLines: 4,
                        ),
                        _TextField(
                          controller: _tratamientoController,
                          label: 'Tratamiento',
                          maxLines: 4,
                        ),
                        _TextField(
                          controller: _anestesiaController,
                          label: 'Tecnica de anestesia',
                          maxLines: 3,
                        ),
                        _TextField(
                          controller: _evolucionController,
                          label: 'Evolucion',
                          maxLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: provider.isSaving
                            ? null
                            : () => _save(context, ficha),
                        icon: provider.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: const Text('Guardar ficha'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _fill(FichaClinica ficha) {
    _edadController.text = ficha.edad?.toString() ?? '';
    _sexoController.text = ficha.sexo ?? '';
    _procedenciaController.text = ficha.procedencia ?? '';
    _ocupacionController.text = ficha.ocupacion ?? '';
    _presionController.text = ficha.presionArterial ?? '';
    _temperaturaController.text = ficha.temperatura?.toString() ?? '';
    _pulsoController.text = ficha.pulso?.toString() ?? '';
    _motivoController.text = ficha.motivoConsulta ?? '';
    _enfermedadController.text = ficha.enfermedadActual ?? '';
    _anamnesisController.text = ficha.anamnesis ?? '';
    _alergiasController.text = ficha.alergias ?? '';
    _medicamentoController.text = ficha.medicamentoActual ?? '';
    _otrasPatologiasController.text = ficha.otrasPatologias ?? '';
    _examenClinicoController.text = ficha.examenClinico ?? '';
    _examenRadiograficoController.text = ficha.examenRadiografico ?? '';
    _diagnosticoController.text = ficha.diagnostico ?? '';
    _tratamientoController.text = ficha.tratamiento ?? '';
    _anestesiaController.text = ficha.tecnicaAnestesia ?? '';
    _evolucionController.text = ficha.evolucion ?? '';
    _hemorragia = ficha.hemorragia;
    _diabetes = ficha.diabetes;
    _hipertension = ficha.hipertension;
    _epilepsia = ficha.epilepsia;
    _problemasCardiovasculares = ficha.problemasCardiovasculares;
    _lipotimias = ficha.lipotimias;
    _tratamientoMedicoActual = ficha.tratamientoMedicoActual;
    setState(() {});
  }

  Future<void> _save(BuildContext context, FichaClinica? ficha) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = FichaClinicaRequest(
      citaId: ficha?.citaId,
      fecha: ficha?.fecha,
      edad: _parseInt(_edadController.text),
      sexo: _emptyToNull(_sexoController.text),
      procedencia: _emptyToNull(_procedenciaController.text),
      ocupacion: _emptyToNull(_ocupacionController.text),
      presionArterial: _emptyToNull(_presionController.text),
      temperatura: _parseDouble(_temperaturaController.text),
      pulso: _parseInt(_pulsoController.text),
      motivoConsulta: _emptyToNull(_motivoController.text),
      enfermedadActual: _emptyToNull(_enfermedadController.text),
      anamnesis: _emptyToNull(_anamnesisController.text),
      hemorragia: _hemorragia,
      diabetes: _diabetes,
      hipertension: _hipertension,
      epilepsia: _epilepsia,
      problemasCardiovasculares: _problemasCardiovasculares,
      lipotimias: _lipotimias,
      tratamientoMedicoActual: _tratamientoMedicoActual,
      alergias: _emptyToNull(_alergiasController.text),
      medicamentoActual: _emptyToNull(_medicamentoController.text),
      otrasPatologias: _emptyToNull(_otrasPatologiasController.text),
      examenClinico: _emptyToNull(_examenClinicoController.text),
      examenRadiografico: _emptyToNull(_examenRadiograficoController.text),
      diagnostico: _emptyToNull(_diagnosticoController.text),
      tratamiento: _emptyToNull(_tratamientoController.text),
      tecnicaAnestesia: _emptyToNull(_anestesiaController.text),
      evolucion: _emptyToNull(_evolucionController.text),
    );

    final message = await context.read<FichasProvider>().actualizarFicha(
      fichaId: widget.fichaId,
      request: request,
    );

    if (!context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    if (message == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Ficha clinica guardada.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  int? _parseInt(String value) {
    final text = value.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }

  double? _parseDouble(String value) {
    final text = value.trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = true,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.inverted,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _DecimalField extends StatelessWidget {
  const _DecimalField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
