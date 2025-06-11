import 'package:flutter/material.dart';
import 'package:pos_app/ui/widgets/client/client_form.dart';
import 'package:provider/provider.dart';
import '../../../models/client/client.dart';
import '../../../services/client_service.dart';
import 'client_description.dart';

class ClientTile extends StatefulWidget {
  final Client client;
  final VoidCallback onDataChanged; // <--- NUEVO: Callback para notificar cambios

  const ClientTile({
    Key? key,
    required this.client,
    required this.onDataChanged, // <--- NUEVO: Requerir el callback
  }) : super(key: key);

  @override
  State<ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<ClientTile>
    with SingleTickerProviderStateMixin {
  // ... (tu código de animación y initState/dispose permanece igual) ...
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: () async { // Hacer onTap async para esperar el resultado de ClientDescription
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClientDescription(client: widget.client),
                ),
              );
              // Si ClientDescription indica que hubo cambios (ej. al eliminar o si pasas un resultado)
              if (result == true && mounted) { // 'true' podría ser una señal de que los datos cambiaron
                widget.onDataChanged();
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _isPressed ? 6 : 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.client.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dirección: ${widget.client.direction}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Teléfono: ${widget.client.phoneNumber}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saldo: \$${widget.client.balance.toStringAsFixed(2)} / Límite: \$${widget.client.creditLimit.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) => ClientForm(
                                client: widget.client,
                                isEditing: true,
                                onSave: (updatedClient) async {
                                  final clientService = Provider.of<ClientService>(context, listen: false);
                                  try {
                                    await clientService.update(updatedClient);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cliente actualizado exitosamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      widget.onDataChanged(); // <--- LLAMAR AL CALLBACK
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al actualizar cliente: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                  // ClientForm ya cierra el diálogo
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar cliente'),
                                content: Text('¿Seguro que deseas eliminar a ${widget.client.name}?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Eliminar'),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && mounted) {
                              try {
                                final clientService = Provider.of<ClientService>(context, listen: false);
                                await clientService.delete(widget.client.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cliente eliminado exitosamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  widget.onDataChanged(); // <--- LLAMAR AL CALLBACK
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}