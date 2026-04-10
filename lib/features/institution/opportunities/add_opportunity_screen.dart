import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({Key? key}) : super(key: key);

  @override
  State<AddOpportunityScreen> createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _majorController = TextEditingController();
  final _durationController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _majorController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _createOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post(
        ApiConstants.institutionOpportunities,
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'city': _cityController.text,
          'major': _majorController.text,
          'duration': int.tryParse(_durationController.text),
        },
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('Opportunity created successfully', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to create opportunity', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Opportunity'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomInput(
              label: 'Opportunity Title',
              hint: 'e.g., Summer Internship Program',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.title),
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'Description',
              hint: 'Describe the opportunity in detail...',
              controller: _descriptionController,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                if (value.length < 50) {
                  return 'Description must be at least 50 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'City',
              hint: 'e.g., Riyadh',
              controller: _cityController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is required';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.location_city),
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'Major',
              hint: 'e.g., Computer Science',
              controller: _majorController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Major is required';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.school),
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'Duration (months)',
              hint: 'e.g., 3',
              controller: _durationController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Duration is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.access_time),
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Create Opportunity',
              onPressed: _createOpportunity,
              isLoading: _isLoading,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}