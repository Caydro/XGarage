<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Enums\VehicleStatus;
use App\Models\PickupRequest;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EmployeeTest extends TestCase
{
    use RefreshDatabase;

    protected User $employee;

    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->employee = User::factory()->create([
            'role' => UserRole::EMPLOYEE,
            'phone' => '01000000001',
        ]);
        $this->token = $this->employee->createToken('test')->plainTextToken;
    }

    public function test_employee_can_view_today_departure_queue(): void
    {
        $owner = User::factory()->create(['role' => UserRole::OWNER]);
        $vehicle = Vehicle::create([
            'user_id' => $owner->id,
            'make' => 'Porsche',
            'model' => 'Panamera',
            'plate_letters' => 'ب و ر',
            'plate_numbers' => '٩١١',
            'plate_full_normalized' => 'ب و ر 911',
            'color_name' => 'Black',
            'color_hex' => '#0F0E13',
            'parking_spot' => 'VIP-02',
            'key_hook_number' => 'Hook #02',
            'current_status' => VehicleStatus::PARKED,
            'is_inside_garage' => true,
        ]);

        PickupRequest::create([
            'vehicle_id' => $vehicle->id,
            'requested_by' => $owner->id,
            'scheduled_for' => Carbon::now()->addHour(),
            'wants_wash' => true,
            'wash_type' => 'exterior',
            'wash_status' => 'pending',
            'status' => 'scheduled',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->getJson('/api/v1/employee/queue');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'vehicle_id',
                        'scheduled_for',
                        'wants_wash',
                        'status',
                        'vehicle' => ['make', 'model', 'plate_letters', 'plate_numbers', 'parking_spot'],
                    ],
                ],
            ]);
    }

    public function test_employee_can_update_spot_and_transition_status(): void
    {
        $owner = User::factory()->create(['role' => UserRole::OWNER]);
        $vehicle = Vehicle::create([
            'user_id' => $owner->id,
            'make' => 'Range Rover',
            'model' => 'Velar',
            'plate_letters' => 'ر ن ج',
            'plate_numbers' => '٥٥٥٥',
            'plate_full_normalized' => 'ر ن ج 5555',
            'color_name' => 'Silver',
            'color_hex' => '#E5E7EB',
            'current_status' => VehicleStatus::PARKED,
            'is_inside_garage' => true,
        ]);

        // 1. Assign spot
        $spotResponse = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->patchJson('/api/v1/employee/vehicles/'.$vehicle->id.'/spot', [
                'parking_spot' => 'B3-15',
                'key_hook_number' => 'Hook #33',
            ]);

        $spotResponse->assertStatus(200)
            ->assertJsonPath('data.parking_spot', 'B3-15')
            ->assertJsonPath('data.key_hook_number', 'Hook #33');

        // 2. Transition status to washing
        $statusResponse1 = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->patchJson('/api/v1/employee/vehicles/'.$vehicle->id.'/status', [
                'status' => 'washing',
                'wash_status' => 'in_progress',
                'notes' => 'Moved to wash bay 2.',
            ]);

        $statusResponse1->assertStatus(200)
            ->assertJsonPath('data.current_status', 'washing');

        $this->assertDatabaseHas('vehicle_status_logs', [
            'vehicle_id' => $vehicle->id,
            'from_status' => 'parked',
            'to_status' => 'washing',
        ]);

        // 3. Mark ready at gate
        $statusResponse2 = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->patchJson('/api/v1/employee/vehicles/'.$vehicle->id.'/status', [
                'status' => 'ready_at_gate',
                'wash_status' => 'completed',
                'notes' => 'Parked at main exit gate.',
            ]);

        $statusResponse2->assertStatus(200)
            ->assertJsonPath('data.current_status', 'ready_at_gate');
    }

    public function test_employee_can_view_garage_summary_kpis(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->getJson('/api/v1/employee/queue/summary');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'total_inside',
                    'leaving_next_hour',
                    'pending_washes',
                    'ready_at_gate',
                ],
            ]);
    }
}
