import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../config.dart';

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
  final _marcaController = TextEditingController();
  final _gradosController = TextEditingController();
  final _tamanioController = TextEditingController();
  final _precioNormalController = TextEditingController();
  final _precioMayoreoController = TextEditingController();
  final _stockController = TextEditingController();

  File? _selectedImage;
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _skuController.text = widget.product.SKU;
    _nombreController.text = widget.product.nombre;
    _marcaController.text = widget.product.marca;
    _gradosController.text = widget.product.gradosAlcohol.toString();
    _tamanioController.text = widget.product.tamanio;
    _precioNormalController.text = widget.product.precioNormal.toString();
    _precioMayoreoController.text = widget.product.precioMayoreo.toString();
    _stockController.text = widget.product.stock.toString();
    _currentImageUrl = '${kApiBaseUrl}${widget.product.imagePath ?? ''}';
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
          marca: _marcaController.text,
          gradosAlcohol: double.parse(_gradosController.text),
          tamanio: _tamanioController.text,
          precioNormal: double.parse(_precioNormalController.text),
          precioMayoreo: double.parse(_precioMayoreoController.text),
          stock: int.parse(_stockController.text),
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
    _marcaController.dispose();
    _gradosController.dispose();
    _tamanioController.dispose();
    _precioNormalController.dispose();
    _precioMayoreoController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Editar Producto',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.orange.shade600,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen actual o seleccionada
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange.shade600,
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
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    )),
                  ),
                ),

                // Botón cambiar imagen
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(
                      Icons.image_outlined,
                      color: Colors.orange.shade600,
                    ),
                    label: Text(
                      'Cambiar Imagen',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.orange.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Campos del formulario
                _buildTextField(_skuController, 'SKU', TextInputType.text),
                _buildTextField(_nombreController, 'Nombre', TextInputType.text),
                _buildTextField(_marcaController, 'Marca', TextInputType.text),
                _buildTextField(_gradosController, 'Grados de alcohol', TextInputType.number),
                _buildTextField(_tamanioController, 'Tamaño', TextInputType.text),
                _buildTextField(_precioNormalController, 'Precio Normal', TextInputType.number),
                _buildTextField(_precioMayoreoController, 'Precio Mayoreo', TextInputType.number),
                _buildTextField(_stockController, 'Stock', TextInputType.number),

                const SizedBox(height: 32),

                // Botón Guardar Cambios
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón Cancelar
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orange.shade600),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}