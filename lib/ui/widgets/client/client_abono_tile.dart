import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fecha y moneda
import 'package:pos_app/models/client/client_abonos.dart'; // Asegúrate que la ruta a tu modelo ClientAbonos sea correcta

class ClientAbonoTile extends StatelessWidget {
  final ClientAbonos abono;

  const ClientAbonoTile({
    Key? key,
    required this.abono,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formateador para la fecha (ej: "10 de junio, 2025")
    final DateFormat dateFormatter = DateFormat('dd \'de\' MMMM, yyyy', 'es_ES');
    // Si prefieres un formato más corto, podrías usar:
    // final DateFormat dateFormatter = DateFormat('dd/MM/yyyy', 'es_ES');

    // Formateador para la moneda
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'es_MX', // O tu locale para el formato de moneda
      symbol: '\$',   // Símbolo de moneda
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0), // Reducimos un poco el margen
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Ajustamos el padding
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo simple
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200, // Un borde aún más sutil
          width: 1,
        ),
        // Puedes mantener una sombra ligera si lo deseas, o quitarla para un look más plano
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Para alinear fecha a la izquierda y monto a la derecha
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fecha del abono
          Text(
            dateFormatter.format(abono.fechaAbono),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500, // Un poco menos de peso que antes
              color: Colors.grey.shade700,
            ),
          ),

          // Monto del abono
          Text(
            currencyFormatter.format(abono.montoAbono),
            style: TextStyle(
              fontSize: 16, // Ligeramente más pequeño para balancear
              fontWeight: FontWeight.w600, // Aún destacado, pero no tan "bold" como antes
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}