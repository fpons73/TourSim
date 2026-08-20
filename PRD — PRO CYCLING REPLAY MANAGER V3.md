

**Versión:** 3.0  
**Plataforma:** Windows 11 (PC)  
**Género:** Simulador Deportivo / Estrategia / Replay Manager  
**Jugadores:** 1  
**Motor:** Godot 4.x  
**Lenguaje recomendado:** GDScript, con posibilidad de C# si se considera necesario  
**Input:** Ratón y teclado; táctil opcional

---

# 1. Rol del Asistente (Meta Prompting)

Eres un desarrollador de software experto de clase mundial en Godot 4.x, GDScript/C#, UI, bases de datos y simuladores deportivos.

Tu objetivo es construir **Pro Cycling Replay Manager** para Windows 11 siguiendo estrictamente este documento.

La aplicación debe combinar:

- simulador de ciclismo;
    
- replay de reglas de juego de mesa;
    
- gestor de etapas;
    
- editor de carreras;
    
- editor de participantes;
    
- simulador histórico;
    
- modo espectador;
    
- modo jugador/controlador.
    

La prioridad es construir una aplicación sólida, clara y visualmente atractiva sin sacrificar la profundidad estadística ni la fidelidad del motor de simulación.

No sustituir las reglas existentes por mecánicas nuevas sin necesidad.

Los nuevos sistemas deben integrarse con el motor existente.

---

# 2. Descripción General y Visión

**Pro Cycling Replay Manager** es un simulador de ciclismo de carretera que transforma el sistema de replay del juego de mesa original en una aplicación digital completa.

El usuario debe poder decidir qué quiere hacer desde el menú principal:

1. Correr una etapa existente.
    
2. Correr una carrera completa.
    
3. Crear una etapa.
    
4. Editar una etapa.
    
5. Crear una carrera.
    
6. Editar una carrera.
    
7. Elegir participantes.
    
8. Simular como espectador.
    
9. Controlar un equipo durante la carrera.
    
10. Consultar resultados y estadísticas históricas.
    

El objetivo no es crear un juego de conducción, sino un **simulador táctico/deportivo**.

---

# 3. Stack y Restricciones Técnicas

## Motor

**Godot 4.x**

La arquitectura debe separar completamente:

### Simulation Core

Responsable de:

- reglas;
    
- RNG;
    
- dados;
    
- corredores;
    
- equipos;
    
- grupos;
    
- tiempos;
    
- fatiga;
    
- IA;
    
- clasificación;
    
- eventos.
    

### Presentation Layer

Responsable de:

- interfaz;
    
- animaciones;
    
- visualización de carrera;
    
- mapas/perfiles;
    
- paneles;
    
- dados;
    
- transiciones.
    

### Data Layer

Responsable de:

- SQLite;
    
- JSON;
    
- CSV;
    
- partidas guardadas;
    
- etapas;
    
- carreras;
    
- equipos;
    
- corredores.
    

La interfaz nunca debe contener directamente la lógica de simulación.

---

# 4. Arquitectura de Datos

## Entidades principales

### Rider

Contendrá:

- identidad;
    
- nacionalidad;
    
- edad;
    
- equipo;
    
- dorsal;
    
- especializaciones;
    
- 14 atributos;
    
- estado;
    
- fatiga;
    
- estadísticas históricas.
    

### Team

Contendrá:

- nombre;
    
- abreviatura;
    
- país;
    
- color principal;
    
- color secundario;
    
- plantilla;
    
- líder;
    
- roles.
    

### Stage

Contendrá:

- nombre;
    
- fecha;
    
- distancia;
    
- tipo;
    
- perfil;
    
- secciones;
    
- terreno;
    
- puertos;
    
- viento;
    
- adoquines;
    
- sprint;
    
- meta;
    
- reglas;
    
- parámetros de simulación.
    

### Race

Contendrá:

- nombre;
    
- edición;
    
- descripción;
    
- fechas;
    
- país;
    
- etapas;
    
- orden de etapas;
    
- participantes;
    
- reglas de clasificación.
    

Una carrera puede contener cualquier número configurable de etapas.

No limitar artificialmente el editor a 21 etapas.

Debe ser posible crear:

- carreras de 1 etapa;
    
- carreras de 3 etapas;
    
- carreras de 7 etapas;
    
- carreras de 21 etapas;
    
- carreras personalizadas.
    

---

# 5. Sistema de Corredores

Los corredores utilizan los 14 atributos establecidos en V2.0.

Todos tienen escala:

**50–99**

## Atributos

1. Llano.
    
2. Montaña.
    
3. Media Montaña.
    
4. Colina.
    
5. Crono.
    
6. Prólogo.
    
7. Pavés.
    
8. Sprint.
    
9. Aceleración.
    
10. Descenso.
    
11. Ataque.
    
12. Aguante.
    
13. Resistencia.
    
14. Recuperación.
    

Los atributos son permanentes.

La fatiga es dinámica.

---

# 6. Biblioteca Principal

La aplicación debe disponer de una pantalla inicial moderna.

## Menú principal

Opciones principales:

### Correr

Permite seleccionar:

- una etapa;
    
- una carrera.
    

### Crear

Permite:

- crear etapa;
    
- crear carrera.
    

### Editar

Permite:

- editar etapas;
    
- editar carreras;
    
- editar equipos;
    
- editar corredores.
    

### Histórico

Permite consultar:

- carreras;
    
- etapas;
    
- resultados;
    
- clasificaciones;
    
- simulaciones anteriores.
    

### Configuración

Permite:

- idioma;
    
- sonido;
    
- animaciones;
    
- velocidad;
    
- tema;
    
- accesibilidad;
    
- RNG/seed.
    

---

# 7. Selección de Etapa

Al seleccionar **Correr → Etapa**, mostrar una biblioteca visual.

Cada etapa debe aparecer como una tarjeta.

La tarjeta debe mostrar:

- nombre;
    
- distancia;
    
- tipo;
    
- perfil;
    
- fecha;
    
- carrera asociada;
    
- dificultad;
    
- número de participantes configurado.
    

Ejemplo:

**ETAPA 12**

> Col de la Madeleine → Alpe d'Huez  
> 183 km  
> Montaña  
> ★★★★★

El perfil de altitud debe aparecer visualmente en la tarjeta.

El usuario puede:

- jugar;
    
- editar;
    
- duplicar;
    
- eliminar;
    
- ver detalles.
    

Las etapas históricas no deben modificarse directamente.

Para modificarlas:

**Duplicar → editar copia**

---

# 8. Selección de Carrera

Al seleccionar **Correr → Carrera**, mostrar las carreras disponibles.

Cada carrera debe mostrar:

- nombre;
    
- edición;
    
- país;
    
- fechas;
    
- número de etapas;
    
- distancia total;
    
- estado;
    
- miniatura/perfil;
    
- número de equipos.
    

Ejemplo:

**TOUR DE FRANCE 2010**

> 21 etapas  
> 3.642 km  
> 22 equipos

Acciones:

- Comenzar carrera.
    
- Ver etapas.
    
- Editar.
    
- Duplicar.
    
- Ver resultados históricos.
    

---

# 9. Creación y Edición de Etapas

Debe existir un **Stage Editor** completo.

## Información básica

Campos:

- nombre;
    
- fecha;
    
- tipo;
    
- distancia;
    
- descripción;
    
- ubicación salida;
    
- ubicación llegada.
    

## Perfil

Editor visual de perfil de etapa.

El usuario podrá construir una etapa mediante secciones.

Cada sección tendrá:

- inicio;
    
- final;
    
- distancia;
    
- terreno;
    
- pendiente;
    
- categoría;
    
- reglas especiales.
    

Tipos de terreno:

- Llano.
    
- Colina.
    
- Media Montaña.
    
- Montaña.
    
- Descenso.
    
- Pavés.
    
- Viento cruzado.
    

## Elementos especiales

Podrán añadirse:

- puerto;
    
- sprint intermedio;
    
- zona de viento;
    
- sector de pavés;
    
- zona de peligro;
    
- meta;
    
- final en descenso;
    
- final explosivo.
    

## Datos avanzados

Permitir editar:

- Tempo Modifier;
    
- Incident Phase;
    
- Time Factor;
    
- reglas de sprint;
    
- reglas especiales;
    
- seed por defecto.
    

Debe existir un modo:

**Básico / Avanzado**

para que un usuario que no quiera tocar fórmulas pueda crear etapas fácilmente.

---

# 10. Creación y Edición de Carreras

El **Race Editor** permite crear una competición completa.

## Información

- nombre;
    
- edición;
    
- país;
    
- descripción;
    
- fecha de inicio;
    
- fecha de final;
    
- imagen/logo opcional.
    

## Etapas

Panel central con todas las etapas.

Ejemplo:

1. Prólogo
    
2. Etapa 1 — Llana
    
3. Etapa 2 — Media Montaña
    
4. Etapa 3 — Pavés
    
5. Etapa 4 — Llana
    
6. Etapa 5 — Montaña
    

El usuario podrá:

- añadir etapa;
    
- crear nueva etapa;
    
- importar etapa;
    
- duplicar;
    
- eliminar;
    
- reordenar mediante drag & drop.
    

También debe poder reutilizar una misma etapa en distintas carreras mediante copias independientes.

---

# 11. Configuración de Participantes

Antes de comenzar una etapa o carrera se muestra el **Participant Manager**.

El usuario puede seleccionar:

### Equipos

- todos;
    
- selección manual;
    
- número personalizado.
    

### Corredores

Dentro de cada equipo:

- seleccionar/desseleccionar corredores;
    
- elegir plantilla;
    
- sustituir corredores;
    
- asignar roles.
    

Debe ser posible crear una carrera con una combinación completamente personalizada.

Ejemplo:

> 18 equipos  
> 8 corredores por equipo  
> 144 corredores

o cualquier otra configuración válida.

---

# 12. Gestión de Plantillas

Para cada equipo:

- seleccionar corredores;
    
- establecer líder;
    
- establecer sprinter;
    
- establecer escalador;
    
- establecer gregarios;
    
- establecer especialistas.
    

Las etiquetas de rol no modifican artificialmente los atributos.

Sirven para:

- IA;
    
- interfaz;
    
- estrategia;
    
- comportamiento.
    

---

# 13. Configuración de la Partida

Antes de comenzar una etapa o carrera aparece una pantalla de configuración.

## Tipo de control

El usuario elige:

### Modo Espectador

La IA controla todos los equipos.

### Controlar equipo

El usuario selecciona un equipo.

Ese equipo será controlado manualmente durante la simulación.

El resto serán IA.

## Velocidad

- Pausado.
    
- Normal.
    
- Rápido.
    
- Muy rápido.
    
- Resolución automática.
    

## Dados

- Animados.
    
- Instantáneos.
    

## Seed

Opciones:

- aleatoria;
    
- introducir seed;
    
- mostrar seed;
    
- guardar seed.
    

---

# 14. Control del Equipo

Cuando el usuario controla un equipo, el motor genera decisiones tácticas.

Cuando exista una decisión relevante:

**la simulación se detiene y aparece el panel de decisión.**

Ejemplo:

### ATAQUE DETECTADO

**Mathieu van der Poel ataca**

Tu equipo:

**¿Qué quieres hacer?**

- Responder.
    
- Atacar.
    
- Mantener ritmo.
    
- No responder.
    

Las decisiones disponibles dependen de la situación.

---

# 15. IA

La IA controla todos los equipos que no sean del jugador.

La IA utiliza:

- atributos;
    
- fatiga;
    
- posición;
    
- clasificación;
    
- compañeros;
    
- objetivo;
    
- terreno;
    
- distancia;
    
- situación;
    
- importancia de etapa.
    

La IA debe tener en cuenta el contexto de carrera.

Un equipo que lidera la General no debe comportarse igual que un equipo que necesita recuperar 4 minutos.

---

# 16. Modo Espectador

El modo espectador debe ser una experiencia completa.

El usuario puede:

- observar;
    
- pausar;
    
- avanzar sección;
    
- acelerar;
    
- ralentizar;
    
- saltar al sprint;
    
- consultar grupos;
    
- consultar corredores;
    
- consultar clasificación;
    
- revisar decisiones IA.
    

Debe existir un modo:

**“Simulación rápida”**

que permita resolver una etapa sin animaciones.

---

# 17. Nueva Interfaz de Carrera

La interfaz actual mostrada en la captura es funcional pero demasiado espartana.

La V3.0 debe rediseñarla completamente.

No utilizar grandes superficies grises vacías como elemento dominante.

El objetivo visual será:

**Sports Manager moderno + broadcast televisivo de ciclismo + dashboard táctico.**

---

# 18. Pantalla de Carrera — Layout

La pantalla debe dividirse en zonas.

## Barra superior

Mostrar:

- carrera;
    
- etapa;
    
- km;
    
- tiempo;
    
- velocidad de simulación;
    
- modo;
    
- seed.
    

## Zona central

Principal área visual.

Mostrar:

- perfil de etapa;
    
- posición de grupos;
    
- diferencia temporal;
    
- situación de carrera.
    

Los grupos deben representarse mediante elementos visuales atractivos, no simples rectángulos.

---

# 19. Pelotón y Grupos

Cada grupo debe aparecer como una entidad visual.

Ejemplo:

### FUGA

**4 corredores**

`+02:14`

Debajo:

- nombres;
    
- dorsales;
    
- colores de equipos.
    

El pelotón se representa visualmente con una masa de corredores simplificada.

No es necesario animar individualmente a todos los corredores.

La representación debe ser elegante y clara.

---

# 20. Perfil de Etapa

El perfil debe ocupar una parte importante de la interfaz.

Debe mostrar:

- km;
    
- altitud;
    
- puertos;
    
- sprint;
    
- pavés;
    
- viento;
    
- posición actual.
    

La posición actual se marca mediante un indicador animado.

Al pasar el ratón por una sección se muestran:

- distancia;
    
- pendiente;
    
- tipo;
    
- grupo líder;
    
- eventos.
    

---

# 21. Panel Derecho

Panel táctico del equipo.

Si controla el jugador:

Mostrar:

### MIS CORREDORES

|Corredor|Grupo|Fatiga|Estado|
|---|---|--:|---|
|Corredor A|Pelotón|34%|OK|
|Corredor B|Fuga|51%|OK|
|Corredor C|Pelotón|18%|OK|

Cada corredor debe tener acceso a su ficha.

---

# 22. Panel de Eventos

Sustituir el actual log de texto por un **Race Feed** visual.

Ejemplos:

🟡 **ATAQUE**

> Corredor X ataca en km 142.

🔴 **INCIDENTE**

> Tres corredores afectados.

🟢 **FUGA**

> 5 corredores forman el grupo delantero.

🏁 **SPRINT**

> Comienza el sprint final.

El usuario puede desplegar el evento para consultar detalles.

---

# 23. Dados

Los dados actuales deben integrarse visualmente en la interfaz.

En lugar de grandes cuadrados aislados:

- utilizar componentes estilizados;
    
- animación breve;
    
- sombra;
    
- iluminación;
    
- resultado grande;
    
- histórico opcional.
    

El jugador podrá hacer clic para ampliar el resultado.

---

# 24. Decisiones

Cuando sea necesario actuar:

Aparecerá un **Decision Panel** claramente destacado.

Ejemplo:

### TU EQUIPO

**Ataque de Pogacar**

**Situación**

> 42 km para meta  
> Pelotón fragmentado  
> Tu líder está fresco

Opciones:

**ATACAR**  
**SEGUIR**  
**MANTENER**  
**AHORRAR**

Las opciones deben mostrar información contextual.

---

# 25. Ficha del Corredor

Al hacer clic en un corredor:

Mostrar:

### Identidad

- foto/placeholder;
    
- nombre;
    
- nacionalidad;
    
- equipo;
    
- rol.
    

### Atributos

Visualización mediante barras:

**Montaña 94** ████████████████

**Sprint 72** ████████████

**Aceleración 88** ██████████████

Los 14 atributos deben estar agrupados:

### Terreno

- Llano
    
- Media Montaña
    
- Montaña
    
- Colina
    
- Pavés
    

### Especialidades

- Sprint
    
- Aceleración
    
- Ataque
    
- Descenso
    
- Crono
    
- Prólogo
    

### Físico

- Aguante
    
- Resistencia
    
- Recuperación
    

---

# 26. Identidad Visual

La aplicación debe abandonar el aspecto de prototipo.

## Estilo

Inspiración conceptual:

- aplicaciones deportivas profesionales;
    
- dashboards de simulación;
    
- retransmisiones de ciclismo;
    
- gestores deportivos.
    

No copiar visualmente una aplicación concreta.

## Paleta

Base oscura:

- fondo azul/gris muy oscuro;
    
- paneles ligeramente más claros;
    
- blanco para información;
    
- gris para información secundaria.
    

Colores de estado:

- amarillo → líder / objetivo;
    
- verde → ventaja / positivo;
    
- rojo → ataque / peligro;
    
- azul → información;
    
- naranja → esfuerzo;
    
- violeta → clasificación especial.
    

---

# 27. Sistema Visual de Equipos

Cada equipo tendrá:

- color principal;
    
- color secundario;
    
- icono/logo;
    
- abreviatura.
    

Los colores deben aparecer consistentemente en:

- corredores;
    
- grupos;
    
- clasificación;
    
- feed;
    
- fichas;
    
- tablas.
    

El usuario debe poder identificar rápidamente qué equipos forman cada grupo.

---

# 28. Navegación de la Aplicación

La aplicación debe utilizar una navegación coherente.

### Inicio

↓

**Correr**

→ Etapa

→ Carrera

### Crear

→ Nueva etapa

→ Nueva carrera

### Biblioteca

→ Etapas

→ Carreras

→ Equipos

→ Corredores

### Histórico

→ Resultados

→ Carreras

→ Estadísticas

### Configuración

---

# 29. Editor Visual

Los editores deben priorizar interfaces visuales.

No obligar al usuario a editar JSON.

JSON/CSV solo será una opción avanzada/importación-exportación.

## Stage Editor

Debe permitir construir visualmente el perfil.

## Race Editor

Debe permitir ordenar etapas mediante drag & drop.

## Participant Editor

Debe permitir seleccionar equipos y corredores mediante listas y filtros.

---

# 30. Filtros y Búsqueda

Las bibliotecas deben incluir:

- búsqueda por nombre;
    
- tipo;
    
- distancia;
    
- país;
    
- fecha;
    
- dificultad;
    
- equipo;
    
- corredor.
    

Ejemplo:

**Buscar etapas**

> [ montaña ]

Filtros:

`Montaña | >200 km | Final en alto`

---

# 31. Duplicación

Todo contenido creado por el usuario debe poder duplicarse.

Ejemplos:

**Tour 2010**

→ Duplicar

**Tour 2010 — What If**

Después modificar:

- equipos;
    
- corredores;
    
- etapas;
    
- participantes.
    

Esto será fundamental para el modo histórico/What If.

---

# 32. Historial de Simulaciones

Guardar las carreras realizadas.

Cada simulación debe almacenar:

- fecha;
    
- etapa/carrera;
    
- seed;
    
- participantes;
    
- resultados;
    
- decisiones;
    
- clasificaciones.
    

El usuario podrá volver a consultar una simulación.

---

# 33. Comparación de Simulaciones

En una futura ampliación, pero preparar arquitectura para ello:

**Simulación A vs Simulación B**

Comparar:

- ganador;
    
- tiempos;
    
- grupos;
    
- ataques;
    
- abandonos;
    
- clasificaciones.
    

---

# 34. Motor de Simulación

Se mantienen los principios de V2.0.

La secuencia será:

**Etapa**

↓

**Secciones**

↓

**Situación**

↓

**Decisiones**

↓

**RNG**

↓

**Rendimiento**

↓

**Fatiga**

↓

**Tiempo**

↓

**Clasificación**

El jugador y la IA utilizan exactamente el mismo motor.

---

# 35. Sistemas de Carrera

Se mantienen:

- Flat Stage.
    
- Flat Stage Hilly.
    
- Mountain.
    
- Medium Mountain.
    
- ITT.
    
- TTT.
    
- Crosswind.
    
- Cobbles.
    
- Prólogo.
    

Todos deben utilizar los 14 atributos.

---

# 36. Guardado

Debe poder guardarse:

### Partida de etapa

En cualquier momento.

### Carrera completa

Incluyendo el estado entre etapas.

### Contenido creado

- etapas;
    
- carreras;
    
- equipos;
    
- corredores.
    

---

# 37. Importación y Exportación

Soportar:

- JSON;
    
- CSV.
    

Para:

- corredores;
    
- equipos;
    
- etapas;
    
- carreras.
    

El usuario avanzado podrá editar datos externamente.

---

# 38. Requisitos de Rendimiento

El simulador debe poder manejar cómodamente:

- 200+ corredores;
    
- carreras de 21+ etapas;
    
- múltiples grupos;
    
- miles de eventos;
    
- simulaciones rápidas.
    

La simulación rápida no debe necesitar renderizar cada evento visualmente.

---

# 39. Modos de Simulación

### Animado

Visualización completa.

### Normal

Animaciones reducidas.

### Rápido

Resolución acelerada.

### Instantáneo

Calcula toda la etapa y presenta resultado.

Esto será especialmente útil para realizar muchas simulaciones estadísticas.

---

# 40. Roadmap V3.0

## Fase 1 — Base V3

- Migración definitiva a Godot 4.x.
    
- Arquitectura Simulation Core.
    
- Base de datos.
    
- 14 atributos.
    
- Fatiga/Recuperación.
    
- Sistema de equipos/corredores.
    

## Fase 2 — Biblioteca

- Biblioteca de etapas.
    
- Biblioteca de carreras.
    
- Selección de participantes.
    
- Configuración de partida.
    

## Fase 3 — Editores

- Stage Editor.
    
- Race Editor.
    
- Team Editor.
    
- Rider Editor.
    

## Fase 4 — Nueva UI

- Dashboard.
    
- Race View.
    
- Perfil interactivo.
    
- Race Feed.
    
- Decision Panel.
    
- Ficha de corredor.
    
- Dados integrados.
    

## Fase 5 — IA

- IA táctica.
    
- Objetivos de equipo.
    
- Estrategia de carrera.
    
- Modo espectador.
    

## Fase 6 — Histórico

- Importación de carreras.
    
- What If.
    
- Duplicación.
    
- Historial.
    

## Fase 7 — Pulido

- Animaciones.
    
- Sonido.
    
- Transiciones.
    
- Temas.
    
- Accesibilidad.
    
- Optimización.
    

---

# 41. Scope

## Incluido

- Simulación de etapas.
    
- Simulación de carreras.
    
- Modo espectador.
    
- Control de un equipo.
    
- IA.
    
- Selección de equipos.
    
- Selección de corredores.
    
- 14 atributos 50–99.
    
- Fatiga.
    
- Aguante.
    
- Resistencia.
    
- Recuperación.
    
- Fugas.
    
- Pelotón.
    
- Sprint.
    
- Montaña.
    
- Media Montaña.
    
- Colina.
    
- Pavés.
    
- Descenso.
    
- CRI.
    
- Prólogo.
    
- TTT.
    
- Viento cruzado.
    
- Editor de etapas.
    
- Editor de carreras.
    
- Biblioteca de contenido.
    
- Duplicación.
    
- Histórico.
    
- Importación/exportación.
    
- Seed.
    
- Guardado.
    
- Nueva interfaz visual.
    
- Windows 11.
    

## Excluido

Inicialmente:

- Multijugador online.
    
- Gestión económica.
    
- Mercado de fichajes completo.
    
- Contratos.
    
- Patrocinadores.
    
- Entrenamiento avanzado.
    
- Mundo abierto.
    
- Control directo de la bicicleta.
    
- Física de ciclismo en tiempo real.
    
- Animaciones 3D realistas de cada ciclista.
    

---

# 42. Principio Fundamental de la V3.0

**Pro Cycling Replay Manager no debe sentirse como una hoja de cálculo con botones.**

Debe sentirse como un **centro de simulación y retransmisión de ciclismo**.

El usuario debe poder:

**Crear una carrera → seleccionar participantes → elegir su equipo → iniciar → tomar decisiones → observar la carrera → analizar el resultado → modificar la carrera → volver a simularla.**

La profundidad estará en el motor.

La accesibilidad estará en la interfaz.

La rejugabilidad estará en los datos, el editor y las seeds.

La personalidad de la carrera estará en los corredores, equipos, atributos, IA y decisiones.

---

# 43. Nota Final (Chat Mode)

Antes de generar código, el modelo debe leer este documento y confirmar su entendimiento en modo conversación (Chat Mode).

Debe confirmar especialmente:

1. Godot 4.x es el motor.
    
2. Los corredores tienen 14 atributos 50–99.
    
3. La simulación utiliza fatiga, resistencia, aguante y recuperación.
    
4. El jugador puede elegir entre espectador o controlar un equipo.
    
5. Todos los demás equipos son controlados por IA.
    
6. La IA utiliza el mismo motor que el jugador.
    
7. El usuario puede elegir participantes.
    
8. El usuario puede seleccionar etapas existentes.
    
9. El usuario puede seleccionar carreras existentes.
    
10. El usuario puede crear etapas.
    
11. El usuario puede editar etapas.
    
12. El usuario puede crear carreras.
    
13. El usuario puede editar carreras.
    
14. Una carrera puede contener un número configurable de etapas.
    
15. Los contenidos pueden duplicarse.
    
16. La interfaz debe evolucionar desde el prototipo actual hacia un sports manager moderno.
    
17. La lógica de simulación debe permanecer separada de la interfaz.
    
18. JSON/CSV son formatos de datos, pero el usuario no debe estar obligado a editarlos.
    
19. El sistema debe soportar seeds reproducibles.
    
20. La aplicación debe sentirse como un simulador/replay manager de ciclismo y no como una hoja de cálculo.