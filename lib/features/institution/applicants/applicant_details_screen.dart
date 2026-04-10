import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ApplicantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> applicant;

  const ApplicantDetailsScreen({
    Key? key,
    required this.applicant,
  }) : super(key: key);

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {
  bool _isLoading = false;
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _acceptApplicant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Applicant'),
        content: const Text('Are you sure you want to accept this applicant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post(
        ApiConstants.acceptApplicant,
        {'application_id': widget.applicant['id']},
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('Applicant accepted successfully', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to accept applicant', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectApplicant() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Applicant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _rejectionReasonController.text);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post(
        ApiConstants.rejectApplicant,
        {
          'application_id': widget.applicant['id'],
          'rejection_reason': reason,
        },
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('Applicant rejected', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to reject applicant', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadCV() async {
    final cvUrl = widget.applicant['cv_url'];
    if (cvUrl != null) {
      final uri = Uri.parse(cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final isPending = widget.applicant['status'] == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicant Details'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        widget.applicant['student_name']?[0] ?? 'A',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.applicant['student_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.applicant['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Details
            const Text(
              'Student Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _DetailCard(
              icon: Icons.school,
              label: 'University',
              value: widget.applicant['university'] ?? 'N/A',
            ),
            _DetailCard(
              icon: Icons.book,
              label: 'Major',
              value: widget.applicant['major'] ?? 'N/A',
            ),
            _DetailCard(
              icon: Icons.phone,
              label: 'Phone',
              value: widget.applicant['phone'] ?? 'N/A',
            ),

            const SizedBox(height: 20),

            // Applied Opportunity
            const Text(
              'Applied For',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.work, color: AppColors.primary),
                title: Text(widget.applicant['opportunity_title'] ?? 'N/A'),
                subtitle: Text(
                  'Applied on ${widget.applicant['applied_at'] ?? 'N/A'}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CV Download
            if (widget.applicant['cv_url'] != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: AppColors.primary,
                  ),
                  title: const Text('Curriculum Vitae'),
                  subtitle: const Text('Tap to download'),
                  trailing: const Icon(Icons.download),
                  onTap: _downloadCV,
                ),
              ),

            const SizedBox(height: 32),

            // Action Buttons
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Reject',
                      onPressed: _isLoading ? null : _rejectApplicant,
                      isLoading: _isLoading,
                      isOutlined: true,
                      color: AppColors.error,
                      icon: Icons.close,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Accept',
                      onPressed: _isLoading ? null : _acceptApplicant,
                      isLoading: _isLoading,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.applicant['status'] == 'accepted'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.applicant['status'] == 'accepted'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.applicant['status'] == 'accepted'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.applicant['status'] == 'accepted'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.applicant['status'] == 'accepted'
                            ? 'This applicant has been accepted'
                            : 'This applicant has been rejected',
                        style: TextStyle(
                          color: widget.applicant['status'] == 'accepted'
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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