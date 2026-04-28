import 'package:flutter/material.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.usuario,
    required this.onLogout,
    super.key,
  });

  final UsuarioAuth? usuario;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = usuario;
    final initials = user == null
        ? 'AD'
        : '${user.nombre[0]}${user.apellidoPaterno[0]}'.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: user?.fotoPerfilUrl == null ||
                        user!.fotoPerfilUrl!.isEmpty
                    ? Center(
                        child: Text(
                          initials,
                          style: textTheme.displayLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                      )
                    : Image.network(
                        user.fotoPerfilUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              initials,
                              style: textTheme.displayLarge?.copyWith(
                                color: AppColors.primary,
                                fontSize: 22,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nombreCompleto ?? 'Administrador',
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.rol ?? 'ADMIN',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileRow(
            icon: Icons.mail_outline_rounded,
            label: user?.correo ?? 'Sin correo',
          ),
          const SizedBox(height: 10),
          _ProfileRow(
            icon: Icons.phone_rounded,
            label: user?.celular ?? 'Sin celular',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
