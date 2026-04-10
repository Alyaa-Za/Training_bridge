import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'opportunities/opportunities_screen.dart';
import 'applicants/applicants_screen.dart';
import 'interns/interns_screen.dart';
import 'complaints/complaints_screen.dart';
import 'profile/institution_profile_screen.dart';
import 'account_status_screen.dart';

class InstitutionHome extends StatefulWidget {
  const InstitutionHome({Key? key}) : super(key: key);

  @override
  State<InstitutionHome> createState() => _InstitutionHomeState();
}

class _InstitutionHomeState extends State<InstitutionHome> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _accountStatus = 'pending_approval';

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OpportunitiesScreen(),
    const ApplicantsScreen(),
    const InternsScreen(),
    const InstitutionProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(ApiConstants.profile);

      if (response.success && response.data != null) {
        setState(() {
          _accountStatus = response.data['status'] ?? 'pending_approval';
        });
      }
    } catch (e) {
      print('Error checking account status: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // إذا الحساب غير مفعّل، اعرض شاشة الحالة فقط
    if (_accountStatus != 'active') {
      return AccountStatusScreen(status: _accountStatus);
    }

    // إذا الحساب مفعّل، اعرض البوابة كاملة
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Interns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Training Bridge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Institution Portal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Support & Complaints'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }
}