<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PickupRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vehicle_id' => $this->vehicle_id,
            'requested_by' => $this->requested_by,
            'handled_by' => $this->handled_by,
            'source' => is_object($this->source) ? $this->source->value : $this->source,
            'scheduled_for' => $this->scheduled_for?->toIso8601String(),
            'wants_wash' => (bool) $this->wants_wash,
            'wash_type' => is_object($this->wash_type) ? $this->wash_type->value : $this->wash_type,
            'wash_status' => is_object($this->wash_status) ? $this->wash_status->value : $this->wash_status,
            'status' => is_object($this->status) ? $this->status->value : $this->status,
            'owner_notes' => $this->owner_notes,
            'ready_at' => $this->ready_at?->toIso8601String(),
            'picked_up_at' => $this->picked_up_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'vehicle' => new VehicleResource($this->whenLoaded('vehicle')),
        ];
    }
}
