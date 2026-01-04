import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'scan_image.dart';
import 'home_screen.dart';
import 'package:ecoscan/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Los colores ahora se obtienen del tema para soporte de modo oscuro

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      // En un caso real, aquí iría el registro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (!_acceptTerms) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
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
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Únete y ayuda al medio ambiente',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  
                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nombre completo
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'Nombre completo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Juan Pérez',
                            prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.primary),
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
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Email
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
                        
                        // Contraseña
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
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Confirmar contraseña
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'Confirmar contraseña',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: '••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
                              return 'Por favor confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // Términos y condiciones
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Acepto los Términos de Servicio y la Política de Privacidad',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Botón de registro
                        ElevatedButton(
                          onPressed: _register,
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
                            'CREAR CUENTA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        
                        // Link para iniciar sesión
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes una cuenta? ',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Separador
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.colorScheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O regístrate con',
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
                        
                        SizedBox(height: 20),
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