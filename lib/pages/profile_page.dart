import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/transportation.dart';
import '../services/storage_service.dart';
import '../widgets/profile/profile_section.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../widgets/map/profile_edit_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('로그인이 필요합니다.'));
          }
          return _ProfileContent(user: user);
        },
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final User user;

  const _ProfileContent({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late StorageService _storageService;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeStorageService();
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final File imageFile = File(image.path);
      final String imageUrl = await _storageService.uploadProfileImage(
        widget.user.id,
        imageFile,
      );

      await Provider.of<AuthProvider>(context, listen: false)
          .updateProfileImage(imageUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드 실패: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.user.profileImageUrl != null
                          ? NetworkImage(widget.user.profileImageUrl!)
                          : null,
                      child: widget.user.profileImageUrl == null
                          ? Text(
                              widget.user.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _isUploading ? null : _updateProfileImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.user.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.user.location!.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ProfileSection(
            title: '이동 수단 설정',
            children: [
              _TransportationSelector(
                currentType: widget.user.transportType,
                onChanged: (type) {
                  Provider.of<AuthProvider>(context, listen: false)
                      .updateUserProfile(transportType: type);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSection(
            title: '계정 설정',
            children: [
              ProfileMenuItem(
                icon: Icons.person,
                title: '프로필 수정',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ProfileEditDialog(user: widget.user),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSection(
            title: '기타',
            children: [
              ProfileMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () async {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/auth');
                },
              ),
              ProfileMenuItem(
                icon: Icons.delete_forever,
                title: '계정 삭제',
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text('정말로 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }
}

class _TransportationSelector extends StatelessWidget {
  final TransportationType currentType;
  final ValueChanged<TransportationType> onChanged;

  const _TransportationSelector({
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<TransportationType>(
              segments: const [
                ButtonSegment(
                  value: TransportationType.car,
                  icon: Icon(Icons.directions_car),
                  label: Text('자가용'),
                ),
                ButtonSegment(
                  value: TransportationType.public,
                  icon: Icon(Icons.directions_transit),
                  label: Text('대중교통'),
                ),
              ],
              selected: {currentType},
              onSelectionChanged: (Set<TransportationType> selected) {
                onChanged(selected.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}