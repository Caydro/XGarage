<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Http\Requests\Owner\UpsertDailyScheduleRequest;
use App\Http\Resources\DailyScheduleResource;
use App\Models\Vehicle;
use App\Services\DailyScheduleService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;

class DailyScheduleController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected DailyScheduleService $scheduleService
    ) {}

    public function upsert(UpsertDailyScheduleRequest $request, Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized to update schedule for this vehicle.', 403);
        }

        $schedule = $this->scheduleService->upsertSchedule($vehicle, $request->validated());

        return $this->successResponse(
            data: new DailyScheduleResource($schedule),
            message: 'Daily schedule saved successfully.'
        );
    }
}
