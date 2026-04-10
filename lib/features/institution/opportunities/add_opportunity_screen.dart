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
  final _slotsController = TextEditingController();

  // Screening Questions
  final List<TextEditingController> _questionControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add first question by default
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _majorController.dispose();
    _durationController.dispose();
    _slotsController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionControllers.add(TextEditingController());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
    });
  }

  Future<void> _createOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    // Collect screening questions
    List<String> questions = _questionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

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
          'slots': int.tryParse(_slotsController.text) ?? 1,
          'screening_questions': questions, // Send as array
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
            // Section 1: Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

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

            Row(
              children: [
                Expanded(
                  child: CustomInput(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInput(
                    label: 'Major',
                    hint: 'e.g., CS',
                    controller: _majorController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Major is required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.school),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    label: 'Duration (months)',
                    hint: 'e.g., 3',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInput(
                    label: 'Available Slots',
                    hint: 'e.g., 5',
                    controller: _slotsController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.people),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section 2: Screening Questions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Screening Questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Add Question'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Add custom questions to screen applicants',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Dynamic Questions
            ..._questionControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Question ${index + 1}',
                          hintText: 'e.g., Do you have Python experience?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.help_outline),
                        ),
                      ),
                    ),
                    if (_questionControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _removeQuestion(index),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),

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