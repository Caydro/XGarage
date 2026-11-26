<?php

namespace App\Http\Controllers\Api\V1\Employee;

use App\Http\Controllers\Controller;
use App\Http\Requests\Employee\UpdateVehicleSpotRequest;
use App\Http\Requests\Employee\UpdateVehicleStatusRequest;
use App\Http\Resources\VehicleResource;
use App\Models\Vehicle;
use App\Services\EmployeeQueueService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleManagementController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected EmployeeQueueService $queueService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $search = $request->query('search');
        $vehicles = $this->queueService->searchVehicles($search);

        return $this->successResponse(
            data: VehicleResource::collection($vehicles),
            message: 'Vehicles search results.'
        );
    }

    public function updateSpot(UpdateVehicleSpotRequest $request, Vehicle $vehicle): JsonResponse
    {
        $updated = $this->queueService->updateVehicleSpot(
            $vehicle,
            $request->validated('parking_spot'),
            $request->validated('key_hook_number')
        );

        return $this->successResponse(
            data: new VehicleResource($updated),
            message: 'Vehicle parking spot updated successfully.'
        );
    }

    public function updateStatus(UpdateVehicleStatusRequest $request, Vehicle $vehicle): JsonResponse
    {
        $updated = $this->queueService->updateVehicleStatus(
            $vehicle,
            $request->user(),
            $request->validated('status'),
            $request->validated('wash_status'),
            $request->validated('notes')
        );

        return $this->successResponse(
            data: new VehicleResource($updated),
            message: 'Vehicle status updated successfully.'
        );
    }
}
