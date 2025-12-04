class Project {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  String status;
  DateTime createdAt;
  List<int> teamMembers;

  Project({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.teamMembers,
  });

  // CORRIGIDO: factory (não actory)
  factory Project.fromMap(Map<String, dynamic> map) {
    // Corrige a conversão de teamMembers
    List<int> teamMembers = [];
    
    if (map['teamMembers'] != null) {
      if (map['teamMembers'] is String) {
        // Se é string (vindo do MySQL), converte "1,2,3" para [1,2,3]
        final String teamStr = map['teamMembers'];
        if (teamStr.isNotEmpty) {
          teamMembers = teamStr.split(',').map((e) => int.parse(e.trim())).toList();
        }
      } else if (map['teamMembers'] is List) {
        // Se já é lista (vindo do SharedPreferences)
        teamMembers = List<int>.from(map['teamMembers']);
      }
    }
    
    return Project(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      status: map['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      teamMembers: teamMembers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'teamMembers': teamMembers,
    };
  }
}