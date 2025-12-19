import 'package:flutter/material.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  // Retailer filters
  final Set<String> _selectedRetailers = {};
  final List<String> _retailers = [
    'NSK Grocer',
    'Tesco',
    'Giant',
    'AEON',
    'Jaya Grocer',
    'Village Grocer',
  ];

  // Price range
  RangeValues _priceRange = const RangeValues(0, 1000);
  final double _maxPrice = 1000.0;

  // Brand filter
  final Set<String> _selectedBrands = {};
  final List<String> _brands = [
    'Brand A',
    'Brand B',
    'Brand C',
    'Brand D',
    'Generic',
  ];

  // Dietary needs
  final Set<String> _selectedDietary = {};
  final List<String> _dietaryOptions = [
    'Halal',
    'Vegetarian',
    'Vegan',
    'Organic',
    'Gluten-Free',
    'Sugar-Free',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Advanced Filters',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(color: kBlack, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Retailer Filter
                  _buildSection(
                    'Retailer',
                    Icons.store,
                    _buildRetailerFilter(),
                  ),
                  const SizedBox(height: 24),

                  // Price Range Filter
                  _buildSection(
                    'Price Range',
                    Icons.attach_money,
                    _buildPriceRangeFilter(),
                  ),
                  const SizedBox(height: 24),

                  // Brand Filter
                  _buildSection(
                    'Brand',
                    Icons.branding_watermark,
                    _buildBrandFilter(),
                  ),
                  const SizedBox(height: 24),

                  // Dietary Needs Filter
                  _buildSection(
                    'Dietary Needs',
                    Icons.restaurant,
                    _buildDietaryFilter(),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              border: Border(
                top: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlack,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters (${_getActiveFilterCount()})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kBlack, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildRetailerFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _retailers.map((retailer) {
        final isSelected = _selectedRetailers.contains(retailer);
        return FilterChip(
          label: Text(retailer),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedRetailers.add(retailer);
              } else {
                _selectedRetailers.remove(retailer);
              }
            });
          },
          backgroundColor: kLightGray,
          selectedColor: kBlack,
          labelStyle: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? kBlack : kMediumGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: _maxPrice,
          divisions: 100,
          labels: RangeLabels(
            'RM ${_priceRange.start.toStringAsFixed(0)}',
            'RM ${_priceRange.end.toStringAsFixed(0)}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
          activeColor: kBlack,
          inactiveColor: kMediumGray.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kMediumGray.withValues(alpha: 0.2)),
              ),
              child: Text(
                'RM ${_priceRange.start.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text('to', style: TextStyle(color: kMediumGray)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kMediumGray.withValues(alpha: 0.2)),
              ),
              child: Text(
                'RM ${_priceRange.end.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          backgroundColor: kLightGray,
          selectedColor: kBlack,
          labelStyle: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? kBlack : kMediumGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietaryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _dietaryOptions.map((option) {
        final isSelected = _selectedDietary.contains(option);
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDietaryIcon(option),
                size: 16,
                color: isSelected ? kWhite : kBlack,
              ),
              const SizedBox(width: 4),
              Text(option),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDietary.add(option);
              } else {
                _selectedDietary.remove(option);
              }
            });
          },
          backgroundColor: kLightGray,
          selectedColor: kBlack,
          labelStyle: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? kBlack : kMediumGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        );
      }).toList(),
    );
  }

  IconData _getDietaryIcon(String option) {
    switch (option) {
      case 'Halal':
        return Icons.check_circle;
      case 'Vegetarian':
        return Icons.eco;
      case 'Vegan':
        return Icons.eco;
      case 'Organic':
        return Icons.agriculture;
      case 'Gluten-Free':
        return Icons.grain;
      case 'Sugar-Free':
        return Icons.cake;
      default:
        return Icons.info;
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedRetailers.isNotEmpty) count++;
    if (_priceRange.start > 0 || _priceRange.end < _maxPrice) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_selectedDietary.isNotEmpty) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedRetailers.clear();
      _priceRange = const RangeValues(0, 1000);
      _selectedBrands.clear();
      _selectedDietary.clear();
    });
  }

  void _applyFilters() {
    // TODO: Apply filters and navigate back with results
    Navigator.pop(context, {
      'retailers': _selectedRetailers.toList(),
      'priceRange': _priceRange,
      'brands': _selectedBrands.toList(),
      'dietary': _selectedDietary.toList(),
    });
  }
}


