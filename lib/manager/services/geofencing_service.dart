import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeofencingService {
  // Coordinates for allowed cities
  static final Map<String, Map<String, double>> _allowedCities = {
    'Ghaziabad': {
      'latitude': 28.6692,
      'longitude': 77.4538,
      'radius': 15000, // 15km radius
    },
    'Noida': {
      'latitude': 28.5355,
      'longitude': 77.3910,
      'radius': 20000, // 20km radius
    },
    'Delhi': {
      'latitude': 28.6139,
      'longitude': 77.2090,
      'radius': 25000, // 25km radius
    },
  };

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<PermissionStatus> checkPermissions() async {
    return await Permission.location.status;
  }

  // Request location permissions
  Future<PermissionStatus> requestPermissions() async {
    return await Permission.location.request();
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Check if current location is within allowed cities
  Future<Map<String, dynamic>> checkAllowedLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'allowed': false,
          'message':
              'Location services are disabled. Please enable them to login.',
          'city': null,
        };
      }

      // Check permissions
      PermissionStatus permission = await checkPermissions();
      if (permission == PermissionStatus.denied) {
        permission = await requestPermissions();
        if (permission == PermissionStatus.denied) {
          return {
            'allowed': false,
            'message':
                'Location permissions are denied. Please allow location access to login.',
            'city': null,
          };
        }
      }

      if (permission == PermissionStatus.permanentlyDenied) {
        return {
          'allowed': false,
          'message':
              'Location permissions are permanently denied. Please enable them in app settings.',
          'city': null,
        };
      }

      // Get current position
      Position position = await getCurrentPosition();

      // Check if within any allowed city
      for (var city in _allowedCities.entries) {
        double distance = _calculateDistance(
          position.latitude,
          position.longitude,
          city.value['latitude']!,
          city.value['longitude']!,
        );

        if (distance <= city.value['radius']!) {
          return {
            'allowed': true,
            'message': 'Location verified. You are in ${city.key}',
            'city': city.key,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'distance': distance,
          };
        }
      }

      // Find nearest allowed city
      String nearestCity = _findNearestCity(
        position.latitude,
        position.longitude,
      );

      return {
        'allowed': false,
        'message':
            'Login only allowed from Ghaziabad, Noida, or Delhi. You are currently outside allowed areas. Nearest allowed city: $nearestCity',
        'city': null,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'nearest_city': nearestCity,
      };
    } catch (e) {
      return {
        'allowed': false,
        'message': 'Error getting location: ${e.toString()}',
        'city': null,
      };
    }
  }

  // Calculate distance between two coordinates in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Find nearest allowed city
  String _findNearestCity(double latitude, double longitude) {
    String nearestCity = '';
    double minDistance = double.maxFinite;

    for (var city in _allowedCities.entries) {
      double distance = _calculateDistance(
        latitude,
        longitude,
        city.value['latitude']!,
        city.value['longitude']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city.key;
      }
    }

    return nearestCity;
  }

  // Get list of allowed cities
  static List<String> getAllowedCities() {
    return _allowedCities.keys.toList();
  }

  // Check if a specific coordinate is within allowed areas
  bool isCoordinateInAllowedArea(double latitude, double longitude) {
    for (var city in _allowedCities.entries) {
      double distance = _calculateDistance(
        latitude,
        longitude,
        city.value['latitude']!,
        city.value['longitude']!,
      );

      if (distance <= city.value['radius']!) {
        return true;
      }
    }
    return false;
  }

  // Open app settings for permission management
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
