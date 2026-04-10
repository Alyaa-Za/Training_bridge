import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'intern_details_screen.dart';

class InternsScreen extends StatefulWidget {
  const InternsScreen({Key? key}) : super(key: key);

  @override
  State<InternsScreen> createState() => _InternsScreenState();
}

class _InternsScreenState extends State<InternsScreen> {
  bool _isLoading = true;
  List<dynamic> _interns = [];

  @override
  void initState() {
    super.initState();
    _loadInterns();
  }

  Future<void> _loadInterns() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(ApiConstants.interns);

      if (response.success) {
        setState(() {
          _interns = response.data as List;
        });
      }
    } catch (e) {
      print('Error loading interns: $e');
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
      appBar: AppBar(
        title: const Text('Active Interns'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interns.isEmpty
          ? const EmptyState(
        icon: Icons.people_outline,
        title: 'No Active Interns',
        message: 'You don\'t have any active interns at the moment',
      )
          : RefreshIndicator(
        onRefresh: _loadInterns,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _interns.length,
          itemBuilder: (context, index) {
            final intern = _interns[index];
            return _InternCard(
              intern: intern,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InternDetailsScreen(
                      intern: intern,
                    ),
                  ),
                );
                if (result == true) {
                  _loadInterns();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _InternCard extends StatelessWidget {
  final Map<String, dynamic> intern;
  final VoidCallback onTap;

  const _InternCard({
    required this.intern,
    required this.onTap,
  });

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
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  intern['student_name']?[0] ?? 'I',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intern['student_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      intern['opportunity_title'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today,
                          'Started: ${intern['start_date'] ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}