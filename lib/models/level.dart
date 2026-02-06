class Level {
  final int id;
  final String title;
  final String mission;
  final String skill;
  final String scenarioDescription;
  final String systemPrompt;

  Level({
    required this.id,
    required this.title,
    required this.mission,
    required this.skill,
    required this.scenarioDescription,
    required this.systemPrompt,
  });
}

final List<Level> adventureLevels = [
  Level(
    id: 1,
    title: "La Lluvia de Vida",
    skill: "Trazos Verticales",
    mission: "¡Las flores tienen sed! Dibuja la lluvia cayendo desde la nube hasta la tierra.",
    scenarioDescription: "Un jardín seco con flores marchitas.",
    systemPrompt: "Identifica trazos verticales. Valida si caen de la zona superior a la inferior. Retorna JSON con 'isValid', 'quality' (0-1) y 'points' (trayectoria).",
  ),
  Level(
    id: 2,
    title: "El Escudo Burbuja",
    skill: "Trazos Circulares",
    mission: "¡Rápido! Dibuja un círculo cerrado alrededor del personaje para protegerlo.",
    scenarioDescription: "Personaje acechado por mosquitos.",
    systemPrompt: "Identifica un trazo circular. Valida si está cerrado (inicio y fin cercanos). Retorna JSON con 'isValid', 'isClosed' y 'bounds'.",
  ),
  Level(
    id: 3,
    title: "Cruzar el Abismo",
    skill: "Trazos Horizontales",
    mission: "Necesitamos cruzar. Dibuja un tronco fuerte de un lado al otro.",
    scenarioDescription: "Dos acantilados separados por un río.",
    systemPrompt: "Busca un trazo horizontal que conecte el lado izquierdo (x<200) con el derecho (x>800). Retorna JSON con 'isValid', 'connectivity' y 'path_coordinates'.",
  ),
];
