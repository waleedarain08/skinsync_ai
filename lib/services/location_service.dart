import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import '../exceptions/app_exception.dart';
import '../models/responses/address_data.dart';
import '../models/responses/geocoding_response.dart';
import '../models/responses/map_clinics_response.dart'
    hide Location;

class LocationService {
  static LocationService? _instance;

  factory LocationService() {
    return _instance ??= LocationService._();
  }

  LocationService._();

  static const String _apiKey = 'AIzaSyDCkkGnM5MsciCvDYI7A_70Px-UiM3Ir8Q';
  static const String _url =
      'https://maps.googleapis.com/maps/api/geocode/json';

  // Future<AddressData?> fetchAddress() async {
  //   final service = Location();
  //   final permission = await service.requestPermission();
  //   if (permission != PermissionStatus.granted) {
  //     throw const AppException('Location permission denied!');
  //   }
  //   final granted = await service.requestService();
  //   if (!granted) {
  //     throw const AppException('Location service denied!');
  //   }
  //   final data = await service.getLocation();
  //   if (data.latitude == null || data.longitude == null) {
  //     throw const AppException('Could not fetch location!');
  //   }
  //   final address = await getAddressFromLatLng(data.latitude!, data.longitude!);
  //   return AddressData(
  //     latLng: LatLng(data.latitude!, data.longitude!),
  //     address: address,
  //   );
  // }

  Future<AddressData?> fetchAddress() async {
    // final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   throw const AppException('Location service denied!');
    // }

    // Check/request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const AppException('Location permission denied!');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const AppException('Location permission denied!');
    }

    // Fetch position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final address = await getAddressFromLatLng(position.latitude, position.longitude);
    return AddressData(
      latLng: LatLng(position.latitude, position.longitude),
      address: address,
    );
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    final url = '$_url?latlng=$latitude,$longitude&key=$_apiKey';
    log('URL: $url');
    final response = await get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw const AppException('Could not fetch address!');
    }
    final data = GeocodingResponse.fromJson(jsonDecode(response.body));
    if (data.results?.isEmpty ?? true) {
      throw const AppException('No address found!');
    }
    return data.results!.first.formattedAddress!;
  }

Future<List<Place>> fetchNearbyClinics({
  required LatLng location,
  String? search,
}) async {
  final uri = Uri.parse('https://places.googleapis.com/v1/places:searchText');
  final trimmedSearch = search?.trim() ?? '';
  final body = {
    // Fold the user's search text into the query so results are
    // relevant to what they typed, while still biasing to MedSpa/clinic
    // results when the search is empty or unrelated.
    'textQuery': trimmedSearch.isEmpty
        ? 'MedSpa Clinic'
        : '$trimmedSearch MedSpa Clinic',
    'maxResultCount': 100,
    'locationBias': {
      'circle': {
        'center': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'radius': 1000,
      },
    },
  };
  final headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': _apiKey,
    'X-Goog-FieldMask': '*',
  };
  final response = await post(uri, body: jsonEncode(body), headers: headers);
  final jsonString = response.body;
  log('JSON: $jsonString');
  return MapClinicsResponse.fromJson(jsonDecode(jsonString)).places ?? [];
}

}
