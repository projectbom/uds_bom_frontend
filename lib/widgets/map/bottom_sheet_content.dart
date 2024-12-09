import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meeting_provider.dart';
import '../../models/user.dart';
import 'user_card_list.dart';

class BottomSheetContent extends StatelessWidget {
  final ScrollController controller;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final VoidCallback onBack;

  const BottomSheetContent({
    Key? key,
    required this.controller,
    this.selectedDate,
    this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 스크롤 이벤트가 상위로 전파되는 것을 방지
        return true;
      },
      child: Consumer<MeetingProvider>(
        builder: (context, meetingProvider, child) {
          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDragHandle(),
                  _buildTopBar(context),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      physics: const ClampingScrollPhysics(),
                      child: UserCardList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateTimeButton(
                icon: Icons.calendar_today,
                label: selectedDate?.toString().split(' ')[0] ?? '날짜',
                onTap: onSelectDate,
              ),
              const SizedBox(width: 16),
              _DateTimeButton(
                icon: Icons.access_time,
                label: selectedTime?.format(context) ?? '시간',
                onTap: onSelectTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}