import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../data/models/opportunity_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/widgets/opportunity_card.dart';
import 'opportunity_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isLoading = true;
  List<OpportunityModel> _opportunities = [];
  List<OpportunityModel> _filteredOpportunities = [];

  String? _selectedCity;
  String? _selectedMajor;
  final TextEditingController _searchController = TextEditingController();

  List<String> _cities = [];
  List<String> _majors = [];

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
    _loadFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOpportunities() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().get(ApiConstants.opportunities);

      if (response.success) {
        _opportunities = (response.data as List)
            .map((e) => OpportunityModel.fromJson(e))
            .toList();
        _filteredOpportunities = _opportunities;
      }
    } catch (e) {
      print('Error loading opportunities: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFilters() async {
    try {
      final response = await ApiService().get('/filters');
      if (response.success) {
        setState(() {
          _cities = List<String>.from(response.data['cities'] ?? []);
          _majors = List<String>.from(response.data['majors'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading filters: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredOpportunities = _opportunities.where((opportunity) {
        bool matchesCity = _selectedCity == null ||
            opportunity.city == _selectedCity;
        bool matchesMajor = _selectedMajor == null ||
            opportunity.major == _selectedMajor;
        bool matchesSearch = _searchController.text.isEmpty ||
            opportunity.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            opportunity.companyName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        return matchesCity && matchesMajor && matchesSearch;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        cities: _cities,
        majors: _majors,
        selectedCity: _selectedCity,
        selectedMajor: _selectedMajor,
        onApply: (city, major) {
          setState(() {
            _selectedCity = city;
            _selectedMajor = major;
          });
          _applyFilters();
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _selectedCity = null;
            _selectedMajor = null;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Opportunities'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search opportunities...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.filter_list),
                        if (_selectedCity != null || _selectedMajor != null)
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
                    onPressed: _showFilterBottomSheet,
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          if (_selectedCity != null || _selectedMajor != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withOpacity(0.1),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCity != null)
                    Chip(
                      label: Text(_selectedCity!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _selectedCity = null);
                        _applyFilters();
                      },
                    ),
                  if (_selectedMajor != null)
                    Chip(
                      label: Text(_selectedMajor!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _selectedMajor = null);
                        _applyFilters();
                      },
                    ),
                ],
              ),
            ),

          // Opportunities List
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading()
                : _filteredOpportunities.isEmpty
                ? EmptyState(
              icon: Icons.search_off,
              title: 'No Opportunities Found',
              message: 'Try adjusting your filters or search query',
              actionLabel: 'Reset Filters',
              onAction: () {
                setState(() {
                  _selectedCity = null;
                  _selectedMajor = null;
                  _searchController.clear();
                });
                _applyFilters();
              },
            )
                : RefreshIndicator(
              onRefresh: _loadOpportunities,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredOpportunities.length,
                itemBuilder: (context, index) {
                  final opportunity = _filteredOpportunities[index];
                  return OpportunityCard(
                    opportunity: opportunity,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OpportunityDetailsScreen(
                            opportunity: opportunity,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 120,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 200,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<String> cities;
  final List<String> majors;
  final String? selectedCity;
  final String? selectedMajor;
  final Function(String?, String?) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.cities,
    required this.majors,
    this.selectedCity,
    this.selectedMajor,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _tempCity;
  String? _tempMajor;

  @override
  void initState() {
    super.initState();
    _tempCity = widget.selectedCity;
    _tempMajor = widget.selectedMajor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Opportunities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onReset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // City Filter
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.cities.map((city) {
                    final isSelected = _tempCity == city;
                    return FilterChip(
                      label: Text(city),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _tempCity = selected ? city : null;
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Major Filter
                const Text(
                  'Major',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.majors.map((major) {
                    final isSelected = _tempMajor == major;
                    return FilterChip(
                      label: Text(major),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _tempMajor = selected ? major : null;
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_tempCity, _tempMajor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}