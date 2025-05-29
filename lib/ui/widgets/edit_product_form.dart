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
          content: const Text('Permiso para acceder a imágenes denegado'),
          backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
        appBar: AppBar(
          title: const Text('Editar Producto'),
          backgroundColor: Colors.orange.shade600,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150)
                    : (widget.product.imagePath != null
                    ? Image.network(_currentImageUrl, height: 150)
                    : Container(height: 150, color: Colors.grey.shade200)),

                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Cambiar Imagen'),
                ),
                const SizedBox(height: 12),
                _buildTextField(_skuController, 'SKU', TextInputType.text),
                _buildTextField(_nombreController, 'Nombre', TextInputType.text),
                _buildTextField(_marcaController, 'Marca', TextInputType.text),
                _buildTextField(_gradosController, 'Grados de Alcohol', TextInputType.number),
                _buildTextField(_tamanioController, 'Tamaño', TextInputType.text),
                _buildTextField(_precioNormalController, 'Precio Normal', TextInputType.number),
                _buildTextField(_precioMayoreoController, 'Precio Mayoreo', TextInputType.number),
                _buildTextField(_stockController, 'Stock', TextInputType.number),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
