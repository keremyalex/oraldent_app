import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PeriodontogramaSummaryBand extends StatelessWidget {
  const PeriodontogramaSummaryBand({
    required this.periodontograma,
    this.dienteSeleccionado,
    this.grupoSeleccionado,
    super.key,
  });

  final Periodontograma periodontograma;
  final PeriodontogramaDiente? dienteSeleccionado;
  final PeriodontogramaSitioGrupo? grupoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final diente = dienteSeleccionado;
    final grupo = grupoSeleccionado;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: diente == null || grupo == null
          ? _Overview(periodontograma: periodontograma)
          : _FaceSummary(diente: diente, grupo: grupo),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.periodontograma});

  final Periodontograma periodontograma;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen periodontal',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          'Toca una cara del grafico para ver sus medidas.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Metric(
              icon: Icons.water_drop_outlined,
              value: '${periodontograma.sitiosConSangrado}',
              label: 'Sangrado',
            ),
            _Metric(
              icon: Icons.grid_view_rounded,
              value: '${periodontograma.sitiosConPlaca}',
              label: 'Placa',
            ),
            _Metric(
              icon: Icons.warning_amber_rounded,
              value: '${periodontograma.sitiosConSupuracion}',
              label: 'Supuracion',
            ),
            _Metric(
              icon: Icons.straighten_rounded,
              value: '${periodontograma.profundidadMaxima} mm',
              label: 'Sondaje max.',
            ),
          ],
        ),
      ],
    );
  }
}

class _FaceSummary extends StatelessWidget {
  const _FaceSummary({required this.diente, required this.grupo});

  final PeriodontogramaDiente diente;
  final PeriodontogramaSitioGrupo grupo;

  @override
  Widget build(BuildContext context) {
    final sitios = grupo.sitios.map(diente.sitio).toList();
    final furcacion = grupo == PeriodontogramaSitioGrupo.vestibular
        ? diente.furcacionVestibular
        : diente.furcacionPalatinaLingual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${diente.numeroFdi}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grupo.titulo,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    diente.ausente
                        ? 'Pieza marcada como ausente'
                        : 'Medidas de la cara seleccionada',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _StatusChip(
              label: 'Movilidad',
              value: diente.movilidad?.toString() ?? '-',
            ),
            _StatusChip(
              label: 'Implante',
              value: diente.implante ? 'Si' : 'No',
            ),
            if (diente.permiteFurcacion)
              _StatusChip(
                label: 'Furcacion',
                value: PeriodontogramaFurcacion.label(furcacion),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _MeasureRow(
                label: 'Sitio',
                values: sitios
                    .map((sitio) => PeriodontogramaSitioTipo.label(sitio.sitio))
                    .toList(),
                header: true,
              ),
              const Divider(height: 12),
              _BoolMeasureRow(
                label: 'Sangrado',
                values: sitios.map((sitio) => sitio.sangradoSondaje).toList(),
                activeColor: const Color(0xFFDC2626),
              ),
              _BoolMeasureRow(
                label: 'Placa',
                values: sitios.map((sitio) => sitio.placa).toList(),
                activeColor: const Color(0xFF0F766E),
              ),
              _MeasureRow(
                label: 'Margen',
                values: sitios
                    .map((sitio) => '${sitio.margenGingivalMm}')
                    .toList(),
              ),
              _MeasureRow(
                label: 'Sondaje',
                values: sitios
                    .map((sitio) => '${sitio.profundidadSondajeMm}')
                    .toList(),
              ),
              _MeasureRow(
                label: 'Insercion',
                values: sitios
                    .map((sitio) => '${sitio.nivelInsercionMm}')
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _MeasureRow extends StatelessWidget {
  const _MeasureRow({
    required this.label,
    required this.values,
    this.header = false,
  });

  final String label;
  final List<String> values;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final color = header ? AppColors.inverted : AppColors.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: header ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          for (final value in values)
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: header ? AppColors.primary : AppColors.inverted,
                  fontSize: 11,
                  fontWeight: header ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BoolMeasureRow extends StatelessWidget {
  const _BoolMeasureRow({
    required this.label,
    required this.values,
    required this.activeColor,
  });

  final String label;
  final List<bool> values;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final active in values)
            Expanded(
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? activeColor : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
