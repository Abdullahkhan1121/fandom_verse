import 'package:flutter/material.dart';

/// One place for the "who we are / how to reach us" details.
/// Both AboutScreen and ContactScreen read from here, so you only edit
/// the details once. Replace every placeholder with your real information.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.bio,
    this.icon = Icons.person_rounded,
  });

  final String name;
  final String role;
  final String bio;
  final IconData icon;
}

class OfficeLocation {
  const OfficeLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.latitude,
    required this.longitude,
  });

  final String name;

  /// Also used as the Google Maps search text, so make it a real address.
  final String address;
  final String phone;
  final String hours;

  /// Coordinates for the embedded map marker. Look these up once (right
  /// click the spot on Google Maps -> the two numbers shown) and hardcode
  /// them here; office locations don't move at runtime.
  final double latitude;
  final double longitude;
}

class AppInfo {
  AppInfo._();

  static const String appName = 'Fandom Verse';
  static const String fullName = 'Fandom Verse Pocket Edition';
  static const String tagline = 'Fandom Trivia on the Go';
  static const String version = '1.0.0';

  static const String mission =
      'Fandom content is scattered across social media, websites and forums. '
      'Fandom Verse brings it together in one place: fandom guides, events '
      'near you, official merchandise and an AI helper, all in your pocket.';

  // TODO: replace with your real contact details.
  static const String contactEmail = 'whizz0027@gmail.com';
  static const String contactPhone = '+92 3368574492';

  // TODO: replace with your real team.
  static const List<TeamMember> team = [
    TeamMember(
      name: 'Abdullah',
      role: 'Lead Developer',
      bio: 'Designed and built the app, from the Flutter screens to the '
          'Firebase backend.',
      icon: Icons.code_rounded,
    ),
    TeamMember(
      name: 'Muhammad Abdullah Rao',
      role: 'UI / UX Designer',
      bio: 'Shaped the look and feel of the app.',
      icon: Icons.palette_rounded,
    ),
    TeamMember(
      name: 'Amna',
      role: 'Content and Testing',
      bio: 'Curated fandom content and tested every feature.',
      icon: Icons.fact_check_rounded,
    ),TeamMember(
      name: 'Abdul Wasay Siddiqui',
      role: 'Content and Testing',
      bio: 'Curated fandom content and tested every feature.',
      icon: Icons.fact_check_rounded,
    ),
  ];

  // TODO: replace with your real office location(s).
  static const List<OfficeLocation> offices = [
    OfficeLocation(
      name: 'Head Office',
      address: 'Aptech Learning, Karachi, Pakistan',
      phone: '+92 3368574492',
      hours: 'Mon - Fri, 9:00 AM - 6:00 PM',
      // TODO: replace with the real coordinates of this office.
      latitude: 24.8607,
      longitude: 67.0011,
    ),
  ];

  static const List<String> techStack = [
    'Flutter',
    'Dart',
    'Firebase Auth',
    'Cloud Firestore',
    'Google Maps',
  ];
}