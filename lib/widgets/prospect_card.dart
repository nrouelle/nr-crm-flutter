import 'package:flutter/material.dart';
import '../models/prospect.dart';

class ProspectCard extends StatelessWidget {
  final Prospect prospect;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProspectCard({
    super.key,
    required this.prospect,
    this.onTap,
    this.onCall,
    this.onEmail,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF219ebc),
                child: Text(
                  prospect.initiales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Informations principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prospect.nomComplet,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF023047),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF219ebc),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prospect.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Téléphone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Color(0xFF219ebc),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          prospect.telephone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    // LinkedIn si disponible
                    if (prospect.linkedin != null && prospect.linkedin!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.link,
                            size: 16,
                            color: Color(0xFF219ebc),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LinkedIn',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0077B5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Actions rapides
              Column(
                children: [
                  // Menu actions
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF023047),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'call':
                          onCall?.call();
                          break;
                        case 'email':
                          onEmail?.call();
                          break;
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'call',
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Color(0xFF219ebc)),
                            SizedBox(width: 8),
                            Text('Appeler'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'email',
                        child: Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Color(0xFF219ebc)),
                            SizedBox(width: 8),
                            Text('Envoyer email'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: Color(0xFFffb703)),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Indicateur de détail
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}