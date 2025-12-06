# PickPocketCounter

Un addon para **Turtle WoW** (Vanilla 1.18) que rastrea todas las estadísticas de la habilidad **Robar** (Pick Pocket) de los Rogues.

![WoW Version](https://img.shields.io/badge/WoW-1.18%20Vanilla-blue)
![Turtle WoW](https://img.shields.io/badge/Turtle%20WoW-Compatible-green)
![Version](https://img.shields.io/badge/Version-2.0-orange)

## Características

### 📊 Estadísticas Completas
- **Dinero robado** (sesión y total)
- **Intentos de robo** (sesión y total)
- **Robos exitosos con dinero**
- **Items robados** con conteo individual por tipo

### 🏆 Sistema de Milestones
- **39 logros** divididos en tres categorías:
  - **Intentos**: Desde "Primer Intento" hasta "Dios de los Ladrones"
  - **Dinero**: Desde "Primeras Monedas" hasta "Dios de la Fortuna"
  - **Items**: Desde "Primer Botín" hasta "Tesoro Nacional"
- **Efectos de sonido** al desbloquear cada milestone
- **Mensajes especiales** en el chat

### 💾 Datos Persistentes
Todas las estadísticas se guardan entre sesiones:
- Total de dinero robado
- Número de intentos
- Items robados (con cantidad por tipo)
- Milestones desbloqueados

## Instalación

1. Descarga o clona este repositorio
2. Copia la carpeta `PickPocketCounter` a tu directorio de addons:
   ```
   Turtle WoW/Interface/AddOns/PickPocketCounter/
   ```
3. Reinicia el juego o usa `/reload`
4. ¡Listo! El addon solo se activa para personajes Rogue

## Comandos

| Comando | Descripción |
|---------|-------------|
| `/ppc` | Muestra estadísticas generales |
| `/ppc items` | Lista todos los items robados con cantidad |
| `/ppc milestones` | Muestra los milestones alcanzados |
| `/ppc help` | Muestra la ayuda de comandos |
| `/ppc clear` | Limpia todas las estadísticas (requiere confirmación) |
| `/ppc debug` | Activa/desactiva el modo debug |

## Ejemplo de Uso

```
/ppc
=== PickPocketCounter ===
Sesion: 5g 23s 40c
Total: 127g 85s 12c
Intentos (sesion/total): 45/1523
Robos con dinero: 1205
Items robados: 847
```

```
/ppc items
=== Items Robados ===
  [Lengüetazo de Sal Seca] x45
  [Vela Derretida] x23
  [Bolsa de Monedas Pequeña] x12
  [Manzana Roja Lustrosa] x8
  ...
```

```
/ppc milestones
=== Milestones Alcanzados ===
  [X] Primer Intento
  [X] Manos Inquietas
  [X] Aprendiz de Ladron
  [X] Primeras Monedas
  [X] Primer Botin
Progreso: 5/39
```

## Milestones

### Intentos
| Cantidad | Título |
|----------|--------|
| 1 | Primer Intento |
| 10 | Manos Inquietas |
| 50 | Aprendiz de Ladrón |
| 100 | Carterista Novato |
| 250 | Dedos Ágiles |
| 500 | Ladrón Callejero |
| 1,000 | Ladrón Profesional |
| 2,500 | Sombra Silenciosa |
| 5,000 | Maestro del Hurto |
| 7,500 | Fantasma de Bolsillos |
| 10,000 | Gran Maestro Ladrón |
| 25,000 | Leyenda del Hampa |
| 50,000 | El Inmaterial |
| 100,000 | Dios de los Ladrones |

### Dinero
| Cantidad | Título |
|----------|--------|
| 1s | Primeras Monedas |
| 5s | Monedero Ligero |
| 10s | Bolsillo Caliente |
| 50s | Plata Fácil |
| 1g | Primer Oro |
| 5g | Ladrón de Oro |
| 10g | Bolsillos de Oro |
| 25g | Manos de Oro |
| 50g | Fortuna Robada |
| 100g | Barón del Crimen |
| 250g | Magnate Sombrío |
| 500g | Rey del Bajo Mundo |
| 1,000g | Emperador de las Sombras |
| 5,000g | El Intocable |
| 10,000g | Dios de la Fortuna |

### Items
| Cantidad | Título |
|----------|--------|
| 1 | Primer Botín |
| 25 | Coleccionista Novato |
| 50 | Coleccionista |
| 100 | Acumulador |
| 250 | Almacén Ambulante |
| 500 | Almacén Andante |
| 1,000 | Rey de los Items |
| 2,500 | Museo del Robo |
| 5,000 | Bóveda Personal |
| 10,000 | Tesoro Nacional |

## Archivos

```
PickPocketCounter/
├── PickPocketCounter.toc    # Archivo de configuración del addon
├── PickPocketCounter.lua    # Código principal
└── README.md                # Este archivo
```

## Compatibilidad

- ✅ Turtle WoW
- ✅ Interfaz en Español

## Notas Técnicas

- El addon detecta la habilidad "Robar" mediante hooks en `UseAction` y `CastSpellByName`
- El dinero se calcula comparando el oro del jugador antes y después del robo
- Debido al timing de Turtle WoW, el dinero se detecta ~40 frames después de cerrar la ventana de loot
- Los items se detectan mediante el evento `CHAT_MSG_LOOT`

## Créditos

- **Autor Original**: Avis57
- **Actualizado para Turtle WoW**: Con ayuda de Claude (Anthropic)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

*¡Que tus bolsillos siempre estén llenos! 🗡️💰*
