import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/residuo_model.dart';

class ApiService {
  // URL base de la API (cambia esto según tu configuración)
  static const String baseUrl = 'https://e6d999cae912.ngrok-free.app';
  
  // Verifica el estado de la API
  Future<bool> checkApiStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/estado'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al verificar el estado de la API: $e');
      return false;
    }
  }
  
  // Analizar imagen desde un archivo
  Future<RespuestaAnalisis> analizarImagen(File imageFile) async {
    try {
      // Crear la solicitud multipart
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/analizar'));
      
      // Adjuntar la imagen
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imageFile.path),
      );
      
      // Enviar la solicitud
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RespuestaAnalisis.fromJson(data);
      } else {
        return RespuestaAnalisis.error(
          'Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error al analizar la imagen: $e');
      return RespuestaAnalisis.error('Error de conexión: $e');
    }
  }
  
  // Analizar imagen desde base64
  Future<RespuestaAnalisis> analizarImagenBase64(String base64Image) async {
    try {
      // Crear la solicitud
      final response = await http.post(
        Uri.parse('$baseUrl/api/analizar'),
        body: {
          'base64': base64Image,
          'mime_type': 'image/jpeg',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RespuestaAnalisis.fromJson(data);
      } else {
        return RespuestaAnalisis.error(
          'Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error al analizar la imagen base64: $e');
      return RespuestaAnalisis.error('Error de conexión: $e');
    }
  }
  
  // Obtener categorías de residuos
  Future<Map<String, dynamic>> obtenerCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categorias'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['categorias'];
        }
        return {};
      }
      return {};
    } catch (e) {
      debugPrint('Error al obtener categorías: $e');
      return {};
    }
  }
  
  // Chatbot con OpenAI
  Future<String> enviarMensajeChatbot(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chatbot'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mensaje': mensaje,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['respuesta'];
        } else {
          return 'Lo siento, hubo un problema al procesar tu mensaje. ¿Podrías intentar de nuevo?';
        }
      } else {
        debugPrint('Error del servidor: ${response.statusCode}');
        return 'Hay problemas de conexión en este momento. ¿Podrías intentar más tarde?';
      }
    } catch (e) {
      debugPrint('Error al enviar mensaje al chatbot: $e');
      return 'No puedo conectarme al servidor en este momento. Verifica tu conexión a internet.';
    }
  }
} 