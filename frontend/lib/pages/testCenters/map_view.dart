import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/testCenters/component/map_view_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  TextEditingController _searchController = TextEditingController();
  List _places = [];
  final String? backendUrl = dotenv.env['BACKEND_URL'];
  final String? geocodingApiKey = dotenv.env['GEOCODING_API_KEY'];
  String _selectedType = 'hospital'; // Default to clinics
  Position? _currentPosition;
  String _selectedKeyword = '';

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _searchAndDisplay() async {
    var address = _searchController.text;
    if (address.isEmpty) {
     address = 'Bang Mot';
      _searchController.text = address;
    }

    try {
      List<Map<String, dynamic>> locations =
          await _getGeocodingResults(address);

      if (locations.isEmpty) {
        throw Exception('No locations found for the address.');
      }

      var location = locations.first;
      List places = await fetchNearbyPlacesFromBackend(
          location['lat'], location['lng'], _selectedType, _selectedKeyword);
      setState(() {
        _places = places;
      });
    } catch (e) {
      print('Error in geocoding or fetching places: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getGeocodingResults(
      String address) async {
    if (geocodingApiKey == null) {
      throw Exception('Geocoding API key is not set');
    }

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$geocodingApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['results'] as List)
              .map((result) =>
                  result['geometry']['location'] as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception('Geocoding API error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch geocoding results');
      }
    } catch (e) {
      print('Error fetching geocoding results: $e');
      throw Exception('Failed to fetch geocoding results');
    }
  }

  Future<List> fetchNearbyPlacesFromBackend(double lat, double lng, String type, String keyword) async {
    if (backendUrl == null) {
      throw Exception('Backend URL is not set');
    }

    final String url = '$backendUrl/map/getNearbyPlaces';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': lat,
          'longitude': lng,
          'type': type,
          'keyword': keyword,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Null response data');
        }
        return data;
      } else {
        throw Exception('Failed to load places from backend');
      }
    } catch (e) {
      print('Error fetching places from backend: $e');
      throw Exception('Failed to load places from backend');
    }
  }

  String _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // distance in km
    return '${distance.toStringAsFixed(1)} km';
  }

  bool _isOpen(Map? openingHours) {
    if (openingHours == null) return false;
    if (openingHours['open_now'] == true) return true;

    DateTime now = DateTime.now();
    int day = now.weekday % 7;
    String nowStr = now.hour.toString().padLeft(2, '0') + now.minute.toString().padLeft(2, '0');

    for (var period in openingHours['periods']) {
      if (period['open']['day'] == day) {
        String openTime = period['open']['time'];
        String closeTime = period['close']['time'];
        if (nowStr.compareTo(openTime) >= 0 && nowStr.compareTo(closeTime) <= 0) {
          return true;
        }
      }
    }
    return false;
  }

  String _nextOpenHours(Map? openingHours) {
    if (openingHours == null) return 'No hours available';
    if (openingHours['open_now'] == true) return 'Open 24 hours';

    DateTime now = DateTime.now();
    int day = now.weekday % 7;

    for (int i = 0; i < 7; i++) {
      int nextDay = (day + i) % 7;
      for (var period in openingHours['periods']) {
        if (period['open']['day'] == nextDay) {
          String openTime = period['open']['time'];
          String formattedTime = '${openTime.substring(0, 2)}:${openTime.substring(2)}';
          String dayStr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][nextDay];
          return '$formattedTime $dayStr';
        }
      }
    }
    return 'No upcoming open hours';
  }

  void _updateType(String type, String keyword) {
    setState(() {
      _selectedType = type;
      _selectedKeyword = keyword;
      _searchAndDisplay(); // Refresh search results based on the new type
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: MapViewBody(
        searchController: _searchController,
        searchAndDisplay: _searchAndDisplay,
        updateType: _updateType,
        places: _places,
        calculateDistance: _calculateDistance,
        isOpen: _isOpen,
        nextOpenHours: _nextOpenHours,
        userLat: _currentPosition?.latitude ?? 0.0,
        userLng: _currentPosition?.longitude ?? 0.0,
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "STI Test Centers Locator",
        style: TTtextStyles.bodylargeRegular.copyWith(fontSize: 18),
      ),
      backgroundColor: AppColors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MapViewBody extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback searchAndDisplay;
  final Function(String, String) updateType;
  final List places;
  final String Function(double, double, double, double) calculateDistance;
  final bool Function(Map?) isOpen;
  final String Function(Map?) nextOpenHours;
  final double userLat;
  final double userLng;

  const MapViewBody({
    super.key,
    required this.searchController,
    required this.searchAndDisplay,
    required this.updateType,
    required this.places,
    required this.calculateDistance,
    required this.isOpen,
    required this.nextOpenHours,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBar(
            searchController: searchController,
            onSearch: searchAndDisplay,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 110),
              child: ButtonRow(
                onTypeChange: updateType,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                var place = places[index];
                return MapViewCard(
                  title: place['name'] ?? 'Unknown',
                  rating: place['rating']?.toDouble() ?? 0.0,
                  totalReviews: place['user_ratings_total'] ?? 0,
                  distance: calculateDistance(
                      place['geometry']['location']['lat'],
                      place['geometry']['location']['lng'],
                      userLat,
                      userLng),
                  description: place['vicinity'] ?? 'No address available',
                  isOpen: isOpen(place['opening_hours']),
                  nextOpenHours: nextOpenHours(place['opening_hours']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const SearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: 'Search Location',
                  hintStyle: TTtextStyles.bodymediumRegular,
                  fillColor: AppColors.secondaryColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor))),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor),
              color: AppColors.primaryColor),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.white),
            onPressed: onSearch,
          ),
        ),
      ],
    );
  }
}

class ButtonRow extends StatefulWidget {
  final Function(String, String) onTypeChange;

  const ButtonRow({super.key, required this.onTypeChange});

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  bool isClinicsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButton(
          text: 'Hospitals',
          icon: Icons.local_hospital,
          isSelected: isClinicsSelected,
          onTap: () {
            setState(() {
              isClinicsSelected = true;
            });
            widget.onTypeChange('hospital', '');
          },
        ),
        CustomButton(
          text: 'Testing Centers',
          icon: Icons.health_and_safety,
          isSelected: !isClinicsSelected,
          onTap: () {
            setState(() {
              isClinicsSelected = false;
            });
            widget.onTypeChange('health', 'STI test centers');
          },
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.secondaryColor
                  : AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TTtextStyles.bodymediumRegular.copyWith(
                color: isSelected
                    ? AppColors.secondaryColor
                    : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
