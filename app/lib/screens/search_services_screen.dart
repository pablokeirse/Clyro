import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'service_detail_screen.dart';

class Provider {
  final String id;
  final String name;
  final String info;
  final double? distanceKm;
  Provider(this.id, this.name, this.info, this.distanceKm);

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
        json['id'] as String,
        json['name'] as String,
        (json['info'] as String?) ?? '',
        (json['distance_km'] as num?)?.toDouble(),
      );
}

class SearchServicesScreen extends StatefulWidget {
  const SearchServicesScreen({super.key});

  @override
  State<SearchServicesScreen> createState() => _SearchServicesScreenState();
}

class _SearchServicesScreenState extends State<SearchServicesScreen> {
  String _category = 'Plumber';
  double _radiusKm = 5;
  final _searchController = TextEditingController();

  List<Provider> _providers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.searchProviders(
        category: _category,
        radiusKm: _radiusKm,
      );
      if (!mounted) return;
      setState(() {
        _providers = data.map(Provider.fromJson).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load providers. Make sure the backend is running.';
        _loading = false;
      });
    }
  }

  List<Provider> get _filtered => _providers
      .where((p) => _searchController.text.isEmpty ||
          p.name.toLowerCase().contains(_searchController.text.toLowerCase()))
      .toList();

  void _openFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(category: _category, radiusKm: _radiusKm),
    );
    if (result != null) {
      setState(() {
        _category = result['category'];
        _radiusKm = result['radius'];
      });
      _loadProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search Services...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openFilters,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border, width: 1.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.accentBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2)),
            ),
            child: Text(
              'Filters selected: $_category, within ${_radiusKm.toInt()}Km',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _loadProviders, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text('No providers found nearby.', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProviders,
                            child: ListView.separated(
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, i) {
                                final p = _filtered[i];
                                return _ProviderCard(
                                  provider: p,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailScreen(
                                        providerId: p.id,
                                        providerName: p.name,
                                        info: p.info,
                                        distanceKm: p.distanceKm ?? 0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onTap;
  const _ProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 70,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlueLight,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                ),
                child: const Center(
                  child: Icon(Icons.handyman_outlined, color: AppColors.accentBlue),
                ),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(provider.info, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 10),
                      if (provider.distanceKm != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${provider.distanceKm}Km away from your location',
                            style: const TextStyle(fontSize: 11, color: AppColors.accentBlue, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String category;
  final double radiusKm;
  const _FilterSheet({required this.category, required this.radiusKm});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _category = widget.category;
  late double _radius = widget.radiusKm;

  final _categories = const ['All', 'Plumber', 'Electrician', 'Cleaner'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((c) {
              final selected = c == _category;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                selectedColor: AppColors.accentBlueLight,
                onSelected: (_) => setState(() => _category = c),
                labelStyle: TextStyle(color: selected ? AppColors.accentBlueDark : AppColors.textPrimary),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Within ${_radius.toInt()}Km', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _radius,
            min: 1,
            max: 25,
            divisions: 24,
            activeColor: AppColors.accentBlue,
            onChanged: (v) => setState(() => _radius = v),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({'category': _category, 'radius': _radius}),
            child: const Text('Apply filters'),
          ),
        ],
      ),
    );
  }
}