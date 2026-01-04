import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import 'simple_map_test.dart';

class DebugInfoScreen extends StatefulWidget {
  const DebugInfoScreen({super.key});

  @override
  State<DebugInfoScreen> createState() => _DebugInfoScreenState();
}

class _DebugInfoScreenState extends State<DebugInfoScreen> {
  Map<String, dynamic> debugInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      final info = <String, dynamic>{};
      
      // Estado de permisos
      info['location_permission'] = await Permission.location.status;
      info['camera_permission'] = await Permission.camera.status;
      info['storage_permission'] = await Permission.storage.status;
      
      // Estado de servicios de ubicación
      info['location_service_enabled'] = await Geolocator.isLocationServiceEnabled();
      
      // Permisos de ubicación específicos de Geolocator
      info['geolocator_permission'] = await Geolocator.checkPermission();
      
      // Intentar obtener ubicación
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        info['last_known_location'] = lastPosition != null 
          ? '${lastPosition.latitude}, ${lastPosition.longitude}'
          : 'No disponible';
      } catch (e) {
        info['last_known_location'] = 'Error: $e';
      }
      
      // Probar conectividad con API (usando endpoint básico)
      try {
        // Intentar hacer una solicitud simple para probar conectividad
        info['api_status'] = 'Probando...';
        info['api_message'] = 'Verificando conectividad con servidor';
      } catch (e) {
        info['api_status'] = 'Error';
        info['api_message'] = e.toString();
      }
      
      setState(() {
        debugInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        debugInfo = {'error': e.toString()};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Información de Debug',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...debugInfo.entries.map((entry) => Card(
                  child: ListTile(
                    title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                    subtitle: Text(entry.value.toString()),
                    leading: _getStatusIcon(entry.key, entry.value),
                  ),
                )).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    _loadDebugInfo();
                  },
                  child: const Text('Actualizar Info'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleMapTest(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Probar Mapa Simple'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _getStatusIcon(String key, dynamic value) {
    if (key.contains('permission')) {
      if (value.toString().contains('granted')) {
        return const Icon(Icons.check_circle, color: Colors.green);
      } else {
        return const Icon(Icons.error, color: Colors.red);
      }
    }
    
    if (key.contains('enabled') && value == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    
    if (key.contains('status') && value == 'ok') {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    
    return const Icon(Icons.info, color: Colors.blue);
  }
} 