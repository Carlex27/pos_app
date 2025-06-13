import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asumiendo que usarás Provider
// Asegúrate que las rutas de importación sean correctas para tu proyecto
import '../../services/ticketSettings_service.dart'; // O la ruta correcta a tu servicio
import '../../models/tickets/ticketSettings.dart'; // O la ruta correcta a tu modelo

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // Controllers para los campos de texto
  final _nombreNegocioController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _rfcController = TextEditingController();
  final _mensajeFinalController = TextEditingController();
  final _urlController = TextEditingController();

  // Para el estado de carga y mensajes
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  // Propiedad para almacenar el ID de la configuración actual, si existe
  int? _currentSettingsId;

  late TicketSettingsService _ticketSettingsService;

  @override
  void initState() {
    super.initState();
    _ticketSettingsService = TicketSettingsService();
    _fetchTicketSettings();
  }

  Future<void> _fetchTicketSettings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final settings = await _ticketSettingsService.fetchAll();
      if (!mounted) return;

      _currentSettingsId = settings.id; // Guarda el ID para la actualización
      _nombreNegocioController.text = settings.nombreNegocio ?? '';
      _direccionController.text = settings.direccion ?? '';
      _telefonoController.text = settings.telefono ?? '';
      _rfcController.text = settings.rfc ?? '';
      _mensajeFinalController.text = settings.mensajeFinal ?? '';
      _urlController.text = settings.url ?? '';

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar configuración: ${e.toString()}";
      });
      debugPrint("Error fetching ticket settings: $e");
    }
  }

  Future<void> _saveTicketSettings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Podrías tener un _isSaving separado
      _errorMessage = null;
      _successMessage = null;
    });

    final settingsToUpdate = TicketSettings(// Importante: usa el ID obtenido del fetch
      nombreNegocio: _nombreNegocioController.text,
      direccion: _direccionController.text,
      telefono: _telefonoController.text,
      rfc: _rfcController.text,
      mensajeFinal: _mensajeFinalController.text,
      url: _urlController.text,
    );

    try {
      final resultMessage = await _ticketSettingsService.update(settingsToUpdate);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = resultMessage;
      });
      // Opcional: Cerrar el diálogo después de un tiempo o con un botón OK
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          // Navigator.of(context).pop(true); // Devuelve true si la pantalla anterior necesita saber que hubo cambios
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al guardar configuración: ${e.toString()}";
      });
      debugPrint("Error updating ticket settings: $e");
    }
  }

  @override
  void dispose() {
    _nombreNegocioController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _rfcController.dispose();
    _mensajeFinalController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5), // Fondo semi-transparente para el efecto de diálogo
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Ancho responsivo
          constraints: const BoxConstraints(maxWidth: 500), // Ancho máximo
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: _isLoading && _nombreNegocioController.text.isEmpty // Muestra cargando solo al inicio
              ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Cargando configuración..."),
                ],
              ))
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Para que el botón se estire
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configuración de Ticket',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333)
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                _buildField(_nombreNegocioController, 'Nombre del negocio', Icons.storefront_outlined),
                const SizedBox(height: 16),
                _buildField(_direccionController, 'Dirección', Icons.location_on_outlined),
                const SizedBox(height: 16),
                _buildField(_telefonoController, 'Teléfono', Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildField(_rfcController, 'RFC', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildField(_mensajeFinalController, 'Mensaje final (opcional)', Icons.message_outlined, maxLines: 3),
                const SizedBox(height: 16),
                _buildField(_urlController, 'URL (opcional)', Icons.link_outlined, keyboardType: TextInputType.url),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                  label: Text(
                    _isLoading ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  onPressed: _isLoading ? null : _saveTicketSettings, // Deshabilita si está cargando/guardando
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7), // Un color morado bonito
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData? icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white, // O un color muy claro como Colors.grey.shade50
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }
}