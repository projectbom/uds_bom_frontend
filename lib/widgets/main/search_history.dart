import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/search_history.dart';

class SearchHistorySection extends StatelessWidget {
  final String userId;
  final ApiService _apiService = ApiService();

  SearchHistorySection({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchHistory>>(
      future: _apiService.getSearchHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const SizedBox();
        }

        final histories = snapshot.data ?? [];
        if (histories.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '최근 검색 기록',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: histories.length,
                itemBuilder: (context, index) {
                  final history = histories[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        // 검색 기록 클릭 시 지도 페이지로 이동
                        Navigator.pushNamed(
                          context, 
                          '/map',
                          arguments: history.participants,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history.searchDate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '참가자 ${history.participants.length}명',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              history.meetingPoint ?? '중간지점 미정',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}