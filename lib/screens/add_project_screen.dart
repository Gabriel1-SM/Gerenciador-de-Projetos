import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/person.dart';
import '../services/database_service.dart';
import 'select_team_screen.dart';

// Tela para adicionar ou editar projetos
class AddProjectScreen extends StatefulWidget {
  final Project? project; // Projeto existente para edição, null para novo

  const AddProjectScreen({Key? key, this.project}) : super(key: key);

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  // Serviço para operações de banco
  final DatabaseService _databaseService = DatabaseService();
  
  // Controladores para campos de texto
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Variáveis de estado do formulário
  DateTime _dueDate = DateTime.now().add(Duration(days: 7));
  String _status = 'Pendente';
  List<int> _selectedTeamMembers = []; // IDs das pessoas selecionadas

  @override
  void initState() {
    super.initState();
    
    // Se está editando um projeto, preenche os campos com dados existentes
    if (widget.project != null) {
      _titleController.text = widget.project!.title;
      _descriptionController.text = widget.project!.description;
      _dueDate = widget.project!.dueDate;
      _status = widget.project!.status;
      _selectedTeamMembers = List.from(widget.project!.teamMembers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project == null ? 'Novo Projeto' : 'Editar Projeto',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botão para salvar no canto superior direito
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveProject,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Campo: Título do projeto
              _buildTextField(
                controller: _titleController,
                label: 'Título',
                hint: 'Nome do projeto',
                maxLines: 1,
              ),
              SizedBox(height: 16),
              
              // Campo: Descrição do projeto
              _buildTextField(
                controller: _descriptionController,
                label: 'Descrição',
                hint: 'Descreva seu projeto...',
                maxLines: 4,
              ),
              SizedBox(height: 24),
              
              // Campo: Data de vencimento
              _buildDateField(),
              SizedBox(height: 16),
              
              // Campo: Status do projeto
              _buildStatusField(),
              SizedBox(height: 16),
              
              // Campo: Seleção da equipe
              _buildTeamField(),
              SizedBox(height: 32),
              
              // Botão principal de salvar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizável para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // Widget para seleção de data
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data de Vencimento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.blue),
            title: Text(
              '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}',
              style: TextStyle(fontSize: 16),
            ),
            trailing: Icon(Icons.arrow_drop_down, color: Colors.grey),
            onTap: _selectDate, // Abre seletor de data
          ),
        ),
      ],
    );
  }

  // Widget para seleção de status
  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: Icon(Icons.flag, color: Colors.blue),
            title: Text(_status),
            trailing: DropdownButton<String>(
              value: _status,
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: <String>['Pendente', 'Em Andamento', 'Concluído']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para seleção da equipe
  Widget _buildTeamField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Equipe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Spacer(),
            // Contador de membros selecionados
            Text(
              '${_selectedTeamMembers.length} membro(s)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: Icon(Icons.people, color: Colors.blue),
            title: Text('Selecionar membros da equipe'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: _selectTeamMembers,
          ),
        ),
        if (_selectedTeamMembers.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildSelectedMembers(),
        ],
      ],
    );
  }

  // Mostra os membros selecionados como chips
  Widget _buildSelectedMembers() {
    return FutureBuilder<List<Person>>(
      future: DatabaseService().getPeople(),
      builder: (context, snapshot) {
        // Estado de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        // Tratamento de erro
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar pessoas'));
        }
        
        // Dados carregados com sucesso
        final people = snapshot.data ?? [];
        // Filtra apenas as pessoas selecionadas
        final selectedPeople = people.where((p) => _selectedTeamMembers.contains(p.id)).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membros da Equipe Selecionados:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Exibe cada membro como um chip removível
            Wrap(
              spacing: 8,
              children: selectedPeople.map((person) => Chip(
                label: Text(person.name.split(' ').first),
                backgroundColor: Colors.blue[100],
                deleteIcon: Icon(Icons.close),
                // Permite remover membro diretamente
                onDeleted: () {
                  setState(() {
                    _selectedTeamMembers.remove(person.id);
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 16),
            // Botão para abrir tela completa de seleção
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectTeamScreen(
                      selectedMembers: _selectedTeamMembers,
                    ),
                  ),
                );
                
                // Atualiza lista de membros selecionados
                if (result != null) {
                  setState(() {
                    _selectedTeamMembers = List<int>.from(result);
                  });
                }
              },
              child: Text('Selecionar Equipe'),
            ),
          ],
        );
      },
    );
  }

  // Botão principal de salvar
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.project == null ? 'CRIAR PROJETO' : 'ATUALIZAR PROJETO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Abre seletor de data
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  // Navega para tela de seleção da equipe
  void _selectTeamMembers() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTeamScreen(
          selectedMembers: _selectedTeamMembers,
        ),
      ),
    );

    // Atualiza lista de membros com resultado da seleção
    if (result != null && result is List<int>) {
      setState(() {
        _selectedTeamMembers = result;
      });
    }
  }

  // Valida e salva o projeto
  void _saveProject() {
    // Validação dos campos obrigatórios
    if (_titleController.text.isEmpty) {
      _showError('Digite um título para o projeto');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      _showError('Digite uma descrição para o projeto');
      return;
    }

    // Cria objeto Project com dados do formulário
    final project = Project(
      id: widget.project?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      status: _status,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
      teamMembers: _selectedTeamMembers,
    );

    // Retorna o projeto para a tela anterior
    Navigator.pop(context, project);
  }

  // Mostra mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    // Libera recursos dos controladores
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}