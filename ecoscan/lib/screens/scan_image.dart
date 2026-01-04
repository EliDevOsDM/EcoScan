import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/residuo_model.dart';
import '../services/api_service.dart';

class ScanImageScreen extends StatefulWidget {
  const ScanImageScreen({super.key});

  @override
  State<ScanImageScreen> createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends State<ScanImageScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  File? _imageFile;
  bool _isAnalyzing = false;
  RespuestaAnalisis? _respuesta;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _currentMotivationalPhrase = '';

  // Frases motivadoras eco-friendly
  final List<String> _motivationalPhrases = [
    "🌱 Cada pequeña acción cuenta para salvar nuestro planeta",
    "♻️ Reciclar hoy es cuidar el mañana de nuestros hijos",
    "🌍 Sé el cambio que quieres ver en el mundo",
    "🌿 La naturaleza no necesita al ser humano, pero nosotros sí la necesitamos",
    "💚 Un planeta limpio comienza con decisiones conscientes",
    "🌳 Plantar un árbol es plantar esperanza para el futuro",
    "🌊 Proteger los océanos es proteger la vida",
    "☀️ La energía renovable es el futuro sostenible",
    "🦋 Cada especie salvada es un tesoro preservado",
    "🌺 Reduce, reutiliza, recicla: las 3 R del cambio",
    "🍃 Vivir verde es vivir con propósito",
    "🌈 Un futuro sostenible es posible si actuamos juntos",
  ];

  // Los colores ahora se obtienen del tema para soporte de modo oscuro

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _updateMotivationalPhrase();
    _checkApiStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateMotivationalPhrase() {
    final random = Random();
    setState(() {
      _currentMotivationalPhrase = _motivationalPhrases[random.nextInt(_motivationalPhrases.length)];
    });
  }

  Future<void> _checkApiStatus() async {
    try {
      final isAvailable = await _apiService.checkApiStatus();
      if (!isAvailable) {
        setState(() {
          _errorMessage = 'La API no está disponible en este momento. Verifica tu conexión.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con la API: $e';
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (context.mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Necesitamos permiso de cámara para analizar residuos'),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    await _requestCameraPermission();

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _respuesta = null;
        _errorMessage = null;
      });
      
      _updateMotivationalPhrase();
      _analizarImagen();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _respuesta = null;
        _errorMessage = null;
      });
      
      _updateMotivationalPhrase();
      _analizarImagen();
    }
  }

  Future<void> _analizarImagen() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final respuesta = await _apiService.analizarImagen(_imageFile!);

      setState(() {
        _respuesta = respuesta;
        _isAnalyzing = false;

        if (!respuesta.success) {
          _errorMessage = respuesta.mensaje ?? 'Error desconocido';
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [theme.colorScheme.primary, theme.colorScheme.secondary]
            : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Analizar Residuo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalSection() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Mensaje Eco-Friendly',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentMotivationalPhrase,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _updateMotivationalPhrase,
            icon: Icon(Icons.refresh, size: 16, color: theme.colorScheme.primary),
            label: Text(
              'Nueva frase',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _imageFile != null
                  ? Stack(
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        if (_isAnalyzing)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Analizando imagen...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '🌱 Identificando residuos para un mejor reciclaje',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Toma una foto para analizar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Identifica residuos y aprende a reciclar',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]
                    : [const Color(0xFF4CAF50), const Color(0xFF4CAF50).withOpacity(0.8)],
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
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _takePicture,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Cámara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [theme.colorScheme.tertiary, theme.colorScheme.tertiary.withOpacity(0.8)]
                    : [const Color(0xFF00ACC1), const Color(0xFF00ACC1).withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _pickImage,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  'Galería',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_respuesta == null || !_respuesta!.success || _respuesta!.analisis == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con animación mejorada
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.2),
                      theme.colorScheme.tertiary.withOpacity(0.1),
                    ]
                  : [
                      const Color(0xFF4CAF50).withOpacity(0.1),
                      const Color(0xFF66BB6A).withOpacity(0.1),
                      const Color(0xFF81C784).withOpacity(0.1),
                    ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Análisis Completado',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✨ Resultado obtenido con IA',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _respuesta!.analisis!.resumen,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Lista de elementos detectados con diseño premium
          ...(_respuesta!.analisis!.elementos.map((elemento) => 
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ]
                    : [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(isDark ? 0.05 : 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: Border.all(
                  color: elemento.reciclable 
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del elemento con badge mejorado
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                elemento.nombre,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                elemento.categoria.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Badge de reciclable mejorado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: elemento.reciclable 
                                ? [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF66BB6A),
                                  ]
                                : [
                                    Colors.red.shade400,
                                    Colors.red.shade500,
                                  ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: (elemento.reciclable 
                                  ? const Color(0xFF4CAF50) 
                                  : Colors.red.shade400).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                elemento.reciclable ? Icons.recycling_rounded : Icons.warning_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                elemento.reciclable ? 'Reciclable' : 'No Reciclable',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Información en cards
                    _buildEnhancedInfoCard(
                      Icons.lightbulb_outline_rounded, 
                      'Recomendación', 
                      elemento.recomendacion, 
                      theme,
                      Colors.orange.shade400,
                    ),
                    const SizedBox(height: 12),
                    _buildEnhancedInfoCard(
                      Icons.info_outline_rounded, 
                      'Estado de Reciclaje', 
                      elemento.estadoReciclaje, 
                      theme,
                      elemento.reciclable 
                        ? theme.colorScheme.primary 
                        : Colors.red.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ).toList()),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoCard(IconData icon, String label, String value, ThemeData theme, Color accentColor) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                theme.colorScheme.surface.withOpacity(0.5),
                theme.colorScheme.surface.withOpacity(0.3),
              ]
            : [
                accentColor.withOpacity(0.05),
                accentColor.withOpacity(0.02),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildMotivationalSection(),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    _buildErrorMessage(),
                    _buildResultsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
