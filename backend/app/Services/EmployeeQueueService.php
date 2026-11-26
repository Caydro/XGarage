<?php

namespace App\Services;

use App\Enums\PickupRequestStatus;
use App\Enums\VehicleStatus;
use App\Enums\WashStatus;
use App\Models\DailySchedule;
use App\Models\PickupRequest;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleStatusLog;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class EmployeeQueueService
{
    /**
     * Build today's operational queue by merging:
     * 1. Active Daily Schedules (excluding today's off-days like Friday)
     * 2. Manual Pickup Requests for today
     */
    public function getTodayQueue(?string $filter = 'all', ?string $search = null): Collection
    {
        $today = Carbon::today();
        $startOfDay = $today->copy()->startOfDay();
        $endOfDay = $today->copy()->endOfDay();

        // 1. Fetch all manual or generated pickup requests for today
        $requests = PickupRequest::with(['vehicle.user'])
            ->whereBetween('scheduled_for', [$startOfDay, $endOfDay])
            ->whereNotIn('status', [PickupRequestStatus::CANCELLED, PickupRequestStatus::COMPLETED])
            ->get();

        $vehicleIdsWithRequests = $requests->pluck('vehicle_id')->all();

        // 2. Fetch active daily schedules whose vehicles do not already have an active request today
        $schedules = DailySchedule::with(['vehicle.user'])
            ->where('is_active', true)
            ->whereNotIn('vehicle_id', $vehicleIdsWithRequests)
            ->get()
            ->filter(function (DailySchedule $schedule) use ($today) {
                return $schedule->isScheduledForDate($today) && $schedule->vehicle && $schedule->vehicle->is_inside_garage;
            });

        // 3. Merge into unified queue array
        $queue = collect();

        foreach ($requests as $req) {
            $queue->push([
                'id' => $req->id,
                'vehicle' => $req->vehicle,
                'scheduled_for' => $req->scheduled_for,
                'source' => is_object($req->source) ? $req->source->value : $req->source,
                'wants_wash' => (bool) $req->wants_wash,
                'wash_type' => is_object($req->wash_type) ? $req->wash_type->value : $req->wash_type,
                'wash_status' => is_object($req->wash_status) ? $req->wash_status->value : $req->wash_status,
                'status' => is_object($req->status) ? $req->status->value : $req->status,
                'owner_notes' => $req->owner_notes,
                'ready_at' => $req->ready_at,
            ]);
        }

        foreach ($schedules as $sched) {
            // Build scheduled datetime for today
            $timeParts = explode(':', $sched->pickup_time);
            $scheduledFor = $today->copy()->setHour((int) $timeParts[0])->setMinute((int) ($timeParts[1] ?? 0));

            $queue->push([
                'id' => 'sched_'.$sched->id,
                'vehicle' => $sched->vehicle,
                'scheduled_for' => $scheduledFor,
                'source' => 'daily_schedule',
                'wants_wash' => (bool) $sched->include_wash,
                'wash_type' => is_object($sched->wash_type) ? $sched->wash_type->value : $sched->wash_type,
                'wash_status' => $sched->include_wash ? 'pending' : 'not_needed',
                'status' => 'scheduled',
                'owner_notes' => 'Daily Schedule Departure',
                'ready_at' => null,
            ]);
        }

        // Apply Search
        if (! empty($search)) {
            $search = mb_strtolower(trim($search));
            $queue = $queue->filter(function ($item) use ($search) {
                $v = $item['vehicle'];
                $owner = $v->user;

                return str_contains(mb_strtolower($v->plate_letters ?? ''), $search)
                    || str_contains(mb_strtolower($v->plate_numbers ?? ''), $search)
                    || str_contains(mb_strtolower($v->plate_full_normalized ?? ''), $search)
                    || str_contains(mb_strtolower($v->make ?? ''), $search)
                    || str_contains(mb_strtolower($v->model ?? ''), $search)
                    || str_contains(mb_strtolower($v->parking_spot ?? ''), $search)
                    || ($owner && (str_contains(mb_strtolower($owner->name), $search) || str_contains($owner->phone, $search)));
            });
        }

        // Apply Filter
        if ($filter === 'upcoming') {
            $queue = $queue->filter(fn ($item) => in_array($item['status'], ['scheduled', 'preparing']));
        } elseif ($filter === 'washing') {
            $queue = $queue->filter(fn ($item) => $item['status'] === 'washing' || in_array($item['wash_status'], ['pending', 'in_progress']));
        } elseif ($filter === 'ready') {
            $queue = $queue->filter(fn ($item) => $item['status'] === 'ready_at_gate');
        }

        // Sort by scheduled_for ascending
        return $queue->sortBy('scheduled_for')->values();
    }

    /**
     * Compute dashboard KPIs
     */
    public function getGarageSummary(): array
    {
        $now = Carbon::now();
        $oneHourLater = $now->copy()->addHour();

        $totalInside = Vehicle::where('is_inside_garage', true)->count();

        $queue = $this->getTodayQueue('all');

        $leavingNextHour = $queue->filter(function ($item) use ($now, $oneHourLater) {
            return $item['scheduled_for']->between($now->copy()->subMinutes(15), $oneHourLater);
        })->count();

        $pendingWashes = $queue->filter(function ($item) {
            return $item['wants_wash'] && in_array($item['wash_status'], ['pending', 'in_progress']);
        })->count();

        $readyAtGate = Vehicle::where('current_status', VehicleStatus::READY_AT_GATE)->count();

        return [
            'total_inside' => $totalInside,
            'leaving_next_hour' => $leavingNextHour,
            'pending_washes' => $pendingWashes,
            'ready_at_gate' => $readyAtGate,
        ];
    }

    /**
     * Transition vehicle status with audit logging
     */
    public function updateVehicleStatus(Vehicle $vehicle, User $employee, string $newStatus, ?string $washStatus = null, ?string $notes = null): Vehicle
    {
        return DB::transaction(function () use ($vehicle, $employee, $newStatus, $washStatus, $notes) {
            $fromStatus = is_object($vehicle->current_status) ? $vehicle->current_status->value : $vehicle->current_status;

            $updateData = ['current_status' => $newStatus];
            if ($newStatus === 'checked_out') {
                $updateData['is_inside_garage'] = false;
            } else {
                $updateData['is_inside_garage'] = true;
            }

            $vehicle->update($updateData);

            // Synchronize active pickup request if exists
            $activeRequest = $vehicle->activePickupRequest;
            if ($activeRequest) {
                $reqUpdates = [];
                if ($newStatus === 'washing') {
                    $reqUpdates['status'] = PickupRequestStatus::WASHING;
                    $reqUpdates['wash_status'] = WashStatus::IN_PROGRESS;
                } elseif ($newStatus === 'ready_at_gate') {
                    $reqUpdates['status'] = PickupRequestStatus::READY_AT_GATE;
                    $reqUpdates['ready_at'] = Carbon::now();
                    if ($activeRequest->wants_wash) {
                        $reqUpdates['wash_status'] = WashStatus::COMPLETED;
                    }
                } elseif ($newStatus === 'checked_out') {
                    $reqUpdates['status'] = PickupRequestStatus::COMPLETED;
                    $reqUpdates['picked_up_at'] = Carbon::now();
                }

                if ($washStatus) {
                    $reqUpdates['wash_status'] = $washStatus;
                }

                if (! empty($reqUpdates)) {
                    $reqUpdates['handled_by'] = $employee->id;
                    $activeRequest->update($reqUpdates);
                }
            }

            // Log status change
            VehicleStatusLog::create([
                'vehicle_id' => $vehicle->id,
                'changed_by' => $employee->id,
                'from_status' => $fromStatus,
                'to_status' => $newStatus,
                'notes' => $notes,
                'created_at' => Carbon::now(),
            ]);

            return $vehicle->fresh(['dailySchedule', 'activePickupRequest', 'user']);
        });
    }

    public function updateVehicleSpot(Vehicle $vehicle, string $spot, ?string $keyHook): Vehicle
    {
        $vehicle->update([
            'parking_spot' => $spot,
            'key_hook_number' => $keyHook,
        ]);

        return $vehicle->fresh(['dailySchedule', 'activePickupRequest', 'user']);
    }

    public function searchVehicles(?string $search): Collection
    {
        $query = Vehicle::with(['user', 'dailySchedule', 'activePickupRequest']);

        if (! empty($search)) {
            $search = mb_strtolower(trim($search));
            $query->where(function ($q) use ($search) {
                $q->where('plate_full_normalized', 'like', "%{$search}%")
                    ->orWhere('plate_letters', 'like', "%{$search}%")
                    ->orWhere('plate_numbers', 'like', "%{$search}%")
                    ->orWhere('make', 'like', "%{$search}%")
                    ->orWhere('model', 'like', "%{$search}%")
                    ->orWhere('parking_spot', 'like', "%{$search}%")
                    ->orWhereHas('user', function ($uq) use ($search) {
                        $uq->where('name', 'like', "%{$search}%")
                            ->orWhere('phone', 'like', "%{$search}%");
                    });
            });
        }

        return $query->latest()->get();
    }
}
