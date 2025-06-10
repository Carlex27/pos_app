import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../models/product/product.dart';
import '../../../services/product_service.dart';
import '../../../config.dart';

class EditProductForm extends StatefulWidget {
  final Product product;

  const EditProductForm({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nombreController = TextEditingController();
  final _departmentController = TextEditingController();
  final _precioCostoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioUnidadVentaController = TextEditingController();
  final _precioUnidadMayoreoController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _minimoMayoreoController = TextEditingController();


  File? _selectedImage;
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _skuController.text = widget.product.SKU;
    _nombreController.text = widget.product.nombre;
    _departmentController.text = widget.product.departamento;
    _precioCostoController.text = widget.product.precioCosto.toString();
    _precioVentaController.text = widget.product.precioVenta.toString();
    _precioUnidadVentaController.text = widget.product.precioUnidadVenta.toString();
    _precioUnidadMayoreoController.text = widget.product.precioUnidadMayoreo.toString();
    _stockController.text = widget.product.stock.toString();
    _stockMinimoController.text = widget.product.stockMinimo.toString();
    _minimoMayoreoController.text = widget.product.minimoMayoreo.toString();

    // Cargar imagen async sin await
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    _currentImageUrl = await imageUrl(widget.product.imagePath);
    if (mounted) {
      setState(() {}); // Actualiza el estado para mostrar la imagen
    }
  }

  Future<String> imageUrl(String? imagePath) async {
    final baseUrl = await getApiBaseUrl(); // Asegúrate de tener esta función en config.dart
    if (imagePath == null || imagePath.isEmpty) {
      return '$baseUrl/images/default.png'; // Cambia esto si tienes una imagen por defecto distinta
    }
    return '$baseUrl$imagePath';
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permiso para acceder a las imágenes denegado'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final productService = Provider.of<ProductService>(context, listen: false);
        await productService.updateProductWithOptionalImage(
          id: widget.product.id,
          sku: _skuController.text,
          nombre: _nombreController.text,
          departamento: _departmentController.text,
          precioCosto: double.parse(_precioCostoController.text),
          precioVenta: double.parse(_precioVentaController.text),
          precioMayoreo: double.parse(_precioUnidadVentaController.text),
          precioUnidadVenta: double.parse(_precioUnidadVentaController.text),
          precioUnidadMayoreo: double.parse(_precioUnidadMayoreoController.text),
          stock: double.parse(_stockController.text),
          stockMinimo: int.parse(_stockMinimoController.text),
          minimoMayoreo: _minimoMayoreoController.text,
          imageFile: _selectedImage, // puede ser null
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        print('Error al actualizar producto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nombreController.dispose();
    _departmentController.dispose();
    _precioCostoController.dispose();
    _precioVentaController.dispose();
    _precioUnidadVentaController.dispose();
    _precioUnidadMayoreoController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _minimoMayoreoController.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
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
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Editar Producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8D4E2A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección de imagen
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                                : (widget.product.imagePath != null
                                ? Image.network(
                              _currentImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 32,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Error al cargar',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFFFB74D),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sin imagen',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Cambiar Imagen'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFFB74D),
                              side: const BorderSide(color: Color(0xFFFFB74D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campos del formulario en filas de 2
                  _buildTextField(_skuController, 'SKU', TextInputType.text, Icons.qr_code_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_nombreController, 'Nombre', TextInputType.text, Icons.label_outline),
                  const SizedBox(height: 16),

                  _buildTextField(_departmentController, 'Departamento', TextInputType.text, Icons.store_mall_directory_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioCostoController, 'Precio Costo', TextInputType.number, Icons.price_check_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioVentaController, 'Precio Venta', TextInputType.number, Icons.attach_money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioUnidadVentaController, 'Precio Unidad Venta', TextInputType.number, Icons.money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioUnidadMayoreoController, 'Precio Unidad Mayoreo', TextInputType.number, Icons.monetization_on_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockController, 'Stock', TextInputType.number, Icons.inventory_2_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockMinimoController, 'Stock Mínimo', TextInputType.number, Icons.remove_shopping_cart_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_minimoMayoreoController, 'Mínimo Mayoreo', TextInputType.text, Icons.stacked_line_chart_outlined),
                  const SizedBox(height: 32),

                  const SizedBox(height: 16),

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

                      // Botón Guardar Cambios
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Guardar Cambios',
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo requerido';
        }
        return null;
      },
    );
  }
}