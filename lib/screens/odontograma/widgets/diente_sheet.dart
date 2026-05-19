import 'package:flutter/material.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/providers/odontograma_provider.dart';
import 'package:odontologia_app/screens/odontograma/widgets/tooth_diagram.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DienteSheet extends StatefulWidget {
  const DienteSheet({required this.diente, required this.enabled, super.key});

  final OdontogramaDiente diente;
  final bool enabled;

  @override
  State<DienteSheet> createState() => _DienteSheetState();
}

class _DienteSheetState extends State<DienteSheet> {
  late bool _ausente;
  late bool _implante;
  late bool _corona;
  late bool _endodoncia;
  late bool _extraccionIndicada;
  String? _selectedFace = OdontogramaCaraTipo.oclusal;
  late final TextEditingController _observacionController;

  @override
  void initState() {
    super.initState();
    _ausente = widget.diente.ausente;
    _implante = _ausente ? false : widget.diente.implante;
    _corona = _ausente ? false : widget.diente.corona;
    _endodoncia = _ausente ? false : widget.diente.endodoncia;
    _extraccionIndicada = _ausente ? false : widget.diente.extraccionIndicada;
    _observacionController = TextEditingController(
      text: widget.diente.observacion ?? '',
    );
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdontogramaProvider>();
    final diente =
        provider.odontograma?.dientePorFdi(widget.diente.numeroFdi) ??
        widget.diente;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pieza ${diente.numeroFdi}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.inverted,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _SectionTitle(
              icon: Icons.grid_view_rounded,
              title: 'Caras del diente',
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: ToothDiagram(
                  diente: diente,
                  selectedFace: _selectedFace,
                  onFaceTap: !widget.enabled || _ausente
                      ? null
                      : (face) => _toggleFaceByType(context, diente, face),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _ausente
                    ? 'Pieza ausente: las caras quedan deshabilitadas'
                    : _selectedFace == null
                    ? 'Selecciona una cara'
                    : '${OdontogramaCaraTipo.label(_selectedFace!)}: ${OdontogramaColor.label(diente.cara(_selectedFace!).color)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cara in diente.caras)
                  ActionChip(
                    avatar: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: OdontogramaColor.asColor(cara.color),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                    ),
                    label: Text(OdontogramaCaraTipo.label(cara.tipo)),
                    onPressed: !widget.enabled || provider.isSaving || _ausente
                        ? null
                        : () => _toggleCara(context, diente, cara),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle(
              icon: Icons.fact_check_outlined,
              title: 'Estado de la pieza',
            ),
            const SizedBox(height: 4),
            _SwitchTile(
              value: _ausente,
              title: 'Ausente',
              enabled: widget.enabled,
              onChanged: _updateAusente,
            ),
            _SwitchTile(
              value: _implante,
              title: 'Implante',
              enabled: widget.enabled && !_ausente,
              onChanged: (value) => setState(() => _implante = value),
            ),
            _SwitchTile(
              value: _corona,
              title: 'Corona',
              enabled: widget.enabled && !_ausente,
              onChanged: (value) => setState(() => _corona = value),
            ),
            _SwitchTile(
              value: _endodoncia,
              title: 'Endodoncia',
              enabled: widget.enabled && !_ausente,
              onChanged: (value) => setState(() => _endodoncia = value),
            ),
            _SwitchTile(
              value: _extraccionIndicada,
              title: 'Extraccion indicada',
              enabled: widget.enabled && !_ausente,
              onChanged: (value) => setState(() => _extraccionIndicada = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _observacionController,
              enabled: widget.enabled,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observacion',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !widget.enabled || provider.isSaving
                    ? null
                    : () => _save(context),
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  widget.enabled ? 'Aplicar cambios' : 'Solo lectura',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCara(
    BuildContext context,
    OdontogramaDiente diente,
    OdontogramaCara cara,
  ) {
    setState(() => _selectedFace = cara.tipo);
    context.read<OdontogramaProvider>().alternarCaraLocal(
      numeroFdi: diente.numeroFdi,
      tipo: cara.tipo,
    );
  }

  void _updateAusente(bool value) {
    setState(() {
      _ausente = value;
      if (value) {
        _implante = false;
        _corona = false;
        _endodoncia = false;
        _extraccionIndicada = false;
      }
    });
  }

  void _toggleFaceByType(
    BuildContext context,
    OdontogramaDiente diente,
    String face,
  ) {
    return _toggleCara(context, diente, diente.cara(face));
  }

  void _save(BuildContext context) {
    context.read<OdontogramaProvider>().actualizarDienteLocal(
      numeroFdi: widget.diente.numeroFdi,
      ausente: _ausente,
      implante: _implante,
      corona: _corona,
      endodoncia: _endodoncia,
      extraccionIndicada: _extraccionIndicada,
      observacion: _observacionController.text.trim().isEmpty
          ? null
          : _observacionController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.value,
    required this.title,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.primary,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.inverted,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
