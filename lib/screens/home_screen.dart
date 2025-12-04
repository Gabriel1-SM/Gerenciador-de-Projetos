import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/stats_card.dart';
import 'add_project_screen.dart';
import 'people_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();
  List<Project> _projects = [];
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ATUALIZA QUANDO O APP VOLTA PARA PRIMEIRO PLANO
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App retornou - atualizando dados...');
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      print('🔄 HomeScreen: Carregando dados...');
      final projects = await _databaseService.getProjects();
      final stats = await _databaseService.getStats();
      
      if (mounted) {
        setState(() {
          _projects = projects;
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
          IconButton(
            icon: Icon(Icons.people),
            onPressed: _goToPeople,
            tooltip: 'Equipe',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
          // Botão de debug (opcional)
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _debugInfo,
            tooltip: 'Debug',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add, size: 28),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // ESTATÍSTICAS
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),
          
          // PROJETOS RECENTES
          SliverToBoxAdapter(
            child: _buildProjectsHeader(),
          ),
          
          // LISTA DE PROJETOS
          _projects.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = _projects[index];
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
          // DEBUG INFO (opcional - remove depois)
          SizedBox(height: 16),
          _buildDebugInfo(),
        ],
      ),
    );
  }

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
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: Icon(Icons.refresh),
            label: Text('Recarregar Dados'),
          ),
        ],
      ),
    );
  }

  void _goToPeople() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PeopleScreen()),
    );

    // SE RECEBEU TRUE OU QUALQUER VALOR, ATUALIZA OS DADOS
    if (result != null) {
      print('🔄 HomeScreen: Recebeu notificação da tela de pessoas - atualizando!');
      await _loadData();
    }
  }

  void _addProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen()),
    );

    if (result != null && result is Project) {
      try {
        await _databaseService.addProject(result);
        await _loadData(); // FORÇA ATUALIZAÇÃO
        _showSuccess('Projeto criado!');
      } catch (e) {
        _showError('Erro ao criar projeto: $e');
      }
    }
  }

  void _editProject(Project project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen(project: project)),
    );

    if (result != null && result is Project) {
      try {
       await _databaseService.updateProject(result.id!, result);
        await _loadData(); // FORÇA ATUALIZAÇÃO
        _showSuccess('Projeto atualizado!');
      } catch (e) {
        _showError('Erro ao atualizar projeto: $e');
      }
    }
  }

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
                await _loadData(); // FORÇA ATUALIZAÇÃO
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

  // MÉTODO DE DEBUG
  void _debugInfo() {
    print('\n=== HOME SCREEN DEBUG ===');
    print('Projetos no estado: ${_projects.length}');
    print('Stats no estado: $_stats');
    print('Projetos detalhados:');
    for (var project in _projects) {
      print(' - "${project.title}" (ID: ${project.id}, Membros: ${project.teamMembers})');
    }
    print('========================\n');
    
    // Mostra snackbar de debug
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug: ${_projects.length} projetos, ${_stats['totalPeople'] ?? 0} pessoas'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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