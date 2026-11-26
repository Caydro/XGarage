<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DailyScheduleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vehicle_id' => $this->vehicle_id,
            'pickup_time' => substr($this->pickup_time, 0, 5), // 'HH:MM'
            'excluded_days' => $this->excluded_days ?? [5],
            'include_wash' => (bool) $this->include_wash,
            'wash_type' => is_object($this->wash_type) ? $this->wash_type->value : $this->wash_type,
            'is_active' => (bool) $this->is_active,
            'skip_date' => $this->skip_date?->format('Y-m-d'),
        ];
    }
}
