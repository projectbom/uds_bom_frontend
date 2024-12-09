import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user.dart';
import 'package:provider/provider.dart';
import '../../providers/meeting_provider.dart';
import '../../services/storage_service.dart';

class ProfileEditDialog extends StatefulWidget {
  final User user;

  const ProfileEditDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  String? _imageUrl;
  bool _isUploading = false;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _imageUrl = widget.user.profileImageUrl;
    _initializeStorageService();
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('참가자 정보 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  child: _imageUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                if (_isUploading)
                  const Positioned.fill(
                    child: CircularProgressIndicator(),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _saveProfile,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image == null) return;

      setState(() => _isUploading = true);
      final File imageFile = File(image.path);
      final String imageUrl = await _storageService.uploadProfileImage(
        widget.user.id,
        imageFile,
      );
      setState(() {
        _imageUrl = imageUrl;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드 실패: ${e.toString()}')),
      );
      setState(() => _isUploading = false);
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요')),
      );
      return;
    }

    final provider = Provider.of<MeetingProvider>(context, listen: false);
    provider.updateParticipant(
      widget.user.id,
      widget.user.copyWith(
        name: _nameController.text.trim(),
        profileImageUrl: _imageUrl,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
