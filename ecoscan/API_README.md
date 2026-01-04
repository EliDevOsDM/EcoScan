# API de Análisis de Residuos - EcoScan

Esta API permite analizar imágenes de residuos usando OpenAI Vision para clasificar diferentes tipos de desechos.

## Instalación

### 1. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 2. Configurar API Key de OpenAI
Crea un archivo `.env` en la raíz del proyecto:
```
OPENAI_API_KEY=tu_api_key_de_openai_aqui
```

O configura la variable de entorno directamente:
```bash
export OPENAI_API_KEY="tu_api_key_de_openai_aqui"
```

### 3. Ejecutar la API
```bash
python backend_api.py
```

La API estará disponible en `http://localhost:5000`

## Endpoints

### GET `/api/estado`
Verifica el estado de la API

**Respuesta:**
```json
{
    "success": true,
    "message": "API funcionando correctamente",
    "version": "1.0.0"
}
```

### GET `/api/categorias`
Obtiene todas las categorías de residuos disponibles

**Respuesta:**
```json
{
    "success": true,
    "categorias": {
        "organicos": {
            "nombre": "Residuos Orgánicos",
            "descripcion": "Restos de comida, cáscaras de frutas, verduras",
            "color": "#4CAF50",
            "consejos": ["Ideal para compostaje", "Se descompone naturalmente"]
        }
        // ... más categorías
    }
}
```

### POST `/api/analizar`
Analiza una imagen de residuo

**Parámetros:**
- `imagen` (archivo): Imagen a analizar
- O `base64` (string): Imagen en formato base64

**Respuesta exitosa:**
```json
{
    "success": true,
    "resultado": {
        "categoria": "plastico",
        "nombre_categoria": "Plástico",
        "confianza": 95,
        "descripcion": "Botella de plástico PET",
        "consejos_reciclaje": ["Reciclar en contenedor azul", "Lavar antes de reciclar"],
        "impacto_ambiental": "El plástico tarda hasta 450 años en descomponerse",
        "color_categoria": "#2196F3",
        "timestamp": "2024-01-01T00:00:00Z"
    }
}
```

## Categorías de Residuos

- **organicos**: Residuos orgánicos (comida, restos vegetales)
- **plastico**: Plásticos (botellas, envases, bolsas)
- **papel**: Papel y cartón
- **vidrio**: Envases de vidrio
- **metal**: Latas y objetos metálicos
- **electronico**: Residuos electrónicos
- **toxico**: Residuos tóxicos o peligrosos

## Obtener API Key de OpenAI

1. Ve a [OpenAI Platform](https://platform.openai.com/)
2. Crea una cuenta o inicia sesión
3. Ve a la sección "API Keys"
4. Crea una nueva API key
5. Copia la key y úsala en tu archivo `.env`

## Notas

- Asegúrate de tener saldo en tu cuenta de OpenAI para usar la API
- La API usa el modelo `gpt-4-vision-preview` para análisis de imágenes
- Las imágenes se procesan localmente antes de enviarlas a OpenAI

## Troubleshooting

### Error: "OPENAI_API_KEY no está configurada"
- Verifica que hayas configurado tu API key correctamente
- Si usas archivo `.env`, asegúrate de que esté en la raíz del proyecto

### Error de conexión con OpenAI  
- Verifica que tu API key sea válida
- Revisa que tengas saldo disponible en tu cuenta de OpenAI
- Comprueba tu conexión a internet 