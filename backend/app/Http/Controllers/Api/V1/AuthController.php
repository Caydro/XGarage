<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected AuthService $authService
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register($request->validated());

        return $this->successResponse(
            data: [
                'user' => new UserResource($result['user']),
                'token' => $result['token'],
            ],
            message: 'User registered successfully.',
            statusCode: 201
        );
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login(
            $request->validated('login'),
            $request->validated('password'),
            $request->validated('device_name')
        );

        return $this->successResponse(
            data: [
                'user' => new UserResource($result['user']),
                'token' => $result['token'],
            ],
            message: 'Logged in successfully.'
        );
    }

    public function me(Request $request): JsonResponse
    {
        return $this->successResponse(
            data: new UserResource($request->user()->load('vehicles')),
            message: 'User profile fetched.'
        );
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return $this->successResponse(
            data: null,
            message: 'Logged out successfully.'
        );
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone,' . $user->id],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'password' => ['nullable', 'string', 'min:6'],
        ]);

        $updateData = [
            'name' => $validated['name'],
            'phone' => $validated['phone'],
            'email' => $validated['email'] ?? null,
        ];

        if (! empty($validated['password'])) {
            $updateData['password'] = \Illuminate\Support\Facades\Hash::make($validated['password']);
        }

        $user->update($updateData);

        // Optional: Update vehicle details directly if provided for car owners
        if ($request->hasAny(['make', 'model', 'plate_letters', 'plate_numbers', 'color_name'])) {
            $vehicleId = $request->input('vehicle_id');
            $vehicle = $vehicleId
                ? $user->vehicles()->find($vehicleId)
                : $user->vehicles()->first();

            if ($vehicle) {
                $vehicleData = $request->only([
                    'make', 'model', 'year', 'color_name', 'color_hex',
                    'plate_letters', 'plate_numbers', 'special_notes',
                ]);
                if (isset($vehicleData['plate_letters']) || isset($vehicleData['plate_numbers'])) {
                    $letters = $vehicleData['plate_letters'] ?? $vehicle->plate_letters;
                    $numbers = $vehicleData['plate_numbers'] ?? $vehicle->plate_numbers;
                    $vehicleData['plate_full_normalized'] = \App\Models\Vehicle::normalizePlate($letters, $numbers);
                }
                $vehicle->update(array_filter($vehicleData, fn ($val) => ! is_null($val)));
            }
        }

        return $this->successResponse(
            data: new UserResource($user->fresh()),
            message: 'Profile updated successfully.'
        );
    }

    public function updateAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
        ]);

        $user = $request->user();

        if ($user->avatar && \Illuminate\Support\Facades\Storage::disk('public')->exists($user->avatar)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($user->avatar);
        }

        $path = $request->file('avatar')->store('avatars', 'public');
        $user->update(['avatar' => $path]);

        return $this->successResponse(
            data: new UserResource($user->fresh()),
            message: 'Profile photo updated successfully.'
        );
    }

    public function updateFcmToken(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fcm_token' => ['required', 'string', 'max:500'],
        ]);

        $request->user()->update([
            'fcm_token' => $validated['fcm_token'],
        ]);

        return $this->successResponse(
            data: ['fcm_token' => $validated['fcm_token']],
            message: 'FCM device token updated successfully.'
        );
    }
}
