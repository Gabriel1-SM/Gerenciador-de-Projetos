import 'package:mysql1/mysql1.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/person.dart';

// Serviço para conexão e operações com MySQL
class MySQLService {
  static late MySqlConnection _connection; // Conexão única com MySQL
  
  // Inicializa conexão com MySQL usando configurações definidas
  static Future<void> initialize() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '01221940',
      db: 'gerenciador_projetos',
    );
    
    try {
      _connection = await MySqlConnection.connect(settings);
      print('✅ Conectado ao MySQL com sucesso!');
    } catch (e) {
      print('❌ Erro ao conectar MySQL: $e');
      rethrow; // Propaga o erro para tratamento superior
    }
  }

  // CRUD para Pessoas --------------------------------------------------------
  
  // Cria uma nova pessoa no banco e retorna o ID gerado
  static Future<int> createPerson(Person person) async {
    final result = await _connection.query(
      'INSERT INTO people (name, email, role, phone, createdAt) VALUES (?, ?, ?, ?, ?)',
      [
        person.name, 
        person.email, 
        person.role, 
        person.phone,
        person.createdAt.millisecondsSinceEpoch
      ]
    );
    return result.insertId!; // Retorna o ID auto-incrementado
  }
  
  // Recupera todas as pessoas ordenadas por data de criação (mais recentes primeiro)
  static Future<List<Person>> getPeople() async {
    final results = await _connection.query('SELECT * FROM people ORDER BY createdAt DESC');
    return results.map((row) => Person.fromMap(row.fields)).toList();
  }
  // Atualiza os dados de uma pessoa existente baseado no ID
  static Future<void> updatePerson(int id, Person person) async {
    await _connection.query(
      'UPDATE people SET name = ?, email = ?, role = ?, phone = ? WHERE id = ?',
      [person.name, person.email, person.role, person.phone, id]
    );
  }
  
  // Remove uma pessoa do banco pelo ID
  static Future<void> deletePerson(int id) async {
    await _connection.query('DELETE FROM people WHERE id = ?', [id]);
  }

  // CRUD para Projetos -------------------------------------------------------
  
  // Cria um novo projeto no banco
  static Future<int> createProject(Project project) async {
    // Converte lista de IDs da equipe para string JSON se não estiver vazia
    final teamMembersJson = project.teamMembers.isNotEmpty 
        ? _listToJson(project.teamMembers) 
        : null;
    
    final result = await _connection.query(
      'INSERT INTO projects (title, description, dueDate, status, createdAt, teamMembers) VALUES (?, ?, ?, ?, ?, ?)',
      [
        project.title,
        project.description,
        project.dueDate.millisecondsSinceEpoch, // Data como timestamp
        project.status,
        project.createdAt.millisecondsSinceEpoch,
        teamMembersJson // Pode ser null se não houver equipe
      ]
    );
    return result.insertId!;
  }
  
  // Recupera todos os projetos ordenados por data de criação
  static Future<List<Project>> getProjects() async {
    final results = await _connection.query('SELECT * FROM projects ORDER BY createdAt DESC');
    return results.map((row) {
      final fields = row.fields;
      return Project.fromMap(fields); // Converte linha para objeto Project
    }).toList();
  }
  
  // Atualiza um projeto existente
  static Future<void> updateProject(int id, Project project) async {
    final teamMembersJson = project.teamMembers.isNotEmpty 
        ? _listToJson(project.teamMembers) 
        : null;
    
    await _connection.query(
      'UPDATE projects SET title = ?, description = ?, dueDate = ?, status = ?, teamMembers = ? WHERE id = ?',
      [
        project.title,
        project.description,
        project.dueDate.millisecondsSinceEpoch,
        project.status,
        teamMembersJson,
        id
      ]
    );
  }
  
  // Remove um projeto pelo ID
  static Future<void> deleteProject(int id) async {
    await _connection.query('DELETE FROM projects WHERE id = ?', [id]);
  }

  // Gerenciamento de Equipes -------------------------------------------------
  
  // Define os membros da equipe para um projeto específico
  static Future<void> setProjectTeam(int projectId, List<int> teamMembers) async {
    final teamMembersJson = _listToJson(teamMembers); // Converte para string
    await _connection.query(
      'UPDATE projects SET teamMembers = ? WHERE id = ?',
      [teamMembersJson, projectId]
    );
  }
  
  // Recupera os membros da equipe de um projeto
  static Future<List<int>> getProjectTeam(int projectId) async {
    final results = await _connection.query(
      'SELECT teamMembers FROM projects WHERE id = ?',
      [projectId]
    );
    
    if (results.isEmpty) return []; // Projeto não encontrado
    final teamMembersJson = results.first['teamMembers'] as String?;
    if (teamMembersJson == null || teamMembersJson.isEmpty) return [];
    
    return _jsonToList(teamMembersJson); // Converte string para lista
  }

  // Funções auxiliares para conversão de dados ------------------------------
  
  // Converte lista de inteiros para string separada por vírgulas
  static String _listToJson(List<int> list) {
    return list.join(',');
  }
  
  // Converte string separada por vírgulas para lista de inteiros
  static List<int> _jsonToList(String json) {
    if (json.isEmpty) return [];
    return json.split(',').map((e) => int.parse(e.trim())).toList();
  }
}

// Serviço principal de banco de dados com sistema de fallback
class DatabaseService {
  static bool useMySQL = true; // Flag para controlar qual banco usar
  
  DatabaseService();

  // Inicializa o serviço de banco de dados - conecta ao MySQL se disponível
  static Future<void> initialize() async {
    if (useMySQL) {
      await MySQLService.initialize(); // Tenta conectar ao MySQL
    }
  }

  // Retorna estatísticas do sistema para dashboard/resumo
  Future<Map<String, dynamic>> getStats() async {
    final projects = await getProjects();
    final people = await getPeople();
    
    // Contagem básica
    final totalProjects = projects.length;
    final totalPeople = people.length;
    
    // Contagem por status de projeto
    final completedProjects = projects.where((p) => p.status == 'Concluído').length;
    final inProgressProjects = projects.where((p) => p.status == 'Em Andamento').length;
    final pendingProjects = projects.where((p) => p.status == 'Pendente').length;
    
    // Retorna mapa com todas as estatísticas
    return {
      'totalProjects': totalProjects,
      'totalPeople': totalPeople,
      'completedProjects': completedProjects,
      'inProgressProjects': inProgressProjects,
      'pendingProjects': pendingProjects,
    };
  }
  
  // ==== MÉTODOS PARA PESSOAS com fallback automático ====
  // Recupera lista de pessoas - tenta MySQL primeiro, fallback para local
  Future<List<Person>> getPeople() async {
    if (useMySQL) {
      try {
        return await MySQLService.getPeople(); // Tenta MySQL
      } catch (e) {
        print('❌ Erro MySQL getPeople, usando fallback: $e');
        useMySQL = false; // Desativa MySQL para próximas chamadas
        return _getPeopleFallback(); // Usa armazenamento local
      }
    } else {
      return _getPeopleFallback(); // Já usando fallback
    }
  }
  
  // Adiciona nova pessoa
  Future<int> addPerson(Person person) async {
    if (useMySQL) {
      try {
        return await MySQLService.createPerson(person);
      } catch (e) {
        print('❌ Erro MySQL addPerson, usando fallback: $e');
        useMySQL = false;
        return _addPersonFallback(person);
      }
    } else {
      return _addPersonFallback(person);
    }
  }
  
  // Atualiza pessoa existente
  Future<void> updatePerson(int id, Person person) async {
    if (useMySQL) {
      try {
        await MySQLService.updatePerson(id, person);
      } catch (e) {
        print('❌ Erro MySQL updatePerson, usando fallback: $e');
        useMySQL = false;
        await _updatePersonFallback(id, person);
      }
    } else {
      await _updatePersonFallback(id, person);
    }
  }
  
  // Remove pessoa
  Future<void> deletePerson(int id) async {
    if (useMySQL) {
      try {
        await MySQLService.deletePerson(id);
      } catch (e) {
        print('❌ Erro MySQL deletePerson, usando fallback: $e');
        useMySQL = false;
        await _deletePersonFallback(id);
      }
    } else {
      await _deletePersonFallback(id);
    }
  }

  // ==== MÉTODOS PARA PROJETOS com fallback automático ====
  
  // Mesmo padrão de fallback para operações de projetos
  Future<List<Project>> getProjects() async {
    if (useMySQL) {
      try {
        return await MySQLService.getProjects();
      } catch (e) {
        print('❌ Erro MySQL getProjects, usando fallback: $e');
        useMySQL = false;
        return _getProjectsFallback();
      }
    } else {
      return _getProjectsFallback();
    }
  }
  
  Future<int> addProject(Project project) async {
    if (useMySQL) {
      try {
        return await MySQLService.createProject(project);
      } catch (e) {
        print('❌ Erro MySQL addProject, usando fallback: $e');
        useMySQL = false;
        return _addProjectFallback(project);
      }
    } else {
      return _addProjectFallback(project);
    }
  }
  
  Future<void> updateProject(int id, Project project) async {
    if (useMySQL) {
      try {
        await MySQLService.updateProject(id, project);
      } catch (e) {
        print('❌ Erro MySQL updateProject, usando fallback: $e');
        useMySQL = false;
        await _updateProjectFallback(id, project);
      }
    } else {
      await _updateProjectFallback(id, project);
    }
  }
  
  Future<void> deleteProject(int id) async {
    if (useMySQL) {
      try {
        await MySQLService.deleteProject(id);
      } catch (e) {
        print('❌ Erro MySQL deleteProject, usando fallback: $e');
        useMySQL = false;
        await _deleteProjectFallback(id);
      }
    } else {
      await _deleteProjectFallback(id);
    }
  }

  // Define equipe para um projeto específico
  Future<void> setProjectTeam(int projectId, List<int> teamMembers) async {
    if (useMySQL) {
      try {
        await MySQLService.setProjectTeam(projectId, teamMembers);
      } catch (e) {
        print('❌ Erro MySQL setProjectTeam, usando fallback: $e');
        useMySQL = false;
        await _setProjectTeamFallback(projectId, teamMembers);
      }
    } else {
      await _setProjectTeamFallback(projectId, teamMembers);
    }
  }

  // ==== MÉTODOS FALLBACK (SharedPreferences) ====
  // Usado quando MySQL não está disponível - armazena dados localmente
  
  static Future<List<Person>> _getPeopleFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final peopleString = prefs.getString('people') ?? '[]';
    final List<dynamic> peopleJson = json.decode(peopleString);
    return peopleJson.map((item) => Person.fromMap(item)).toList();
  }
  
  static Future<int> _addPersonFallback(Person person) async {
    final prefs = await SharedPreferences.getInstance();
    final people = await _getPeopleFallback();
    
    // Gera novo ID baseado no último ID existente
    final newId = people.isEmpty ? 1 : (people.last.id ?? 0) + 1;
    final newPerson = Person(
      id: newId,
      name: person.name,
      email: person.email,
      role: person.role,
      phone: person.phone,
      createdAt: person.createdAt,
    );
    
    people.add(newPerson);
    // Salva lista atualizada como string JSON
    await prefs.setString('people', json.encode(people.map((p) => p.toMap()).toList()));
    return newId;
  }
  
  static Future<void> _updatePersonFallback(int id, Person person) async {
    final prefs = await SharedPreferences.getInstance();
    final people = await _getPeopleFallback();
    
    final index = people.indexWhere((p) => p.id == id);
    if (index != -1) {
      people[index] = person; // Substitui pessoa existente
      await prefs.setString('people', json.encode(people.map((p) => p.toMap()).toList()));
    }
  }
  
  static Future<void> _deletePersonFallback(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final people = await _getPeopleFallback();
    
    people.removeWhere((p) => p.id == id); // Remove pelo ID
    await prefs.setString('people', json.encode(people.map((p) => p.toMap()).toList()));
  }
  
  // Mesmo padrão para projetos
  static Future<List<Project>> _getProjectsFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsString = prefs.getString('projects') ?? '[]';
    final List<dynamic> projectsJson = json.decode(projectsString);
    return projectsJson.map((item) => Project.fromMap(item)).toList();
  }
  
  static Future<int> _addProjectFallback(Project project) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await _getProjectsFallback();
    
    final newId = projects.isEmpty ? 1 : (projects.last.id ?? 0) + 1;
    final newProject = Project(
      id: newId,
      title: project.title,
      description: project.description,
      dueDate: project.dueDate,
      status: project.status,
      createdAt: project.createdAt,
      teamMembers: project.teamMembers,
    );
    
    projects.add(newProject);
    await prefs.setString('projects', json.encode(projects.map((p) => p.toMap()).toList()));
    return newId;
  }
  
  static Future<void> _updateProjectFallback(int id, Project project) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await _getProjectsFallback();
    
    final index = projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      projects[index] = project;
      await prefs.setString('projects', json.encode(projects.map((p) => p.toMap()).toList()));
    }
  }
  
  static Future<void> _deleteProjectFallback(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await _getProjectsFallback();
    
    projects.removeWhere((p) => p.id == id);
    await prefs.setString('projects', json.encode(projects.map((p) => p.toMap()).toList()));
  }
  
  static Future<void> _setProjectTeamFallback(int projectId, List<int> teamMembers) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await _getProjectsFallback();
    
    final index = projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      projects[index].teamMembers = teamMembers; // Atualiza apenas a equipe
      await prefs.setString('projects', json.encode(projects.map((p) => p.toMap()).toList()));
    }
  }
}