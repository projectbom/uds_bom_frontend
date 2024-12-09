import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/location.dart';
import '../../models/transportation.dart';
import '../../providers/meeting_provider.dart';
import 'user_card.dart';

class UserCardList extends StatelessWidget {
  const UserCardList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        final users = meetingProvider.participants;

        return Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, users.length, meetingProvider),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildUserList(context, users, meetingProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int userCount, MeetingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '참여자',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (userCount < 5)
            Tooltip(
              message: '참여자 추가 (최대 5명)',
              child: IconButton(
                icon: const Icon(Icons.person_add),
                color: Theme.of(context).primaryColor,
                onPressed: () => _handleAddParticipant(context, provider),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<User> users, MeetingProvider provider) {
    return ListView.separated(
      itemCount: users.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return Dismissible(
          key: ValueKey(user.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissibleBackground(),
          confirmDismiss: (direction) => _confirmDismiss(context, user, users.length),
          onDismissed: (_) {
            provider.removeParticipant(user.id);
          },
          child: UserCard(
            key: ValueKey('card_${user.id}'),
            user: user,
            onLocationUpdate: (location) {
              provider.updateUserLocation(user.id, location);
            },
            onTransportTypeUpdate: (type) {
              provider.updateUserTransportation(user.id, type);
            },
          ),
        );
      },
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: Icon(
        Icons.delete_outline,
        color: Colors.red.shade700,
      ),
    );
  }

  void _handleAddParticipant(BuildContext context, MeetingProvider provider) {
    try {
      provider.addParticipant(
        User(
          id: DateTime.now().toString(),
          name: '참가자 ${provider.participants.length + 1}',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<bool> _confirmDismiss(BuildContext context, User user, int userCount) async {
    if (userCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1명의 참가자가 필요합니다'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('참가자 삭제'),
        content: Text('${user.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}