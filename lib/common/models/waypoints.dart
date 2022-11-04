import 'package:flutter/foundation.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:geocoding/geocoding.dart';

class Waypoint {
  Waypoint(this.latitude, this.longitude,
      {required this.address, this.isActivated = true});

  static Future<Waypoint> fromCoordinates(latitude, longitude,
      {isActivated}) async {
    late Placemark placemark;
    try {
      placemark = (await placemarkFromCoordinates(latitude, longitude)).first;
    } catch (e) {
      placemark = Placemark();
    }

    return Waypoint(latitude, longitude,
        address: placemark, isActivated: isActivated);
  }

  Waypoint copyWith({latitude, longitude, address, isActivated}) {
    isActivated = isActivated ?? this.isActivated;
    latitude = latitude ?? this.latitude;
    longitude = longitude ?? this.longitude;
    address = address ?? this.address;
    return Waypoint(latitude, longitude,
        address: address, isActivated: isActivated);
  }

  static Future<Waypoint> fromAddress(String address,
      {isActivated = true}) async {
    final locations = await locationFromAddress(address);
    var first = locations.first;
    return Waypoint.fromCoordinates(first.latitude, first.longitude,
        isActivated: isActivated);
  }

  static Future<Waypoint> fromLatLng(LatLng point, {isActivated = true}) async {
    return Waypoint.fromCoordinates(point.latitude, point.longitude,
        isActivated: isActivated);
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static Future<Waypoint> fromLngLat(LngLat point, {isActivated = true}) {
    return Waypoint.fromCoordinates(point.lat, point.lng,
        isActivated: isActivated);
  }

  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final bool isActivated;
  final double latitude;
  final double longitude;
  final Placemark address;

  @override
  String toString() =>
      "${address.street}\n${address.locality} ${address.postalCode}";
}

class Waypoints extends Iterator<Waypoint> with ChangeNotifier {
  Waypoints() : waypoints = [];

  static Future<Waypoints> fromLatLng(List<LatLng> points) async {
    final out = Waypoints();
    for (final waypoint in points) {
      out.waypoints.add(await Waypoint.fromLatLng(waypoint, isActivated: true));
    }
    return out;
  }

  List<LatLng> toLatLng({bool activeOnly = false}) {
    List<LatLng> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LatLng(waypoint.latitude, waypoint.longitude));
    }
    return out;
  }

  static Future<Waypoints> fromLngLat(List<LngLat> points) async {
    final out = Waypoints();

    for (final waypoint in points) {
      out.waypoints.add(await Waypoint.fromLngLat(waypoint, isActivated: true));
    }
    return out;
  }

  static fromLatLngToLngLat(List<LatLng> toConvert) {
    List<LngLat> out = [];
    for (final point in toConvert) {
      out.add(LngLat(lng: point.longitude, lat: point.latitude));
    }
    return out;
  }

  static fromLngLatToLatLng(List<LngLat> toConvert) {
    List<LatLng> out = [];
    for (final point in toConvert) {
      out.add(LatLng(point.lat, point.lng));
    }
    return out;
  }

  List<LngLat> toLngLat({bool activeOnly = false}) {
    List<LngLat> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LngLat(lng: waypoint.longitude, lat: waypoint.latitude));
    }
    return out;
  }

  LatLng get meanLatLng {
    double lat = 0;
    double long = 0;
    for (final waypoint in waypoints) {
      lat += waypoint.latitude;
      long += waypoint.longitude;
    }

    return LatLng(lat / waypoints.length, long / waypoints.length);
  }

  late final List<Waypoint> waypoints;
  void add(Waypoint point) {
    waypoints.add(point);
    notifyListeners();
  }

  Waypoint operator [](int item) => waypoints[item];
  void operator []=(int item, Waypoint val) {
    waypoints[item] = val;
    notifyListeners();
  }

  // Iterator implementation
  int _currentIndex = 0;
  int get length => waypoints.length;
  int get activeLength {
    int total = 0;
    for (final point in waypoints) {
      if (point.isActivated) total++;
    }
    return total;
  }

  bool get isEmpty => waypoints.isEmpty;
  bool get hasActivated {
    for (final point in waypoints) {
      if (point.isActivated) return true;
    }
    return false;
  }

  @override
  Waypoint get current => waypoints[_currentIndex];

  @override
  bool moveNext() {
    _currentIndex++;
    return _currentIndex < waypoints.length;
  }
}
