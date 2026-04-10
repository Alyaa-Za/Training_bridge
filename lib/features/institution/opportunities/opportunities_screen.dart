import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/opportunity_model.dart';
import 'add_opportunity_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({Key? key}) : super(key: key);

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  bool _isLoading = true;
  List<OpportunityModel> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(
        ApiConstants.institutionOpportunities,
      );

      if (response.success) {
        _opportunities = (response.data as List)
            .map((e) => OpportunityModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error loading opportunities: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteOpportunity(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Opportunity'),
        content: const Text(
          'Are you sure you want to delete this opportunity? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await ApiService().delete(
          '${ApiConstants.institutionOpportunities}/$id',
        );

        if (!mounted) return;

        if (response.success) {
          _showSnackBar('Opportunity deleted successfully', isError: false);
          _loadOpportunities();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      } catch (e) {
        _showSnackBar('Failed to delete opportunity', isError: true);
      }
    }
  }

  Future<void> _toggleStatus(int id, bool currentStatus) async {
    try {
      final response = await ApiService().put(
        '${ApiConstants.institutionOpportunities}/$id/toggle',
        {'is_active': !currentStatus},
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar(
          currentStatus ? 'Opportunity disabled' : 'Opportunity enabled',
          isError: false,
        );
        _loadOpportunities();
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to update status', isError: true);
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

  void _navigateToAddOpportunity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddOpportunityScreen()),
    );

    if (result == true) {
      _loadOpportunities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Opportunities'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _opportunities.isEmpty
          ? EmptyState(
        icon: Icons.work_off,
        title: 'No Opportunities',
        message: 'Create your first training opportunity',
        actionLabel: 'Create Opportunity',
        onAction: _navigateToAddOpportunity,
      )
          : RefreshIndicator(
        onRefresh: _loadOpportunities,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _opportunities.length,
          itemBuilder: (context, index) {
            final opportunity = _opportunities[index];
            return _OpportunityCard(
              opportunity: opportunity,
              onDelete: () => _deleteOpportunity(opportunity.id),
              onToggle: () => _toggleStatus(
                opportunity.id,
                opportunity.isActive,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddOpportunity,
        icon: const Icon(Icons.add),
        label: const Text('Add Opportunity'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _OpportunityCard({
    required this.opportunity,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    opportunity.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: opportunity.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    opportunity.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: opportunity.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  opportunity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.location_on,
                      label: opportunity.city,
                    ),
                    _InfoChip(
                      icon: Icons.school,
                      label: opportunity.major,
                    ),
                    if (opportunity.duration != null)
                      _InfoChip(
                        icon: Icons.access_time,
                        label: '${opportunity.duration} months',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  opportunity.isActive ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                label: Text(opportunity.isActive ? 'Disable' : 'Enable'),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to edit screen
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}