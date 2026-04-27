import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/citas_provider.dart';
import 'package:odontologia_app/providers/dashboard_provider.dart';
import 'package:odontologia_app/providers/horarios_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/router/app_router.dart';
import 'package:odontologia_app/services/auth_service.dart';
import 'package:odontologia_app/services/citas_service.dart';
import 'package:odontologia_app/services/dashboard_service.dart';
import 'package:odontologia_app/services/horarios_service.dart';
import 'package:odontologia_app/services/pacientes_service.dart';
import 'package:odontologia_app/services/session_storage.dart';
import 'package:odontologia_app/services/servicios_service.dart';
import 'package:odontologia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final apiClient = ApiClient();
  const secureStorage = FlutterSecureStorage();
  final sessionStorage = SessionStorage(secureStorage);
  final authProvider = AuthProvider(AuthService(apiClient, sessionStorage));
  await authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => CitasProvider(CitasService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => PacientesProvider(PacientesService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => HorariosProvider(HorariosService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiciosProvider(ServiciosService(apiClient)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return MaterialApp.router(
      title: 'OralDent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: createAppRouter(authProvider),
    );
  }
}
