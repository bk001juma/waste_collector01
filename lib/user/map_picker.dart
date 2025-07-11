import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _selectedLocation = const LatLng(
    -6.7924,
    39.2083,
  ); // Default: Dar es Salaam

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Pickup Location"),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("selected_location"),
                position: _selectedLocation,
              ),
            },
            onTap: _onMapTapped,
            onMapCreated: (controller) {},
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: const Icon(Icons.check),
              label: const Text("Confirm Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
