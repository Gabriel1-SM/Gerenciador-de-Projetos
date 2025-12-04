import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/stats_card.dart';
import 'add_project_screen.dart';
import 'people_screen.dart';

// Tela principal do aplicativo - Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Serviço para operações de banco de dados
  final DatabaseService _databaseService = DatabaseService();
  
  // Lista de projetos carregados
  List<Project> _projects = [];
  
  // Estatísticas do sistema
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    // Adiciona observador para detectar mudanças no ciclo de vida do app
    WidgetsBinding.instance.addObserver(this);
    _loadData(); // Carrega dados ao iniciar
  }

  @override
  void dispose() {
    // Remove observador ao sair da tela
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detecta quando o app volta para primeiro plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App retornou - atualizando dados...');
      _loadData(); // Atualiza dados quando app retorna
    }
  }

  // Carrega projetos e estatísticas do banco
  Future<void> _loadData() async {
    try {
      print('🔄 HomeScreen: Carregando dados...');
      
      // Busca dados em paralelo
      final projects = await _databaseService.getProjects();
      final stats = await _databaseService.getStats();
      
      if (mounted) {
        setState(() {
          _projects = projects;
          // Garante que todos os valores de estatística existem
          _stats = {
            'totalProjects': stats['totalProjects'] ?? 0,
            'totalPeople': stats['totalPeople'] ?? 0,
            'completedProjects': stats['completedProjects'] ?? 0,
            'inProgressProjects': stats['inProgressProjects'] ?? 0,
            'pendingProjects': stats['pendingProjects'] ?? 0,
          };
        });
      }
      
      print('✅ HomeScreen: Dados carregados - ${projects.length} projetos, ${stats['totalPeople']} pessoas');
    } catch (e) {
      print('❌ HomeScreen: Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botão para acessar tela de pessoas
          IconButton(
            icon: Icon(Icons.people),
            onPressed: _goToPeople,
            tooltip: 'Equipe',
          ),
          // Botão para atualizar manualmente
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
          // Botão para informações de debug
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _debugInfo,
            tooltip: 'Debug',
          ),
        ],
      ),
      body: _buildBody(),
      // Botão para adicionar novo projeto
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add, size: 28),
        shape: CircleBorder(),
      ),
    );
  }

  // Constrói o corpo principal da tela
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData, // Puxar para baixo atualiza
      child: CustomScrollView(
        slivers: [
          // Seção de estatísticas (widget fixo)
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),
          
          // Cabeçalho da seção de projetos
          SliverToBoxAdapter(
            child: _buildProjectsHeader(),
          ),
          
          // Lista de projetos
          _projects.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = _projects[index];
                      // Usa widget reutilizável para cada projeto
                      return ProjectCard(
                        project: project,
                        onEdit: () => _editProject(project),
                        onDelete: () => _deleteProject(project),
                      );
                    },
                    childCount: _projects.length,
                  ),
                ),
        ],
      ),
    );
  }

  // Seção de cartões de estatísticas
  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          // Grid 2x2 com cartões de estatística
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Não rola internamente
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                title: 'Total Projetos',
                value: _stats['totalProjects'] ?? 0,
                color: Colors.blue,
                icon: Icons.assignment,
              ),
              StatsCard(
                title: 'Concluídos',
                value: _stats['completedProjects'] ?? 0,
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              StatsCard(
                title: 'Em Andamento',
                value: _stats['inProgressProjects'] ?? 0,
                color: Colors.orange,
                icon: Icons.autorenew,
              ),
              StatsCard(
                title: 'Membros',
                value: _stats['totalPeople'] ?? 0,
                color: Colors.purple,
                icon: Icons.people,
              ),
            ],
          ),
          // Informações de debug
          SizedBox(height: 16),
          _buildDebugInfo(),
        ],
      ),
    );
  }

  // Widget para mostrar informações de debug
  Widget _buildDebugInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Debug Info:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            'Projetos: ${_projects.length} | Pessoas: ${_stats['totalPeople'] ?? 0}',
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
          Text(
            'Stats: $_stats',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Cabeçalho da seção de projetos
  Widget _buildProjectsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            'Projetos Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Spacer(),
          if (_projects.isNotEmpty)
            Text(
              '${_projects.length} projeto(s)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  // Estado quando não há projetos
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Nenhum projeto encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Toque no + para criar seu primeiro projeto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          // Botão para recarregar manualmente
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: Icon(Icons.refresh),
            label: Text('Recarregar Dados'),
          ),
        ],
      ),
    );
  }

  // Navega para tela de pessoas
  void _goToPeople() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PeopleScreen()),
    );

    // Se recebeu algum valor (notificação de alteração)
    if (result != null) {
      print('🔄 HomeScreen: Recebeu notificação da tela de pessoas - atualizando!');
      await _loadData(); // Atualiza dados
    }
  }

  // Abre tela para adicionar novo projeto
  void _addProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen()),
    );

    if (result != null && result is Project) {
      try {
        await _databaseService.addProject(result);
        await _loadData(); // Atualiza dados
        _showSuccess('Projeto criado!');
      } catch (e) {
        _showError('Erro ao criar projeto: $e');
      }
    }
  }

  // Abre tela para editar projeto existente
  void _editProject(Project project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen(project: project)),
    );

    if (result != null && result is Project) {
      try {
        await _databaseService.updateProject(result.id!, result);
        await _loadData(); // Atualiza dados
        _showSuccess('Projeto atualizado!');
      } catch (e) {
        _showError('Erro ao atualizar projeto: $e');
      }
    }
  }

  // Solicita confirmação e exclui projeto
  void _deleteProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Projeto'),
        content: Text('Tem certeza que deseja excluir "${project.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _databaseService.deleteProject(project.id!);
                await _loadData(); // Atualiza dados
                _showSuccess('Projeto excluído com sucesso!');
              } catch (e) {
                _showError('Erro ao excluir projeto: $e');
              }
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Método para debug - mostra informações no console
  void _debugInfo() {
    print('\n=== HOME SCREEN DEBUG ===');
    print('Projetos no estado: ${_projects.length}');
    print('Stats no estado: $_stats');
    print('Projetos detalhados:');
    for (var project in _projects) {
      print(' - "${project.title}" (ID: ${project.id}, Membros: ${project.teamMembers})');
    }
    print('========================\n');
    
    // Mostra snackbar com informações
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug: ${_projects.length} projetos, ${_stats['totalPeople'] ?? 0} pessoas'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Mostra mensagem de sucesso
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Mostra mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}