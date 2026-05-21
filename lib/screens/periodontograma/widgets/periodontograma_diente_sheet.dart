import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/providers/periodontograma_provider.dart';
import 'package:odontologia_app/services/periodontograma_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PeriodontogramaDienteSheet extends StatefulWidget {
  const PeriodontogramaDienteSheet.general({required this.diente, super.key})
    : grupo = null;

  const PeriodontogramaDienteSheet.sitios({
    required this.diente,
    required PeriodontogramaSitioGrupo this.grupo,
    super.key,
  });

  final PeriodontogramaDiente diente;
  final PeriodontogramaSitioGrupo? grupo;

  @override
  State<PeriodontogramaDienteSheet> createState() =>
      _PeriodontogramaDienteSheetState();
}

class _PeriodontogramaDienteSheetState
    extends State<PeriodontogramaDienteSheet> {
  late bool _ausente;
  late bool _implante;
  late int? _movilidad;
  late String _furcacionVestibular;
  late String _furcacionPalatinaLingual;
  late final TextEditingController _observacionController;
  late String _sitioSeleccionado;

  @override
  void initState() {
    super.initState();
    _ausente = widget.diente.ausente;
    _implante = widget.diente.implante;
    _movilidad = widget.diente.movilidad;
    _furcacionVestibular = widget.diente.permiteFurcacion
        ? widget.diente.furcacionVestibular
        : PeriodontogramaFurcacion.ninguna;
    _furcacionPalatinaLingual = widget.diente.permiteFurcacion
        ? widget.diente.furcacionPalatinaLingual
        : PeriodontogramaFurcacion.ninguna;
    _sitioSeleccionado =
        widget.grupo?.sitios.first ?? PeriodontogramaSitioTipo.mesioVestibular;
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
    final provider = context.watch<PeriodontogramaProvider>();
    final diente =
        provider.periodontograma?.dientePorFdi(widget.diente.numeroFdi) ??
        widget.diente;
    final grupo = widget.grupo;

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
            if (grupo == null)
              _GeneralToothEditor(
                diente: diente,
                ausente: _ausente,
                implante: _implante,
                movilidad: _movilidad,
                observacionController: _observacionController,
                onAusenteChanged: (value) => setState(() => _ausente = value),
                onImplanteChanged: (value) => setState(() => _implante = value),
                onMovilidadChanged: (value) =>
                    setState(() => _movilidad = value),
                onSave: () => _saveTooth(context, diente),
              )
            else
              _SitesGroupEditor(
                diente: diente,
                grupo: grupo,
                selectedSite: _sitioSeleccionado,
                furcacion: _furcacionForGroup(grupo),
                onSiteSelected: (value) =>
                    setState(() => _sitioSeleccionado = value),
                onFurcacionChanged: (value) =>
                    setState(() => _setFurcacionForGroup(grupo, value)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTooth(
    BuildContext context,
    PeriodontogramaDiente diente,
  ) async {
    final message = await context
        .read<PeriodontogramaProvider>()
        .actualizarDiente(
          diente: diente,
          request: PeriodontogramaDienteRequest(
            ausente: _ausente,
            implante: _implante,
            movilidad: _movilidad,
            furcacionVestibular: diente.permiteFurcacion
                ? _furcacionVestibular
                : PeriodontogramaFurcacion.ninguna,
            furcacionPalatinaLingual: diente.permiteFurcacion
                ? _furcacionPalatinaLingual
                : PeriodontogramaFurcacion.ninguna,
            observacion: _observacionController.text.trim().isEmpty
                ? null
                : _observacionController.text.trim(),
          ),
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Pieza periodontal guardada.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }

  String _furcacionForGroup(PeriodontogramaSitioGrupo grupo) {
    return switch (grupo) {
      PeriodontogramaSitioGrupo.vestibular => _furcacionVestibular,
      PeriodontogramaSitioGrupo.palatinaLingual => _furcacionPalatinaLingual,
    };
  }

  void _setFurcacionForGroup(PeriodontogramaSitioGrupo grupo, String value) {
    switch (grupo) {
      case PeriodontogramaSitioGrupo.vestibular:
        _furcacionVestibular = value;
      case PeriodontogramaSitioGrupo.palatinaLingual:
        _furcacionPalatinaLingual = value;
    }
  }
}

class _GeneralToothEditor extends StatelessWidget {
  const _GeneralToothEditor({
    required this.diente,
    required this.ausente,
    required this.implante,
    required this.movilidad,
    required this.observacionController,
    required this.onAusenteChanged,
    required this.onImplanteChanged,
    required this.onMovilidadChanged,
    required this.onSave,
  });

  final PeriodontogramaDiente diente;
  final bool ausente;
  final bool implante;
  final int? movilidad;
  final TextEditingController observacionController;
  final ValueChanged<bool> onAusenteChanged;
  final ValueChanged<bool> onImplanteChanged;
  final ValueChanged<int?> onMovilidadChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodontogramaProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.fact_check_outlined,
          title: 'Estado general',
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: ausente,
          onChanged: onAusenteChanged,
          title: const Text('Ausente'),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.primary,
        ),
        SwitchListTile(
          value: implante,
          onChanged: onImplanteChanged,
          title: const Text('Implante'),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.primary,
        ),
        DropdownButtonFormField<int?>(
          initialValue: movilidad,
          decoration: const InputDecoration(
            labelText: 'Movilidad',
            prefixIcon: Icon(Icons.swap_vert_rounded),
          ),
          items: const [
            DropdownMenuItem<int?>(value: null, child: Text('Sin movilidad')),
            DropdownMenuItem(value: 0, child: Text('Grado 0')),
            DropdownMenuItem(value: 1, child: Text('Grado 1')),
            DropdownMenuItem(value: 2, child: Text('Grado 2')),
            DropdownMenuItem(value: 3, child: Text('Grado 3')),
          ],
          onChanged: onMovilidadChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: observacionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Observacion de la pieza',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: provider.isSaving ? null : onSave,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar pieza'),
          ),
        ),
      ],
    );
  }
}

class _SitesGroupEditor extends StatelessWidget {
  const _SitesGroupEditor({
    required this.diente,
    required this.grupo,
    required this.selectedSite,
    required this.furcacion,
    required this.onSiteSelected,
    required this.onFurcacionChanged,
  });

  final PeriodontogramaDiente diente;
  final PeriodontogramaSitioGrupo grupo;
  final String selectedSite;
  final String furcacion;
  final ValueChanged<String> onSiteSelected;
  final ValueChanged<String> onFurcacionChanged;

  @override
  Widget build(BuildContext context) {
    final sitio = diente.sitio(selectedSite);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: Icons.grid_view_rounded, title: grupo.titulo),
        const SizedBox(height: 10),
        if (diente.permiteFurcacion) ...[
          _FurcacionDropdown(
            label: grupo.furcacionLabel,
            value: furcacion,
            onChanged: onFurcacionChanged,
          ),
          const SizedBox(height: 14),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tipo in grupo.sitios)
              ChoiceChip(
                label: Text(PeriodontogramaSitioTipo.label(tipo)),
                selected: selectedSite == tipo,
                onSelected: (_) => onSiteSelected(tipo),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _SitioEditor(
          key: ValueKey('${diente.numeroFdi}-${sitio.sitio}-${sitio.id}'),
          diente: diente,
          sitio: sitio,
          furcacionVestibular: diente.permiteFurcacion
              ? grupo == PeriodontogramaSitioGrupo.vestibular
                    ? furcacion
                    : diente.furcacionVestibular
              : PeriodontogramaFurcacion.ninguna,
          furcacionPalatinaLingual: diente.permiteFurcacion
              ? grupo == PeriodontogramaSitioGrupo.palatinaLingual
                    ? furcacion
                    : diente.furcacionPalatinaLingual
              : PeriodontogramaFurcacion.ninguna,
        ),
      ],
    );
  }
}

class _FurcacionDropdown extends StatelessWidget {
  const _FurcacionDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_tree_outlined),
      ),
      items: [
        for (final value in PeriodontogramaFurcacion.all)
          DropdownMenuItem(
            value: value,
            child: Text(PeriodontogramaFurcacion.label(value)),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _SitioEditor extends StatefulWidget {
  const _SitioEditor({
    required this.diente,
    required this.sitio,
    required this.furcacionVestibular,
    required this.furcacionPalatinaLingual,
    super.key,
  });

  final PeriodontogramaDiente diente;
  final PeriodontogramaSitio sitio;
  final String furcacionVestibular;
  final String furcacionPalatinaLingual;

  @override
  State<_SitioEditor> createState() => _SitioEditorState();
}

class _SitioEditorState extends State<_SitioEditor> {
  late bool _sangrado;
  late bool _placa;
  late bool _supuracion;
  late double _margen;
  late double _profundidad;
  late final TextEditingController _observacionController;

  @override
  void initState() {
    super.initState();
    _sangrado = widget.sitio.sangradoSondaje;
    _placa = widget.sitio.placa;
    _supuracion = widget.sitio.supuracion;
    _margen = widget.sitio.margenGingivalMm.toDouble();
    _profundidad = widget.sitio.profundidadSondajeMm.toDouble();
    _observacionController = TextEditingController(
      text: widget.sitio.observacion ?? '',
    );
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodontogramaProvider>();
    final nivelInsercion = _profundidad.round() - _margen.round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sitio ${PeriodontogramaSitioTipo.label(widget.sitio.sitio)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inverted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _sangrado,
            onChanged: (value) => setState(() => _sangrado = value),
            title: const Text('Sangrado al sondaje'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _placa,
            onChanged: (value) => setState(() => _placa = value),
            title: const Text('Placa'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _supuracion,
            onChanged: (value) => setState(() => _supuracion = value),
            title: const Text('Supuracion'),
            contentPadding: EdgeInsets.zero,
          ),
          _MetricSlider(
            label: 'Margen gingival',
            valueLabel: '${_margen.round()} mm',
            value: _margen,
            min: -20,
            max: 20,
            onChanged: (value) => setState(() => _margen = value),
          ),
          _MetricSlider(
            label: 'Profundidad de sondaje',
            valueLabel: '${_profundidad.round()} mm',
            value: _profundidad,
            min: 0,
            max: 20,
            onChanged: (value) => setState(() => _profundidad = value),
          ),
          const SizedBox(height: 8),
          Text(
            'Nivel de insercion calculado: $nivelInsercion mm',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Observacion del sitio',
              prefixIcon: Icon(Icons.subject_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.isSaving ? null : () => _save(context),
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar sitio'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final provider = context.read<PeriodontogramaProvider>();
    final toothMessage = await provider.actualizarDiente(
      diente: widget.diente,
      request: PeriodontogramaDienteRequest(
        ausente: widget.diente.ausente,
        implante: widget.diente.implante,
        movilidad: widget.diente.movilidad,
        furcacionVestibular: widget.furcacionVestibular,
        furcacionPalatinaLingual: widget.furcacionPalatinaLingual,
        observacion: widget.diente.observacion,
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (toothMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(toothMessage), backgroundColor: Colors.red),
      );
      return;
    }

    final message = await provider.actualizarSitio(
      diente: widget.diente,
      sitio: widget.sitio,
      request: PeriodontogramaSitioRequest(
        sangradoSondaje: _sangrado,
        placa: _placa,
        supuracion: _supuracion,
        margenGingivalMm: _margen.round(),
        profundidadSondajeMm: _profundidad.round(),
        observacion: _observacionController.text.trim().isEmpty
            ? null
            : _observacionController.text.trim(),
      ),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Sitio periodontal guardado.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  const _MetricSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              valueLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
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
