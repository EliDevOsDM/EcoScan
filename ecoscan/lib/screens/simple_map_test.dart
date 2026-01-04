import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SimpleMapTest extends StatefulWidget {
  const SimpleMapTest({super.key});

  @override
  State<SimpleMapTest> createState() => _SimpleMapTestState();
}

class _SimpleMapTestState extends State<SimpleMapTest> {
  late GoogleMapController _controller;
  
  // Tu ubicación de Ecuador
  static const LatLng _ecuador = LatLng(-2.0847163, -79.9320967);
  
  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('ecuador'),
      position: _ecuador,
      infoWindow: const InfoWindow(
        title: 'Ecuador',
        snippet: 'Tu ubicación',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mapa Simple'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: const Text(
              'Mapa de prueba para dispositivos físicos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: _ecuador,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_ecuador, 16.0),
                    );
                  },
                  child: const Text('Zoom In'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_ecuador, 12.0),
                    );
                  },
                  child: const Text('Zoom Out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 