import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import 'user_form.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onDelete;
  final void Function(String username, String password, String selectedRole)? onEdit;

  const UserTile({
    Key? key,
    required this.user,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar con inicial del usuario
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFB74D).withOpacity(0.8),
                    const Color(0xFFFF8A65).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del usuario
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rol del usuario
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRoleColor(user.role).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Fecha de creación
                  Text(
                    'Desde: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Botones de acción con el mismo estilo del ProductTile
            Column(
              children: [
                // Botón editar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => UserForm(
                          user: user,
                          onSave: (username, password, selectedRole) {
                            if (onEdit != null) {
                              onEdit!(username, password, selectedRole);
                            }
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botón eliminar
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDelete != null ? () => _showDeleteDialog(context) : null,
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Colors.red.shade600;
      case 'vendedor':
        return Colors.blue.shade600;
      case 'supervisor':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8D4E2A),
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${user.username}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}