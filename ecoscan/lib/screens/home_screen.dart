import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'scan_image.dart';
import 'map_screen.dart';
import 'chatbot_screen.dart';
import 'debug_info_screen.dart';
import '../theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildWelcomeHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive padding y tamaños
    final padding = screenWidth < 360 ? 16.0 : (screenWidth > 600 ? 32.0 : 24.0);
    final borderRadius = screenWidth < 360 ? 24.0 : 32.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [theme.colorScheme.primary, theme.colorScheme.secondary]
            : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const Spacer(),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return InkWell(
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              themeProvider.themeModeIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              themeProvider.themeModeString,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: screenWidth < 360 ? 16 : 24),
            Text(
              '¡Hola!',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 28 : (screenWidth > 600 ? 36 : 32),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 6 : 8),
            Text(
              'Bienvenido a EcoScan',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 16 : (screenWidth > 600 ? 20 : 18),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 2 : 4),
            Text(
              'Cuida el planeta, una acción a la vez 🌱',
              style: TextStyle(
                fontSize: screenWidth < 360 ? 14 : (screenWidth > 600 ? 18 : 16),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
    bool isFullWidth = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final cardPadding = screenWidth < 360 ? 12.0 : (isFullWidth ? 20.0 : 16.0);
    final iconPadding = screenWidth < 360 ? 8.0 : (isFullWidth ? 12.0 : 10.0);
    final borderRadius = screenWidth < 360 ? 16.0 : 20.0;
    final iconBorderRadius = screenWidth < 360 ? 8.0 : 12.0;
    
    // Responsive heights
    final minHeight = screenWidth < 360 
        ? (isFullWidth ? 100.0 : 110.0)
        : screenWidth > 600
            ? (isFullWidth ? 140.0 : 150.0)
            : (isFullWidth ? 120.0 : 130.0);
    
    // Responsive font sizes
    final titleFontSize = screenWidth < 360 
        ? (isFullWidth ? 16.0 : 12.0)
        : screenWidth > 600
            ? (isFullWidth ? 20.0 : 16.0)
            : (isFullWidth ? 18.0 : 14.0);
    
    final subtitleFontSize = screenWidth < 360 
        ? (isFullWidth ? 12.0 : 10.0)
        : screenWidth > 600
            ? (isFullWidth ? 16.0 : 13.0)
            : (isFullWidth ? 14.0 : 11.0);
    
    final iconSize = screenWidth < 360 
        ? (isFullWidth ? 24.0 : 18.0)
        : screenWidth > 600
            ? (isFullWidth ? 32.0 : 24.0)
            : (isFullWidth ? 28.0 : 20.0);
    
    final verticalSpacing = screenWidth < 360 
        ? (isFullWidth ? 12.0 : 8.0)
        : (isFullWidth ? 16.0 : 12.0);
    
    final textSpacing = screenWidth < 360 
        ? (isFullWidth ? 4.0 : 2.0)
        : (isFullWidth ? 6.0 : 4.0);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 8,
          shadowColor: gradientColors.first.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              constraints: BoxConstraints(
                minHeight: minHeight,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(iconBorderRadius),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: isFullWidth ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: textSpacing),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: isFullWidth ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive padding
    final horizontalPadding = screenWidth < 360 ? 16.0 : (screenWidth > 600 ? 24.0 : 20.0);
    final verticalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final cardSpacing = screenWidth < 360 ? 12.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPCIONES PRINCIPALES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: cardSpacing + 4),
          // Grid 2x2 para las opciones principales
          Column(
            children: [
              // Primera fila - Analizar y Ubicar
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      title: 'Analizar Residuo',
                      subtitle: 'Identifica y clasifica tus residuos con IA',
                      icon: Icons.camera_alt,
                      gradientColors: isDark 
                        ? [const Color(0xFF66BB6A), const Color(0xFF4CAF50)]
                        : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanImageScreen(),
                          ),
                        );
                      },
                      index: 0,
                      isFullWidth: false,
                    ),
                  ),
                  SizedBox(width: cardSpacing),
                  Expanded(
                    child: _buildOptionCard(
                      title: 'Ubicar Contenedor',
                      subtitle: 'Encuentra puntos de reciclaje cercanos',
                      icon: Icons.location_on,
                      gradientColors: isDark 
                        ? [const Color(0xFF66BB6A), const Color(0xFF4CAF50)]
                        : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                      index: 1,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardSpacing),
              // Segunda fila - EcoBot y otra opción futura
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      title: 'EcoBot',
                      subtitle: 'Consulta sobre reciclaje con IA',
                      icon: Icons.smart_toy,
                      gradientColors: isDark 
                        ? [const Color(0xFF66BB6A), const Color(0xFF4CAF50)]
                        : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatbotScreen(),
                          ),
                        );
                      },
                      index: 2,
                      isFullWidth: false,
                    ),
                  ),
                  SizedBox(width: cardSpacing),
                  Expanded(
                    child: _buildOptionCard(
                      title: 'Configuración',
                      subtitle: 'Ajustes y preferencias de la app',
                      icon: Icons.settings,
                      gradientColors: isDark 
                        ? [const Color(0xFF66BB6A), const Color(0xFF4CAF50)]
                        : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                      onTap: () {
                        // Aquí puedes agregar navegación a pantalla de configuración
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuración próximamente'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      index: 3,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcoTips() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive padding y spacing
    final horizontalPadding = screenWidth < 360 ? 16.0 : (screenWidth > 600 ? 24.0 : 20.0);
    final verticalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final cardPadding = screenWidth < 360 ? 12.0 : 16.0;
    final cardSpacing = screenWidth < 360 ? 8.0 : 12.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final titleFontSize = screenWidth < 360 ? 14.0 : (screenWidth > 600 ? 18.0 : 16.0);
    final descriptionFontSize = screenWidth < 360 ? 12.0 : (screenWidth > 600 ? 16.0 : 14.0);
    
    final tips = [
      {
        'icon': Icons.recycling,
        'title': 'Recicla Correctamente',
        'description': 'Separa tus residuos según su tipo para un mejor procesamiento',
      },
      {
        'icon': Icons.water_drop,
        'title': 'Ahorra Agua',
        'description': 'Cada gota cuenta para preservar nuestro planeta',
      },
      {
        'icon': Icons.energy_savings_leaf,
        'title': 'Energía Limpia',
        'description': 'Usa fuentes de energía renovable cuando sea posible',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSEJOS ECO-FRIENDLY',
            style: TextStyle(
              fontSize: screenWidth < 360 ? 12 : (screenWidth > 600 ? 16 : 14),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: cardSpacing + 4),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            
            return Container(
              margin: EdgeInsets.only(bottom: index < tips.length - 1 ? cardSpacing : 0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth < 360 ? 6 : 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth < 360 ? 6 : 8),
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          color: theme.colorScheme.primary,
                          size: iconSize,
                        ),
                      ),
                      SizedBox(width: screenWidth < 360 ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip['title'] as String,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: screenWidth < 360 ? 2 : 4),
                            Text(
                              tip['description'] as String,
                              style: TextStyle(
                                fontSize: descriptionFontSize,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildWelcomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: bottomSpacing),
                    _buildOptionsGrid(),
                    _buildEcoTips(),
                    SizedBox(height: bottomSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Botón debug temporal - ELIMINAR EN PRODUCCIÓN
    );
  }
}
