import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healup/models/user_model.dart';
import 'package:healup/services/database_service.dart';
import 'package:healup/screens/profile_edit_screen.dart';
import 'package:healup/screens/medical_info_screen.dart';
import 'package:healup/screens/userSettings.dart';
import 'package:healup/firestore-data/appointmentHistoryList.dart';

class EnhancedUserProfile extends StatefulWidget {
  const EnhancedUserProfile({Key? key}) : super(key: key);

  @override
  _EnhancedUserProfileState createState() => _EnhancedUserProfileState();
}

class _EnhancedUserProfileState extends State<EnhancedUserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: user == null
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder<UserModel?>(
                stream: DatabaseService.getUserStream(user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading profile',
                            style: GoogleFonts.lato(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  final userModel = snapshot.data;
                  if (userModel == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No profile data found',
                            style: GoogleFonts.lato(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      _buildAppBar(userModel),
                      _buildProfileHeader(userModel),
                      _buildQuickStats(userModel),
                      _buildProfileSections(userModel),
                      _buildAppointmentHistory(),
                      SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAppBar(UserModel userModel) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.indigo[600],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profile',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo[600]!, Colors.indigo[400]!],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserSettings()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileEditScreen(userModel: userModel),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel userModel) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: userModel.profileImage != null
                      ? (userModel.profileImage!.startsWith('assets/')
                            ? AssetImage(userModel.profileImage!)
                            : CachedNetworkImageProvider(
                                userModel.profileImage!,
                              ))
                      : null,
                  child: userModel.profileImage == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileEditScreen(userModel: userModel),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              userModel.name,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (userModel.bio != null && userModel.bio!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                userModel.bio!,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  icon: Icons.email,
                  label: 'Email',
                  value: userModel.email,
                  color: Colors.blue,
                ),
                _buildInfoChip(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: userModel.phone ?? 'Not added',
                  color: Colors.green,
                ),
                _buildInfoChip(
                  icon: Icons.location_city,
                  label: 'City',
                  value: userModel.city ?? 'Not added',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value.length > 15 ? '${value.substring(0, 15)}...' : value,
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(UserModel userModel) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: FontAwesomeIcons.calendarCheck,
                    title: 'Appointments',
                    value: '12',
                    subtitle: 'This month',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: FontAwesomeIcons.heartPulse,
                    title: 'Health Score',
                    value: '85%',
                    subtitle: 'Good',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: FontAwesomeIcons.pills,
                    title: 'Medications',
                    value: '${userModel.medications.length}',
                    subtitle: 'Active',
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: FontAwesomeIcons.exclamationTriangle,
                    title: 'Allergies',
                    value: '${userModel.allergies.length}',
                    subtitle: 'Known',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections(UserModel userModel) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              icon: FontAwesomeIcons.userMd,
              title: 'Medical Information',
              subtitle: 'Allergies, conditions, medications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MedicalInfoScreen(userModel: userModel),
                  ),
                );
              },
              color: Colors.purple,
            ),
            SizedBox(height: 12),
            _buildSectionCard(
              icon: FontAwesomeIcons.bell,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              color: Colors.blue,
            ),
            SizedBox(height: 12),
            _buildSectionCard(
              icon: FontAwesomeIcons.shield,
              title: 'Privacy & Security',
              subtitle: 'Account security and privacy settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettings()),
                );
              },
              color: Colors.green,
            ),
            SizedBox(height: 12),
            _buildSectionCard(
              icon: FontAwesomeIcons.questionCircle,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                Navigator.pushNamed(context, '/help');
              },
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
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
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHistory() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Appointments',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/MyAppointments');
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.lato(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(height: 200, child: AppointmentHistoryList()),
          ],
        ),
      ),
    );
  }
}
