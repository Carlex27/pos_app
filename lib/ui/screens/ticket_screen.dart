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

    // Guardar el contexto del ScaffoldMessenger ANTES de operaciones async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final settingsToUpdate = TicketSettings(
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
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(resultMessage),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      if (navigator.canPop()) {
        navigator.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error al guardar configuración: ${e.toString()}"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _isLoading && _nombreNegocioController.text.isEmpty
            ? Container(
          padding: const EdgeInsets.all(40),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFFB74D),
              ),
              SizedBox(height: 16),
              Text(
                "Cargando configuración...",
                style: TextStyle(
                  color: Color(0xFF8D4E2A),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con icono
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFB74D).withOpacity(0.8),
                        const Color(0xFFFF8A65).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuración de Ticket',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D4E2A),
                  ),
                ),
                const SizedBox(height: 24),

                // Campos del formulario
                _buildTextField(
                  _nombreNegocioController,
                  'Nombre del negocio',
                  TextInputType.text,
                  Icons.storefront_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _direccionController,
                  'Dirección',
                  TextInputType.text,
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _telefonoController,
                  'Teléfono',
                  TextInputType.phone,
                  Icons.phone_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _rfcController,
                  'RFC',
                  TextInputType.text,
                  Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _mensajeFinalController,
                  'Mensaje final (opcional)',
                  TextInputType.multiline,
                  Icons.message_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _urlController,
                  'URL (opcional)',
                  TextInputType.url,
                  Icons.link_outlined,
                ),
                const SizedBox(height: 32),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Cancelar
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    // Botón Guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveTicketSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB74D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Guardar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      TextInputType type,
      IconData icon, {
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFFB74D),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}