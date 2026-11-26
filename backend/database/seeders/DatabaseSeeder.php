<?php

namespace Database\Seeders;

use App\Enums\PickupRequestSource;
use App\Enums\PickupRequestStatus;
use App\Enums\UserRole;
use App\Enums\VehicleStatus;
use App\Enums\WashStatus;
use App\Enums\WashType;
use App\Models\DailySchedule;
use App\Models\PickupRequest;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleStatusLog;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Employee Account
        $employee = User::updateOrCreate(
            ['phone' => '01000000001'],
            [
                'name' => 'Ahmed Valet Lead',
                'email' => 'employee@xgarage.com',
                'password' => Hash::make('password123'),
                'role' => UserRole::EMPLOYEE,
                'locale' => 'ar',
            ]
        );

        // 2. Owner 1: Tarek Mansour
        $owner1 = User::updateOrCreate(
            ['phone' => '01011111111'],
            [
                'name' => 'طارق منصور (Tarek Mansour)',
                'email' => 'tarek@example.com',
                'password' => Hash::make('password123'),
                'role' => UserRole::OWNER,
                'locale' => 'ar',
            ]
        );

        $vehicle1 = Vehicle::updateOrCreate(
            ['user_id' => $owner1->id, 'plate_full_normalized' => 'أ ب ج 1234'],
            [
                'make' => 'Mercedes-Benz',
                'model' => 'C200 AMG',
                'year' => 2023,
                'color_name' => 'Obsidian Black',
                'color_hex' => '#0F0E13',
                'plate_letters' => 'أ ب ج',
                'plate_numbers' => '١٢٣٤',
                'parking_spot' => 'B1-04',
                'key_hook_number' => 'Hook #04',
                'special_notes' => 'Low front spoiler, please take speed bumps slowly.',
                'current_status' => VehicleStatus::PARKED,
                'is_inside_garage' => true,
            ]
        );

        DailySchedule::updateOrCreate(
            ['vehicle_id' => $vehicle1->id],
            [
                'pickup_time' => '09:00:00',
                'excluded_days' => [5], // Friday off
                'include_wash' => true,
                'wash_type' => WashType::EXTERIOR,
                'is_active' => true,
                'skip_date' => null,
            ]
        );

        PickupRequest::updateOrCreate(
            [
                'vehicle_id' => $vehicle1->id,
                'scheduled_for' => Carbon::today()->setHour(9)->setMinute(0),
            ],
            [
                'requested_by' => $owner1->id,
                'source' => PickupRequestSource::DAILY_SCHEDULE,
                'wants_wash' => true,
                'wash_type' => WashType::EXTERIOR,
                'wash_status' => WashStatus::PENDING,
                'status' => PickupRequestStatus::SCHEDULED,
                'owner_notes' => 'Leaving for office at 9 AM',
            ]
        );

        // 3. Owner 2: Sarah Khalil
        $owner2 = User::updateOrCreate(
            ['phone' => '01022222222'],
            [
                'name' => 'سارة خليل (Sarah Khalil)',
                'email' => 'sarah@example.com',
                'password' => Hash::make('password123'),
                'role' => UserRole::OWNER,
                'locale' => 'en',
            ]
        );

        $vehicle2 = Vehicle::updateOrCreate(
            ['user_id' => $owner2->id, 'plate_full_normalized' => 'س ر ح 5678'],
            [
                'make' => 'BMW',
                'model' => '320i M Sport',
                'year' => 2022,
                'color_name' => 'Alpine White',
                'color_hex' => '#F8FAFC',
                'plate_letters' => 'س ر ح',
                'plate_numbers' => '٥٦٧٨',
                'parking_spot' => 'A2-11',
                'key_hook_number' => 'Hook #11',
                'special_notes' => 'Please fold electric side mirrors.',
                'current_status' => VehicleStatus::WASHING,
                'is_inside_garage' => true,
            ]
        );

        DailySchedule::updateOrCreate(
            ['vehicle_id' => $vehicle2->id],
            [
                'pickup_time' => '08:30:00',
                'excluded_days' => [5], // Friday off
                'include_wash' => true,
                'wash_type' => WashType::FULL,
                'is_active' => true,
            ]
        );

        PickupRequest::updateOrCreate(
            [
                'vehicle_id' => $vehicle2->id,
                'scheduled_for' => Carbon::today()->setHour(8)->setMinute(30),
            ],
            [
                'requested_by' => $owner2->id,
                'handled_by' => $employee->id,
                'source' => PickupRequestSource::DAILY_SCHEDULE,
                'wants_wash' => true,
                'wash_type' => WashType::FULL,
                'wash_status' => WashStatus::IN_PROGRESS,
                'status' => PickupRequestStatus::WASHING,
                'owner_notes' => 'Full clean inside and outside please',
            ]
        );

        // 4. Owner 3: Omar Farouk
        $owner3 = User::updateOrCreate(
            ['phone' => '01033333333'],
            [
                'name' => 'عمر فاروق (Omar Farouk)',
                'email' => 'omar@example.com',
                'password' => Hash::make('password123'),
                'role' => UserRole::OWNER,
                'locale' => 'ar',
            ]
        );

        $vehicle3 = Vehicle::updateOrCreate(
            ['user_id' => $owner3->id, 'plate_full_normalized' => 'ق ر ش 9999'],
            [
                'make' => 'Porsche',
                'model' => 'Macan GTS',
                'year' => 2024,
                'color_name' => 'Crimson Ruby',
                'color_hex' => '#991B1B',
                'plate_letters' => 'ق ر ش',
                'plate_numbers' => '٩٩٩٩',
                'parking_spot' => 'VIP-01',
                'key_hook_number' => 'Hook #01',
                'special_notes' => 'Keep keys in VIP lockbox.',
                'current_status' => VehicleStatus::READY_AT_GATE,
                'is_inside_garage' => true,
            ]
        );

        DailySchedule::updateOrCreate(
            ['vehicle_id' => $vehicle3->id],
            [
                'pickup_time' => '10:00:00',
                'excluded_days' => [5, 6], // Fri & Sat off
                'include_wash' => true,
                'wash_type' => WashType::FULL,
                'is_active' => true,
            ]
        );

        PickupRequest::updateOrCreate(
            [
                'vehicle_id' => $vehicle3->id,
                'scheduled_for' => Carbon::today()->setHour(8)->setMinute(15),
            ],
            [
                'requested_by' => $owner3->id,
                'handled_by' => $employee->id,
                'source' => PickupRequestSource::MANUAL,
                'wants_wash' => true,
                'wash_type' => WashType::FULL,
                'wash_status' => WashStatus::COMPLETED,
                'status' => PickupRequestStatus::READY_AT_GATE,
                'ready_at' => Carbon::now()->subMinutes(10),
                'owner_notes' => 'Need car ready early at gate',
            ]
        );

        VehicleStatusLog::create([
            'vehicle_id' => $vehicle3->id,
            'changed_by' => $employee->id,
            'from_status' => 'washing',
            'to_status' => 'ready_at_gate',
            'notes' => 'Vehicle washed, dried, and parked at exit bay 1.',
            'created_at' => Carbon::now()->subMinutes(10),
        ]);
    }
}
