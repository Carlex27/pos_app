import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/models/department/department.dart';
import 'package:pos_app/services/department_service.dart';
import 'package:provider/provider.dart';
import '../../../services/product_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NewProductForm extends StatefulWidget {
  const NewProductForm({super.key});

  @override
  State<NewProductForm> createState() => _NewProductFormState();


}

class _NewProductFormState extends State<NewProductForm> {
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
  final _minimoMayoreoController = TextEditingController();
  final _unidadesPorPresentacionController = TextEditingController();

  File? _selectedImage;

  List<Department> _departments = [];
  Department? _selectedDepartment;

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
        ),
      );
    }
  }
  Future<void> _loadDepartments() async {
    try {
      final departmentService = Provider.of<DepartmentService>(context, listen: false);
      final result = await departmentService.fetchAll();
      setState(() {
        _departments = result.where((d) => d.isActive).toList();
      });
    } catch (e) {
      print('Error al cargar departamentos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDepartments();
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
    _unidadesPorPresentacionController.dispose();
    _precioMayoreoController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor selecciona una imagen'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      // Guardar el contexto del ScaffoldMessenger ANTES de operaciones async
      // que podrían hacer que el widget se desmonte o el contexto cambie.
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context); // Guardar Navigator también

      try {
        final productService = Provider.of<ProductService>(context, listen: false);

        await productService.uploadProductWithImage(
          sku: _skuController.text,
          nombre: _nombreController.text,
          departamento: _selectedDepartment?.name ?? '',
          precioCosto: double.parse(_precioCostoController.text),
          precioVenta: double.parse(_precioVentaController.text),
          precioMayoreo: double.parse(_precioMayoreoController.text),
          // Asegúrate de que este campo esté presente en tu servicio y modelo si lo necesitas
          precioUnidadVenta: double.parse(_precioUnidadVentaController.text),
          // Este campo faltaba en tu llamada original al servicio en NewProductForm,
          // pero estaba presente en los controladores. Asegúrate de incluirlo si es necesario.
          // precioUnidadMayoreo: double.parse(_precioUnidadMayoreoController.text), // Asegúrate de esto también
          stock: double.parse(_stockController.text),
          stockMinimo: int.parse(_stockMinimoController.text),
          unidadesPorPresentacion: int.parse(_unidadesPorPresentacionController.text),
          minimoMayoreo: _minimoMayoreoController.text,
          imageFile: _selectedImage!,
        );

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Producto creado exitosamente'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        if (navigator.canPop()) {
          navigator.pop(true); // <--- DEVOLVER true AQUÍ
        }

      } catch (e) {
        print('Error al crear producto: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Opcionalmente, podrías hacer pop(false) aquí si quieres distinguir
        // entre un cierre por cancelación y un cierre por error.
        // if (navigator.canPop()) {
        //   navigator.pop(false);
        // }
      }
    }
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
                      Icons.add_box_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nuevo Producto',
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
                        if (_selectedImage != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 80,
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
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
                          ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(_selectedImage == null ? 'Seleccionar Imagen' : 'Cambiar Imagen'),
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
                  // Campos del formulario en filas de 2
                  _buildTextField(_skuController, 'SKU', TextInputType.text, Icons.qr_code_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_nombreController, 'Nombre', TextInputType.text, Icons.label_outline),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<Department>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Departamento',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.store_mall_directory_outlined, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept.name),
                      );
                    }).toList(),
                    onChanged: (dept) {
                      setState(() {
                        _selectedDepartment = dept;
                      });
                    },
                    validator: (value) => value == null ? 'Selecciona un departamento' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_precioCostoController, 'Precio Costo', TextInputType.number, Icons.price_check_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioVentaController, 'Precio Venta', TextInputType.number, Icons.attach_money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioMayoreoController, 'Precio Mayoreo', TextInputType.number, Icons.attach_money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_precioUnidadVentaController, 'Precio Unidad Venta', TextInputType.number, Icons.money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_unidadesPorPresentacionController, 'Unidades por presentacion', TextInputType.number, Icons.money_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockController, 'Stock', TextInputType.number, Icons.inventory_2_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_stockMinimoController, 'Stock Mínimo', TextInputType.number, Icons.remove_shopping_cart_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_minimoMayoreoController, 'Mínimo Mayoreo', TextInputType.number, Icons.stacked_line_chart_outlined),
                  const SizedBox(height: 32),

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
                        onPressed: _submitForm,
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
                        child: const Text(
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