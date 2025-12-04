import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Editar'), onTap: onEdit),
                    PopupMenuItem(child: Text('Excluir'), onTap: onDelete),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(project.description),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(project.status)),
                Spacer(),
                Text('Vence: ${_formatDate(project.dueDate)}'),
              ],
            ),
            if (project.teamMembers.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Equipe: ${project.teamMembers.length} membro(s)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}