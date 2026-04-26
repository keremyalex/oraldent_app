import 'package:go_router/go_router.dart';
import 'package:odontologia_app/screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    )
  ]
);