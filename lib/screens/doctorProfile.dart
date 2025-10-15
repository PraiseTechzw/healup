import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healup/screens/bookingScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  final String doctor;

  const DoctorProfile({Key? key, required this.doctor}) : super(key: key);
  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  _launchCaller(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        text,
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .orderBy('name')
              .startAt([widget.doctor])
              .endAt([widget.doctor + '\uf8ff'])
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No doctors found'));
            }
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: ListView.builder(
                itemCount: snapshot.data!.size,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5),
                          child: IconButton(
                            icon: Icon(
                              Icons.chevron_left_sharp,
                              color: Colors.indigo,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: NetworkImage(document['image']),
                          //backgroundColor: Colors.lightBlue[100],
                          radius: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          document['name'],
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          document['type'],
                          style: GoogleFonts.lato(
                            //fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final double rating = (document['rating'] is int)
                                ? (document['rating'] as int).toDouble()
                                : (document['rating'] as num?)?.toDouble() ??
                                      0.0;
                            final int fullStars = rating.floor().clamp(0, 5);
                            final bool hasHalfStar =
                                (rating - fullStars) >= 0.5 && fullStars < 5;
                            final int emptyStars =
                                5 - fullStars - (hasHalfStar ? 1 : 0);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < fullStars; i++)
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.indigoAccent,
                                    size: 22,
                                  ),
                                if (hasHalfStar)
                                  Icon(
                                    Icons.star_half_rounded,
                                    color: Colors.indigoAccent,
                                    size: 22,
                                  ),
                                for (var i = 0; i < emptyStars; i++)
                                  Icon(
                                    Icons.star_outline_rounded,
                                    color: Colors.black26,
                                    size: 22,
                                  ),
                                SizedBox(width: 6),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.only(left: 22, right: 22),
                          alignment: Alignment.center,
                          child: Text(
                            (() {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final spec = data['specialization'];
                              if (spec is String && spec.isNotEmpty) {
                                return spec;
                              }
                              final specs = data['specializations'];
                              if (specs is List && specs.isNotEmpty) {
                                return specs.join(', ');
                              }
                              return '';
                            })(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 15),
                              Icon(Icons.place_outlined),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      document['address'],
                                      style: GoogleFonts.lato(fontSize: 16),
                                    ),
                                    SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final encoded = Uri.encodeComponent(
                                          document['address'],
                                        );
                                        final url =
                                            'https://www.google.com/maps/search/?api=1&query=$encoded';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions,
                                            color: Colors.indigo,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Get directions',
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 12,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(FontAwesomeIcons.phone),
                              SizedBox(width: 11),
                              TextButton(
                                onPressed: () =>
                                    _launchCaller("tel:" + document['phone']),
                                child: Text(
                                  document['phone'].toString(),
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 12,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(Icons.email_outlined),
                              SizedBox(width: 11),
                              TextButton(
                                onPressed: () => _openUrl(
                                  "mailto:" + (document['email'] ?? ''),
                                ),
                                child: Text(
                                  (document['email'] ?? '').toString(),
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 0),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(Icons.access_time_rounded),
                              SizedBox(width: 20),
                              Text(
                                'Working Hours',
                                style: GoogleFonts.lato(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.only(left: 60),
                          child: Row(
                            children: [
                              Text(
                                'Today: ',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                document['openHour'] +
                                    " - " +
                                    document['closeHour'],
                                style: GoogleFonts.lato(fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        _sectionTitle('Languages'),
                        SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final langs = (data['languages'] is List)
                                  ? List<String>.from(data['languages'])
                                  : <String>[];
                              if (langs.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: langs
                                    .map(
                                      (l) => Chip(
                                        label: Text(l),
                                        backgroundColor: Colors.indigo
                                            .withOpacity(0.08),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Experience & Education'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final experience = data['experience'];
                              final education = data['education'] ?? '';
                              final graduationYear = data['graduationYear'];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (experience != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '${experience} years experience',
                                          style: GoogleFonts.lato(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  if (education is String &&
                                      education.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            education,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (graduationYear != null) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Graduated $graduationYear',
                                          style: GoogleFonts.lato(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Clinic'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final clinicName = data['clinicName'] ?? '';
                              final clinicAddress = data['clinicAddress'] ?? '';
                              final clinicPhone = data['clinicPhone'] ?? '';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (clinicName.toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_hospital_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            clinicName,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (clinicAddress.toString().isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.place_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            clinicAddress,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (clinicPhone.toString().isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_outlined,
                                          size: 18,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () =>
                                              _launchCaller('tel:$clinicPhone'),
                                          child: Text(
                                            clinicPhone,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Specializations'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final specs = (data['specializations'] is List)
                                  ? List<String>.from(data['specializations'])
                                  : <String>[];
                              final single = data['specialization'];
                              final items = specs.isNotEmpty
                                  ? specs
                                  : (single is String && single.isNotEmpty
                                        ? [single]
                                        : <String>[]);
                              if (items.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: items
                                    .map(
                                      (s) => Chip(
                                        label: Text(s),
                                        backgroundColor: Colors.indigo
                                            .withOpacity(0.08),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Consultation Fees'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final feesRaw =
                                  (data['consultationFees'] ?? {}) as Map;
                              if (feesRaw.isEmpty) {
                                final fee = data['consultationFee'];
                                if (fee != null) {
                                  return Text(
                                    'Standard: \'$fee\'',
                                    style: GoogleFonts.lato(fontSize: 15),
                                  );
                                }
                                return Text('-', style: GoogleFonts.lato());
                              }
                              final entries = feesRaw.entries.toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: entries
                                    .map<Widget>(
                                      (e) => Padding(
                                        padding: EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.payments_outlined,
                                              size: 18,
                                              color: Colors.indigo,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '${e.key}: ${e.value}',
                                              style: GoogleFonts.lato(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Services'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final services = (data['services'] is List)
                                  ? List<String>.from(data['services'])
                                  : <String>[];
                              if (services.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: services
                                    .map(
                                      (s) => Chip(
                                        label: Text(s),
                                        backgroundColor: Colors.indigo
                                            .withOpacity(0.08),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Certifications'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final certs = (data['certifications'] is List)
                                  ? List<String>.from(data['certifications'])
                                  : <String>[];
                              if (certs.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: certs
                                    .map(
                                      (c) => Padding(
                                        padding: EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.verified_outlined,
                                              size: 18,
                                              color: Colors.indigo,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                c,
                                                style: GoogleFonts.lato(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('About'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final bio =
                                  (data['bio'] ?? data['description'] ?? '')
                                      .toString();
                              if (bio.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              return Text(
                                bio,
                                style: GoogleFonts.lato(fontSize: 15),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Status'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final isVerified =
                                  (data['isVerified'] ?? false) == true;
                              final available =
                                  (data['isAvailable'] ?? true) == true;
                              final workingDays = (data['workingDays'] is List)
                                  ? List<String>.from(data['workingDays'])
                                  : <String>[];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isVerified
                                            ? Icons.verified
                                            : Icons.verified_outlined,
                                        color: isVerified
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        isVerified
                                            ? 'Verified'
                                            : 'Not verified',
                                        style: GoogleFonts.lato(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        available
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        color: available
                                            ? Colors.green
                                            : Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        available ? 'Available' : 'Unavailable',
                                        style: GoogleFonts.lato(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  if (workingDays.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: workingDays
                                          .map(
                                            (d) => Chip(
                                              label: Text(d),
                                              backgroundColor: Colors.indigo
                                                  .withOpacity(0.08),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        _sectionTitle('Social'),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Builder(
                            builder: (_) {
                              final data =
                                  document.data() as Map<String, dynamic>;
                              final social = (data['socialMedia'] is Map)
                                  ? Map<String, dynamic>.from(
                                      data['socialMedia'],
                                    )
                                  : <String, dynamic>{};
                              if (social.isEmpty)
                                return Text('-', style: GoogleFonts.lato());
                              final entries = social.entries.toList();
                              return Column(
                                children: entries
                                    .map(
                                      (e) => ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.link,
                                          color: Colors.indigo,
                                        ),
                                        title: Text(
                                          e.key,
                                          style: GoogleFonts.lato(fontSize: 15),
                                        ),
                                        subtitle: Text(
                                          e.value.toString(),
                                          style: GoogleFonts.lato(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        onTap: () =>
                                            _openUrl(e.value.toString()),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.indigo.withOpacity(0.9),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    doctor: document['name'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Book an Appointment',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
