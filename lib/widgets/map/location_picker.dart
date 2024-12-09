import 'package:flutter/material.dart';
import '../../models/location.dart';
import '../../models/transportation.dart';
import '../../providers/location_provider.dart';
import 'transportation_selector.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  final Location? initialLocation;
  final TransportationType initialTransportType;
  final Function(Location) onLocationSelected;
  final Function(TransportationType) onTransportTypeChanged;

  const LocationPicker({
    Key? key,
    this.initialLocation,
    this.initialTransportType = TransportationType.car,
    required this.onLocationSelected,
    required this.onTransportTypeChanged,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Location? _selectedLocation;
  TransportationType _selectedTransportType = TransportationType.car;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedTransportType = widget.initialTransportType;
    if (_selectedLocation != null) {
      _searchController.text = _selectedLocation!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchField(),
        const SizedBox(height: 8),
        TransportationSelector(
          selectedType: _selectedTransportType,
          onTypeChanged: _handleTransportTypeChanged,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '출발 위치를 입력하세요',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _buildSuffixIcon(locationProvider),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onTap: () => _showSearchBottomSheet(context),
          readOnly: true,
        );
      },
    );
  }

  Widget _buildSuffixIcon(LocationProvider locationProvider) {
    if (locationProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      );
    }
    return IconButton(
      icon: const Icon(Icons.my_location),
      onPressed: () => _getCurrentLocation(locationProvider),
    );
  }

  Future<void> _getCurrentLocation(LocationProvider locationProvider) async {
    try {
      await locationProvider.getCurrentLocation();
      if (locationProvider.currentLocation != null) {
        _updateSelectedLocation(locationProvider.currentLocation!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LocationSearchBottomSheet(
        onLocationSelected: _updateSelectedLocation,
      ),
    );
  }

  void _updateSelectedLocation(Location location) {
    setState(() {
      _selectedLocation = location;
      _searchController.text = location.address;
    });
    widget.onLocationSelected(location);
  }

  void _handleTransportTypeChanged(TransportationType type) {
    setState(() => _selectedTransportType = type);
    widget.onTransportTypeChanged(type);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _LocationSearchBottomSheet extends StatefulWidget {
  final Function(Location) onLocationSelected;

  const _LocationSearchBottomSheet({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<_LocationSearchBottomSheet> createState() => _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState extends State<_LocationSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchField(locationProvider),
              if (locationProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else
                Expanded(
                  child: _buildRecentLocations(locationProvider),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '위치 검색',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '주소를 입력하세요',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (query) {
          setState(() {});
          _debounceTimer?.cancel();
          if (query.isEmpty) return;

          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            _searchLocation(locationProvider, query);
          });
        },
      ),
    );
  }

  Widget _buildRecentLocations(LocationProvider locationProvider) {
    return ListView.builder(
      itemCount: locationProvider.recentLocations.length,
      itemBuilder: (context, index) {
        final address = locationProvider.recentLocations[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(address),
          onTap: () => _searchLocation(locationProvider, address),
        );
      },
    );
  }

  Future<void> _searchLocation(LocationProvider locationProvider, String query) async {
    try {
      final location = await locationProvider.searchLocation(query);
      if (!mounted) return;
      widget.onLocationSelected(location);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}