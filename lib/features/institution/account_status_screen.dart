import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AccountStatusScreen extends StatelessWidget {
  final String status;
  final String? message;

  const AccountStatusScreen({
    Key? key,
    required this.status,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: 60,
                    color: _getStatusColor(),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  _getStatusTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  message ?? _getDefaultMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Logout logic
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return Icons.hourglass_empty;
      case 'suspended':
        return Icons.block;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusTitle() {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Account Under Review';
      case 'suspended':
        return 'Account Suspended';
      case 'rejected':
        return 'Account Rejected';
      default:
        return 'Account Status';
    }
  }

  String _getDefaultMessage() {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Your account is currently under review by the university administration. You will be notified once your account is activated.';
      case 'suspended':
        return 'Your account has been suspended. Please contact the university administration for more information.';
      case 'rejected':
        return 'Your account registration has been rejected. Please contact the university administration.';
      default:
        return 'Please contact support for more information.';
    }
  }
}