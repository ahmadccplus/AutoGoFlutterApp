import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/repositories/car_repository.dart';
import '../../providers/car_provider.dart';
import '../../providers/auth_provider.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _doorsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  String? _transmission;
  String? _fuelType;
  bool _airConditioning = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _doorsController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images.map((image) => File(image.path)).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _submitCar() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthStatus();
    
    if (!isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to post your car'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    if (_images.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one image'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = CarRepository();
      
      // For demo: Convert images to placeholder URLs
      // In production, upload images to cloud storage first
      final imageUrls = _images.map((image) => 
        'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=${_makeController.text}+${_modelController.text}'
      ).toList();

      await repository.createCar(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        pricePerDay: double.parse(_priceController.text.trim()),
        locationAddress: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        images: imageUrls,
        seats: _seatsController.text.trim().isEmpty 
            ? null 
            : int.parse(_seatsController.text.trim()),
        doors: _doorsController.text.trim().isEmpty 
            ? null 
            : int.parse(_doorsController.text.trim()),
        transmission: _transmission,
        fuelType: _fuelType,
        airConditioning: _airConditioning,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        // Refresh car list
        context.read<CarProvider>().loadAvailableCars(reset: true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car posted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to post car';
        if (e.toString().contains('401') || e.toString().contains('403')) {
          errorMessage = 'Please login again to post your car';
        } else if (e.toString().contains('Network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post Your Car',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              const Text(
                'Car Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add at least one image of your car',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Images'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add More Images'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Car Details
              const Text(
                'Car Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Make',
                controller: _makeController,
                hint: 'e.g., Toyota',
                prefixIcon: Icons.directions_car,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Make is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Model',
                controller: _modelController,
                hint: 'e.g., Camry',
                prefixIcon: Icons.directions_car,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Year',
                controller: _yearController,
                hint: 'e.g., 2022',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Price per Day (\$)',
                controller: _priceController,
                hint: 'e.g., 50',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Location (Optional)',
                controller: _locationController,
                hint: 'e.g., Kuala Lumpur, Malaysia',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Seats (Optional)',
                      controller: _seatsController,
                      hint: 'e.g., 5',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.people,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Doors (Optional)',
                      controller: _doorsController,
                      hint: 'e.g., 4',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.door_sliding,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Transmission
              DropdownButtonFormField<String>(
                value: _transmission,
                decoration: const InputDecoration(
                  labelText: 'Transmission (Optional)',
                  prefixIcon: Icon(Icons.settings),
                  border: OutlineInputBorder(),
                ),
                items: ['automatic', 'manual']
                    .map((transmission) => DropdownMenuItem(
                          value: transmission,
                          child: Text(transmission.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _transmission = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Fuel Type
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type (Optional)',
                  prefixIcon: Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(),
                ),
                items: ['petrol', 'diesel', 'electric', 'hybrid']
                    .map((fuel) => DropdownMenuItem(
                          value: fuel,
                          child: Text(fuel.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fuelType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Air Conditioning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: CheckboxListTile(
                  title: const Text('Air Conditioning'),
                  value: _airConditioning,
                  onChanged: (value) {
                    setState(() {
                      _airConditioning = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description (Optional)',
                controller: _descriptionController,
                hint: 'Describe your car...',
                maxLines: 4,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Post Car',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
