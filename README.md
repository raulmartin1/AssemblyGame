
# CandyNDS Fase 1

Este proyecto es una implementación inicial del juego **Candy Crush** en formato simplificado, como parte del curso en Computadors, GEI (URV). La fase 1 utiliza un modo de texto para la representación del tablero y las interacciones, mientras que la fase 2 introducirá gráficos.

## Tabla de Contenidos

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Requisitos del Entorno](#requisitos-del-entorno)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Dinámica del Juego](#dinámica-del-juego)
5. [Contribución](#contribución)

---

## Descripción del Proyecto

CandyNDS es una versión simplificada de Candy Crush que incluye:
- Intercambio de dos elementos adyacentes para formar secuencias de 3 o más.
- Tablero inicial de 9x9 (modo texto).
- Variación en elementos, puntuación, gelatinas, y sugerencias.
- Implementado con rutinas en ensamblador ARM.

---

## Requisitos del Entorno

1. **Entorno de desarrollo:**  
   - `devkitPro` (1.6.0) → `devkitARM` para compilación.
   - Emulador `DeSmuME` (0.9.11) para depuración y ejecución.
   - Carpeta de instalación recomendada: `C:\URV\bmde.zip`.

2. **Configuración del sistema:**  
   - Variables de entorno ajustadas para `PATH`.

---

## Estructura del Proyecto

El proyecto se divide en múltiples rutinas esenciales:
- `candy1_init.s`: Inicialización y recombinación del tablero.
- `candy1_secu.s`: Detección y eliminación de secuencias.
- `candy1_move.s`: Manejo de caídas y conteo de repeticiones.
- `candy1_comb.s`: Detección y sugerencia de combinaciones.

Además, incluye un programa principal `candy1_main.c` que gestiona el flujo del juego.

---

## Dinámica del Juego

1. **Inicialización del tablero:** Se generan elementos aleatorios evitando secuencias iniciales.
2. **Jugadas:** El usuario intercambia elementos colindantes en horizontal o vertical.
3. **Caídas:** Los elementos superiores llenan los espacios vacíos tras una jugada.
4. **Puntuación:** Basada en la longitud de las secuencias y los combos formados.
5. **Gelatinas:** Deberán eliminarse para superar el nivel.
6. **Movimientos:** Número limitado por nivel; deben usarse estratégicamente.
7. **Sugerencias y recombinación:** Se ofrecen pistas o se reordena el tablero si no hay movimientos posibles.

---

## Contribución

1. **Tareas asignadas por roles:**
   - Cada estudiante implementa y prueba 2 rutinas como mínimo.
2. **Integración:**
   - Las tareas individuales se fusionan en una versión final del proyecto.
3. **Control de versiones:**
   - Uso de ramas por tarea (prog1, prog2, etc.) con commits regulares.

---

