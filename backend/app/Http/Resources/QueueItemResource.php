<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QueueItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $vehicle = $this->resource['vehicle'];
        $owner = $vehicle->user;

        return [
            'id' => $this->resource['id'],
            'vehicle_id' => $vehicle->id,
            'scheduled_for' => $this->resource['scheduled_for']->toIso8601String(),
            'scheduled_time' => $this->resource['scheduled_for']->format('H:i'),
            'source' => $this->resource['source'],
            'is_from_schedule' => $this->resource['source'] === 'daily_schedule',
            'wants_wash' => (bool) $this->resource['wants_wash'],
            'wash_type' => $this->resource['wash_type'],
            'wash_status' => $this->resource['wash_status'],
            'status' => $this->resource['status'],
            'owner_notes' => $this->resource['owner_notes'] ?? null,
            'ready_at' => isset($this->resource['ready_at']) && $this->resource['ready_at'] ? $this->resource['ready_at']->toIso8601String() : null,
            'vehicle' => [
                'id' => $vehicle->id,
                'make' => $vehicle->make,
                'model' => $vehicle->model,
                'year' => $vehicle->year,
                'color_name' => $vehicle->color_name,
                'color_hex' => $vehicle->color_hex,
                'plate_letters' => $vehicle->plate_letters,
                'plate_numbers' => $vehicle->plate_numbers,
                'plate_full_normalized' => $vehicle->plate_full_normalized,
                'parking_spot' => $vehicle->parking_spot,
                'key_hook_number' => $vehicle->key_hook_number,
                'special_notes' => $vehicle->special_notes,
                'current_status' => is_object($vehicle->current_status) ? $vehicle->current_status->value : $vehicle->current_status,
                'owner_name' => $owner ? $owner->name : 'N/A',
                'owner_phone' => $owner ? $owner->phone : 'N/A',
            ],
        ];
    }
}
