import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../pages/search_result_screen.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({Key? key}) : super(key: key);

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  DateTime selectedDate = DateTime.now();

  String? selectedFromStop;
  String? selectedToStop;

  bool isBusSelected = true;
  bool isMetroSelected = false;

  String transportType = '';

  int passengerCount = 1;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Widget _buildPassengerCounter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.teal[700]),
          const SizedBox(width: 8),
          const Text(
            'Passengers',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.teal),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.teal[700],
            onPressed: () {
              if (passengerCount > 1) {
                setState(() {
                  passengerCount--;
                });
              }
            },
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              passengerCount.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.add_circle_outline,color: (passengerCount==4)?Colors.grey:null,),
            color: Colors.teal[700],
            onPressed: () {
              if(passengerCount<4){
              setState(() {

                passengerCount++;
              });}
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField2<String>(
              hint: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    ' From ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
              value: selectedFromStop,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'From',
                labelStyle: TextStyle(color: Colors.teal[900], fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.only(left: 0, right: 20, top: 8, bottom: 8),
              ),
              isExpanded: true,
              items: routeProvider.allStops.map((allStops) {
                return DropdownMenuItem<String>(
                  value: allStops['name'].toString(),
                  child: Text(allStops['name'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedFromStop = value),
              buttonStyleData: ButtonStyleData(height: 50, padding: EdgeInsets.zero, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white)),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 280,
                offset: const Offset(0, -10),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
              ),
              menuItemStyleData: const MenuItemStyleData(height: 48, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
              iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal.shade700, size: 26)),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField2<String>(
              hint: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    ' To ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
              value: selectedToStop,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'To',
                labelStyle: TextStyle(color: Colors.teal[900], fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.only(left: 0, right: 20, top: 8, bottom: 8),
              ),
              isExpanded: true,
              items: routeProvider.allStops.map((allStops) {
                return DropdownMenuItem<String>(
                  value: allStops['name'].toString(),
                  child: Text(allStops['name'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedToStop = value),
              buttonStyleData: ButtonStyleData(height: 50, padding: EdgeInsets.zero, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white)),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 280,
                offset: const Offset(0, -10),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
              ),
              menuItemStyleData: const MenuItemStyleData(height: 48, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
              iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal.shade700, size: 26)),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: Offset(0, 4))],
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 22, color: Colors.teal.shade700),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                      style: TextStyle(color: Colors.teal[900], fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down_rounded, size: 28, color: Colors.teal.shade700),
                  ],
                ),
              ),
            ),


            _buildPassengerCounter(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    isBusSelected = true;
                    isMetroSelected = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: isBusSelected ? const Color(0xFF165E5A) : Colors.white,
                      border: Border.all(color: const Color(0xFF165E5A)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus, color: isBusSelected ? Colors.white : const Color(0xFF165E5A)),
                        const SizedBox(width: 8),
                        Text('Bus', style: TextStyle(color: isBusSelected ? Colors.white : const Color(0xFF165E5A), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => setState(() {
                    isMetroSelected = true;
                    isBusSelected = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMetroSelected ? const Color(0xFF165E5A) : Colors.white,
                      border: Border.all(color: const Color(0xFF165E5A)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_subway, color: isMetroSelected ? Colors.white : const Color(0xFF165E5A)),
                        const SizedBox(width: 8),
                        Text('Metro', style: TextStyle(color: isMetroSelected ? Colors.white : const Color(0xFF165E5A), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final routeProvider = Provider.of<RouteProvider>(context, listen: false);

                  if ((selectedFromStop == null && selectedToStop == null) ||
                      (selectedFromStop != null && selectedToStop != null && selectedFromStop == selectedToStop) ||
                      (!isBusSelected && !isMetroSelected)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields correctly')),
                    );
                    return;
                  }

                  if (isBusSelected) transportType = 'PMPML';
                  if (isMetroSelected) transportType = 'METRO';

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    await routeProvider.fetchStopsForRoute(
                      from: selectedFromStop ?? '',
                      to: selectedToStop ?? '',
                      transportType: transportType,
                      journeyDate: selectedDate.toString(),
                      passengers: passengerCount.toString()
                    ).then((value) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchResultsScreen(passengerCount)),
                      );
                    });
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Search failed: $error')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF165E5A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'SEARCH',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
