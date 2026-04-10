import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({Key? key}) : super(key: key);

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _weekController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e', isError: true);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> reportData = {
        'week_number': int.parse(_weekController.text),
        'content': _contentController.text,
      };

      final response = await ApiService().post(
        ApiConstants.submitReport,
        reportData,
      );

      // If there's a file, upload it separately
      if (_selectedFile != null && response.success) {
        final reportId = response.data['id'];
        await ApiService().uploadFile(
          '${ApiConstants.submitReport}/$reportId/attachment',
          'attachment',
          _selectedFile!.path,
        );
      }

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('Report submitted successfully', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to submit report', isError: true);
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
        title: const Text('Add Weekly Report'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Week Number
            CustomInput(
              label: 'Week Number',
              hint: 'Enter week number',
              controller: _weekController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Week number is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.calendar_today),
            ),

            const SizedBox(height: 20),

            // Report Content
            CustomInput(
              label: 'Report Content',
              hint: 'Describe your progress this week...',
              controller: _contentController,
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Report content is required';
                }
                if (value.length < 50) {
                  return 'Report must be at least 50 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Attachment Section
            const Text(
              'Attachment (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (_selectedFile != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.attach_file,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    _selectedFile!.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Text(
              'Supported formats: PDF, DOC, DOCX, JPG, PNG',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            PrimaryButton(
              text: 'Submit Report',
              onPressed: _submitReport,
              isLoading: _isLoading,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}