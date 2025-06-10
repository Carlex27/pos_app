import 'package:flutter/material.dart';
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

  Future<void> _fetchClients([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ClientService>(context, listen: false);
      final clients = query.isEmpty
          ? await service.fetchAll()
          : await service.search(query);

      setState(() {
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching clients: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openNewClientForm() {
    showDialog(
      context: context,
      builder: (_) => ClientForm(
        client: Client.empty(),
        onSave: (newClient) {
          final service = Provider.of<ClientService>(context, listen: false);
          service.create(newClient);
          _fetchClients();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header con búsqueda y botón nuevo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
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
                        _fetchClients(_searchQuery);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Lista de clientes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClients.isEmpty
                  ? const Center(child: Text('No se encontraron clientes'))
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: _filteredClients.length,
                itemBuilder: (c, i) => ClientTile(client: _filteredClients[i]),
              ),
            ),
          ],
        ),
      ),

      // Botón flotante
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: ElevatedButton.icon(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
