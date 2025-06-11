import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/models/department/department.dart';
import 'package:pos_app/services/department_service.dart';
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
  final _precioCostoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioMayoreoController = TextEditingController();
  final _precioUnidadVentaController = TextEditingController();
  final _precioUnidadMayoreoController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _stockPorUnidadController = TextEditingController();
  final _minimoMayoreoController = TextEditingController();
  final _unidadesPorProductoController = TextEditingController();


  File? _selectedImage;
  late String _currentImageUrl;

  List<Department> _departments = [];
  Department? _selectedDepartment;


  @override
  void initState() {
    super.initState();
    _skuController.text = widget.product.SKU;
    _nombreController.text = widget.product.nombre;
    _precioCostoController.text = widget.product.precioCosto.toString();
    _precioVentaController.text = widget.product.precioVenta.toString();
    _precioMayoreoController.text = widget.product.precioMayoreo.toString();
    _precioUnidadVentaController.text = widget.product.precioUnidadVenta.toString();
    _precioUnidadMayoreoController.text = widget.product.precioUnidadMayoreo.toString();
    _stockController.text = widget.product.stock.toString();
    _stockMinimoController.text = widget.product.stockMinimo.toString();
    _minimoMayoreoController.text = widget.product.minimoMayoreo.toString();
    _unidadesPorProductoController.text = widget.product.unidadesPorPresentacion.toString();
    _stockPorUnidadController.text = widget.product.stockPorUnidad.toString();

    _loadDepartments();
    // Cargar imagen async sin await
    _loadImageUrl();
  }
  Future<void> _loadDepartments() async {
    try {
      final departmentService = Provider.of<DepartmentService>(context, listen: false);
      final result = await departmentService.fetchAll();
      setState(() {
        _departments = result.where((d) => d.isActive).toList();
        _selectedDepartment = _departments.firstWhere(
              (d) => d.name == widget.product.departamento,
          orElse: () => _selectedDepartment!,
        );
      });
    } catch (e) {
      print('Error al cargar departamentos: $e');
    }
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
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        final productService = Provider.of<ProductService>(context, listen: false);
        // Crear un objeto Product actualizado para potencialmente pasarlo,
        // aunque para el flujo actual con onDataChanged solo necesitamos la señal.
        // Sin embargo, tener el objeto actualizado es buena práctica.
        final updatedProductData = Product(
          id: widget.product.id, // Mantener el ID original
          SKU: _skuController.text,
          nombre: _nombreController.text,
          departamento: _selectedDepartment?.name ?? widget.product.departamento, // Usar el departamento actual si no se cambia
          precioCosto: double.parse(_precioCostoController.text),
          precioVenta: double.parse(_precioVentaController.text),
          precioMayoreo: double.parse(_precioMayoreoController.text),
          precioUnidadVenta: double.parse(_precioUnidadVentaController.text),
          precioUnidadMayoreo: double.parse(_precioUnidadMayoreoController.text),
          unidadesPorPresentacion: int.parse(_unidadesPorProductoController.text),
          stock: double.parse(_stockController.text),
          stockPorUnidad: widget.product.stockPorUnidad, // Este campo parece que no se edita en el form
          stockMinimo: int.parse(_stockMinimoController.text),
          minimoMayoreo: int.parse(_minimoMayoreoController.text),
          imagePath: widget.product.imagePath, // Se manejará por separado con _selectedImage
          // Asumir que se mantiene el estado activo
          // ... otros campos que no se editan directamente en este formulario pero son parte del modelo Product
        );

        await productService.updateProductWithOptionalImage(
          id: widget.product.id,
          sku: updatedProductData.SKU,
          nombre: updatedProductData.nombre,
          departamento: updatedProductData.departamento,
          precioCosto: updatedProductData.precioCosto,
          precioVenta: updatedProductData.precioVenta,
          precioMayoreo: updatedProductData.precioMayoreo,
          precioUnidadVenta: updatedProductData.precioUnidadVenta,
          precioUnidadMayoreo: updatedProductData.precioUnidadMayoreo,
          unidadesPorPresentacion: updatedProductData.unidadesPorPresentacion,
          stock: updatedProductData.stock,
          stockPorUnidad: updatedProductData.stockPorUnidad,
          stockMinimo: updatedProductData.stockMinimo,
          minimoMayoreo: updatedProductData.minimoMayoreo,
          imageFile: _selectedImage,
        );

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        if (mounted) { // Asegúrate de que EditProductForm sigue montado
          Navigator.of(context).pop(true); // <--- ESTO ES CRUCIAL. Usa el 'context' de EditProductForm.
        }

      } catch (e) {
        print('Error al actualizar producto: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Opcionalmente, pop(false) o no hacer pop para que el usuario pueda reintentar.
        // if (navigator.canPop()) {
        //   navigator.pop(false);
        // }
      }
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nombreController.dispose();
    _precioCostoController.dispose();
    _precioVentaController.dispose();
    _precioUnidadVentaController.dispose();
    _precioUnidadMayoreoController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _minimoMayoreoController.dispose();
    _unidadesPorProductoController.dispose();
    _precioMayoreoController.dispose();
    _stockPorUnidadController.dispose();
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

                  DropdownButtonFormField<Department>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Departamento',
                      prefixIcon: Icon(Icons.store_mall_directory_outlined, color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept.name),
                      );
                    }).toList(),
                    onChanged: (dept) => setState(() => _selectedDepartment = dept),
                    validator: (value) => value == null ? 'Selecciona un departamento' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_precioCostoController, 'Precio Costo', TextInputType.number, Icons.price_check_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioVentaController, 'Precio Venta', TextInputType.number, Icons.attach_money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioMayoreoController, 'Precio Mayoreo', TextInputType.number, Icons.monetization_on_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioUnidadVentaController, 'Precio Unidad Venta', TextInputType.number, Icons.money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioUnidadMayoreoController, 'Precio Unidad Mayoreo', TextInputType.number, Icons.monetization_on_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_unidadesPorProductoController, 'Unidades por Producto', TextInputType.number, Icons.format_list_numbered_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockController, 'Stock', TextInputType.number, Icons.inventory_2_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockPorUnidadController, 'Stock por unidad', TextInputType.number, Icons.inventory_2_outlined),
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