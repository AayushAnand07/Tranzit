import 'package:flutter/material.dart';

class SearchTrainScreen extends StatefulWidget {
  const SearchTrainScreen({Key? key}) : super(key: key);

  @override
  State<SearchTrainScreen> createState() => _SearchTrainScreenState();
}

class _SearchTrainScreenState extends State<SearchTrainScreen> {
  bool isRoundTrip = true;
  String fromLocation = "Chittagong";
  String toLocation = "Chandpur";
  DateTime? departDate = DateTime(2022, 1, 28);
  DateTime? returnDate;
  TimeOfDay departureTime = TimeOfDay(hour: 8, minute: 0);
  int passengerCount = 2;
  String travelClass = "Bussines";

  final Color headerColor = Color(0xFF5867DD); // Blue header
  final Color toggleActiveColor = Color(0xFF4ECB71); // Green toggle/btn
  final Color toggleInactiveColor = Colors.white;
  final Color cardBg = Colors.white;
  final Color iconColor = Color(0xFF052C53);
  final Color fieldTextColor = Color(0xFF052C53);

  Future<void> _pickDate(BuildContext context, bool isReturn) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = initialDate.subtract(Duration(days: 365));
    DateTime lastDate = initialDate.add(Duration(days: 365));

    final chosen = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    setState(() {
      if (isReturn) {
        returnDate = chosen;
      } else {
        departDate = chosen;
      }
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );
    if (picked != null) {
      setState(() {
        departureTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text(
                  "Hello, Manjurul!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Where do you want to go?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isRoundTrip = true),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isRoundTrip ? toggleActiveColor : toggleInactiveColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Round Trip",
                              style: TextStyle(
                                color: isRoundTrip ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isRoundTrip = false),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: !isRoundTrip ? toggleActiveColor : toggleInactiveColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "One Way",
                              style: TextStyle(
                                color: !isRoundTrip ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          // Main card section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 440),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // From/To fields
                      TextFormField(
                        initialValue: fromLocation,
                        decoration: InputDecoration(
                          labelText: "From (Location)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFFF6F7FB),
                        ),
                        style: TextStyle(color: fieldTextColor, fontSize: 16),
                        readOnly: true,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        initialValue: toLocation,
                        decoration: InputDecoration(
                          labelText: "To (Destination)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFFF6F7FB),
                        ),
                        style: TextStyle(color: fieldTextColor, fontSize: 16),
                        readOnly: true,
                      ),
                      SizedBox(height: 18),
                      // Depart & Return
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(context, false),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: iconColor, size: 18),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Depart", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      SizedBox(height: 2),
                                      Text(
                                        "${departDate != null ? "${departDate!.day} ${_monthString(departDate!.month)} ${departDate!.year}" : 'Choose date'}",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(context, true),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: iconColor, size: 18),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Return", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      SizedBox(height: 2),
                                      Text(
                                        "${returnDate != null ? "${returnDate!.day} ${_monthString(returnDate!.month)} ${returnDate!.year}" : 'Choose date'}",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24),
                      // Time & Passenger
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: iconColor, size: 18),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Time", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      SizedBox(height: 2),
                                      Text(
                                        "${departureTime.format(context)}",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.person, color: iconColor, size: 18),
                                SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Passenger", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    SizedBox(height: 2),
                                    Text(
                                      passengerCount.toString().padLeft(2, "0"),
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24),
                      // Class
                      Row(
                        children: [
                          Icon(Icons.emoji_events_outlined, color: iconColor, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: travelClass,
                              decoration: InputDecoration(
                                labelText: "Class",
                                border: InputBorder.none,
                              ),
                              items: [
                                DropdownMenuItem(child: Text("Bussines"), value: "Bussines"),
                                DropdownMenuItem(child: Text("Economy"), value: "Economy"),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => travelClass = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: implement search logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: toggleActiveColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            "Search Train",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.4, fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, -2)),
        ]),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home, label: "Home", active: true),
            _NavItem(icon: Icons.receipt_long, label: "Tickets"),
            _NavItem(icon: Icons.person, label: "Profile"),
          ],
        ),
      ),
    );
  }

  String _monthString(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    Key? key, required this.icon, required this.label, this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Color(0xFF4ECB71) : Colors.grey[400], size: 28),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Color(0xFF4ECB71) : Colors.grey[500],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
