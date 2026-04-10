import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/user_model.dart';
import '../../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  UserModel? _user;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();

  File? _selectedCV;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(ApiConstants.profile);

      if (response.success) {
        _user = UserModel.fromJson(response.data);
        _nameController.text = _user!.name;
        _phoneController.text = _user!.phone ?? '';
        _universityController.text = _user!.university ?? '';
        _majorController.text = _user!.major ?? '';
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().put(
        ApiConstants.profile,
        {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'university': _universityController.text,
          'major': _majorController.text,
        },
      );

      if (!mounted) return;

      if (response.success) {
        setState(() => _isEditing = false);
        _showSnackBar('Profile updated successfully', isError: false);
        _loadProfile();
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to update profile', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedCV = File(result.files.single.path!);
        });
        await _uploadCV();
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e', isError: true);
    }
  }

  Future<void> _uploadCV() async {
    if (_selectedCV == null) return;

    try {
      final response = await ApiService().uploadFile(
        '${ApiConstants.profile}/cv',
        'cv',
        _selectedCV!.path,
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('CV uploaded successfully', isError: false);
        _loadProfile();
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to upload CV', isError: true);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SecureStorage().clearAll();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
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
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        _user?.name[0].toUpperCase() ?? 'S',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user?.name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() => _isEditing = true);
                  },
                ),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isEditing) ...[
                    CustomInput(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Phone',
                      hint: 'Enter your phone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'University',
                      hint: 'Enter your university',
                      controller: _universityController,
                      prefixIcon: const Icon(Icons.school),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Major',
                      hint: 'Enter your major',
                      controller: _majorController,
                      prefixIcon: const Icon(Icons.book),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Cancel',
                            onPressed: () {
                              setState(() => _isEditing = false);
                              _loadProfile();
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Save',
                            onPressed: _updateProfile,
                            icon: Icons.check,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildInfoTile(
                      Icons.phone,
                      'Phone',
                      _user?.phone ?? 'Not provided',
                    ),
                    _buildInfoTile(
                      Icons.school,
                      'University',
                      _user?.university ?? 'Not provided',
                    ),
                    _buildInfoTile(
                      Icons.book,
                      'Major',
                      _user?.major ?? 'Not provided',
                    ),
                  ],

                  const SizedBox(height: 24),

                  // CV Section
                  const Text(
                    'Curriculum Vitae',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: AppColors.primary,
                      ),
                      title: const Text('Upload CV'),
                      subtitle: const Text('PDF format only'),
                      trailing: const Icon(Icons.upload_file),
                      onTap: _pickCV,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Language'),
                          trailing: const Text('English'),
                          onTap: () {
                            // Show language picker
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: AppColors.error),
                          ),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}