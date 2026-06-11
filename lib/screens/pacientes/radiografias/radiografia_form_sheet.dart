import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odontologia_app/models/radiografia.dart';
import 'package:odontologia_app/providers/radiografias_provider.dart';
import 'package:odontologia_app/screens/pacientes/radiografias/image_source_sheet.dart';
import 'package:odontologia_app/services/radiografias_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class RadiografiaFormSheet extends StatefulWidget {
  const RadiografiaFormSheet({
    required this.fichaId,
    this.radiografia,
    super.key,
  });

  final int fichaId;
  final Radiografia? radiografia;

  @override
  State<RadiografiaFormSheet> createState() => _RadiografiaFormSheetState();
}

class _RadiografiaFormSheetState extends State<RadiografiaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _tipoController = TextEditingController();
  final _piezaController = TextEditingController();
  final _zonaController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _porcentajeController = TextEditingController();
  final _nivelCrestaController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _fechaEstudio;
  bool _perdidaOsea = false;
  String? _tipoPerdida;
  String? _severidad;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    final radiografia = widget.radiografia;
    if (radiografia == null) {
      _tipoController.text = 'PERIAPICAL';
      _fechaEstudio = DateTime.now();
      return;
    }
    _tituloController.text = radiografia.titulo;
    _descripcionController.text = radiografia.descripcion ?? '';
    _tipoController.text = radiografia.tipo ?? '';
    _piezaController.text = radiografia.numeroFdi?.toString() ?? '';
    _zonaController.text = radiografia.zona ?? '';
    _diagnosticoController.text = radiografia.diagnosticoRadiografico ?? '';
    _porcentajeController.text =
        radiografia.porcentajePerdidaOseaEstimado?.toString() ?? '';
    _nivelCrestaController.text =
        radiografia.nivelCrestaOseaMm?.toString() ?? '';
    _observacionesController.text =
        radiografia.observacionesPeriodontales ?? '';
    _fechaEstudio = radiografia.fechaEstudio;
    _perdidaOsea = radiografia.perdidaOseaObservada;
    _tipoPerdida = radiografia.tipoPerdidaOsea;
    _severidad = radiografia.severidadPerdidaOsea;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _tipoController.dispose();
    _piezaController.dispose();
    _zonaController.dispose();
    _diagnosticoController.dispose();
    _porcentajeController.dispose();
    _nivelCrestaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadiografiasProvider>();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isEditing = widget.radiografia != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, bottom + 18),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar radiografia' : 'Nueva radiografia',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.inverted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: provider.isSaving ? null : _pickImage,
                    icon: const Icon(Icons.image_search_outlined),
                    label: Text(
                      _filePath == null
                          ? 'Seleccionar imagen'
                          : 'Imagen seleccionada',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _TextField(
                controller: _tituloController,
                label: 'Titulo',
                icon: Icons.image_outlined,
                required: true,
              ),
              const SizedBox(height: 12),
              _TextField(
                controller: _descripcionController,
                label: 'Descripcion',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      controller: _tipoController,
                      label: 'Tipo',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TextField(
                      controller: _piezaController,
                      label: 'Pieza FDI',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextField(controller: _zonaController, label: 'Zona'),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de estudio'),
                subtitle: Text(_formatDate(_fechaEstudio ?? DateTime.now())),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: provider.isSaving ? null : _pickDate,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Perdida osea observada'),
                value: _perdidaOsea,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => _perdidaOsea = value),
              ),
              if (_perdidaOsea) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _EnumDropdown(
                        label: 'Tipo perdida',
                        value: _tipoPerdida,
                        values: const {
                          'HORIZONTAL': 'Horizontal',
                          'VERTICAL': 'Vertical',
                          'MIXTA': 'Mixta',
                          'NO_EVALUABLE': 'No evaluable',
                        },
                        onChanged: (value) =>
                            setState(() => _tipoPerdida = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _EnumDropdown(
                        label: 'Severidad',
                        value: _severidad,
                        values: const {
                          'LEVE': 'Leve',
                          'MODERADA': 'Moderada',
                          'SEVERA': 'Severa',
                          'NO_EVALUABLE': 'No evaluable',
                        },
                        onChanged: (value) =>
                            setState(() => _severidad = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TextField(
                        controller: _porcentajeController,
                        label: '% perdida',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextField(
                        controller: _nivelCrestaController,
                        label: 'Cresta osea mm',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _TextField(
                controller: _diagnosticoController,
                label: 'Diagnostico radiografico',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _TextField(
                controller: _observacionesController,
                label: 'Observaciones periodontales',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: provider.isSaving ? null : _save,
                  icon: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Guardar radiografia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await chooseImageSource(context);
    if (source == null || !mounted) {
      return;
    }
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (file != null && mounted) {
      setState(() => _filePath = file.path);
    }
  }

  Future<void> _pickDate() async {
    final current = _fechaEstudio ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null && mounted) {
      setState(() => _fechaEstudio = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.radiografia == null && _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una imagen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = RadiografiaRequest(
      titulo: _tituloController.text.trim(),
      descripcion: _emptyToNull(_descripcionController.text),
      tipo: _emptyToNull(_tipoController.text),
      fechaEstudio: _fechaEstudio,
      numeroFdi: _parseInt(_piezaController.text),
      zona: _emptyToNull(_zonaController.text),
      diagnosticoRadiografico: _emptyToNull(_diagnosticoController.text),
      perdidaOseaObservada: _perdidaOsea,
      tipoPerdidaOsea: _perdidaOsea ? _tipoPerdida : null,
      severidadPerdidaOsea: _perdidaOsea ? _severidad : null,
      porcentajePerdidaOseaEstimado: _perdidaOsea
          ? _parseDouble(_porcentajeController.text)
          : null,
      nivelCrestaOseaMm: _perdidaOsea
          ? _parseDouble(_nivelCrestaController.text)
          : null,
      observacionesPeriodontales: _emptyToNull(_observacionesController.text),
    );

    final provider = context.read<RadiografiasProvider>();
    final radiografia = widget.radiografia;
    final message = radiografia == null
        ? await provider.crear(
            fichaId: widget.fichaId,
            request: request,
            filePath: _filePath!,
          )
        : await provider.actualizar(radiografia: radiografia, request: request);

    if (!mounted) {
      return;
    }
    if (message == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            radiografia == null
                ? 'Radiografia creada.'
                : 'Radiografia guardada.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.icon,
    this.required = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool required;
  final int? minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      validator: required
          ? (value) =>
                value == null || value.trim().isEmpty ? 'Requerido' : null
          : null,
    );
  }
}

class _EnumDropdown extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final Map<String, String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in values.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
    );
  }
}
