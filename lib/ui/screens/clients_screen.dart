import 'package:flutter/material.dart';
import 'package:pos_app/ui/screens/saldos_screen.dart';
import 'package:provider/provider.dart';
import '../../models/client/client.dart';
import '../../services/client_service.dart';
import '../widgets/client/client_tile.dart';
import '../widgets/client/client_form.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  // _fetchClients ahora es la fuente de verdad para refrescar
  Future<void> _fetchClients([String query = '']) async {
    // Si el widget ya no está montado, no hagas nada.
    // Esto es importante si _fetchClients es llamado desde un callback
    // y la pantalla ya se ha cerrado.
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ClientService>(context, listen: false);
      final clients = query.isEmpty
          ? await service.fetchAll()
          : await service.search(query);

      // Verifica de nuevo si está montado antes de llamar a setState
      if (mounted) {
        setState(() {
          _filteredClients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
      if (mounted) { // Verifica antes de setState en el catch también
        setState(() => _isLoading = false);
      }
    }
  }

  void _openNewClientForm() {
    // Guardamos el context de ClientsScreen ANTES de mostrar el diálogo.
    // Esto es para el ScaffoldMessenger, ya que el diálogo tendrá su propio context.
    final currentContext = context;

    showDialog(
      context: currentContext, // Usar el context de ClientsScreen para mostrar el diálogo
      barrierDismissible: false, // Es buena idea evitar cierres accidentales mientras se guarda
      builder: (dialogContext) { // dialogContext es el context específico del diálogo
        return ClientForm(
          client: Client.empty(),
          onSave: (newClient) async {
            // ClientForm llama a onSave ANTES de hacer pop internamente si así está configurado.
            // Si ClientForm NO hace pop por sí mismo, entonces nosotros debemos hacerlo.

            // Asumamos que ClientForm NO hace pop después de llamar a onSave.
            // Si SÍ lo hace, puedes quitar el Navigator.of(dialogContext).pop() de aquí.

            final service = Provider.of<ClientService>(currentContext, listen: false); // Usar currentContext para Provider

            try {
              await service.create(newClient);

              // 1. Cierra el diálogo PRIMERO, usando SU PROPIO CONTEXTO.
              // Asegúrate de que ClientForm no esté también intentando hacer pop.
              // Si ClientForm tiene su propio Navigator.pop() en su _submit, puedes comentar la siguiente línea.
              if (Navigator.canPop(dialogContext)) { // Verifica si el diálogo puede ser popeado
                Navigator.of(dialogContext).pop();
              }


              // 2. DESPUÉS de que el diálogo esté cerrado, refresca los datos.
              // El 'mounted' aquí se refiere a ClientsScreen.
              if (mounted) {
                await _fetchClients(); // Espera a que se complete el fetch
                ScaffoldMessenger.of(currentContext).showSnackBar( // Usa currentContext
                  const SnackBar(
                    content: Text('Cliente creado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (error) {
              debugPrint("Error al crear cliente: $error");

              // Opcional: Cierra el diálogo incluso si hay error,
              // o muestra el error DENTRO del diálogo y no lo cierres.
              // if (Navigator.canPop(dialogContext)) {
              // Navigator.of(dialogContext).pop();
              // }

              if (mounted) { // mounted se refiere a ClientsScreen
                ScaffoldMessenger.of(currentContext).showSnackBar( // Usa currentContext
                  SnackBar(
                    content: Text('Error al crear cliente: $error.\nPor favor, inténtalo de nuevo.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                // ... (código del header sin cambios) ...
                children: [
                  const Text(
                    'Clientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF7043),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _fetchClients(_searchQuery); // La búsqueda ya refresca
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClients.isEmpty
                  ? const Center(child: Text('No se encontraron clientes'))
                  : RefreshIndicator( // <--- AÑADIR RefreshIndicator
                onRefresh: () => _fetchClients(_searchQuery), // Permite pull-to-refresh
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Espacio para FAB
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) { // Cambiado c, i a context, index por convención
                    return ClientTile(
                      client: _filteredClients[index],
                      onDataChanged: () => _fetchClients(_searchQuery), // <--- PASAR EL CALLBACK
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // ... (código de FloatingActionButton sin cambios) ...
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 16, right: 16), // Ajusta el padding según necesites
        child: Row( // Cambiamos Column por Row
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio entre los botones
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SaldosScreen()),
                );
              },
              icon: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
              label: const Text(
                'Reporte de Saldos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openNewClientForm,
              icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
              label: const Text(
                'Agregar nuevo cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}