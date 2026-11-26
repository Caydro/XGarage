<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_as_owner_with_initial_vehicle(): void
    {
        $payload = [
            'name' => 'Kareem Ali',
            'phone' => '01099998888',
            'email' => 'kareem@test.com',
            'password' => 'secret123',
            'locale' => 'ar',
            'make' => 'Audi',
            'model' => 'A6',
            'year' => 2023,
            'color_name' => 'Daytona Gray',
            'color_hex' => '#4B5563',
            'plate_letters' => 'ق هـ و',
            'plate_numbers' => '٤٣٢١',
        ];

        $response = $this->postJson('/api/v1/auth/register', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'phone', 'role', 'locale'],
                    'token',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'phone' => '01099998888',
            'role' => UserRole::OWNER->value,
        ]);

        $this->assertDatabaseHas('vehicles', [
            'make' => 'Audi',
            'model' => 'A6',
            'plate_letters' => 'ق هـ و',
        ]);
    }

    public function test_registration_fails_with_duplicate_phone(): void
    {
        User::factory()->create(['phone' => '01011112222']);

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Duplicate Test',
            'phone' => '01011112222',
            'password' => 'secret123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone']);
    }

    public function test_user_can_login_with_phone_and_password(): void
    {
        $user = User::factory()->create([
            'phone' => '01055554444',
            'password' => bcrypt('password123'),
            'role' => UserRole::OWNER,
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'login' => '01055554444',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonStructure(['data' => ['token']]);
    }

    public function test_user_can_fetch_profile_and_logout(): void
    {
        $user = User::factory()->create(['role' => UserRole::OWNER]);
        $token = $user->createToken('test')->plainTextToken;

        $meResponse = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200)
            ->assertJsonPath('data.id', $user->id);

        $logoutResponse = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/auth/logout');

        $logoutResponse->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
