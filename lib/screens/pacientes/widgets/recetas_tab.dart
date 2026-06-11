import 'package:flutter/material.dart';
import 'package:odontologia_app/models/receta.dart';
import 'package:odontologia_app/providers/recetas_provider.dart';
import 'package:odontologia_app/services/recetas_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class RecetasTab extends StatefulWidget {
  const RecetasTab({required this.fichaId, super.key});

  final int fichaId;

  @override
  State<RecetasTab> createState() => _RecetasTabState();
}

class _RecetasTabState extends State<RecetasTab> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecetasProvider>().loadIfNeeded(widget.fichaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecetasProvider>();
    final recetas = provider.recetasDeFicha(widget.fichaId);
    final isLoading = provider.cargandoFicha(widget.fichaId);
    final error = provider.errorDeFicha(widget.fichaId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recetas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.inverted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filled(
              onPressed: provider.isSaving ? null : () => _openForm(context),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Nueva receta',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading && recetas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null && recetas.isEmpty)
          _MessageCard(
            icon: Icons.cloud_off_rounded,
            title: 'No se pudieron cargar las recetas',
            message: error,
            actionLabel: 'Reintentar',
            onAction: () =>
                context.read<RecetasProvider>().load(widget.fichaId),
          )
        else if (recetas.isEmpty)
          _MessageCard(
            icon: Icons.receipt_long_outlined,
            title: 'Sin recetas',
            message: 'Crea una receta para esta ficha clinica.',
            actionLabel: 'Crear receta',
            onAction: provider.isSaving ? null : () => _openForm(context),
          )
        else
          ...recetas.map(
            (receta) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecetaCard(
                receta: receta,
                onEdit: () => _openForm(context, receta: receta),
                onDelete: () => _confirmDelete(context, receta),
                onPdf: provider.isSaving
                    ? null
                    : () => _openPdf(context, receta),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context, {Receta? receta}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<RecetasProvider>(),
          child: RecetaFormSheet(fichaId: widget.fichaId, receta: receta),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Receta receta) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: const Text('La receta dejara de aparecer en esta ficha.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final message = await context.read<RecetasProvider>().desactivar(receta);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Receta eliminada.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, Receta receta) async {
    final message = await context.read<RecetasProvider>().abrirPdf(receta.id);
    if (!context.mounted) {
      return;
    }
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

class _RecetaCard extends StatelessWidget {
  const _RecetaCard({
    required this.receta,
    required this.onEdit,
    required this.onDelete,
    required this.onPdf,
  });

  final Receta receta;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receta.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.inverted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${receta.detalles.length} medicamento(s) · ${receta.fechaFormateada}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (receta.indicacionesGenerales?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              receta.indicacionesGenerales!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChipButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF',
                onTap: onPdf,
              ),
              _ActionChipButton(
                icon: Icons.edit_outlined,
                label: 'Editar',
                onTap: onEdit,
              ),
              _ActionChipButton(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecetaFormSheet extends StatefulWidget {
  const RecetaFormSheet({required this.fichaId, this.receta, super.key});

  final int fichaId;
  final Receta? receta;

  @override
  State<RecetaFormSheet> createState() => _RecetaFormSheetState();
}

class _RecetaFormSheetState extends State<RecetaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _medicamentoController = TextEditingController();
  final _dosisController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _duracionController = TextEditingController();
  final _indicacionesController = TextEditingController();
  final _indicacionesGeneralesController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final receta = widget.receta;
    if (receta == null) {
      return;
    }
    final detalle = receta.detalles.isEmpty ? null : receta.detalles.first;
    _medicamentoController.text = detalle?.medicamento ?? '';
    _dosisController.text = detalle?.dosis ?? '';
    _frecuenciaController.text = detalle?.frecuencia ?? '';
    _duracionController.text = detalle?.duracion ?? '';
    _indicacionesController.text = detalle?.indicaciones ?? '';
    _indicacionesGeneralesController.text = receta.indicacionesGenerales ?? '';
    _observacionesController.text = receta.observaciones ?? '';
  }

  @override
  void dispose() {
    _medicamentoController.dispose();
    _dosisController.dispose();
    _frecuenciaController.dispose();
    _duracionController.dispose();
    _indicacionesController.dispose();
    _indicacionesGeneralesController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecetasProvider>();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

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
                widget.receta == null ? 'Nueva receta' : 'Editar receta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.inverted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicamentoController,
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosisController,
                decoration: const InputDecoration(labelText: 'Dosis'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frecuenciaController,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duracionController,
                decoration: const InputDecoration(labelText: 'Duracion'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _indicacionesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Indicaciones del medicamento',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _indicacionesGeneralesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Indicaciones generales',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.isSaving ? null : _save,
                  icon: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Guardar receta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = RecetaRequest(
      indicacionesGenerales: _emptyToNull(
        _indicacionesGeneralesController.text,
      ),
      observaciones: _emptyToNull(_observacionesController.text),
      detalles: [
        RecetaDetalleRequest(
          medicamento: _medicamentoController.text.trim(),
          dosis: _emptyToNull(_dosisController.text),
          frecuencia: _emptyToNull(_frecuenciaController.text),
          duracion: _emptyToNull(_duracionController.text),
          indicaciones: _emptyToNull(_indicacionesController.text),
          orden: 0,
        ),
      ],
    );

    final provider = context.read<RecetasProvider>();
    final receta = widget.receta;
    final message = receta == null
        ? await provider.crear(fichaId: widget.fichaId, request: request)
        : await provider.actualizar(receta: receta, request: request);

    if (!mounted) {
      return;
    }
    if (message == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(receta == null ? 'Receta creada.' : 'Receta guardada.'),
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
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      backgroundColor: Colors.white,
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.inverted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
