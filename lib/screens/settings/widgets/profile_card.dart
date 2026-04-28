import 'package:flutter/material.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.usuario,
    required this.onLogout,
    required this.onChangePhoto,
    required this.onEditProfile,
    this.isUploadingPhoto = false,
    super.key,
  });

  final UsuarioAuth? usuario;
  final VoidCallback onLogout;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final bool isUploadingPhoto;

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
              _ProfileAvatar(
                user: user,
                initials: initials,
                isUploading: isUploadingPhoto,
                onTap: onChangePhoto,
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
            height: 46,
            child: FilledButton.icon(
              onPressed: isUploadingPhoto ? null : onEditProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar datos'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: isUploadingPhoto ? null : onChangePhoto,
              icon: isUploadingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera_outlined),
              label: Text(
                isUploadingPhoto ? 'Subiendo foto...' : 'Cambiar foto',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.user,
    required this.initials,
    required this.isUploading,
    required this.onTap,
  });

  final UsuarioAuth? user;
  final String initials;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = user?.fotoPerfilUrl;

    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: photo == null || photo.isEmpty
                ? Center(
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                    ),
                  )
                : Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          initials,
                          style:
                              Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 22,
                                  ),
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 14,
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
