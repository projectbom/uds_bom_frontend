import 'package:flutter/material.dart';
import '../../models/place.dart';
import 'dart:math' as math;

class PlaceList extends StatefulWidget {
  final List<Place> places;
  final Function(Place)? onPlaceSelected;

  const PlaceList({
    Key? key,
    required this.places,
    this.onPlaceSelected,
  }) : super(key: key);

  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  PlaceType _selectedType = PlaceType.all;

  List<Place> get _filteredPlaces => _selectedType == PlaceType.all
      ? widget.places
      : widget.places.where((p) => p.type == _selectedType.value).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                '추천 장소',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<PlaceType>(
                value: _selectedType,
                items: PlaceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _currentPage = 0;
                      _pageController.jumpToPage(0);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredPlaces.isEmpty
              ? const Center(
                  child: Text('추천 장소가 없습니다'),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: (_filteredPlaces.length / 5).ceil(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  itemBuilder: (context, pageIndex) {
                    final startIndex = pageIndex * 5;
                    final endIndex = math.min(startIndex + 5, _filteredPlaces.length);
                    final pageItems = _filteredPlaces.sublist(startIndex, endIndex);

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pageItems.length,
                      itemBuilder: (context, index) {
                        final place = pageItems[index];
                        return _PlaceCard(
                          place: place,
                          onTap: () => widget.onPlaceSelected?.call(place),
                        );
                      },
                    );
                  },
                ),
        ),
        if (_filteredPlaces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (_filteredPlaces.length / 5).ceil(),
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const _PlaceCard({
    Key? key,
    required this.place,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: place.imageUrl != null
                    ? Image.network(
                        place.imageUrl!,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 140,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          place.rating.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${place.userRatingsTotal})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (place.distance != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${place.distance!.toStringAsFixed(1)}km',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}