import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationPickerView extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerView({Key? key, this.initialLat, this.initialLng})
    : super(key: key);

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  LatLng? _pickedLocation;
  String _address = "";
  bool _isLoading = false;

  // Default: Amman, Jordan (Fallback)
  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(31.9539, 35.9106),
    zoom: 12,
  );

  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  void _setInitialLocation() {
    if (widget.initialLat != null && widget.initialLng != null) {
      LatLng pos = LatLng(widget.initialLat!, widget.initialLng!);

      // Start camera exactly at user location
      _initialCameraPosition = CameraPosition(target: pos, zoom: 15);

      // Drop pin immediately
      _pickedLocation = pos;

      // Get address immediately
      _getAddressFromLatLng(pos);
    } else {
      _initialCameraPosition = _defaultCameraPosition;
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _address = "${place.street}, ${place.locality}, ${place.country}";
            // Clean up address string
            _address = _address.replaceAll(RegExp(r'^, | ,'), '').trim();
            _pickedLocation = position;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      List<Location> locations = await locationFromAddress(
        _searchController.text,
      );

      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng newPos = LatLng(loc.latitude, loc.longitude);

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 14));
        _getAddressFromLatLng(newPos);
      } else {
        Get.snackbar("Not Found", "Could not find that location");
      }
    } catch (e) {
      Get.snackbar("Error", "Location not found: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                _initialCameraPosition ?? _defaultCameraPosition,
            onMapCreated: (controller) => _mapController = controller,

            // ✅ FIX: Ensure cloud map ID is null to avoid renderer conflicts
            cloudMapId: null,

            onTap: (pos) {
              setState(() => _isLoading = true);
              _getAddressFromLatLng(pos).whenComplete(() {
                if (mounted) setState(() => _isLoading = false);
              });
            },
            markers:
                _pickedLocation == null
                    ? {}
                    : {
                      Marker(
                        markerId: const MarkerId('picked'),
                        position: _pickedLocation!,
                      ),
                    },
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _searchLocation(),
                decoration: InputDecoration(
                  hintText: "Search city...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ),
              ),
            ),
          ),

          // Save Button
          if (_pickedLocation != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Get.back(
                    result: {
                      "lat": _pickedLocation!.latitude,
                      "lng": _pickedLocation!.longitude,
                      "address": _address,
                    },
                  );
                },
                child: Text(
                  "Save Location: $_address",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
