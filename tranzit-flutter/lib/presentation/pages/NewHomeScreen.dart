import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/profile.provider.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/route.provider.dart';
import 'package:tranzit/infrastructure/providers/speech.provider.dart';
import 'package:tranzit/infrastructure/services/chat.service.dart';
import 'package:tranzit/presentation/components/speech_input_model.dart';
import 'package:tranzit/presentation/pages/booking_history_page.dart';
import 'package:tranzit/presentation/pages/login_screen.dart';

import '../components/popular_route_card.dart';
import '../components/search_Card.dart';

class NewHomeScreen extends StatefulWidget {
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    Future.microtask(() {
      context.read<RouteProvider>().getAllStops();
      if (userId != null) {
        context.read<CreateProfileProvider>().getUserName(userId);
      }
    });
  }



  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    return token;
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _showSpeechInput() {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SpeechInputModal(
        onSpeechResult: (String speechText) {
          print('Speech Query: $speechText');

          _handleVoiceQuery(speechText);
        },
      ),
    );
  }

  void _handleVoiceQuery(String query)async {
    final speechProvider = context.read<SpeechProvider>();
    final token = await getFCMToken();
    await speechProvider.postSpeechForProcessing(query,token.toString());
  }

  @override
  Widget build(BuildContext context) {


    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> _pages = [
      _buildHomePage(screenHeight),
      BookingHistory(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: _showSpeechInput,
        backgroundColor: const Color(0xFF0E4546),
        child: const Icon(Icons.mic, size: 28,color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0E4546),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.confirmation_number, 1),
              label: 'My Tickets',
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0E4546).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF0E4546) : Colors.grey,
      ),
    );
  }

  Widget _buildHomePage(double screenHeight) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: screenHeight * 0.20,
          color: const Color(0xff004751),
          padding: EdgeInsets.only(left: 20, right: 20, top: screenHeight * 0.07),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hi Welcome,',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Consumer<CreateProfileProvider>(
                    builder: (context, profileProvider, child) {
                      final username = profileProvider.userName ?? "User";
                      return Text(
                        username,
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    },
                  )
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => LoginSignupScreen()),
                          (route) => false);
                },
                child: const Icon(Icons.logout, size: 28, color: Colors.white),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                const SizedBox(height: 20),

                SearchCard(),
                PopularRoutesSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
