import 'package:flutter/material.dart';
import 'package:odontologia_app/models/servicio.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/services/servicios_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ServicioFormSheet extends StatefulWidget {
  const ServicioFormSheet({this.servicio, super.key});

  final Servicio? servicio;

  @override
  State<ServicioFormSheet> createState() => _ServicioFormSheetState();
}

class _ServicioFormSheetState extends State<ServicioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final servicio = widget.servicio;
    _nombreController.text = servicio?.nombre ?? '';
    _descripcionController.text = servicio?.descripcion ?? '';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiciosProvider>();
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 22, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.servicio == null
                          ? 'Nuevo servicio'
                          : 'Editar servicio',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        color: AppColors.inverted,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar sin guardar',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nombreController,
                enabled: !provider.isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Limpieza dental',
                  prefixIcon: Icon(Icons.medical_services_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionController,
                enabled: !provider.isSaving,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripcion',
                  hintText: 'Detalle breve del tratamiento',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: provider.isSaving ? null : () => _save(context),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar servicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = ServicioRequest(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    final message = await context.read<ServiciosProvider>().save(
      id: widget.servicio?.id,
      request: request,
    );

    if (!context.mounted) {
      return;
    }

    if (message == null) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
