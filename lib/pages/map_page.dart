import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../widgets/map/google_map_view.dart';
import '../widgets/map/place_list.dart';
import '../widgets/map/bottom_sheet_content.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meetingProvider = context.read<MeetingProvider>();
      meetingProvider.addInitialParticipants();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Consumer<MeetingProvider>(
          builder: (context, meetingProvider, child) {
            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: meetingProvider.isLoading,
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMapView(
                      users: meetingProvider.participants,
                      meetingPoint: meetingProvider.meetingPoint,
                    ),
                  ),
                ),
                if (meetingProvider.meetingPoint != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height * 0.3,
                    child: PlaceList(
                      places: meetingProvider.recommendedPlaces,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      // 스크롤 이벤트가 상위로 전파되는 것을 방지
                      return true;
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => FocusScope.of(context).unfocus(),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                          minHeight: MediaQuery.of(context).size.height * 0.1,
                        ),
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.3,
                          minChildSize: 0.1,
                          maxChildSize: 0.6,
                          snap: true,
                          snapSizes: const [0.3, 0.6],
                          builder: (context, scrollController) {
                            return BottomSheetContent(
                              controller: scrollController,
                              selectedDate: _selectedDate,
                              selectedTime: _selectedTime,
                              onSelectDate: () => _selectDate(context),
                              onSelectTime: () => _selectTime(context),
                              onBack: () => Navigator.of(context).pop(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (meetingProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}