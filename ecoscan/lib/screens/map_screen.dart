import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _mapInitialized = false;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _filterSlideAnimation;
  
  Position? _currentPosition;
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  String _selectedCategory = 'Todos';
  String _selectedModalFilter = 'Todos'; // Nuevo filtro para el modal
  bool _showFilters = true;
  
  // Punto inicial (Ubicación en Ecuador basada en debug info)
  static const LatLng _defaultLocation = LatLng(-2.0847163, -79.9320967); // Ecuador
  
  final Set<Marker> _markers = {};
  final Map<String, Color> _categoryColors = {
    'Plástico': Color(0xFF2196F3),
    'Papel': Color(0xFFFF9800),
    'Vidrio': Color(0xFF9C27B0),
    'Metal': Color(0xFF607D8B),
    'Orgánico': Color(0xFF4CAF50),
    'Electrónico': Color(0xFF795548),
    'Todos': Color(0xFF00BCD4),
  };

  final Map<String, IconData> _categoryIcons = {
    'Plástico': Icons.recycling,
    'Papel': Icons.description,
    'Vidrio': Icons.wine_bar,
    'Metal': Icons.build,
    'Orgánico': Icons.eco,
    'Electrónico': Icons.electrical_services,
    'Todos': Icons.location_on,
  };

  // Datos de ejemplo de puntos de reciclaje (COORDENADAS PARA ECUADOR)
  final List<Map<String, dynamic>> _recyclingPoints = [
    {
      'id': '1',
      'name': 'EcoCenter Guayaquil',
      'category': 'Todos',
      'address': 'Av. 9 de Octubre 1250, Centro',
      'position': LatLng(-2.190000, -79.890000),
      'rating': 4.8,
      'distance': '0.5 km',
      'phone': '+593 123 456 789',
      'hours': 'Lun-Vie: 8:00-18:00',
      'types': ['Plástico', 'Papel', 'Vidrio', 'Metal'],
      'verified': true,
      'image': 'assets/images/recycle_center.jpg',
    },
    {
      'id': '2',
      'name': 'Verde Vida Urdesa',
      'category': 'Plástico',
      'address': 'Calle Ficus 319, Urdesa',
      'position': LatLng(-2.150000, -79.920000),
      'rating': 4.9,
      'distance': '1.2 km',
      'phone': '+593 987 654 321',
      'hours': 'Lun-Sab: 7:00-19:00',
      'types': ['Plástico', 'Metal'],
      'verified': true,
      'image': 'assets/images/plastic_center.jpg',
    },
    {
      'id': '3',
      'name': 'Papel Verde Samborondón',
      'category': 'Papel',
      'address': 'Av. Samborondón 1618, Samborondón',
      'position': LatLng(-2.100000, -79.880000),
      'rating': 4.6,
      'distance': '2.1 km',
      'phone': '+593 555 123 456',
      'hours': 'Lun-Dom: 6:00-20:00',
      'types': ['Papel', 'Vidrio'],
      'verified': false,
      'image': 'assets/images/paper_center.jpg',
    },
    {
      'id': '4',
      'name': 'Crystal Clean Las Peñas',
      'category': 'Vidrio',
      'address': 'Av. Simón Bolívar 266, Las Peñas',
      'position': LatLng(-2.200000, -79.900000),
      'rating': 4.7,
      'distance': '3.5 km',
      'phone': '+593 444 789 123',
      'hours': 'Mar-Dom: 9:00-17:00',
      'types': ['Vidrio', 'Electrónico'],
      'verified': true,
      'image': 'assets/images/glass_center.jpg',
    },
    {
      'id': '5',
      'name': 'TechRecycle Pro',
      'category': 'Electrónico',
      'address': 'Av. Francisco de Orellana 719, Kennedy',
      'position': LatLng(-2.140000, -79.910000),
      'rating': 4.5,
      'distance': '1.8 km',
      'phone': '+593 333 555 777',
      'hours': 'Lun-Vie: 8:30-17:30',
      'types': ['Electrónico', 'Metal'],
      'verified': true,
      'image': 'assets/images/tech_center.jpg',
    },
    {
      'id': '6',
      'name': 'Reto Innovación',
      'category': 'Electrónico',
      'address': 'Av. El Bombero, Guayaquil',
      'position': LatLng(-2.178004, -79.943972),
      'rating': 4.5,
      'distance': '1.8 km',
      'phone': '+593 333 555 888',
      'hours': 'Lun-Vie: 8:30-17:30',
      'types': ['Electrónico', 'Metal'],
      'verified': true,
      'image': 'assets/images/tech_center.jpg',
    },
    {
      'id': '7',
      'name': 'Reto Innovación Super Tecnológico',
      'category': 'Electrónico',
      'address': 'Av. El Bombero, Guayaquil',
      'position': LatLng(-2.084643, -79.919898),
      'rating': 4.5,
      'distance': '1.8 km',
      'phone': '+593 333 555 999',
      'hours': 'Lun-Vie: 8:30-17:30',
      'types': ['Electrónico', 'Metal'],
      'verified': true,
      'image': 'assets/images/tech_center.jpg',
    },
    {
      'id': '8',
      'name': 'EcoRecycle Ceibos',
      'category': 'Orgánico',
      'address': 'Av. Comandante Espinar 719, Ceibos',
      'position': LatLng(-2.086412, -79.931751),
      'rating': 4.5,
      'distance': '1.8 km',
      'phone': '+593 333 555 000',
      'hours': 'Lun-Vie: 8:30-17:30',
      'types': ['Orgánico', 'Papel'],
      'verified': true,
      'image': 'assets/images/organic_center.jpg',
    },
    {
      'id': '9',
      'name': 'Metal Recycle Norte',
      'category': 'Metal',
      'address': 'Av. Carlos Julio Arosemena, Norte',
      'position': LatLng(-2.120000, -79.895000),
      'rating': 4.3,
      'distance': '2.5 km',
      'phone': '+593 222 333 444',
      'hours': 'Lun-Sab: 7:30-16:30',
      'types': ['Metal', 'Electrónico'],
      'verified': true,
      'image': 'assets/images/metal_center.jpg',
    },
    {
      'id': '10',
      'name': 'Orgánico Verde Alborada',
      'category': 'Orgánico',
      'address': 'Av. Rodolfo Baquerizo Nazur, Alborada',
      'position': LatLng(-2.130000, -79.885000),
      'rating': 4.4,
      'distance': '3.2 km',
      'phone': '+593 555 666 777',
      'hours': 'Lun-Dom: 6:00-18:00',
      'types': ['Orgánico', 'Papel'],
      'verified': false,
      'image': 'assets/images/organic_center.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.bounceOut),
    );
    
    _filterSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeOutBack),
    );
    
    // Secuencia de animaciones
    Timer(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
    
    Timer(const Duration(milliseconds: 1000), () {
      _filterAnimationController.forward();
    });
    
    Timer(const Duration(milliseconds: 1500), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Crear marcadores iniciales inmediatamente
    _createMarkers();
    
    // Solicitar permisos
    await _requestLocationPermission();
    
    // Si tenemos permisos, obtener ubicación
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    } else {
      // Si no hay permisos, al menos cargar ubicación por defecto
      print('Sin permisos de ubicación, usando ubicación por defecto');
      setState(() {
        _isLoading = false;
      });
      _createMarkers();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Solicitar permisos de almacenamiento primero (necesario para algunas funciones)
      await Permission.storage.request();
      
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Los servicios de ubicación están deshabilitados. Habilítalos en Configuración.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }

      // Verificar permisos actuales usando Geolocator (más confiable para ubicación)
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Si se denegó permanentemente, dirigir a configuración
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionDialog();
        }
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }

      // Solicitar permisos si están denegados
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Aceptar tanto whileInUse como always
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        setState(() {
          _locationPermissionGranted = true;
        });
        print('Permisos de ubicación concedidos: $permission');
        _getCurrentLocation();
      } else {
        setState(() {
          _locationPermissionGranted = false;
        });
        print('Permisos de ubicación denegados: $permission');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se necesita acceso a la ubicación para mostrar tu posición en el mapa.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al solicitar permisos de ubicación: $e');
      setState(() {
        _locationPermissionGranted = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al acceder a la ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de Ubicación'),
          content: const Text(
            'Para mostrar tu ubicación en el mapa, necesitamos acceso a la ubicación. '
            'Ve a Configuración > Apps > EcoScan > Permisos y habilita la ubicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Intentar obtener la última ubicación conocida primero (más rápido)
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      
      if (lastPosition != null) {
        setState(() {
          _currentPosition = lastPosition;
          _isLoading = false;
        });
        _createMarkers();
        
        // Mover la cámara a la ubicación del usuario
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(lastPosition.latitude, lastPosition.longitude),
              15.0,
            ),
          );
        }
      }

      // Obtener ubicación actual más precisa
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Timeout para evitar esperas largas
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _createMarkers();
      
      // Mover la cámara a la ubicación actual
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );
      
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Si no se puede obtener la ubicación, usar ubicación por defecto
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo obtener tu ubicación. Mostrando ubicación por defecto.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Mover a ubicación por defecto
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_defaultLocation, 12.0),
      );
      _createMarkers();
    }
  }

  void _createMarkers() async {
    _markers.clear();
    
    // Cargar el icono personalizado de reciclaje una sola vez
    final recycleIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 5.0, // Valor alto para hacer el ícono MUY pequeño
        size: const Size(16, 16), // Tamaño muy pequeño
      ),
      'assets/images/icono5.png', // AQUÍ PONES TU IMAGEN
    );
    
    // Crear marcador personalizado para mi ubicación
    final myLocationIcon = await _createMyLocationMarker();
    
    // Marcador de ubicación actual
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: myLocationIcon,
          infoWindow: const InfoWindow(
            title: '📍 Mi ubicación',
            snippet: 'Estás aquí',
          ),
        ),
      );
    } else {
      // Si no tenemos posición actual, crear marcador en ubicación por defecto
      _markers.add(
        Marker(
          markerId: const MarkerId('default_location'),
          position: _defaultLocation,
          icon: myLocationIcon,
          infoWindow: const InfoWindow(
            title: '📍 Ubicación de referencia',
            snippet: 'Zona de Ecuador',
          ),
        ),
      );
    }

    // Marcadores de puntos de reciclaje filtrados por tipo de residuo
    List<Map<String, dynamic>> filteredPoints = _recyclingPoints.where((point) {
      if (_selectedCategory == 'Todos') {
        return true; // Mostrar todos los puntos
      } else {
        // Filtrar por tipo de residuo que acepta el punto
        List<String> acceptedTypes = List<String>.from(point['types']);
        return acceptedTypes.contains(_selectedCategory);
      }
    }).toList();

    for (var point in filteredPoints) {
      _markers.add(
        Marker(
          markerId: MarkerId(point['id']),
          position: point['position'],
          icon: recycleIcon, // USA TU IMAGEN PERSONALIZADA AQUÍ
          infoWindow: InfoWindow(
            title: '${point['verified'] ? '✅ ' : ''}${point['name']}',
            snippet: '${point['distance']} • ⭐ ${point['rating']} • ${_selectedCategory == 'Todos' ? point['types'].length : 1} tipo${_selectedCategory == 'Todos' ? 's' : ''}',
          ),
          onTap: () => _showPointDetails(point),
        ),
      );
    }
    
    // Actualizar el estado para refrescar los marcadores
    if (mounted) {
      setState(() {});
    }
  }

  double _getCategoryHue(String category) {
    switch (category) {
      case 'Plástico': return BitmapDescriptor.hueBlue;
      case 'Papel': return BitmapDescriptor.hueOrange;
      case 'Vidrio': return BitmapDescriptor.hueViolet;
      case 'Metal': return BitmapDescriptor.hueYellow;
      case 'Orgánico': return BitmapDescriptor.hueGreen;
      case 'Electrónico': return BitmapDescriptor.hueRed;
      default: return BitmapDescriptor.hueCyan;
    }
  }

  Future<BitmapDescriptor> _createMyLocationMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 80.0;
    const double radius = size / 2;

    // Círculo exterior azul
    final Paint outerPaint = Paint()..color = const Color(0xFF2196F3);
    canvas.drawCircle(Offset(radius, radius), radius, outerPaint);
    
    // Borde blanco
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(radius, radius), radius - 2, borderPaint);

    // Círculo interior más pequeño (punto azul más oscuro)
    final Paint innerPaint = Paint()..color = const Color(0xFF1976D2);
    canvas.drawCircle(Offset(radius, radius), radius * 0.4, innerPaint);
    
    // Borde blanco del círculo interior
    final Paint innerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(radius, radius), radius * 0.4 - 1, innerBorderPaint);

    // Punto central blanco
    final Paint centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius * 0.15, centerPaint);

    // Efecto de pulso (círculo semi-transparente)
    final Paint pulsePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(radius, radius), radius + 8, pulsePaint);

    final img = await pictureRecorder.endRecording().toImage(size.toInt() + 16, size.toInt() + 16);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }



  Widget _buildMapWidget() {
    return Container(
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultLocation, // Siempre usar ubicación por defecto inicialmente
          zoom: 12.0,
        ),
        markers: _markers,
        myLocationEnabled: false, // Desactivar temporalmente para debug
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        compassEnabled: true,
        // Forzar renderizado en dispositivos físicos
        liteModeEnabled: false,
        tiltGesturesEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          try {
            print('🗺️ Google Maps creado exitosamente');
            _onMapCreated(controller);
            // Forzar creación de marcadores después de crear el mapa
            Future.delayed(const Duration(milliseconds: 500), () {
              _createMarkers();
              print('📍 Marcadores creados: ${_markers.length}');
            });
            
            // Debug específico para dispositivos físicos
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _mapController != null) {
                print('🔄 Refrescando mapa para dispositivos físicos...');
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_defaultLocation, 12.1),
                ).then((_) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(_defaultLocation, 12.0),
                    );
                  });
                });
              }
            });
          } catch (e) {
            print('❌ Error creando mapa: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error cargando el mapa: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Aplicar estilo personalizado al mapa
    String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dadada"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#c9c9c9"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      }
    ]
    ''';
    
    controller.setMapStyle(mapStyle);
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _createMarkers();
    });
    
    // Animación de feedback
    _filterAnimationController.reset();
    _filterAnimationController.forward();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterMenu(),
    );
  }

  Widget _buildFilterMenu() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
            ? [
                const Color(0xFF1E1E1E),
                const Color(0xFF2D2D2D),
              ]
            : [
                Colors.white,
                const Color(0xFFF8F9FA),
              ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrar Puntos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Selecciona el tipo de residuo',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de categorías
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categoryColors.keys.length,
              itemBuilder: (context, index) {
                final category = _categoryColors.keys.elementAt(index);
                final isSelected = _selectedCategory == category;
                final pointCount = category == 'Todos' 
                  ? _recyclingPoints.length 
                  : _recyclingPoints.where((point) {
                      List<String> acceptedTypes = List<String>.from(point['types']);
                      return acceptedTypes.contains(category);
                    }).length;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _filterByCategory(category);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  _categoryColors[category]!,
                                  _categoryColors[category]!.withOpacity(0.8),
                                ],
                              )
                            : null,
                          color: isSelected 
                            ? null 
                            : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? Colors.white.withOpacity(0.3)
                              : _categoryColors[category]!.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                ? _categoryColors[category]!.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 15 : 8,
                              offset: Offset(0, isSelected ? 6 : 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? Colors.white.withOpacity(0.2)
                                  : _categoryColors[category]!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: AnimatedScale(
                                scale: isSelected ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _categoryIcons[category] ?? Icons.category,
                                  size: 24,
                                  color: isSelected 
                                    ? Colors.white 
                                    : _categoryColors[category],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected 
                                        ? Colors.white 
                                        : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '$pointCount punto${pointCount != 1 ? 's' : ''} disponible${pointCount != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected 
                                        ? Colors.white.withOpacity(0.8)
                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Botón para cerrar
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointDetails(Map<String, dynamic> point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPointDetailsModal(point),
    );
  }

  Widget _buildPointDetailsModal(Map<String, dynamic> point) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2D2D2D),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar con efecto glassmorphism
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Header con imagen de fondo
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _categoryColors[point['category']]!,
                            _categoryColors[point['category']]!.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _categoryColors[point['category']]!.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Patrón de fondo
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: CustomPaint(
                                painter: _PatternPainter(),
                              ),
                            ),
                          ),
                          
                          // Contenido del header
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _categoryIcons[point['category']] ?? Icons.location_on,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (point['verified'])
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.verified, size: 14, color: Colors.white),
                                            SizedBox(width: 3),
                                            Text(
                                              'Verificado',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  point['name'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${point['rating']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.white, size: 14),
                                          const SizedBox(width: 3),
                                          Text(
                                            point['distance'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Filtros bonitos para tipos de residuo
                    Row(
                      children: [
                        Text(
                          'Filtrar residuos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getFilteredTypes(point['types']).length} tipos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Chips de filtro horizontal
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('Todos', theme),
                          const SizedBox(width: 8),
                          ...(point['types'] as List<String>).map((type) => 
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(type, theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Información del punto
                    _buildEnhancedDetailRow(
                      Icons.location_on_outlined,
                      'Dirección',
                      point['address'],
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildEnhancedDetailRow(
                      Icons.phone_outlined,
                      'Teléfono',
                      point['phone'],
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildEnhancedDetailRow(
                      Icons.schedule_outlined,
                      'Horarios',
                      point['hours'],
                      theme,
                    ),
                    const SizedBox(height: 24),
                    
                    // Tipos de residuos aceptados (filtrados)
                    Text(
                      'Residuos que aceptamos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _getFilteredTypes(point['types']).map((type) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _categoryColors[type] ?? theme.colorScheme.primary,
                                (_categoryColors[type] ?? theme.colorScheme.primary).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: (_categoryColors[type] ?? theme.colorScheme.primary).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcons[type] ?? Icons.recycling,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.navigation, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Navegando a ${point['name']}'),
                                        ],
                                      ),
                                      backgroundColor: theme.colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.navigation, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cómo llegar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                // TODO: Implementar llamada telefónica
                              },
                              child: Icon(
                                Icons.phone,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, ThemeData theme) {
    final isSelected = _selectedModalFilter == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModalFilter = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
            ? LinearGradient(
                colors: [
                  _categoryColors[type] ?? theme.colorScheme.primary,
                  (_categoryColors[type] ?? theme.colorScheme.primary).withOpacity(0.8),
                ],
              )
            : null,
          color: isSelected ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
            ? null 
            : Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: (_categoryColors[type] ?? theme.colorScheme.primary).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _categoryIcons[type] ?? Icons.category,
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getFilteredTypes(List<String> allTypes) {
    if (_selectedModalFilter == 'Todos') {
      return allTypes;
    }
    return allTypes.where((type) => type == _selectedModalFilter).toList();
  }

  int _getFilteredPointsCount() {
    if (_selectedCategory == 'Todos') {
      return _recyclingPoints.length;
    } else {
      return _recyclingPoints.where((point) {
        List<String> acceptedTypes = List<String>.from(point['types']);
        return acceptedTypes.contains(_selectedCategory);
      }).length;
    }
  }

  Widget _buildEnhancedDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Mapa
          _isLoading
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cargando puntos de reciclaje...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _buildMapWidget(),
          
          // Header con efecto glassmorphism
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Puntos de Reciclaje',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                                                     Text(
                                     '${_getFilteredPointsCount()} puntos ${_selectedCategory == 'Todos' ? 'cercanos' : 'de $_selectedCategory'}',
                                     style: TextStyle(
                                       fontSize: 14,
                                       color: Colors.white.withOpacity(0.8),
                                     ),
                                   ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          

          


          // Botones flotantes con animación
          Positioned(
            bottom: 30,
            right: 20,
            child: ScaleTransition(
              scale: _fabScaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de filtros
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _categoryColors[_selectedCategory]!,
                          _categoryColors[_selectedCategory]!.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _categoryColors[_selectedCategory]!.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "filter_fab",
                      onPressed: _showFilterMenu,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 28,
                          ),
                          if (_selectedCategory != 'Todos')
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_getFilteredPointsCount()}',
                                    style: TextStyle(
                                      color: _categoryColors[_selectedCategory]!,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Botón de ubicación actual
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "location_fab",
                                              onPressed: () async {
                          if (_mapController != null) {
                            if (_currentPosition != null) {
                              await _mapController!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                    zoom: 16.0,
                                  ),
                                ),
                              );
                            } else {
                              await _getCurrentLocation();
                              if (_currentPosition != null) {
                                await _mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                      zoom: 16.0,
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('El mapa aún se está cargando...'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: const Icon(Icons.my_location, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Botón de información
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "info_fab",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Información'),
                            content: const Text(
                              'Encuentra los puntos de reciclaje más cercanos a ti. '
                              'Filtra por tipo de residuo y obtén direcciones para llegar.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                      backgroundColor: theme.colorScheme.surface,
                      elevation: 0,
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter personalizado para el patrón de fondo
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double spacing = 20;
    
    // Líneas verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Líneas horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 