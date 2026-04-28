import 'package:flutter/material.dart';
import 'package:odontologia_app/models/horario_atencion.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class HorarioDaySection extends StatelessWidget {
  const HorarioDaySection({
    required this.dayLabel,
    required this.horarios,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String dayLabel;
  final List<HorarioAtencion> horarios;
  final ValueChanged<HorarioAtencion> onEdit;
  final ValueChanged<HorarioAtencion> onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${horarios.length} ${horarios.length == 1 ? 'bloque' : 'bloques'} de atencion',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < horarios.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            _HorarioBlockTile(
              horario: horarios[index],
              onEdit: () => onEdit(horarios[index]),
              onDelete: () => onDelete(horarios[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _HorarioBlockTile extends StatelessWidget {
  const _HorarioBlockTile({
    required this.horario,
    required this.onEdit,
    required this.onDelete,
  });

  final HorarioAtencion horario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horario.rango,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${horario.duracionCitaMinutos} min por cita',
                    if (horario.observacion != null &&
                        horario.observacion!.isNotEmpty)
                      horario.observacion!,
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Desactivar')),
            ],
          ),
        ],
      ),
    );
  }
}
