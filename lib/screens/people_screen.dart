import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/person.dart';
import 'add_person_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({Key? key}) : super(key: key);

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Person> _people = [];

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    try {
      final people = await _databaseService.getPeople();
      if (mounted) {
        setState(() {
          _people = people;
        });
      }
    } catch (e) {
      print('Erro ao carregar pessoas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Equipe',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPeople,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        child: Icon(Icons.person_add),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildBody() {
    if (_people.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPeople,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _people.length,
        itemBuilder: (context, index) {
          final person = _people[index];
          return _buildPersonCard(person);
        },
      ),
    );
  }

  Widget _buildPersonCard(Person person) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              person.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            person.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.email),
              Text(
                person.role,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) {
              if (value == 'edit') _editPerson(person);
              if (value == 'delete') _deletePerson(person);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _editPerson(person),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'Nenhuma pessoa cadastrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Toque no + para adicionar\nmembros da equipe',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPersonScreen()),
    );

    if (result != null && result is Person) {
      try {
        await _databaseService.addPerson(result);
        await _loadPeople();
        _showSuccess('Pessoa adicionada!');
        
        // NOTIFICA A HOME SCREEN PARA ATUALIZAR
        Navigator.pop(context, true);
      } catch (e) {
        _showError('Erro ao adicionar pessoa: $e');
      }
    }
  }

  void _editPerson(Person person) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPersonScreen(person: person)),
    );

    if (result != null && result is Person) {
      try {
        await _databaseService.updatePerson(result.id!, result);
        await _loadPeople();
        _showSuccess('Pessoa atualizada!');
      } catch (e) {
        _showError('Erro ao atualizar pessoa: $e');
      }
    }
  }

  void _deletePerson(Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Pessoa'),
        content: Text('Tem certeza que deseja excluir "${person.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _databaseService.deletePerson(person.id!);
                await _loadPeople();
                _showSuccess('Pessoa excluída!');
                
                // NOTIFICA A HOME SCREEN PARA ATUALIZAR
                Navigator.pop(context, true);
              } catch (e) {
                _showError('Erro ao excluir pessoa: $e');
              }
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
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