<?php

namespace App\Http\Controllers\Api\V1\Owner;

use App\Http\Controllers\Controller;
use App\Http\Requests\Owner\CreatePickupRequestRequest;
use App\Http\Resources\PickupRequestResource;
use App\Models\PickupRequest;
use App\Models\Vehicle;
use App\Services\PickupRequestService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PickupRequestController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected PickupRequestService $requestService
    ) {}

    public function store(CreatePickupRequestRequest $request, Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->user_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized to request pickup for this vehicle.', 403);
        }

        $pickup = $this->requestService->createRequest($vehicle, $request->user(), $request->validated());

        return $this->successResponse(
            data: new PickupRequestResource($pickup),
            message: 'Pickup request created successfully.',
            statusCode: 201
        );
    }

    public function cancel(Request $request, PickupRequest $pickupRequest): JsonResponse
    {
        $cancelled = $this->requestService->cancelRequest($pickupRequest, $request->user());

        return $this->successResponse(
            data: new PickupRequestResource($cancelled),
            message: 'Pickup request cancelled successfully.'
        );
    }
}
