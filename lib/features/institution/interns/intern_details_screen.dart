import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class InternDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> intern;

  const InternDetailsScreen({
    Key? key,
    required this.intern,
  }) : super(key: key);

  @override
  State<InternDetailsScreen> createState() => _InternDetailsScreenState();
}

class _InternDetailsScreenState extends State<InternDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _reports = [];
  Map<String, dynamic>? _evaluation;

  // Evaluation Form
  final _evaluationFormKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmittingEvaluation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gradeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load reports
      final reportsResponse = await ApiService().get(
        '/institution/interns/${widget.intern['id']}/reports',
      );

      if (reportsResponse.success) {
        _reports = reportsResponse.data as List;
      }

      // Load existing evaluation
      final evalResponse = await ApiService().get(
        '/institution/interns/${widget.intern['id']}/evaluation',
      );

      if (evalResponse.success && evalResponse.data != null) {
        _evaluation = evalResponse.data;
        _gradeController.text = _evaluation!['grade']?.toString() ?? '';
        _notesController.text = _evaluation!['notes'] ?? '';
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitEvaluation() async {
    if (!_evaluationFormKey.currentState!.validate()) return;

    setState(() => _isSubmittingEvaluation = true);

    try {
      final response = await ApiService().post(
        ApiConstants.evaluate,
        {
          'intern_id': widget.intern['id'],
          'grade': double.parse(_gradeController.text),
          'notes': _notesController.text,
        },
      );

      if (!mounted) return;

      if (response.success) {
        _showSnackBar('Evaluation submitted successfully', isError: false);
        _loadData();
      } else {
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to submit evaluation', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmittingEvaluation = false);
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
        title: Text(widget.intern['student_name'] ?? 'Intern Details'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Reports'),
            Tab(text: 'Evaluation'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildEvaluationTab(),
        ],
      ),
    );
  }

  // Reports Tab
  Widget _buildReportsTab() {
    if (_reports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 80,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No Reports Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The intern hasn\'t submitted any reports',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _ReportCard(report: report);
        },
      ),
    );
  }

  // Evaluation Tab
  Widget _buildEvaluationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _evaluationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: AppColors.info.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Evaluate the intern\'s overall performance during the training period',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Intern Info Summary
            const Text(
              'Intern Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Name', widget.intern['student_name'] ?? 'N/A'),
                    const Divider(height: 24),
                    _buildInfoRow('University', widget.intern['university'] ?? 'N/A'),
                    const Divider(height: 24),
                    _buildInfoRow('Major', widget.intern['major'] ?? 'N/A'),
                    const Divider(height: 24),
                    _buildInfoRow('Start Date', widget.intern['start_date'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grade Input
            const Text(
              'Final Grade',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _gradeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter grade (0-100)',
                prefixIcon: const Icon(Icons.grade),
                suffixText: '/ 100',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Grade is required';
                }
                final grade = double.tryParse(value);
                if (grade == null) {
                  return 'Please enter a valid number';
                }
                if (grade < 0 || grade > 100) {
                  return 'Grade must be between 0 and 100';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Notes Input
            const Text(
              'Evaluation Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _notesController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your evaluation notes here...\n\n'
                    'Include:\n'
                    '- Performance quality\n'
                    '- Attendance and punctuality\n'
                    '- Skills improvement\n'
                    '- Overall behavior',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Evaluation notes are required';
                }
                if (value.length < 20) {
                  return 'Please provide detailed notes (at least 20 characters)';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            if (_evaluation == null)
              PrimaryButton(
                text: 'Submit Evaluation',
                onPressed: _submitEvaluation,
                isLoading: _isSubmittingEvaluation,
                icon: Icons.send,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Evaluation has been submitted',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _evaluation = null;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'W${report['week_number'] ?? '?'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        title: Text(
          'Week ${report['week_number'] ?? 'N/A'} Report',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Submitted: ${report['submitted_at'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Content:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report['content'] ?? 'No content',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (report['attachment'] != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Open attachment
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'View Attachment',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}