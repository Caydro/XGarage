# Design System & Glassmorphism Tokens — XGarage

## 1. Visual Theme: Crimson Obsidian Glassmorphism
A luxurious, dark, high-contrast palette inspired by high-end automotive styling and dark obsidian glass with neon rose/crimson accents.

### 1.1 Color Tokens
- **Backgrounds:**
  - `bgPrimary`: `#0F0E13` (Deep Obsidian Black)
  - `bgSecondary`: `#17151E` (Dark Charcoal Plum)
  - `bgElevated`: `#1E1B26` (Midnight Card Foundation)
  - `surfaceCard`: `#1E1B26` with alpha `0.72`
  - `surfaceInput`: `#252130` (Input Fields, Secondary Pills)
- **Brand Accents:**
  - `primaryCrimson`: `#D9385A` (Vibrant Crimson Rose)
  - `primaryCrimsonDark`: `#A31D3B` (Deep Ruby)
  - `primaryGlow`: `#E11D48` (Ambient Radial Mesh Glow at 18%)
  - `accentRoseSoft`: `#3B1825` (Subtle Tag / Badge Tint)
  - `accentRoseBorder`: `#FF5C7C`
- **Glass Borders:**
  - `glassBorderHighlight`: `#FF5C7C` with alpha `0.35` (Top-Left Rim, 1.2px)
  - `glassBorderSubtle`: `#FFFFFF` with alpha `0.08` (Bottom-Right Rim)
- **Typography Colors (WCAG AA >= 4.5:1):**
  - `textPrimary`: `#FFFFFF` (Crisp White)
  - `textSecondary`: `#B4B0C2` (Cool Silver-Lavender)
  - `textMuted`: `#78738A` (Muted Slate)
- **Status Accents:**
  - `statusReady`: `#10B981` (Emerald Green) on `#0F2E24`
  - `statusWashing`: `#38BDF8` (Cyan Sky Blue) on `#0F293A`
  - `statusScheduled`: `#F59E0B` (Warm Amber) on `#33240E`
  - `statusDanger`: `#F43F5E` (Neon Rose Red) on `#38141F`

### 1.2 Typography
- Arabic: `Cairo` (Weights: 400, 500, 600, 700, 800)
- English: `Plus Jakarta Sans` (Weights: 400, 500, 600, 700, 800)
- Plate Numbers: Bold Monospace / Cairo Heavy for Arabic numbers (`١٢٣٤`)

### 1.3 Tactile Components
- `GlassContainer`: Translucent surface with layered gradient border and backdrop blur for hero cards and navigation bars. Translucent non-blur gradient cards inside `ListView.builder` for peak 60fps rendering.
- `LicensePlateBadge`: Physical split-plate design with Arabic plate text (`أ ب ج | ١٢٣٤`), Latin transliteration, and authentic country stripe.
- `AppButton`: Tactile scale animation (0.97 on press), soft crimson glow shadow, haptic feedback, and built-in loading spinner that locks double-taps.
