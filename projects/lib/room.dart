import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Main widget for Room Booking
class Room
    extends
        StatefulWidget //  Stateful widget are used because the selected ui part will change at run time
        {
  const Room({super.key});
  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  // List of ROOMS for booking
  final List<String> rooms = [
    'ROOM A01',
    'ROOM A02',
    'ROOM A03',
    'ROOM B01',
    'ROOM B02',
    'ROOM B03',
  ];

  // Currenlty Selected Room
  String? selectedRoom;

  // Appointment for selected Room
  List<Appointment> _appointments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is the app bar
      appBar: AppBar(
        title: const Text('Room Booking System'),
        backgroundColor: const Color.fromRGBO(110, 99, 255, 1),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Scrollable Rooms buttons in a row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              children:
                  rooms.map((room) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: RoomButton(
                        label: room,
                        onTap: () {
                          setState(() {
                            selectedRoom = room;
                            _appointments = _getDataSource(room);
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Calendar shown only if a room is selected
          if (selectedRoom != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Selected: $selectedRoom',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: SfCalendar(
                view: CalendarView.week,
                allowedViews: const [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.month,
                ],
                // minDate: DateTime.now(),
                initialDisplayDate: DateTime.now(),
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 7.5,
                  endHour: 23,
                  timeInterval: Duration(minutes: 30),
                  timeFormat: 'HH:mm',
                ),
                dataSource: MeetingDataSource(_appointments),
                // On tap, to create a new appointment on the calendar
                onTap: (CalendarTapDetails details) async {
                  // checking for already booked slot
                  if (details.targetElement == CalendarElement.appointment) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Time slot is already booked'),
                        showCloseIcon: true,
                      ),
                    );
                    return;
                  }
                  if (details.targetElement == CalendarElement.calendarCell &&
                      details.date != null) {
                    final DateTime startTime = details.date!;
                    final DateTime endTime = startTime.add(
                      const Duration(minutes: 30),
                    );
                    // Checking for booking of past time slots
                    if (startTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot book past time slots'),
                          showCloseIcon: true,
                        ),
                      );
                      return;
                    }

                    // function for checking conflicts
                    bool hasConflict(DateTime start, DateTime end) {
                      return _appointments.any(
                        (a) =>
                            a.startTime.isBefore(end) &&
                            a.endTime.isAfter(start),
                      );
                    }

                    // Show dialog box of confirmation for room booking
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Book this slot?'),
                            content: Text(
                              'Room: $selectedRoom\n'
                              'Time: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - '
                              '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Book'),
                              ),
                            ],
                          ),
                    );
                    //If booking confirmed then add appointment
                    if (confirmed == true) {
                      if (!hasConflict(startTime, endTime)) {
                        setState(() {
                          _appointments.add(
                            Appointment(
                              startTime: startTime,
                              endTime: endTime,
                              subject: 'Your Booking',
                              color: Colors.green,
                            ),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Time slot already booked'),
                            showCloseIcon: true,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
// Function to get appointments for a selected room (currently returns empty)
  List<Appointment> _getDataSource(String room) {
    return [];
  }
}

//
// Widget for room button
class RoomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const RoomButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(110, 99, 255, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'IndieFlower',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Data source class to supply appointments to the calendar
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
