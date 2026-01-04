class Elemento {
  final String nombre;
  final String categoria;
  final bool reciclable;
  final String recomendacion;
  final String categoriaInfo;
  final List<String> ejemplosSimilares;
  final String estadoReciclaje;

  Elemento({
    required this.nombre,
    required this.categoria,
    required this.reciclable,
    required this.recomendacion,
    required this.categoriaInfo,
    required this.ejemplosSimilares,
    required this.estadoReciclaje,
  });

  factory Elemento.fromJson(Map<String, dynamic> json) {
    return Elemento(
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      reciclable: json['reciclable'] ?? false,
      recomendacion: json['recomendacion'] ?? '',
      categoriaInfo: json['categoria_info'] ?? '',
      ejemplosSimilares: List<String>.from(json['ejemplos_similares'] ?? []),
      estadoReciclaje: json['estado_reciclaje'] ?? '',
    );
  }
}

class RespuestaAnalisis {
  final bool success;
  final Analisis? analisis;
  final String? error;
  final String? mensaje;
  final String? textoCompleto;

  RespuestaAnalisis({
    required this.success,
    this.analisis,
    this.error,
    this.mensaje,
    this.textoCompleto,
  });

  factory RespuestaAnalisis.fromJson(Map<String, dynamic> json) {
    return RespuestaAnalisis(
      success: json['success'] ?? false,
      analisis: json['analisis'] != null ? Analisis.fromJson(json['analisis']) : null,
      error: json['error'],
      mensaje: json['mensaje'],
      textoCompleto: json['texto_completo'],
    );
  }

  factory RespuestaAnalisis.error(String errorMsg) {
    return RespuestaAnalisis(
      success: false,
      error: 'Error',
      mensaje: errorMsg,
    );
  }
}

class Analisis {
  final List<Elemento> elementos;
  final String resumen;

  Analisis({
    required this.elementos,
    required this.resumen,
  });

  factory Analisis.fromJson(Map<String, dynamic> json) {
    return Analisis(
      elementos: json['elementos'] != null
          ? List<Elemento>.from(
              json['elementos'].map((x) => Elemento.fromJson(x)))
          : [],
      resumen: json['resumen'] ?? '',
    );
  }
} 