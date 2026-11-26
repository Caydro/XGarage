<?php

namespace App\Http\Controllers\Api\V1\Employee;

use App\Http\Controllers\Controller;
use App\Http\Resources\QueueItemResource;
use App\Services\EmployeeQueueService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QueueController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected EmployeeQueueService $queueService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $filter = $request->query('filter', 'all');
        $search = $request->query('search', null);

        $queue = $this->queueService->getTodayQueue($filter, $search);

        return $this->successResponse(
            data: QueueItemResource::collection($queue),
            message: 'Departure queue loaded.'
        );
    }

    public function summary(): JsonResponse
    {
        $summary = $this->queueService->getGarageSummary();

        return $this->successResponse(
            data: $summary,
            message: 'Garage summary statistics loaded.'
        );
    }
}
