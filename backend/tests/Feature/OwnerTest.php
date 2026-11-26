<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Enums\VehicleStatus;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OwnerTest extends TestCase
{
    use RefreshDatabase;

    protected User $owner;

    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->owner = User::factory()->create([
            'role' => UserRole::OWNER,
            'phone' => '01099887766',
        ]);
        $this->token = $this->owner->createToken('test')->plainTextToken;
    }

    public function test_owner_can_add_and_view_vehicles(): void
    {
        $vehicleData = [
            'make' => 'Mercedes-Benz',
            'model' => 'E300',
            'year' => 2024,
            'color_name' => 'Obsidian Black',
            'color_hex' => '#0F0E13',
            'plate_letters' => 'ن م ك',
            'plate_numbers' => '٧٨٩٠',
            'special_notes' => 'Do not wash with hard brushes.',
        ];

        $postResponse = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->postJson('/api/v1/owner/vehicles', $vehicleData);

        $postResponse->assertStatus(201)
            ->assertJsonPath('data.make', 'Mercedes-Benz')
            ->assertJsonPath('data.plate_letters', 'ن م ك');

        $vehicleId = $postResponse->json('data.id');

        $getResponse = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->getJson('/api/v1/owner/vehicles/'.$vehicleId);

        $getResponse->assertStatus(200)
            ->assertJsonPath('data.id', $vehicleId);
    }

    public function test_owner_can_set_daily_recurring_schedule(): void
    {
        $vehicle = Vehicle::create([
            'user_id' => $this->owner->id,
            'make' => 'BMW',
            'model' => '520i',
            'plate_letters' => 'أ ب ج',
            'plate_numbers' => '١٢٣٤',
            'plate_full_normalized' => 'أ ب ج 1234',
            'color_name' => 'Blue',
            'color_hex' => '#1E3A8A',
            'current_status' => VehicleStatus::PARKED,
        ]);

        $scheduleData = [
            'pickup_time' => '08:45',
            'excluded_days' => [5], // Friday off
            'include_wash' => true,
            'wash_type' => 'exterior',
            'is_active' => true,
        ];

        $response = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->putJson('/api/v1/owner/vehicles/'.$vehicle->id.'/daily-schedule', $scheduleData);

        $response->assertStatus(200)
            ->assertJsonPath('data.pickup_time', '08:45')
            ->assertJsonPath('data.include_wash', true)
            ->assertJsonPath('data.excluded_days', [5]);
    }

    public function test_owner_can_request_immediate_pickup_and_cancel(): void
    {
        $vehicle = Vehicle::create([
            'user_id' => $this->owner->id,
            'make' => 'Toyota',
            'model' => 'Land Cruiser',
            'plate_letters' => 'ل ك ر',
            'plate_numbers' => '٢٠٠٠',
            'plate_full_normalized' => 'ل ك ر 2000',
            'color_name' => 'White',
            'color_hex' => '#FFFFFF',
            'current_status' => VehicleStatus::PARKED,
        ]);

        $requestData = [
            'wants_wash' => true,
            'wash_type' => 'full',
            'owner_notes' => 'Coming down in 15 mins.',
        ];

        $response = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->postJson('/api/v1/owner/vehicles/'.$vehicle->id.'/pickup-requests', $requestData);

        $response->assertStatus(201)
            ->assertJsonPath('data.wants_wash', true)
            ->assertJsonPath('data.status', 'scheduled');

        $requestId = $response->json('data.id');

        $cancelResponse = $this->withHeader('Authorization', 'Bearer '.$this->token)
            ->patchJson('/api/v1/owner/pickup-requests/'.$requestId.'/cancel');

        $cancelResponse->assertStatus(200)
            ->assertJsonPath('data.status', 'cancelled');
    }
}
