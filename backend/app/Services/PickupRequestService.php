<?php

namespace App\Services;

use App\Enums\PickupRequestSource;
use App\Enums\PickupRequestStatus;
use App\Enums\WashStatus;
use App\Enums\WashType;
use App\Models\PickupRequest;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PickupRequestService
{
    public function createRequest(Vehicle $vehicle, User $user, array $data): PickupRequest
    {
        return DB::transaction(function () use ($vehicle, $user, $data) {
            // Cancel any previously active request for this vehicle to prevent duplicates
            PickupRequest::where('vehicle_id', $vehicle->id)
                ->whereIn('status', [PickupRequestStatus::SCHEDULED, PickupRequestStatus::PREPARING])
                ->update(['status' => PickupRequestStatus::CANCELLED]);

            $scheduledFor = ! empty($data['scheduled_for'])
                ? Carbon::parse($data['scheduled_for'])
                : Carbon::now()->addMinutes(10); // Immediate retrieval default

            $wantsWash = (bool) ($data['wants_wash'] ?? false);
            $washType = $wantsWash && ! empty($data['wash_type']) ? $data['wash_type'] : WashType::NONE->value;
            $washStatus = $wantsWash ? WashStatus::PENDING->value : WashStatus::NOT_NEEDED->value;

            $request = PickupRequest::create([
                'vehicle_id' => $vehicle->id,
                'requested_by' => $user->id,
                'source' => PickupRequestSource::MANUAL,
                'scheduled_for' => $scheduledFor,
                'wants_wash' => $wantsWash,
                'wash_type' => $washType,
                'wash_status' => $washStatus,
                'status' => PickupRequestStatus::SCHEDULED,
                'owner_notes' => $data['owner_notes'] ?? null,
            ]);

            // Ensure vehicle inside status is active
            $vehicle->update([
                'is_inside_garage' => true,
            ]);

            return $request->load('vehicle');
        });
    }

    public function cancelRequest(PickupRequest $request, User $user): PickupRequest
    {
        if ($request->requested_by !== $user->id && ! $user->isEmployee()) {
            throw ValidationException::withMessages([
                'request' => ['Unauthorized to cancel this request.'],
            ]);
        }

        if (in_array($request->status, [PickupRequestStatus::READY_AT_GATE, PickupRequestStatus::COMPLETED])) {
            throw ValidationException::withMessages([
                'request' => ['Cannot cancel a request that is already ready or completed.'],
            ]);
        }

        $request->update(['status' => PickupRequestStatus::CANCELLED]);

        return $request;
    }
}
