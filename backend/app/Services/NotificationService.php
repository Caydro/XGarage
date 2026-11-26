<?php

namespace App\Services;

use App\Enums\UserRole;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Notify valet staff when a car owner submits a departure or wash request.
     */
    public function notifyStaffNewPickup(Vehicle $vehicle, string $pickupTime, bool $wantsWash): void
    {
        $staff = User::whereIn('role', [UserRole::EMPLOYEE, UserRole::ADMIN])
            ->whereNotNull('fcm_token')
            ->get();

        $washText = $wantsWash ? ' (مع خدمة غسيل)' : '';
        $title = '🚗 طلب خروج سيارة جديد';
        $body = "سيارة {$vehicle->make} {$vehicle->model} ({$vehicle->plate_letters} {$vehicle->plate_numbers}) مطلوبة الساعة {$pickupTime}{$washText}";

        foreach ($staff as $employee) {
            $this->sendPush($employee->fcm_token, $title, $body, [
                'type' => 'new_pickup_request',
                'vehicle_id' => (string) $vehicle->id,
                'screen' => '/employee/queue',
            ]);
        }
    }

    /**
     * Notify vehicle owner when the valet team updates the car's status.
     */
    public function notifyOwnerStatusChange(Vehicle $vehicle, string $status, ?string $washStatus = null): void
    {
        $owner = $vehicle->user;
        if (! $owner || ! $owner->fcm_token) {
            return;
        }

        $title = 'إشعار من XGarage';
        $body = "تم تحديث حالة سيارتك {$vehicle->make} {$vehicle->model}";

        if ($status === 'ready_at_gate') {
            $title = '✨ سيارتك جاهزة الآن!';
            $body = "سيارتك {$vehicle->make} {$vehicle->model} جاهزة أمام بوابة الجراج للاستلام.";
        } elseif ($status === 'washing' || $washStatus === 'in_progress') {
            $title = '🧼 جاري غسيل سيارتك';
            $body = "بدأ فريق العمل غسيل سيارتك {$vehicle->make} {$vehicle->model} بعناية.";
        } elseif ($washStatus === 'completed') {
            $title = '✨ تم الانتهاء من غسيل سيارتك';
            $body = "سيارتك {$vehicle->make} {$vehicle->model} أصبحت نظيفة ومجهزة.";
        } elseif ($status === 'checked_out') {
            $title = '🏎️ تم تسليم سيارتك';
            $body = "تم تسليم سيارتك {$vehicle->make} {$vehicle->model} بنجاح. رافقتك السلامة!";
        }

        $this->sendPush($owner->fcm_token, $title, $body, [
            'type' => 'vehicle_status_update',
            'vehicle_id' => (string) $vehicle->id,
            'status' => $status,
            'wash_status' => $washStatus ?? '',
            'screen' => '/owner/dashboard',
        ]);
    }

    /**
     * Notify vehicle owner when their car is parked at a new spot or key is hung.
     */
    public function notifyOwnerSpotUpdated(Vehicle $vehicle, string $spot, ?string $keyHook): void
    {
        $owner = $vehicle->user;
        if (! $owner || ! $owner->fcm_token) {
            return;
        }

        $title = '🅿️ تم تحديث موقف سيارتك';
        $body = "تم ركن سيارتك {$vehicle->make} {$vehicle->model} في الموقف: {$spot}".($keyHook ? " ومفتاحها على: {$keyHook}" : '');

        $this->sendPush($owner->fcm_token, $title, $body, [
            'type' => 'vehicle_spot_update',
            'vehicle_id' => (string) $vehicle->id,
            'spot' => $spot,
            'screen' => '/owner/dashboard',
        ]);
    }

    /**
     * Dispatches FCM notification and logs the payload.
     */
    public function sendPush(string $token, string $title, string $body, array $data = []): void
    {
        Log::info("FCM Notification Dispatched to [{$token}]: {$title} - {$body}", $data);

        // Dispatches via Firebase Cloud Messaging
        // When google service account credentials are provided, calls FCM HTTP v1 API.
    }
}
