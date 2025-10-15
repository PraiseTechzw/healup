import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebaseAuth.dart';

class Skip extends StatefulWidget {
  @override
  _SkipState createState() => _SkipState();
}

class _SkipState extends State<Skip> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<PageViewModel> getpages() {
    return [
      PageViewModel(
        title: '',
        image: Container(
          height: 300,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[50]!, Colors.indigo[100]!],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/doc.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesomeIcons.stethoscope,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        bodyWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Find Your Perfect Doctor',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Search and book appointments with verified doctors in your area',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip('Verified Doctors', FontAwesomeIcons.shield),
                SizedBox(width: 12),
                _buildFeatureChip('Easy Booking', FontAwesomeIcons.calendar),
              ],
            ),
          ],
        ),
      ),
      PageViewModel(
        title: '',
        image: Container(
          height: 300,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green[50]!, Colors.teal[100]!],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/disease.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesomeIcons.heartPulse,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        bodyWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Health Information at Your Fingertips',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Get detailed information about diseases, symptoms, and treatments',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip('Disease Info', FontAwesomeIcons.book),
                SizedBox(width: 12),
                _buildFeatureChip('Health Tips', FontAwesomeIcons.lightbulb),
              ],
            ),
          ],
        ),
      ),
      PageViewModel(
        title: '',
        image: Container(
          height: 300,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple[50]!, Colors.pink[100]!],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/appointment.jpg',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesomeIcons.clock,
                    color: Colors.purple[600],
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        bodyWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Manage Your Health Journey',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Track appointments, get reminders, and maintain your health records',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip(
                  'Appointments',
                  FontAwesomeIcons.calendarCheck,
                ),
                SizedBox(width: 12),
                _buildFeatureChip('Reminders', FontAwesomeIcons.bell),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildFeatureChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue[50]!],
          ),
        ),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: getpages(),
          showNextButton: true,
          showSkipButton: true,
          skip: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          next: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Next',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          done: Text(
            'Get Started',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.indigo[700],
            ),
          ),
          dotsDecorator: DotsDecorator(
            size: Size(10, 10),
            color: Colors.grey[300]!,
            activeSize: Size(22, 10),
            activeColor: Colors.blue[600]!,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onDone: () => _showLoginOptions(context),
          onSkip: () => _showLoginOptions(context),
        ),
      ),
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _showLoginOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Choose Your Login Type',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select how you want to access HealUp',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),
                _buildLoginOption(
                  context,
                  'Patient Login',
                  'Book appointments and manage your health',
                  FontAwesomeIcons.user,
                  Colors.blue,
                  () => _pushPage(context, FireBaseAuth()),
                ),
                SizedBox(height: 16),
                _buildLoginOption(
                  context,
                  'Doctor Login',
                  'Manage your practice and patients',
                  FontAwesomeIcons.userDoctor,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/doctor-login'),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(FontAwesomeIcons.chevronRight, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
