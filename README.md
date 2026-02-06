# SketchMage

**Slogan:** Donde los trazos se vuelven vida y la motricidad se vuelve magia.

## Versión: 1.0 (Final Hackathon Scope)
**Categoría:** Educación / AR / Multimodalidad
**Tecnología Núcleo:** Google Gemini (Multimodal & Low Latency)

## Concepto
SketchMage es una aplicación de Realidad Aumentada Asistida por IA diseñada para el desarrollo de la motricidad fina en niños. A diferencia de las apps tradicionales que ocurren solo en la pantalla, SketchMage utiliza la cámara y la visión de Gemini para convertir el papel físico en un escenario interactivo.

El núcleo de la experiencia es la mecánica **"The Living Path" (El Sendero Vivo)**, donde los dibujos estáticos del niño son interpretados por la IA en real-time, validados por su precisión motriz y transformados en objetos digitales que interactúan con personajes virtuales.

## La Innovación Central: "The Living Path"
Definición: El juego no avanza tocando la pantalla, sino dibujando físicamente conexiones en el papel que la IA debe validar espacial y físicamente.

### Flujo de Interacción:
1. **Problema:** Un personaje virtual (ej. un conejo) está atrapado en el lado izquierdo de la hoja de papel.
2. **Prompt Visual:** La IA resalta el vacío entre el personaje y su meta.
3. **Acción Física:** El niño dibuja una línea (un puente) en el papel real.
4. **Juicio de la IA (Gemini):** Analiza si la línea conecta los puntos, si el trazo es sólido y si la inclinación es correcta.
5. **Resultado Mágico:** Si es válido, la línea se transforma en un puente 3D en pantalla y el personaje cruza.

## Estructura de Contenido

### Modo Aventura: Los 5 Niveles de Maestría Motriz
1. **La Lluvia de Vida (Trazos Verticales):** Coordinación ojo-mano.
2. **El Escudo Burbuja (Trazos Circulares):** Cierre de formas.
3. **Cruzar el Abismo (Trazos Horizontales):** Conexión de puntos.
4. **La Montaña del Rayo (Diagonales/Zig-Zag):** Cambios de dirección.
5. **El Vuelo Acrobático (Bucles):** Fluidez motriz (pre-cursiva).

### Modo Creativo: "El Lienzo Infinito"
Usa IA Generativa para identificar dibujos libres del niño y proponer retos contextuales dinámicos.

## Arquitectura Técnica
- **Frontend:** Flutter
- **IA:** Google Gemini API (Flash para baja latencia)
- **Generación de Assets:** Imagen 4 (vía API)
- **Backend:** Firebase

## Crear .env
GEMINI_API_KEY=


## Roadmap Hackathon (MVP)
1. Interfaz de cámara funcional con overlay AR.
2. Integración con Gemini respondiendo en < 2 segundos.
3. Nivel 3 (El Puente) totalmente jugable.
4. Demo del Modo Creativo con reconocimiento de objetos.
