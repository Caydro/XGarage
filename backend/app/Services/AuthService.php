<?php

namespace App\Services;

use App\Enums\UserRole;
use App\Enums\VehicleStatus;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'phone' => $data['phone'],
                'email' => $data['email'] ?? null,
                'password' => Hash::make($data['password']),
                'role' => UserRole::OWNER,
                'locale' => $data['locale'] ?? 'ar',
            ]);

            // If first vehicle details are provided
            if (! empty($data['make']) && ! empty($data['model']) && ! empty($data['plate_letters']) && ! empty($data['plate_numbers'])) {
                Vehicle::create([
                    'user_id' => $user->id,
                    'make' => $data['make'],
                    'model' => $data['model'],
                    'year' => $data['year'] ?? null,
                    'color_name' => $data['color_name'] ?? 'Black',
                    'color_hex' => $data['color_hex'] ?? '#0F0E13',
                    'plate_letters' => $data['plate_letters'],
                    'plate_numbers' => $data['plate_numbers'],
                    'plate_full_normalized' => Vehicle::normalizePlate($data['plate_letters'], $data['plate_numbers']),
                    'current_status' => VehicleStatus::PARKED,
                    'is_inside_garage' => true,
                ]);
            }

            $token = $user->createToken('auth-token')->plainTextToken;

            return [
                'user' => $user->load('vehicles'),
                'token' => $token,
            ];
        });
    }

    public function login(string $login, string $password, ?string $deviceName = null): array
    {
        $user = User::where('phone', $login)
            ->orWhere('email', $login)
            ->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['Invalid credentials provided.'],
            ]);
        }

        $tokenName = $deviceName ?: 'device-token';
        $token = $user->createToken($tokenName)->plainTextToken;

        return [
            'user' => $user->load('vehicles'),
            'token' => $token,
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }
}
