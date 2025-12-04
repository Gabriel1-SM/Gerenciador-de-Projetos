import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/person.dart';

class SelectTeamScreen extends StatefulWidget {
  final List<int> selectedMembers;

  const SelectTeamScreen({Key? key, required this.selectedMembers}) : super(key: key);

  @override
  _SelectTeamScreenState createState() => _SelectTeamScreenState();
}

class _SelectTeamScreenState extends State<SelectTeamScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Person> _people = [];
  List<int> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _selectedMembers = List.from(widget.selectedMembers);
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    try {
      final people = await _databaseService.getPeople();
      setState(() {
        _people = people;
      });
    } catch (e) {
      print('Erro ao carregar pessoas: $e');
    }
  }

  void _toggleSelection(int personId) {
    setState(() {
      if (_selectedMembers.contains(personId)) {
        _selectedMembers.remove(personId);
      } else {
        _selectedMembers.add(personId);
      }
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedMembers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecionar Equipe',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveSelection,
            tooltip: 'Confirmar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_people.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header com contador
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.blue[800], size: 20),
              SizedBox(width: 8),
              Text(
                '${_selectedMembers.length} membro(s) selecionado(s)',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Lista de pessoas
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _people.length,
            itemBuilder: (context, index) {
              final person = _people[index];
              final isSelected = _selectedMembers.contains(person.id);
              
              return _buildPersonItem(person, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonItem(Person person, bool isSelected) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          child: Text(
            person.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          person.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blue[800] : Colors.grey[800],
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
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) => _toggleSelection(person.id!),
          shape: CircleBorder(),
          activeColor: Colors.blue,
        ),
        onTap: () => _toggleSelection(person.id!),
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
              'Cadastre pessoas na tela de Equipe primeiro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Volta para tela anterior
              },
              icon: Icon(Icons.arrow_back),
              label: Text('Voltar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}