<?php

namespace App\Models;

use App\Enums\PickupRequestSource;
use App\Enums\PickupRequestStatus;
use App\Enums\WashStatus;
use App\Enums\WashType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PickupRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'vehicle_id',
        'requested_by',
        'handled_by',
        'source',
        'scheduled_for',
        'wants_wash',
        'wash_type',
        'wash_status',
        'status',
        'owner_notes',
        'ready_at',
        'picked_up_at',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_for' => 'datetime',
            'wants_wash' => 'boolean',
            'wash_type' => WashType::class,
            'wash_status' => WashStatus::class,
            'source' => PickupRequestSource::class,
            'status' => PickupRequestStatus::class,
            'ready_at' => 'datetime',
            'picked_up_at' => 'datetime',
        ];
    }

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function requestedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function handledBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }
}
