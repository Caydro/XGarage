<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\Employee\QueueController;
use App\Http\Controllers\Api\V1\Employee\VehicleManagementController;
use App\Http\Controllers\Api\V1\Owner\DailyScheduleController;
use App\Http\Controllers\Api\V1\Owner\DashboardController;
use App\Http\Controllers\Api\V1\Owner\PickupRequestController;
use App\Http\Controllers\Api\V1\Owner\VehicleController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // Authentication Routes
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/me', [AuthController::class, 'me']);
            Route::put('/profile', [AuthController::class, 'updateProfile']);
            Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    // Car Owner Routes
    Route::prefix('owner')
        ->middleware(['auth:sanctum', 'role:owner'])
        ->group(function () {
            Route::get('/dashboard', [DashboardController::class, 'index']);

            Route::get('/vehicles', [VehicleController::class, 'index']);
            Route::post('/vehicles', [VehicleController::class, 'store']);
            Route::get('/vehicles/{vehicle}', [VehicleController::class, 'show']);
            Route::put('/vehicles/{vehicle}', [VehicleController::class, 'update']);
            Route::delete('/vehicles/{vehicle}', [VehicleController::class, 'destroy']);

            Route::put('/vehicles/{vehicle}/daily-schedule', [DailyScheduleController::class, 'upsert']);
            Route::post('/vehicles/{vehicle}/pickup-requests', [PickupRequestController::class, 'store']);
            Route::patch('/pickup-requests/{pickupRequest}/cancel', [PickupRequestController::class, 'cancel']);
        });

    // Employee & Valet Staff Routes
    Route::prefix('employee')
        ->middleware(['auth:sanctum', 'role:employee,admin'])
        ->group(function () {
            Route::get('/queue', [QueueController::class, 'index']);
            Route::get('/queue/summary', [QueueController::class, 'summary']);

            Route::get('/vehicles', [VehicleManagementController::class, 'index']);
            Route::patch('/vehicles/{vehicle}/spot', [VehicleManagementController::class, 'updateSpot']);
            Route::patch('/vehicles/{vehicle}/status', [VehicleManagementController::class, 'updateStatus']);
        });
});
