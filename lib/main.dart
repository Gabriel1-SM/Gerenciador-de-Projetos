import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:gerenciador_projetos/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //garantia que o Flutter está inicializado
  
  // Inicializar DatabaseService
  try {
    await DatabaseService.initialize();
    print('✅ DatabaseService inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar DatabaseService: $e');
  }
  
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Projetos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 1,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}