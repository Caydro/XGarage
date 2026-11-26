<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Http\Resources\PickupRequestResource;
use App\Http\Resources\VehicleResource;
use App\Models\PickupRequest;
use App\Services\VehicleService;
use App\Traits\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected VehicleService $vehicleService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $vehicles = $this->vehicleService->getUserVehicles($user);

        // Find primary vehicle (first or active)
        $primaryVehicle = $vehicles->first();

        // Find active pickup request for this user
        $activeRequest = PickupRequest::with('vehicle')
            ->where('requested_by', $user->id)
            ->whereIn('status', ['scheduled', 'preparing', 'washing', 'ready_at_gate'])
            ->latest()
            ->first();

        $today = Carbon::today();
        $todayScheduleActive = false;
        $todayScheduleTime = null;

        if ($primaryVehicle && $primaryVehicle->dailySchedule) {
            $sched = $primaryVehicle->dailySchedule;
            if ($sched->isScheduledForDate($today)) {
                $todayScheduleActive = true;
                $todayScheduleTime = substr($sched->pickup_time, 0, 5);
            }
        }

        return $this->successResponse(
            data: [
                'primary_vehicle' => $primaryVehicle ? new VehicleResource($primaryVehicle) : null,
                'vehicles' => VehicleResource::collection($vehicles),
                'active_request' => $activeRequest ? new PickupRequestResource($activeRequest) : null,
                'today_schedule' => [
                    'is_active_today' => $todayScheduleActive,
                    'pickup_time' => $todayScheduleTime,
                ],
            ],
            message: 'Owner dashboard data loaded.'
        );
    }
}
