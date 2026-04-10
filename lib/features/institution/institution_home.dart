import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'opportunities/opportunities_screen.dart';
import 'applicants/applicants_screen.dart';
import 'profile/institution_profile_screen.dart';

class InstitutionHome extends StatefulWidget {
  const InstitutionHome({Key? key}) : super(key: key);

  @override
  State<InstitutionHome> createState() => _InstitutionHomeState();
}

class _InstitutionHomeState extends State<InstitutionHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OpportunitiesScreen(),
    const ApplicantsScreen(),
    const InstitutionProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}