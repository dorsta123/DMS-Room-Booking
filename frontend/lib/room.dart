  import 'dart:convert';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:syncfusion_flutter_calendar/calendar.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart'; // Make sure this is at the top
  // import 'dart:io' show Platform;
  import 'package:flutter/foundation.dart' show kIsWeb;

  // Main widget for Room Booking
  class Room extends StatefulWidget // this class encapsulating ui part and logic part
    {  final String profColor;
  final String profName;
      // Stateful widget are used because the selected ui part will change at run time
      const Room({super.key,required this.profColor, required this.profName});
      @override
      State<Room> createState() => _RoomState();
    }
  List<String>? userData;
  class _RoomState extends State<Room> {
  @override
  void initState(){
    super.initState();
    userData=[widget.profColor,widget.profName];
  }
    List<DateTime> selectedSlots = [];
    List<TimeRegion> _getSelectedRegions() {
      return selectedSlots
          .map(
            (slot) => TimeRegion(
              startTime: slot,
              endTime: slot.add(Duration(minutes: 30)),
              color: Colors.blue.shade50,
              enablePointerInteraction: false,
            ),
          )
          .toList();
    }
/*
    String getBaseUrl() {
      if (kIsWeb) {
        return 'http://127.0.0.1:5008'; // For Flutter Web (runs in browser)
      } else {
        return 'http://10.0.2.2:5008'; // For Android emulator
      } // For real Android device, use your PC's IP like:
    }
*/
    // API function
    /*
    void fetchUser() async {
      final url = Uri.parse('${getBaseUrl()}/slot/SL101');
      final response = await http.get(url);
      final user = jsonDecode(response.body);
      final userName = user[1];
      var color = userName['color'];
      var name = userName['booked_by'];

      if (response.statusCode == 200) {
        setState(() {
          userData = [color.toString(), name.toString()];
        });
      } else {
        print('API failed ho gye');
      }
    }
  */
    // List of ROOMS for booking
    final List<String> rooms = [
      'ROOM A01',
      'ROOM A02',
      'ROOM A03',
      'ROOM B01',
      'ROOM B02',
      'ROOM B03',
    ];

    // dynamic color from api
    final Map<String, Color> colorNameMap = {
      "red": Colors.red,
      "green": Colors.green,
      "yellow": const Color.fromARGB(255, 222, 200, 0),
      "blue":Colors.blue,
      "brown":Color.fromARGB(255, 146, 102, 86),

    };
    // Currenlty Selected Room
    String? selectedRoom;

    // Appointment for selected Room
    List<Appointment> _appointments = [];
    // function for uploading the data from local to firebase firestore
    Future<void> uploadData() async {
      try {
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        final DateFormat timeFormat = DateFormat('HH:mm');
        final List<String> slotTimes =
            selectedSlots.map((slot) {
              final date = dateFormat.format(slot);
              final start = timeFormat.format(slot);
              final end = timeFormat.format(slot.add(Duration(minutes: 30)));
              return '$date $start-$end';
            }).toList();
        final data = await FirebaseFirestore.instance.collection("Bookings").add({
          "Name": userData?[1],
          "Color": userData?[0],
          "Date": FieldValue.serverTimestamp(),
          "Room": selectedRoom,
          "Slot": slotTimes,
        });
        print("Selected slots:");
        print(slotTimes);
        // print(data.id);
      } catch (e) {
        print(e);
      }
    }

    Future<List<Appointment>> fetchAppointmentsFromFirestore(String room) async {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final List<Appointment> appointments = [];

      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection("Bookings")
                .where("Room", isEqualTo: room)
                .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final name = data['Name'];
          final colorName = data['Color']?.toLowerCase();
          final slotList = List<String>.from(data['Slot']);

          for (String slot in slotList) {
            final dateTimeParts = slot.split(' ');
            if (dateTimeParts.length != 2) continue;

            final datePart = dateTimeParts[0];
            final timeRange = dateTimeParts[1].split('-');
            if (timeRange.length != 2) continue;

            final startTimeStr = '$datePart ${timeRange[0]}';
            final endTimeStr = '$datePart ${timeRange[1]}';

            final startTime = dateFormat.parse(startTimeStr);
            final endTime = dateFormat.parse(endTimeStr);

            appointments.add(
              Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: 'Booked by - Dr. $name',
                color: colorNameMap[colorName] ?? Colors.grey,
              ),
            );
          }
        }
      } catch (e) {
        print("Error loading appointments: $e");
      }

      return appointments;
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // This is the app bar
        appBar: AppBar(
          title: const Text(
            'Room Booking System',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w700,
              fontSize: 25,
            ),
          ),
          actions:<Widget> [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child:Text(widget.profName[0],style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20),),
                  
                  ),
                )
                // Icon(Icons.account_c)
              ],
            )
          ],
          backgroundColor: const Color.fromARGB(255, 0, 0, 255),
          centerTitle: true,
        ),
        body: Column(
          // To Arrange Widgets Vertically
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Scrollable Rooms buttons in a row
            SingleChildScrollView(
              // it allows horizontal scrolling
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ), // for giving padding
              child: Row(
                children:
                    rooms.map((room) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ), // for giving padding
                        child: RoomButton(
                          label: room,
                          onTap: () async {
                            // fetchUser();
                            final appointments =
                                await fetchAppointmentsFromFirestore(room);
                            setState(() {
                              // used for updating the ui part during runtime
                              selectedRoom = room;
                              _appointments = appointments;
                              // _appointments = _getDataSource(room);
                            });
                            // fetchUser();
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),

            // Calendar shown only if a room is selected
            if (selectedRoom != null) ...[
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'Selected: $selectedRoom',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Spacer(), // pushes next widgets to the end
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 15),
                    child: ElevatedButton(
                      onPressed:
                          canSelectRooms() // for checking the slecting room is valid or not
                              ? () async {
                                for (DateTime slot in selectedSlots) {
                                  final DateTime startTime = slot;
                                  final DateTime endTime = startTime.add(
                                    const Duration(minutes: 30),
                                  );
                                  // Prevent double booking
                                  bool hasConflict = _appointments.any(
                                    (a) =>
                                        a.startTime.isBefore(endTime) &&
                                        a.endTime.isAfter(startTime),
                                  );
                                  if (!hasConflict) {
                                    setState(() {
                                      _appointments.add(
                                        Appointment(
                                          startTime: startTime,
                                          endTime: endTime,
                                          subject:
                                              'Booked by - Dr. ${userData?[1] ?? "Unknown"}',
                                          color:
                                              colorNameMap[userData?[0].toLowerCase()] ?? Colors.grey,
                                        ),
                                      );
                                    });
                                  }
                                }
                                // Clear selected slots and refresh
                                await uploadData();
                                setState(() {
                                  // canSelectRooms();
                                  selectedSlots.clear();
                                });
                              }
                              : null,

                      child: Text('Booked'),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SfCalendar(
                  // displays a visual booking calendar
                  view: CalendarView.day,
                  allowedViews: const [
                    // it supports multiple views like day,week & month
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.month,
                  ],
                  // minDate: DateTime.now(),
                  initialDisplayDate: DateTime.now().subtract(Duration(days: 1)),
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    // it enables calender timeslot setting
                    startHour: 7.5,
                    endHour: 23,
                    timeInterval: Duration(minutes: 30),
                    timeFormat: 'HH:mm',
                  ),
                  dataSource: MeetingDataSource(
                    _appointments,
                  ), //This line connects your list of room bookings to the calendar
                  // On tap, to create a new appointment on the calendar
                  onTap: (CalendarTapDetails details) async {
                    if (details.targetElement == CalendarElement.calendarCell &&
                        details.date != null) {
                      final DateTime selected = details.date!;
                      // Prevent adding past slots
                      if (selected.isBefore(DateTime.now())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot select past time slots'),
                            showCloseIcon: true,
                          ),
                        );
                        // Remove if already selected (optional)
                        setState(() {
                          selectedSlots.remove(selected);
                        });
                        return;
                      }
                      setState(() {
                        if (selectedSlots.contains(selected)) {
                          selectedSlots.remove(selected);
                        } else {
                          selectedSlots.add(selected);
                        }
                      });
                    }
                  },
                  specialRegions: _getSelectedRegions(),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // function checking validity of a room
    bool canSelectRooms() {
      final now = DateTime.now();
      if (selectedSlots.isEmpty) {
        return false;
      }
      for (DateTime slot in selectedSlots) {
        // Past time check
        if (slot.isBefore(now)) {
          return false;
        }
        // Already booked check
        final slotEnd = slot.add(Duration(minutes: 30));
        bool conflict = _appointments.any(
          (a) => a.startTime.isBefore(slotEnd) && a.endTime.isAfter(slot),
        );
        if (conflict) {
          return false;
        }
      }
      return true; // Must have at least one slot selected
    }

    // Function to get appointments for a selected room (currently returns empty)
    List<Appointment> _getDataSource(String room) {
      return [];
    }
  }

  // Widget for room button
  class RoomButton extends StatelessWidget {
    // using statless widget because ui part is not changing during runtime
    final String label;
    final VoidCallback onTap;
    const RoomButton({super.key, required this.label, required this.onTap});
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        //gesture detector is used to detect gesture tap
        onTap: onTap,
        child: Container(
          width: 120,
          height: 50,
          alignment:
              Alignment.center, // for the child widget's  alignment to center
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 255),
            borderRadius: BorderRadius.circular(20), // it gives box radius
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'IndieFlower',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  // Data source class to supply appointments to the calendar
  class MeetingDataSource extends CalendarDataSource {
    MeetingDataSource(List<Appointment> source) // accepts the  list of bookings
    {
      appointments = source; // Passes the booking data to the calendar widget
    }
  }
