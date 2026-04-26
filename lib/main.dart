import 'package:flutter/material.dart';
import 'package:odontologia_app/router/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OralDent',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}