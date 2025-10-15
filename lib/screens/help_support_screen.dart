import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FAQs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          ExpansionTile(
            title: const Text('How do I book an appointment?'),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: const [
              Text(
                'Open a doctor profile and tap "Book an Appointment", then select a time.',
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I manage notifications?'),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: const [
              Text(
                'Go to Profile → Notifications to view and manage your alerts.',
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I update my profile?'),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: const [
              Text(
                'Go to Profile → Edit Profile, update fields and save your changes.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                    color: Colors.indigo,
                  ),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@healup.app'),
                  onTap: () => _openUrl('mailto:support@healup.app'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.phone_outlined,
                    color: Colors.indigo,
                  ),
                  title: const Text('Call Support'),
                  subtitle: const Text('+263 77 000 0000'),
                  onTap: () => _openUrl('tel:+263770000000'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.indigo),
                  title: const Text('Visit Help Center'),
                  subtitle: const Text('healup.app/help'),
                  onTap: () => _openUrl('https://healup.app/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'We’re here to help. Reach out anytime!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
