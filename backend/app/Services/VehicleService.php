<?php

namespace App\Services;

use App\Enums\VehicleStatus;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Database\Eloquent\Collection;

class VehicleService
{
    public function getUserVehicles(User $user): Collection
    {
        return $user->vehicles()
            ->with(['dailySchedule', 'activePickupRequest'])
            ->latest()
            ->get();
    }

    public function createVehicle(User $user, array $data): Vehicle
    {
        $data['user_id'] = $user->id;
        $data['plate_full_normalized'] = Vehicle::normalizePlate($data['plate_letters'], $data['plate_numbers']);
        $data['current_status'] = VehicleStatus::PARKED;
        $data['is_inside_garage'] = true;

        return Vehicle::create($data);
    }

    public function updateVehicle(Vehicle $vehicle, array $data): Vehicle
    {
        if (isset($data['plate_letters']) || isset($data['plate_numbers'])) {
            $letters = $data['plate_letters'] ?? $vehicle->plate_letters;
            $numbers = $data['plate_numbers'] ?? $vehicle->plate_numbers;
            $data['plate_full_normalized'] = Vehicle::normalizePlate($letters, $numbers);
        }

        $vehicle->update($data);

        return $vehicle->fresh(['dailySchedule', 'activePickupRequest']);
    }

    public function deleteVehicle(Vehicle $vehicle): void
    {
        $vehicle->delete();
    }
}
