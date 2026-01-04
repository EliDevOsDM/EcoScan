from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
import json
from PIL import Image
import requests
import os
from werkzeug.utils import secure_filename
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Permitir CORS para Flutter

# API Key de OpenAI
OPENAI_API_KEY = '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'
OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

# Categorías de residuos predefinidas
CATEGORIAS_RESIDUOS = {
    "organicos": {
        "nombre": "Residuos Orgánicos",
        "descripcion": "Restos de comida, cáscaras de frutas, verduras",
        "color": "#4CAF50",
        "reciclable": True,
        "tipo_reciclaje": "compostaje",
        "consejos": ["Ideal para compostaje", "Se descompone naturalmente"]
    },
    "plastico": {
        "nombre": "Plástico",
        "descripcion": "Botellas, envases, bolsas plásticas",
        "color": "#2196F3",
        "reciclable": True,
        "tipo_reciclaje": "contenedor_azul",
        "consejos": ["Reciclar en contenedor azul", "Lavar antes de reciclar"]
    },
    "papel": {
        "nombre": "Papel y Cartón",
        "descripcion": "Periódicos, cajas, documentos",
        "color": "#FF9800",
        "reciclable": True,
        "tipo_reciclaje": "contenedor_azul",
        "consejos": ["Reciclar en contenedor azul", "Separar grapas y clips"]
    },
    "vidrio": {
        "nombre": "Vidrio",
        "descripcion": "Botellas, frascos, envases de vidrio",
        "color": "#9C27B0",
        "reciclable": True,
        "tipo_reciclaje": "contenedor_verde",
        "consejos": ["Reciclar en contenedor verde", "Quitar tapas metálicas"]
    },
    "metal": {
        "nombre": "Metal",
        "descripcion": "Latas, aluminio, hierro",
        "color": "#607D8B",
        "reciclable": True,
        "tipo_reciclaje": "contenedor_amarillo",
        "consejos": ["Reciclar en contenedor amarillo", "Lavar y aplastar"]
    },
    "electronico": {
        "nombre": "Residuos Electrónicos",
        "descripcion": "Celulares, baterías, electrodomésticos",
        "color": "#795548",
        "reciclable": True,
        "tipo_reciclaje": "punto_limpio",
        "consejos": ["Llevar a punto limpio", "No tirar a la basura común"]
    },
    "toxico": {
        "nombre": "Residuos Tóxicos",
        "descripcion": "Pilas, productos químicos, medicamentos",
        "color": "#F44336",
        "reciclable": False,
        "tipo_reciclaje": "especial",
        "consejos": ["Llevar a punto limpio", "Manejo especial requerido"]
    },
    "sin_residuo": {
        "nombre": "Sin Residuo Detectado",
        "descripcion": "No se detectó ningún residuo en la imagen",
        "color": "#9E9E9E",
        "reciclable": False,
        "tipo_reciclaje": "ninguno",
        "consejos": ["No hay residuo para reciclar", "Intenta con una imagen más clara"]
    },
    "no_reciclable": {
        "nombre": "Residuo No Reciclable",
        "descripcion": "Residuo que no puede ser reciclado con métodos convencionales",
        "color": "#FF5722",
        "reciclable": False,
        "tipo_reciclaje": "basura_comun",
        "consejos": ["Desechar en basura común", "Buscar alternativas de reducción"]
    }
}

@app.route('/api/estado', methods=['GET'])
def verificar_estado():
    """Verificar el estado de la API"""
    try:
        return jsonify({
            "success": True,
            "message": "API funcionando correctamente",
            "version": "1.0.0"
        })
    except Exception as e:
        logger.error(f"Error al verificar estado: {e}")
        return jsonify({
            "success": False,
            "message": "Error interno del servidor"
        }), 500

@app.route('/api/categorias', methods=['GET'])
def obtener_categorias():
    """Obtener todas las categorías de residuos"""
    try:
        return jsonify({
            "success": True,
            "categorias": CATEGORIAS_RESIDUOS
        })
    except Exception as e:
        logger.error(f"Error al obtener categorías: {e}")
        return jsonify({
            "success": False,
            "message": "Error al obtener categorías"
        }), 500

def analizar_imagen_con_openai(image_base64):
    """Analizar imagen usando OpenAI Vision API con requests"""
    try:
        # Prompt específico para análisis de residuos mejorado
        prompt = """
        Analiza CUIDADOSAMENTE esta imagen para identificar residuos o desechos.

        INSTRUCCIONES CRÍTICAS:
        1. Si NO HAY RESIDUOS, usa categoria "sin_residuo"
        2. Si hay objetos que NO SON RESIDUOS (personas, paisajes, etc.), usa "sin_residuo"
        3. Si el residuo NO ES RECICLABLE por métodos convencionales, usa "no_reciclable"
        4. Solo clasifica como reciclable si REALMENTE puede ser reciclado

        CATEGORÍAS VÁLIDAS:
        - "organicos": restos de comida, cáscaras, desechos vegetales REALES
        - "plastico": botellas, envases, bolsas plásticas LIMPIAS Y RECICLABLES
        - "papel": periódicos, cajas, documentos SIN CONTAMINAR
        - "vidrio": botellas, frascos de vidrio ENTEROS
        - "metal": latas, aluminio, hierro LIMPIO
        - "electronico": dispositivos, baterías, componentes electrónicos
        - "toxico": químicos, pilas, medicamentos, materiales peligrosos
        - "sin_residuo": NO HAY RESIDUOS o imagen no clara
        - "no_reciclable": residuo presente pero NO reciclable

        EVALUACIÓN DE RECICLABILIDAD:
        - true: SOLO si es DEFINITIVAMENTE reciclable
        - false: si no es reciclable, está contaminado, o no hay residuo

        Responde SOLO JSON válido:
        {
            "categoria": "una de las categorías exactas de arriba",
            "reciclable": true/false,
            "confianza": 1-100,
            "descripcion": "descripción específica del objeto o 'No se detectó residuo'",
            "consejos_reciclaje": ["consejo específico 1", "consejo específico 2"],
            "impacto_ambiental": "impacto ambiental breve o explicación de por qué no es reciclable"
        }
        
        SÉ MUY ESTRICTO: mejor decir "sin_residuo" que clasificar incorrectamente.
        """
        
        # Headers para la API de OpenAI
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {OPENAI_API_KEY}"
        }
        
        # Payload para la API
        payload = {
            "model": "gpt-4o-mini",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_base64}"
                            }
                        }
                    ]
                }
            ],
            "max_tokens": 500
        }
        
        # Hacer la llamada a OpenAI
        response = requests.post(OPENAI_API_URL, headers=headers, json=payload)
        
        if response.status_code == 200:
            result = response.json()
            resultado = result['choices'][0]['message']['content']
            
            # Limpiar el resultado de markdown si está presente
            if "```json" in resultado:
                # Extraer solo el JSON del markdown
                start = resultado.find("```json") + 7
                end = resultado.find("```", start)
                if end > start:
                    resultado = resultado[start:end].strip()
            
            # Intentar parsear como JSON
            try:
                resultado_json = json.loads(resultado)
                
                # Validar que tenga los campos requeridos
                if 'categoria' not in resultado_json:
                    resultado_json['categoria'] = 'sin_residuo'
                if 'reciclable' not in resultado_json:
                    resultado_json['reciclable'] = False
                if 'confianza' not in resultado_json:
                    resultado_json['confianza'] = 50
                if 'descripcion' not in resultado_json:
                    resultado_json['descripcion'] = 'No se pudo identificar claramente'
                if 'consejos_reciclaje' not in resultado_json:
                    resultado_json['consejos_reciclaje'] = ['Consultar autoridades locales']
                if 'impacto_ambiental' not in resultado_json:
                    resultado_json['impacto_ambiental'] = 'Requiere evaluación adicional'
                
                return resultado_json
            except Exception as e:
                logger.error(f"Error parsing JSON: {e}, contenido: {resultado}")
                # Si no es JSON válido, crear respuesta conservadora
                return {
                    "categoria": "sin_residuo",
                    "reciclable": False,
                    "confianza": 30,
                    "descripcion": "No se pudo analizar la imagen correctamente",
                    "consejos_reciclaje": ["Intenta con una imagen más clara", "Asegúrate de que haya un residuo visible"],
                    "impacto_ambiental": "No se puede determinar sin análisis válido"
                }
        else:
            logger.error(f"Error en OpenAI API: {response.status_code} - {response.text}")
            raise Exception(f"OpenAI API error: {response.status_code}")
                
    except Exception as e:
        logger.error(f"Error al analizar con OpenAI: {e}")
        raise e

@app.route('/api/analizar', methods=['POST'])
def analizar_imagen():
    """Analizar imagen de residuo"""
    try:
        image_base64 = None
        
        # Verificar si es multipart (archivo) o base64
        if request.files and 'imagen' in request.files:
            # Procesar archivo subido
            file = request.files['imagen']
            if file.filename == '':
                return jsonify({
                    "success": False,
                    "message": "No se seleccionó archivo"
                }), 400
            
            # Convertir imagen a base64
            image = Image.open(file.stream)
            buffer = io.BytesIO()
            image.save(buffer, format='JPEG')
            image_base64 = base64.b64encode(buffer.getvalue()).decode()
            
        elif request.form.get('base64'):
            # Usar base64 enviado directamente
            image_base64 = request.form.get('base64')
            
        else:
            return jsonify({
                "success": False,
                "message": "No se proporcionó imagen"
            }), 400
        
        # Analizar con OpenAI
        resultado_analisis = analizar_imagen_con_openai(image_base64)
        
        # Validación adicional: si la confianza es muy baja, ser más conservador
        confianza = resultado_analisis.get('confianza', 50)
        if confianza < 40:
            logger.warning(f"Confianza muy baja ({confianza}%), ajustando respuesta")
            if resultado_analisis.get('categoria') not in ['sin_residuo', 'no_reciclable']:
                resultado_analisis['reciclable'] = False
                resultado_analisis['consejos_reciclaje'] = [
                    "Confianza baja en el análisis",
                    "Consulta autoridades locales antes de reciclar",
                    "Considera tomar una foto más clara"
                ]
        
        # Obtener información de categoría
        categoria = resultado_analisis.get('categoria', 'sin_residuo')
        info_categoria = CATEGORIAS_RESIDUOS.get(categoria, {
            "nombre": "Categoría Desconocida",
            "descripcion": "Categoría no identificada en el sistema",
            "color": "#9E9E9E",
            "reciclable": False,
            "tipo_reciclaje": "consultar",
            "consejos": ["Consultar autoridades locales"]
        })
        
        # Usar el valor de reciclabilidad del análisis de IA, con fallback a la categoría
        es_reciclable = resultado_analisis.get('reciclable', info_categoria.get('reciclable', False))
        
        # Determinar estado de reciclaje más específico
        if categoria == 'sin_residuo':
            estado_reciclaje = "Sin residuo detectado"
        elif categoria == 'no_reciclable':
            estado_reciclaje = "No reciclable"
        elif categoria == 'toxico':
            estado_reciclaje = "Requiere manejo especial"
        elif es_reciclable:
            estado_reciclaje = f"Reciclable - {info_categoria.get('tipo_reciclaje', 'consultar método')}"
        else:
            estado_reciclaje = "No reciclable por métodos convencionales"
        
        # Crear elemento según el formato esperado por Flutter
        elemento = {
            "nombre": resultado_analisis.get('descripcion', info_categoria["descripcion"]),
            "categoria": categoria,
            "reciclable": es_reciclable,
            "recomendacion": "; ".join(resultado_analisis.get('consejos_reciclaje', info_categoria['consejos'])),
            "categoria_info": info_categoria["descripcion"],
            "ejemplos_similares": ["Elementos similares de " + info_categoria["nombre"]] if categoria != 'sin_residuo' else [],
            "estado_reciclaje": estado_reciclaje
        }
        
        # Preparar mensaje más específico según el resultado
        confianza = resultado_analisis.get('confianza', 50)
        descripcion = resultado_analisis.get('descripcion', '')
        impacto = resultado_analisis.get('impacto_ambiental', '')
        
        if categoria == 'sin_residuo':
            resumen = f"No se detectó ningún residuo en la imagen. {impacto}"
            mensaje = f"Análisis completado - No hay residuo para clasificar (Confianza: {confianza}%)"
        elif es_reciclable:
            resumen = f"✅ Residuo RECICLABLE identificado: {descripcion}. {impacto}"
            mensaje = f"¡Excelente! Este residuo SÍ es reciclable (Confianza: {confianza}%)"
        else:
            resumen = f"❌ Residuo NO RECICLABLE: {descripcion}. {impacto}"
            mensaje = f"Atención: Este residuo NO es reciclable por métodos convencionales (Confianza: {confianza}%)"
        
        # Preparar respuesta en el formato esperado por Flutter
        respuesta = {
            "success": True,
            "analisis": {
                "elementos": [elemento],
                "resumen": resumen
            },
            "mensaje": mensaje,
            "texto_completo": f"Categoría: {info_categoria['nombre']}\nDescripción: {descripcion}\nReciclable: {'SÍ' if es_reciclable else 'NO'}\nEstado: {estado_reciclaje}\nImpacto: {impacto}"
        }
        
        return jsonify(respuesta)
        
    except Exception as e:
        logger.error(f"Error al analizar imagen: {e}")
        return jsonify({
            "success": False,
            "message": f"Error al procesar imagen: {str(e)}"
        }), 500

@app.route('/api/chatbot', methods=['POST'])
def chatbot_responder():
    """Endpoint para el chatbot potenciado por OpenAI"""
    try:
        # Obtener el mensaje del usuario
        data = request.get_json()
        if not data or 'mensaje' not in data:
            return jsonify({
                "success": False,
                "message": "No se proporcionó mensaje"
            }), 400
        
        mensaje_usuario = data['mensaje'].strip()
        if not mensaje_usuario:
            return jsonify({
                "success": False,
                "message": "Mensaje vacío"
            }), 400
        
        # Generar respuesta con OpenAI
        respuesta_bot = generar_respuesta_chatbot(mensaje_usuario)
        
        return jsonify({
            "success": True,
            "respuesta": respuesta_bot,
            "timestamp": "2024-01-01T00:00:00Z"
        })
        
    except Exception as e:
        logger.error(f"Error en chatbot: {e}")
        return jsonify({
            "success": False,
            "message": f"Error al procesar mensaje: {str(e)}"
        }), 500

def generar_respuesta_chatbot(mensaje_usuario):
    """Generar respuesta del chatbot usando OpenAI"""
    try:
        # Prompt especializado para el chatbot de reciclaje
        prompt = f"""
        Eres EcoBot, un asistente experto en reciclaje y medio ambiente. Tu trabajo es ayudar a las personas con sus dudas sobre reciclaje de manera amigable y educativa.

        INSTRUCCIONES:
        - Responde SOLO sobre temas de reciclaje, medio ambiente y sostenibilidad
        - Sé amigable, educativo y motivador
        - Usa emojis relacionados con el medio ambiente (🌱♻️🌍🌿💚)
        - Si te preguntan algo no relacionado con reciclaje, redirige amablemente al tema
        - Mantén las respuestas concisas pero informativas
        - Incluye consejos prácticos cuando sea relevante
        - No hagas preguntas de seguimiento a menos que sea necesario para clarificar

        TEMAS QUE PUEDES MANEJAR:
        - Cómo reciclar diferentes materiales
        - Dónde llevar residuos especiales
        - Compostaje casero
        - Símbolos de reciclaje
        - Impacto ambiental
        - Consejos de sostenibilidad
        - Puntos limpios y centros de reciclaje

        USUARIO PREGUNTA: {mensaje_usuario}

        RESPONDE como EcoBot:
        """
        
        # Headers para la API de OpenAI
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {OPENAI_API_KEY}"
        }
        
        # Payload para la API
        payload = {
            "model": "gpt-4o-mini",
            "messages": [
                {
                    "role": "system",
                    "content": "Eres EcoBot, un asistente experto en reciclaje y medio ambiente. Siempre respondes de manera amigable y educativa sobre temas de sostenibilidad."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "max_tokens": 300,
            "temperature": 0.7
        }
        
        # Hacer la llamada a OpenAI
        response = requests.post(OPENAI_API_URL, headers=headers, json=payload)
        
        if response.status_code == 200:
            result = response.json()
            respuesta = result['choices'][0]['message']['content'].strip()
            return respuesta
        else:
            logger.error(f"Error en OpenAI API: {response.status_code} - {response.text}")
            # Respuesta de fallback
            return "🤖 Lo siento, tengo problemas técnicos en este momento. ¿Podrías intentar de nuevo? Mientras tanto, recuerda que reciclar es una excelente manera de cuidar nuestro planeta 🌍"
                
    except Exception as e:
        logger.error(f"Error al generar respuesta de chatbot: {e}")
        # Respuesta de fallback en caso de error
        return "🌱 Disculpa, hay un problema temporal. ¿Podrías repetir tu pregunta? Estoy aquí para ayudarte con todo sobre reciclaje."

@app.route('/api/test-categorias', methods=['GET'])
def test_categorias():
    """Endpoint de prueba para verificar las nuevas categorías"""
    try:
        return jsonify({
            "success": True,
            "message": "Sistema de categorías actualizado",
            "categorias_disponibles": list(CATEGORIAS_RESIDUOS.keys()),
            "categorias_no_reciclables": [
                cat for cat, info in CATEGORIAS_RESIDUOS.items() 
                if not info.get('reciclable', False)
            ],
            "categorias_reciclables": [
                cat for cat, info in CATEGORIAS_RESIDUOS.items() 
                if info.get('reciclable', False)
            ],
            "version": "2.0.0 - Sistema mejorado de detección"
        })
    except Exception as e:
        logger.error(f"Error en test de categorías: {e}")
        return jsonify({
            "success": False,
            "message": "Error en test de categorías"
        }), 500

if __name__ == '__main__':
    print("🚀 Servidor EcoScan v2.0 iniciando en puerto 5000...")
    print("✅ API Key de OpenAI configurada correctamente")
    print("🔧 MEJORAS IMPLEMENTADAS:")
    print("   ✓ Detección mejorada de 'sin residuo'")
    print("   ✓ Clasificación precisa de reciclabilidad")
    print("   ✓ Nuevas categorías: sin_residuo, no_reciclable")
    print("   ✓ Validación de confianza baja")
    print("   ✓ Prompt mejorado para OpenAI")
    print("")
    print("🔍 Endpoints disponibles:")
    print("   - GET  /api/estado")
    print("   - GET  /api/categorias") 
    print("   - GET  /api/test-categorias")
    print("   - POST /api/analizar (MEJORADO)")
    print("   - POST /api/chatbot (NUEVO - OpenAI)")
    print("=" * 60)
    
    # Ejecutar servidor
    app.run(host='0.0.0.0', port=5000, debug=True) 