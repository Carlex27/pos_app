import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y moneda
import 'package:pos_app/models/client/client.dart'; // Asegúrate de importar tu modelo Client
import 'package:pos_app/services/client_service.dart'; // Importa tu ClientService
import 'package:provider/provider.dart';

class SaldosScreen extends StatefulWidget {
  const SaldosScreen({Key? key}) : super(key: key);

  @override
  State<SaldosScreen> createState() => _SaldosScreenState();
}

class _SaldosScreenState extends State<SaldosScreen> {
  late Future<List<Client>> _clientsFuture;
  late Future<double> _totalBalanceFuture; // Para el saldo total

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'es_ES');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final clientService = Provider.of<ClientService>(context, listen: false);
    _clientsFuture = clientService.fetchAll();
    _totalBalanceFuture = clientService.getTotalBalance(); // Cargar el saldo total
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Saldos de Clientes'),
        backgroundColor: Colors.teal.shade700,
        elevation: 2,
      ),
      body: Column( // Envolvemos en Column para poner el total arriba
        children: [
          // Sección para mostrar el Saldo Total
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<double>(
              future: _totalBalanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 50, // Damos una altura fija mientras carga
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Error al cargar saldo total',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Crédito pendiente: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                        Text(
                          _currencyFormatter.format(snapshot.data!),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: snapshot.data! > 0 ? Colors.orange.shade800 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 50); // Fallback por si acaso
              },
            ),
          ),

          // Lista de Clientes (expandida para que ocupe el resto del espacio)
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error al cargar los clientes: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay clientes para mostrar.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final clients = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0), // Ajustamos padding superior
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  client.phoneNumber.isNotEmpty ? client.phoneNumber : 'No disponible',
                                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  client.lastAbonoDate != null
                                      ? 'Último pago: ${_dateFormatter.format(client.lastAbonoDate!)}'
                                      : 'Último pago: No registrado',
                                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Chip(
                                avatar: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: client.balance > 0 ? Colors.orange.shade800 : Colors.green.shade700,
                                  size: 18,
                                ),
                                label: Text(
                                  'Saldo: ${_currencyFormatter.format(client.balance)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: client.balance > 0 ? Colors.orange.shade800 : Colors.green.shade700,
                                  ),
                                ),
                                backgroundColor: client.balance > 0
                                    ? Colors.orange.shade100.withOpacity(0.7)
                                    : Colors.green.shade100.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}