import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:gerenciador_projetos/services/database_service.dart';

// Função principal que inicia o aplicativo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseService.initialize();
    print('✅ DatabaseService inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar DatabaseService: $e');
  }
  
  // Executa o aplicativo
  runApp(MyApp());
}

// Classe principal do aplicativo que define a estrutura básica
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título do aplicativo
      title: 'Gerenciador de Projetos',
      
      // Configuração do tema visual
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
      
      // Define a tela inicial do aplicativo
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}