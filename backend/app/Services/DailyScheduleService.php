<?php

namespace App\Services;

use App\Models\DailySchedule;
use App\Models\Vehicle;

class DailyScheduleService
{
    public function upsertSchedule(Vehicle $vehicle, array $data): DailySchedule
    {
        return DailySchedule::updateOrCreate(
            ['vehicle_id' => $vehicle->id],
            [
                'pickup_time' => $data['pickup_time'],
                'excluded_days' => $data['excluded_days'],
                'include_wash' => $data['include_wash'],
                'wash_type' => $data['wash_type'],
                'is_active' => $data['is_active'],
                'skip_date' => $data['skip_date'] ?? null,
            ]
        );
    }
}
