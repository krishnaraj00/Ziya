import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DummyMapScreen extends StatelessWidget {
  const DummyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const MalappuramLatLng = LatLng(11.0720 , 76.0740);
    const MalappuramAddress = "Malappuram, Kerala, India";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: MalappuramLatLng,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ziyaproject',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: MalappuramLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {

                  Navigator.pop(context, {
                    'location': MalappuramAddress, // Must match expected key
                  });
                },
                child: const Text(
                  "Continue with this location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
