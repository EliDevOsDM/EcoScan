import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'scan_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Los colores ahora se obtienen del tema para soporte de modo oscuro

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Sin validación, simplemente navega al HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para hacer que la UI sea responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  // Logo y título
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: isSmallScreen ? 120 : 150,
                          width: isSmallScreen ? 120 : 150,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 24),
                        Text(
                          'Identifica y recicla correctamente',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 48),
                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Label para Email
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'nombre@ejemplo.com',
                            prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        // Label para contraseña
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Remember me checkbox y recuperar contraseña
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recordarme',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Aquí iría la funcionalidad de recuperar contraseña
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        // Login button
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.tertiary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'INICIAR SESIÓN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿No tienes una cuenta? ',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: Text(
                                'Regístrate',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Elementos adicionales para rellenar el espacio inferior
                        SizedBox(height: isSmallScreen ? 30 : 50),
                        
                        // Separador visual
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.colorScheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O continúa con',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.colorScheme.outline)),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Botones de redes sociales
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              icon: Icons.g_mobiledata_rounded,
                              color: Colors.red.shade600,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 16),
                            _socialButton(
                              icon: Icons.facebook_rounded,
                              color: Colors.blue.shade800,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 16),
                            _socialButton(
                              icon: Icons.apple_rounded,
                              color: Colors.black87,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        
                        // Footer con texto informativo
                        SizedBox(height: isSmallScreen ? 30 : 40),
                        Text(
                          'Al iniciar sesión, aceptas nuestros Términos de Servicio y Política de Privacidad',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
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
    );
  }
  
  // Widget para los botones de redes sociales
  Widget _socialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}