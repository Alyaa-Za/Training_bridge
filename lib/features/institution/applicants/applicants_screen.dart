import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'applicant_details_screen.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({Key? key}) : super(key: key);

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  bool _isLoading = true;
  List<dynamic> _applicants = [];
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(
        '${ApiConstants.applicants}?status=$_filterStatus',
      );

      if (response.success) {
        _applicants = response.data as List;
      }
    } catch (e) {
      print('Error loading applicants: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FilterOption(
              label: 'All',
              value: 'all',
              isSelected: _filterStatus == 'all',
              onTap: () {
                setState(() => _filterStatus = 'all');
                Navigator.pop(context);
                _loadApplicants();
              },
            ),
            _FilterOption(
              label: 'Pending',
              value: 'pending',
              isSelected: _filterStatus == 'pending',
              onTap: () {
                setState(() => _filterStatus = 'pending');
                Navigator.pop(context);
                _loadApplicants();
              },
            ),
            _FilterOption(
              label: 'Accepted',
              value: 'accepted',
              isSelected: _filterStatus == 'accepted',
              onTap: () {
                setState(() => _filterStatus = 'accepted');
                Navigator.pop(context);
                _loadApplicants();
              },
            ),
            _FilterOption(
              label: 'Rejected',
              value: 'rejected',
              isSelected: _filterStatus == 'rejected',
              onTap: () {
                setState(() => _filterStatus = 'rejected');
                Navigator.pop(context);
                _loadApplicants();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Applicants'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_filterStatus != 'all')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
          ? EmptyState(
        icon: Icons.people_outline,
        title: 'No Applicants',
        message: _filterStatus == 'all'
            ? 'No one has applied yet'
            : 'No $_filterStatus applicants',
      )
          : RefreshIndicator(
        onRefresh: _loadApplicants,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _applicants.length,
          itemBuilder: (context, index) {
            final applicant = _applicants[index];
            return _ApplicantCard(
              applicant: applicant,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplicantDetailsScreen(
                      applicant: applicant,
                    ),
                  ),
                );
                if (result == true) {
                  _loadApplicants();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Map<String, dynamic> applicant;
  final VoidCallback onTap;

  const _ApplicantCard({
    required this.applicant,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      applicant['student_name']?[0] ?? 'A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant['student_name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          applicant['university'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: applicant['status'] ?? 'pending',
                    color: _getStatusColor(applicant['status'] ?? 'pending'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.work,
                      label: applicant['opportunity_title'] ?? 'N/A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                    icon: Icons.school,
                    label: applicant['major'] ?? 'N/A',
                  ),
                  Text(
                    applicant['applied_at'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}