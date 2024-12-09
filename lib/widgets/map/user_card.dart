import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/location.dart';
import '../../models/transportation.dart';
import 'location_picker.dart';
import 'profile_edit_dialog.dart';

class UserCard extends StatelessWidget {
  final User user;
  final Function(Location) onLocationUpdate;
  final Function(TransportationType) onTransportTypeUpdate;
  final VoidCallback? onRemove;

  const UserCard({
    Key? key,
    required this.user,
    required this.onLocationUpdate,
    required this.onTransportTypeUpdate,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => _showProfileEditDialog(context),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: user.profileImageUrl != null
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                            child: user.profileImageUrl == null
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 20),
                                  )
                                : null,
                          ),
                          if (user.isLocationSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (user.location != null)
                              Text(
                                _getTransportTypeText(user.transportType),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showProfileEditDialog(context),
                  visualDensity: VisualDensity.compact,
                  color: Theme.of(context).primaryColor,
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LocationPicker(
              initialLocation: user.location,
              initialTransportType: user.transportType,
              onLocationSelected: onLocationUpdate,
              onTransportTypeChanged: onTransportTypeUpdate,
            ),
          ],
        ),
      ),
    );
  }

  String _getTransportTypeText(TransportationType type) {
    switch (type) {
      case TransportationType.car:
        return '자가용으로 이동';
      case TransportationType.public:
        return '대중교통으로 이동';
    }
  }

  void _showProfileEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(user: user),
    );
  }
}