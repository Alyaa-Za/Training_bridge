import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailsScreen({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  @override
  State<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final response = await ApiService().get(
        '${ApiConstants.opportunities}/${widget.opportunity.id}/check-application',
      );
      if (response.success && mounted) {
        setState(() {
          _hasApplied = response.data['has_applied'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  Future<void> _applyToOpportunity() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post(
        ApiConstants.applyOpportunity,
        {'opportunity_id': widget.opportunity.id},
      );

      if (!mounted) return;

      if (response.success) {
        setState(() => _hasApplied = true);
        _showSnackBar(response.message, isError: false);
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to apply', isError: true);
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
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.opportunity.logo != null
                  ? CachedNetworkImage(
                imageUrl: widget.opportunity.logo!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.business,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              )
                  : Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.business,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.opportunity.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Company Name
                  Text(
                    widget.opportunity.companyName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: widget.opportunity.city,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.school,
                          label: 'Major',
                          value: widget.opportunity.major,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (widget.opportunity.duration != null)
                    _InfoCard(
                      icon: Icons.access_time,
                      label: 'Duration',
                      value: '${widget.opportunity.duration} months',
                    ),

                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'About This Opportunity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.opportunity.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dates if available
                  if (widget.opportunity.startDate != null ||
                      widget.opportunity.endDate != null) ...[
                    const Text(
                      'Important Dates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.opportunity.startDate != null)
                      _DateRow(
                        label: 'Start Date',
                        date: widget.opportunity.startDate!,
                      ),
                    if (widget.opportunity.endDate != null)
                      _DateRow(
                        label: 'End Date',
                        date: widget.opportunity.endDate!,
                      ),
                  ],

                  const SizedBox(height: 100), // Space for sticky button
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Apply Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: PrimaryButton(
          text: _hasApplied ? 'Already Applied' : 'Apply Now',
          onPressed: _hasApplied ? null : _applyToOpportunity,
          isLoading: _isLoading,
          icon: _hasApplied ? Icons.check_circle : Icons.send,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String date;

  const _DateRow({
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}