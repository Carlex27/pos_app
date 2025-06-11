import 'package:flutter/material.dart';
import 'package:pos_app/models/client/client.dart';
import 'package:pos_app/models/client/client_abonos.dart'; // Importa tu modelo ClientAbonos
import 'package:pos_app/services/client_service.dart';    // Importa tu ClientService
import 'package:pos_app/ui/widgets/client/client_abono_tile.dart'; // Importa tu ClientAbonoTile
import 'package:provider/provider.dart';                 // Importa Provider

class ClientAbonoWidget extends StatefulWidget {
  final Client client;

  const ClientAbonoWidget({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientAbonoWidget> createState() => _ClientAbonoState();
}

class _ClientAbonoState extends State<ClientAbonoWidget> {
  late Future<List<ClientAbonos>> _abonosFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de los abonos aquí
    _loadAbonos();
  }

  void _loadAbonos() {
    // Usamos Provider para obtener la instancia de ClientService
    final clientService = Provider.of<ClientService>(context, listen: false);
    _abonosFuture = clientService.fetchAbonos(widget.client.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Abonos de ${widget.client.name}'),
      content: Container(
        width: double.maxFinite, // Ocupa el ancho disponible
        // Es buena idea limitar la altura del contenido del AlertDialog
        // o hacerlo scrollable si la lista es muy larga.
        // Aquí usamos ConstrainedBox para un ejemplo, ajusta según necesidad.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Limita al 60% de la altura de la pantalla
        ),
        child: FutureBuilder<List<ClientAbonos>>(
          future: _abonosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Puedes mostrar un mensaje de error más detallado o específico
              print('Error cargando abonos: ${snapshot.error}');
              print('Stack trace: ${snapshot.stackTrace}');
              return Center(child: Text('Error al cargar los abonos. Intenta de nuevo más tarde.\nDetalle: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Este cliente no tiene abonos registrados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            final abonos = snapshot.data!;
            // Filtramos los abonos activos si es necesario, como se discutió.
            // Si tu API ya los devuelve filtrados, puedes omitir este paso.
            final abonosActivos = abonos.where((abono) => abono.active).toList();

            if (abonosActivos.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay abonos activos para mostrar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true, // Importante para que ListView funcione dentro de Column/AlertDialog
              itemCount: abonosActivos.length,
              itemBuilder: (context, index) {
                final abono = abonosActivos[index];
                return ClientAbonoTile(abono: abono);
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}