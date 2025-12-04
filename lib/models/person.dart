class Person {
  int? id;
  String name;
  String email;
  String role;
  String phone;
  DateTime createdAt;

  Person({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  // Converte Map para Person
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      phone: map['phone'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Converte Person para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}