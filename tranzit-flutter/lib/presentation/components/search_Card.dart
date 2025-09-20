import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../infrastructure/models/route.model.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../pages/search_result_screen.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({Key? key}) : super(key: key);

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  DateTime selectedDate = DateTime.now();
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

  String? selectedFromStop;
  String? selectedToStop;

  bool isBusSelected = true;
  bool isMetroSelected = false;

  String transportType='' ;

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
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.teal[900]),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                      style: TextStyle(
                        color: Colors.teal[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.edit_calendar, size: 18, color: Colors.teal[900]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              isExpanded: true,
              value: selectedFromStop,
              items: routeProvider.allStops.map((allStops) {
                return DropdownMenuItem<String>(
                  value: allStops['name'].toString(),
                  child: Text(allStops['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFromStop = value;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 250, // 👈 limits dropdown height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                offset: const Offset(0, -2), // 👈 small tweak to align just below
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),


            const SizedBox(height: 16),

            DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              isExpanded: true,
              value: selectedToStop,
              items: routeProvider.allStops.map((allStops) {
                return DropdownMenuItem<String>(
                  value: allStops['name'].toString(),
                  child: Text(allStops['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedToStop = value;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 250, // 👈 limits dropdown height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                offset: const Offset(0, -2), // 👈 small tweak to align just below
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),

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
                        Icon(Icons.directions_bus,
                            color: isBusSelected ? Colors.white : const Color(0xFF165E5A)),
                        const SizedBox(width: 8),
                        Text(
                          'Bus',
                          style: TextStyle(
                            color: isBusSelected ? Colors.white : const Color(0xFF165E5A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                        Icon(Icons.directions_subway,
                            color: isMetroSelected ? Colors.white : const Color(0xFF165E5A)),
                        const SizedBox(width: 8),
                        Text(
                          'Metro',
                          style: TextStyle(
                            color: isMetroSelected ? Colors.white : const Color(0xFF165E5A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                onPressed: () async  {
                    if ((selectedFromStop == null && selectedToStop == null) ||
                        (selectedFromStop != null && selectedToStop != null && selectedFromStop == selectedToStop) ||
                        (!isBusSelected && !isMetroSelected)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields correctly')),
                      );
                      return;
                    }


                    if (isBusSelected) transportType ='MTC';
                    if (isMetroSelected) transportType='METRO';


                    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

                    try {
                     await routeProvider.fetchStopsForRoute(
                        from: selectedFromStop ?? '',
                        to: selectedToStop ?? '',
                        transportType: transportType,
                      ).then((value) => Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => SearchResultsScreen()),
                     ));

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'SEARCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}