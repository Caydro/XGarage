<?php

namespace App\Models;

use App\Enums\VehicleStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Vehicle extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'make',
        'model',
        'year',
        'color_name',
        'color_hex',
        'plate_letters',
        'plate_numbers',
        'plate_full_normalized',
        'plate_image_path',
        'parking_spot',
        'key_hook_number',
        'special_notes',
        'current_status',
        'is_inside_garage',
    ];

    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'current_status' => VehicleStatus::class,
            'is_inside_garage' => 'boolean',
        ];
    }

    public static function normalizePlate(string $letters, string $numbers): string
    {
        $cleanLetters = trim(preg_replace('/\s+/', ' ', $letters));
        $cleanNumbers = trim(preg_replace('/\s+/', '', $numbers));

        return $cleanLetters.' '.$cleanNumbers;
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function dailySchedule(): HasOne
    {
        return $this->hasOne(DailySchedule::class);
    }

    public function pickupRequests(): HasMany
    {
        return $this->hasMany(PickupRequest::class);
    }

    public function activePickupRequest(): HasOne
    {
        return $this->hasOne(PickupRequest::class)
            ->whereIn('status', ['scheduled', 'preparing', 'washing', 'ready_at_gate'])
            ->latestOfMany();
    }

    public function statusLogs(): HasMany
    {
        return $this->hasMany(VehicleStatusLog::class);
    }
}
