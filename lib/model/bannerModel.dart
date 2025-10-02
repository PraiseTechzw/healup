import 'package:flutter/material.dart';

class BannerModel {
  String text;
  String image;
  List<Color> cardBackground;

  BannerModel(this.text, this.image, this.cardBackground);
}

List<BannerModel> bannerCards = [
  new BannerModel("Check Disease", "assets/414.jpg", [
    Colors.lightBlue[100]!,
    Colors.lightBlue[200]!,
  ]),
  new BannerModel("Covid-19", "assets/covid.jpg", [
    Colors.red[100]!,
    Colors.red[200]!,
  ]),
  new BannerModel("Appointment", "assets/appointment.jpg", [
    Colors.green[100]!,
    Colors.green[200]!,
  ]),
];
