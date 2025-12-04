import 'package:flutter/material.dart';
import '../models/person.dart';

// Tela para adicionar ou editar pessoas
class AddPersonScreen extends StatefulWidget {
  final Person? person; // Pessoa existente para edição, null para nova

  const AddPersonScreen({Key? key, this.person}) : super(key: key);

  @override
  _AddPersonScreenState createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Estado para o cargo selecionado
  String _role = 'Desenvolvedor';

  @override
  void initState() {
    super.initState();
    // Se está editando uma pessoa, preenche os campos com dados existentes
    if (widget.person != null) {
      _nameController.text = widget.person!.name;
      _emailController.text = widget.person!.email;
      _phoneController.text = widget.person!.phone;
      _role = widget.person!.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Título dinâmico baseado no modo (adicionar/editar)
          widget.person == null ? 'Nova Pessoa' : 'Editar Pessoa',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botão de salvar no canto superior direito
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _savePerson,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Campo: Nome completo
              _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                hint: 'Digite o nome',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              
              // Campo: E-mail
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'email@exemplo.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              
              // Campo: Telefone
              _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                hint: '(00) 00000-0000',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              
              // Campo: Cargo (dropdown)
              _buildRoleField(),
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(icon, color: Colors.blue),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // Widget para seleção de cargo
  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargo',
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
            leading: Icon(Icons.work, color: Colors.blue),
            title: Text(_role),
            trailing: DropdownButton<String>(
              value: _role,
              underline: Container(), // Remove linha padrão
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!; // Atualiza cargo selecionado
                });
              },
              // Lista de cargos disponíveis
              items: <String>[
                'Desenvolvedor',
                'Designer',
                'Gerente de Projeto',
                'Analista',
                'Testador',
                'Product Owner',
                'Scrum Master'
              ].map<DropdownMenuItem<String>>((String value) {
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

  // Botão principal de salvar
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _savePerson,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          // Texto dinâmico baseado no modo
          widget.person == null ? 'SALVAR PESSOA' : 'ATUALIZAR PESSOA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Valida e salva a pessoa
  void _savePerson() {
    // Validação dos campos obrigatórios
    if (_nameController.text.isEmpty) {
      _showError('Digite o nome da pessoa');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('Digite o e-mail da pessoa');
      return;
    }

    // Cria objeto Person com dados do formulário
    final person = Person(
      id: widget.person?.id, // Mantém ID se estiver editando
      name: _nameController.text,
      email: _emailController.text,
      role: _role,
      phone: _phoneController.text,
      createdAt: widget.person?.createdAt ?? DateTime.now(), // Nova data ou mantém original
    );

    // Retorna a pessoa para a tela anterior
    Navigator.pop(context, person);
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}