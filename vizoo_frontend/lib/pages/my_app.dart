import 'package:flutter/material.dart';
import 'package:vizoo_frontend/apps/router/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoSlap'),
      routerConfig: RouterCustum.router,
    );
  }
}