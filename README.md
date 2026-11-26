# XGARAGE

A full-stack valet operations and scheduled vehicle departure platform engineered for private residential garages, commercial compounds, and high-density valet operations.

The system replaces manual valet coordination with an automated queue prioritized by scheduled pickup times, integrates recurring morning departure schedules, handles car wash requests, and tracks vehicle parking spots and physical key hooks in real time.

---

## Architecture Overview

```
XGARAGE/
├── android/          # Android platform project & Gradle configuration
├── assets/           # Brand assets, high-res graphics, and launcher icons
├── backend/          # Laravel 11 REST API (PHP 8.3, Sanctum, Service Layer)
├── database/         # MySQL schema dump (xgarage_db.sql) ready for phpMyAdmin
├── ios/              # iOS platform runner
├── lib/              # Flutter 3 / Dart 3 mobile application
│   ├── core/         # Theme, glassmorphism tokens, network client, DI, router
│   └── features/     # Feature-first modules (auth, owner, employee, settings, splash)
├── test/             # Flutter unit & widget tests
└── pubspec.yaml      # Flutter dependencies & asset registrations
```

---

## Tech Stack

### Mobile Frontend (`Flutter 3 / Dart 3`)
- **Architecture:** Feature-first Clean Architecture (Domain Entities $\rightarrow$ Data DTOs/Repositories $\rightarrow$ Presentation Cubits/Pages).
- **State Management:** `flutter_bloc` / `Cubit` with strictly typed, sealed state hierarchies.
- **Design System:** Custom Dark Obsidian Glassmorphism system (`#0F0E13` background, `#D9385A` crimson neon accents, layered backdrop blur filters, and hairline gradient borders).
- **Localization:** Native bilingual engine supporting Arabic (RTL) and English (LTR) with instant runtime switching (`GoogleFonts.cairo` and `GoogleFonts.plusJakartaSans`).
- **Networking:** Resilient `Dio` HTTP client with auto-recovering multi-host probe fallback (supports Laragon Apache on port 80, `php artisan serve` on port 8000, and local network Wi-Fi IP).

### Backend API (`Laravel 11 / PHP 8.3`)
- **Authentication:** Laravel Sanctum with device-named token issuance and revocation.
- **Design Pattern:** Thin Controllers $\rightarrow$ FormRequest Validation $\rightarrow$ Service Layer with `DB::transaction` atomic execution $\rightarrow$ JsonResource envelopes.
- **Enums (PHP 8.3):** Backed enums for `UserRole`, `VehicleStatus`, `WashType`, `WashStatus`, `PickupRequestStatus`, and `PickupRequestSource`.
- **Code Quality:** Automated Pest/PHPUnit feature test suite and Pint coding style enforcement.

### Database (`MySQL 8`)
- Relational schema with normalized tables: `users`, `vehicles`, `daily_schedules`, `pickup_requests`, `vehicle_status_logs`, and `personal_access_tokens`.
- Automated foreign keys, cascade deletes, and composite indexes for queue lookups.

---

## Core Workflows

### 1. Vehicle Owners
- **Daily Recurring Departure:** Set recurring morning departure times (e.g. Sunday–Thursday at 08:30 AM) with automatic weekend exclusions and single-day skip toggles.
- **Wash Scheduling:** Request integrated wash services (Exterior, Interior, or Full Wash) attached to morning departures or requested ad-hoc.
- **Immediate Retrieval:** Trigger an on-demand "Take Car Out" request with real-time status updates (`Scheduled` $\rightarrow$ `Washing` $\rightarrow$ `Ready` $\rightarrow$ `Delivered`).
- **Vehicle Profiles:** Manage multiple vehicles with Egyptian-standard license plate badges, color codes, parking spot tracking, and custom driver notes.

### 2. Valet & Garage Staff
- **Departure Queue:** Chronologically ordered departure queue showing vehicles due for departure, requested wash services, parking spot coordinates, and key hook numbers.
- **Live Spot & Hook Management:** Reassign parking spots (e.g. `B1-04`) and key hook IDs (`Hook #04`) with audit logging.
- **One-Tap Status Progression:** Transition vehicle statuses (`parked` $\rightarrow$ `scheduled` $\rightarrow$ `washing` $\rightarrow$ `ready` $\rightarrow$ `delivered`) with automatic timestamp tracking.
- **Garage Capacity KPIs:** Live metrics showing vehicles inside, departures scheduled today, pending washes, and ready vehicles.

---

## Quickstart Guide

### Prerequisites
- Flutter SDK `^3.24.0`
- PHP `^8.3`
- Composer `^2.7`
- MySQL `^8.0` (or Laragon / XAMPP)

---

### Step 1: Database Setup

You can either import the pre-configured database or run Laravel migrations.

#### Option A: Import SQL Dump (Recommended)
1. Open **phpMyAdmin** (or MySQL CLI).
2. Create a new database named `xgarage_db` with collation `utf8mb4_unicode_ci`.
3. Import `database/xgarage_db.sql`:
   ```sql
   mysql -u root -p xgarage_db < database/xgarage_db.sql
   ```

#### Option B: Run Migrations & Seeders
```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate:fresh --seed
```

---

### Step 2: Start Backend Server

If you use **Laragon**, the project is automatically available at:
```
http://127.0.0.1/garage_back/public/api/v1
```

If you use the built-in **Artisan** development server:
```bash
cd backend
php artisan serve --port=8000
```

---

### Step 3: Run Mobile Application

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

*Note:* The Flutter app features automatic backend host discovery. When launched on an Android Emulator, it connects to Laragon on `10.0.2.2/garage_back/public/api/v1` or Artisan on `10.0.2.2:8000/api/v1` automatically. You can also change the host live from the in-app **Settings $\rightarrow$ Connected Garage Server** screen.

---

## Demo Credentials

The seeded database includes the following ready-to-test accounts:

| Role | Phone | Password | Description |
| :--- | :--- | :--- | :--- |
| **Valet Lead** | `01000000001` | `password123` | Employee access with full queue & vehicle spot management |
| **Car Owner** | `01011111111` | `password123` | Owner profile (Tarek Mansour) with pre-configured Mercedes C200 |
| **Car Owner** | `01022222222` | `password123` | Owner profile (Sarah Khalil) with BMW 320i |
| **Car Owner** | `01033333333` | `password123` | Owner profile (Omar Farouk) with Audi A4 |

---

## API Endpoints (`/api/v1`)

### Authentication
- `POST /api/v1/auth/login` — Phone/password authentication, returns Sanctum token
- `POST /api/v1/auth/register` — Owner self-registration with initial vehicle setup
- `GET /api/v1/auth/me` — Authenticated user profile
- `POST /api/v1/auth/logout` — Revoke current access token

### Owner Endpoints
- `GET /api/v1/owner/dashboard` — Primary vehicle, daily schedule, and active departure request
- `GET /api/v1/owner/vehicles` — List owner vehicles
- `POST /api/v1/owner/vehicles` — Add new vehicle
- `POST /api/v1/owner/daily-schedule` — Upsert recurring schedule
- `POST /api/v1/owner/pickup-requests` — Request immediate or scheduled departure

### Valet Employee Endpoints
- `GET /api/v1/employee/queue` — Today's prioritized queue & garage summary KPIs
- `PATCH /api/v1/employee/vehicles/{id}/spot` — Update parking spot and key hook ID
- `PATCH /api/v1/employee/vehicles/{id}/status` — Advance vehicle and wash status

---

## Running Tests

### Flutter Tests
```bash
flutter analyze
flutter test
```

### Laravel Tests
```bash
cd backend
php artisan test
vendor/bin/pint --test
```

---

## License

This project is licensed under the MIT License.
