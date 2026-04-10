import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentApplicants = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get('/institution/dashboard');

      if (response.success) {
        setState(() {
          _stats = response.data['stats'] ?? {};
          _recentApplicants = response.data['recent_applicants'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text('Dashboard'),
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),

            // Stats Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate([
                  _StatCard(
                    icon: Icons.work,
                    label: 'Active Opportunities',
                    value: _stats['active_opportunities']?.toString() ?? '0',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    icon: Icons.pending_actions,
                    label: 'New Applicants',
                    value: _stats['new_applicants']?.toString() ?? '0',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    icon: Icons.people,
                    label: 'Active Interns',
                    value: _stats['active_interns']?.toString() ?? '0',
                    color: AppColors.success,
                  ),
                  _StatCard(
                    icon: Icons.done_all,
                    label: 'Total Applications',
                    value: _stats['total_applications']?.toString() ?? '0',
                    color: AppColors.primaryDark,
                  ),
                ]),
              ),
            ),

            // Recent Applicants
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Applicants',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to applicants tab
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            if (_recentApplicants.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No recent applicants'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final applicant = _recentApplicants[index];
                      return _ApplicantCard(applicant: applicant);
                    },
                    childCount: _recentApplicants.length > 5
                        ? 5
                        : _recentApplicants.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Map<String, dynamic> applicant;

  const _ApplicantCard({required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            applicant['name']?[0] ?? 'A',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(applicant['name'] ?? 'Unknown'),
        subtitle: Text(applicant['opportunity_title'] ?? ''),
        trailing: Text(
          applicant['applied_at'] ?? '',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}