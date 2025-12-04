# 📋 Gerenciador de Projetos - Documentação

## 🎯 Visão Geral
Sistema mobile de gerenciamento de projetos e equipes desenvolvido em Flutter com backend MySQL. Aplicação completa com CRUD, interface moderna e persistência de dados.

## 🏗️ Arquitetura do Sistema

### Stack Tecnológica
- **Frontend**: Flutter 3.x / Dart
- **Backend**: MySQL 8.0 (Produção) + SQLite (Fallback)
- **Estado**: setState + Streams
- **UI**: Material Design 3
- **Driver MySQL**: mysql1 0.20.x

### Estrutura do Projeto
```
lib/
├── models/              # Entidades de dados
│   ├── project.dart    # Modelo Projeto
│   └── person.dart     # Modelo Pessoa
├── services/           # Lógica de negócio
│   └── database_service.dart  # Serviço de dados
├── screens/           # Telas da aplicação
│   ├── home_screen.dart      # Dashboard
│   ├── people_screen.dart    # Gerenciamento de pessoas
│   ├── add_project_screen.dart # Criar/editar projetos
│   ├── add_person_screen.dart  # Criar/editar pessoas
│   └── select_team_screen.dart # Selecionar equipe
└── widgets/           # Componentes reutilizáveis
    ├── project_card.dart    # Card de projeto
    └── stats_card.dart      # Card de estatísticas
```

## 🚀 Funcionalidades

### ✅ CRUD Completo
- **Projetos**: Criar, listar, editar, excluir
- **Pessoas**: Cadastrar, gerenciar, vincular
- **Equipes**: Seleção múltipla de membros

### 📊 Dashboard Inteligente
- Estatísticas em tempo real
- Total de projetos e membros
- Distribuição por status
- Refresh indicator

### 🔗 Vinculação Avançada
- Projetos com múltiplos membros
- Visualização em chips interativos
- Seleção intuitiva com checkboxes

### 🛡️ Sistema Resiliente
- Fallback automático MySQL → SQLite
- Persistência local com SharedPreferences
- Tratamento robusto de erros

## 🗃️ Modelos de Dados

### Pessoa (Person)
```dart
{
  "id": 1,
  "name": "João Silva",
  "email": "joao@empresa.com",
  "role": "Desenvolvedor",
  "phone": "(11) 99999-9999",
  "createdAt": 1640995200000
}
```

### Projeto (Project)
```dart
{
  "id": 1,
  "title": "Site E-commerce",
  "description": "Desenvolvimento de loja virtual",
  "dueDate": 1643673600000,
  "status": "Em Andamento",
  "createdAt": 1640995200000,
  "teamMembers": [1, 3, 5]  // IDs das pessoas
}
```

## ⚙️ Configuração do Ambiente

### Pré-requisitos
```bash
# Flutter SDK
flutter --version  # >= 3.0.0

# MySQL Server
sudo dnf install mysql-server

# Extensões Flutter
flutter config --enable-linux-desktop
```

### Instalação
```bash
# 1. Clonar repositório
git clone <url-projeto>
cd gerenciador_projetos

# 2. Instalar dependências
flutter pub get

# 3. Configurar MySQL
sudo systemctl start mysqld
sudo mysql_secure_installation

# 4. Criar banco e tabelas
sudo mysql -u root -p
```
```sql
CREATE DATABASE gerenciador_projetos;
USE gerenciador_projetos;

CREATE TABLE people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    createdAt BIGINT NOT NULL
);

CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    dueDate BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    createdAt BIGINT NOT NULL,
    teamMembers TEXT
);
```

### Configurar Credenciais
Edite `lib/services/database_service.dart`:
```dart
final settings = ConnectionSettings(
  host: 'localhost',
  port: 3306,
  user: 'root',          // Seu usuário
  password: '01221940',  // Sua senha
  db: 'gerenciador_projetos',
);
```

## 🏃‍♂️ Executando o Projeto

### Modo Desenvolvimento
```bash
# Iniciar MySQL
sudo systemctl start mysqld

# Executar aplicação
cd gerenciador_projetos
flutter run -d linux
```

### Comandos Úteis
```bash
# Limpar e reinstalar
flutter clean && flutter pub get

# Verificar problemas
flutter analyze
flutter doctor

# Build para produção
flutter build linux --release
```

## 🔧 Solução de Problemas

### MySQL Não Conecta
```bash
# Verificar serviço
sudo systemctl status mysqld

# Testar conexão manual
sudo mysql -u root -p

# Verificar portas
sudo netstat -tlnp | grep mysql
```

### Erros Comuns
1. **"Got packets out of order"**: Problema no driver mysql1
   - Solução: Usar SQLite fallback já implementado

2. **Dados não persistem**: Verificar permissões MySQL
   ```sql
   GRANT ALL PRIVILEGES ON gerenciador_projetos.* TO 'root'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **App não atualiza**: WidgetsBindingObserver
   - Implementado: Atualiza ao retornar do background

## 📈 Diagramas

### Fluxo de Dados
```
Usuário → Interface → DatabaseService → [MySQL | SQLite]
                    (Lógica)           (Persistência)
```

### Fallback System
```
Tentativa MySQL → Sucesso? → SIM → Usa MySQL
                   ↓ NÃO
                 Usa SQLite → Mantém dados locais
```

## 🎨 Interface do Usuário

### Telas Principais
1. **Dashboard** - Visão geral com estatísticas
2. **Gerenciar Projetos** - Lista com ações CRUD
3. **Gerenciar Pessoas** - Cadastro de equipe
4. **Formulários** - Criação/edição com validação
5. **Seleção de Equipe** - Interface multi-seleção

### Componentes
- **ProjectCard**: Card de projeto com ações
- **StatsCard**: Estatísticas com ícones
- **Chips**: Membros selecionados
- **SnackBars**: Feedback visual

## 🔍 Monitoramento e Debug

### Logs do Sistema
```dart
print('✅ Conectado ao MySQL com sucesso!');
print('❌ Erro MySQL, usando fallback: $e');
```

### Debug no Dashboard
- Botão de debug (ícone de inseto)
- Informações em tempo real
- Snackbars de feedback

## 📚 Recursos de Aprendizado

### Conceitos Implementados
- **State Management**: setState + lifecycle
- **Persistence**: MySQL + SQLite + SharedPreferences
- **Async Programming**: FutureBuilder, async/await
- **Error Handling**: Try/catch com fallback
- **Navigation**: Navigator 2.0

### Padrões Utilizados
- **Repository Pattern**: DatabaseService
- **Factory Pattern**: fromMap() nos models
- **Observer Pattern**: WidgetsBindingObserver
- **Strategy Pattern**: MySQL vs SQLite

## 🤝 Contribuição

### Melhorias Futuras
1. [ ] Autenticação de usuários
2. [ ] API REST externa
3. [ ] Sincronização em nuvem
4. [ ] Exportação PDF/Excel
5. [ ] Notificações push

### Reportar Problemas
1. Verificar se MySQL está rodando
2. Conferir credenciais no código
3. Testar com `flutter doctor`
4. Abrir issue com logs completos

## 📄 Licença
© 2025 Gerenciador de Projetos - Projeto Acadêmico

## 🙏 Agradecimentos
- Comunidade Flutter
- Documentação MySQL
- Material Design guidelines

---

**Happy Coding!** 🚀