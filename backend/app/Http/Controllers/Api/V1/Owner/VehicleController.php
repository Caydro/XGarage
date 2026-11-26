<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Http\Requests\Owner\StoreVehicleRequest;
use App\Http\Requests\Owner\UpdateVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Models\Vehicle;
use App\Services\VehicleService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected VehicleService $vehicleService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $vehicles = $this->vehicleService->getUserVehicles($request->user());

        return $this->successResponse(
            data: VehicleResource::collection($vehicles),
            message: 'Vehicles retrieved.'
        );
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $vehicle = $this->vehicleService->createVehicle($request->user(), $request->validated());

        return $this->successResponse(
            data: new VehicleResource($vehicle->load(['dailySchedule', 'activePickupRequest'])),
            message: 'Vehicle added successfully.',
            statusCode: 201
        );
    }

    public function show(Request $request, Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized to view this vehicle.', 403);
        }

        return $this->successResponse(
            data: new VehicleResource($vehicle->load(['dailySchedule', 'activePickupRequest'])),
            message: 'Vehicle details retrieved.'
        );
    }

    public function update(UpdateVehicleRequest $request, Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized to update this vehicle.', 403);
        }

        $updated = $this->vehicleService->updateVehicle($vehicle, $request->validated());

        return $this->successResponse(
            data: new VehicleResource($updated),
            message: 'Vehicle updated successfully.'
        );
    }

    public function destroy(Request $request, Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized to delete this vehicle.', 403);
        }

        $this->vehicleService->deleteVehicle($vehicle);

        return $this->successResponse(
            data: null,
            message: 'Vehicle deleted successfully.'
        );
    }
}
