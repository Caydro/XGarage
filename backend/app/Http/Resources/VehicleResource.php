<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VehicleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'make' => $this->make,
            'model' => $this->model,
            'year' => $this->year,
            'color_name' => $this->color_name,
            'color_hex' => $this->color_hex,
            'plate_letters' => $this->plate_letters,
            'plate_numbers' => $this->plate_numbers,
            'plate_full_normalized' => $this->plate_full_normalized,
            'plate_image_path' => $this->plate_image_path,
            'parking_spot' => $this->parking_spot,
            'key_hook_number' => $this->key_hook_number,
            'special_notes' => $this->special_notes,
            'current_status' => is_object($this->current_status) ? $this->current_status->value : $this->current_status,
            'is_inside_garage' => (bool) $this->is_inside_garage,
            'daily_schedule' => new DailyScheduleResource($this->whenLoaded('dailySchedule')),
            'active_pickup_request' => new PickupRequestResource($this->whenLoaded('activePickupRequest')),
            'owner_name' => $this->user?->name,
            'owner' => new UserResource($this->whenLoaded('user')),
        ];
    }
}
