class SearchHistory {
  final String id;
  final String userId;
  final String searchDate;
  final List<String> participants;
  final String? meetingPoint;

  SearchHistory({
    required this.id,
    required this.userId,
    required this.searchDate,
    required this.participants,
    this.meetingPoint,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      userId: json['user_id'],
      searchDate: json['search_date'],
      participants: List<String>.from(json['participants']),
      meetingPoint: json['meeting_point'],
    );
  }
}