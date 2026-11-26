# XGarage — EGM Technical Architecture Blueprint & API Contract

## 1. System Overview & Problem Statement
XGarage is a bilingual (Arabic RTL / English LTR) Smart Garage & Valet Management platform connecting Car Owners (`owner`) and Garage Operations Staff (`employee` / `admin`).
Key friction points resolved:
- Chaos of phone calls and manual coordination for morning garage departures.
- Blocked parked cars requiring advance shifting and pre-departure preparation.
- Coordinating pre-departure car wash services so vehicles are cleaned and at the exit gate on time.
- Managing recurring routines with customizable off-days (e.g. Friday rest days, skip tomorrow) and on-demand exit requests.

---

## 2. Database Schema & Data Dictionary

### 2.1 `users`
- `id`: unsigned bigint PK
- `name`: string(100)
- `phone`: string(20), unique, indexed
- `email`: string(100), nullable, unique
- `password`: string(255)
- `role`: enum(`owner`, `employee`, `admin`), default `owner`, indexed
- `fcm_token`: string(255), nullable
- `locale`: enum(`ar`, `en`), default `ar`
- `remember_token`: nullable
- `created_at`, `updated_at`: timestamps

### 2.2 `vehicles`
- `id`: unsigned bigint PK
- `user_id`: unsigned bigint FK -> `users(id)` ON DELETE CASCADE
- `make`: string(50) (e.g., 'Mercedes-Benz', 'Toyota')
- `model`: string(50) (e.g., 'C200', 'Corolla')
- `year`: smallint unsigned, nullable (e.g., 2023)
- `color_name`: string(30) (e.g., 'Obsidian Black', 'Pearl White')
- `color_hex`: string(7) (e.g., '#0F0E13', '#FFFFFF')
- `plate_letters`: string(20) (e.g., 'أ ب ج')
- `plate_numbers`: string(10) (e.g., '١٢٣٤' or '1234')
- `plate_full_normalized`: string(50), indexed for fast search
- `plate_image_path`: string(255), nullable
- `parking_spot`: string(20), nullable (e.g., 'B2-14')
- `key_hook_number`: string(20), nullable (e.g., 'Hook #12')
- `special_notes`: text, nullable (e.g., 'Low front bumper, fold mirrors')
- `current_status`: enum(`parked`, `washing`, `ready_at_gate`, `checked_out`), default `parked`, indexed
- `is_inside_garage`: boolean, default true, indexed
- `created_at`, `updated_at`, `deleted_at`: timestamps & soft deletes

### 2.3 `daily_schedules`
- `id`: unsigned bigint PK
- `vehicle_id`: unsigned bigint FK -> `vehicles(id)` ON DELETE CASCADE, unique
- `pickup_time`: time (e.g., '09:00:00')
- `excluded_days`: json (array of ints 0..6 where 0=Sunday, 5=Friday, 6=Saturday; default `[5]`)
- `include_wash`: boolean, default false
- `wash_type`: enum(`none`, `exterior`, `full`), default `none`
- `is_active`: boolean, default true, indexed
- `skip_date`: date, nullable (marks single day vacation/skip)
- `created_at`, `updated_at`: timestamps

### 2.4 `pickup_requests`
- `id`: unsigned bigint PK
- `vehicle_id`: unsigned bigint FK -> `vehicles(id)` ON DELETE CASCADE
- `requested_by`: unsigned bigint FK -> `users(id)`
- `handled_by`: unsigned bigint FK -> `users(id)`, nullable
- `source`: enum(`manual`, `daily_schedule`), default `manual`
- `scheduled_for`: datetime, indexed
- `wants_wash`: boolean, default false
- `wash_type`: enum(`none`, `exterior`, `full`), default `none`
- `wash_status`: enum(`not_needed`, `pending`, `in_progress`, `completed`), default `not_needed`
- `status`: enum(`scheduled`, `preparing`, `washing`, `ready_at_gate`, `completed`, `cancelled`), default `scheduled`, indexed
- `owner_notes`: text, nullable
- `ready_at`: datetime, nullable
- `picked_up_at`: datetime, nullable
- `created_at`, `updated_at`: timestamps

### 2.5 `vehicle_status_logs`
- `id`: unsigned bigint PK
- `vehicle_id`: unsigned bigint FK -> `vehicles(id)` ON DELETE CASCADE
- `changed_by`: unsigned bigint FK -> `users(id)`
- `from_status`: string(30)
- `to_status`: string(30)
- `notes`: text, nullable
- `created_at`: timestamp

---

## 3. Strict 1:1 API Contract (`/api/v1`)

### 3.1 Standard JSON Response Format
```json
// Success
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "meta": { ... } // optional
}

// Error
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "field": ["Validation message"]
  }
}
```

### 3.2 Endpoints Summary
- `POST /api/v1/auth/register`: Register owner + optional first vehicle
- `POST /api/v1/auth/login`: Issue Sanctum token + user & role payload
- `GET /api/v1/auth/me`: Current authenticated user
- `POST /api/v1/auth/logout`: Revoke current token

- `GET /api/v1/owner/dashboard`: Owner active vehicles, current requests, today's schedule status
- `GET /api/v1/owner/vehicles`: List user vehicles
- `POST /api/v1/owner/vehicles`: Add vehicle
- `GET /api/v1/owner/vehicles/{vehicle}`: Vehicle details with schedule & active request
- `PUT /api/v1/owner/vehicles/{vehicle}`: Update vehicle
- `DELETE /api/v1/owner/vehicles/{vehicle}`: Soft delete vehicle
- `PUT /api/v1/owner/vehicles/{vehicle}/daily-schedule`: Upsert daily schedule
- `POST /api/v1/owner/vehicles/{vehicle}/pickup-requests`: Create on-demand pickup request
- `PATCH /api/v1/owner/pickup-requests/{request}/cancel`: Cancel active request

- `GET /api/v1/employee/queue`: Merged departure queue for today (upcoming/washing/ready/all)
- `GET /api/v1/employee/vehicles`: Search all vehicles by plate, owner, or spot
- `PATCH /api/v1/employee/vehicles/{vehicle}/spot`: Update spot and key hook
- `PATCH /api/v1/employee/vehicles/{vehicle}/status`: Update vehicle status with audit logging

---

## 4. Flutter State Management & Clean Architecture Map

```
lib/
├── bootstrap.dart
├── main.dart
├── core/
│   ├── config/ (app_config.dart, env constants)
│   ├── di/ (injection.dart with get_it)
│   ├── error/ (failures.dart, exceptions.dart)
│   ├── network/ (api_client.dart, api_endpoints.dart, auth_interceptor.dart)
│   ├── router/ (app_router.dart, app_routes.dart)
│   ├── storage/ (token_storage.dart)
│   ├── theme/ (app_colors.dart, app_typography.dart, app_theme.dart, glass_container.dart)
│   └── widgets/ (app_button.dart, license_plate_badge.dart, state_views.dart)
├── features/
│   ├── auth/ (domain, data, presentation: login_page, register_page)
│   ├── owner_home/ (domain, data, presentation: owner_dashboard_page, schedule_sheet, vehicle_form_page)
│   ├── employee_dashboard/ (domain, data, presentation: employee_queue_page, vehicle_search_page, status_update_sheet)
│   └── settings/ (presentation: settings_page, locale_cubit)
```
