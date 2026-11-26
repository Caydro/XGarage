<?php

namespace App\Models;

use App\Enums\WashType;
use Carbon\CarbonInterface;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailySchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'vehicle_id',
        'pickup_time',
        'excluded_days',
        'include_wash',
        'wash_type',
        'is_active',
        'skip_date',
    ];

    protected function casts(): array
    {
        return [
            'excluded_days' => 'array',
            'include_wash' => 'boolean',
            'wash_type' => WashType::class,
            'is_active' => 'boolean',
            'skip_date' => 'date',
        ];
    }

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    /**
     * Checks if this schedule is active for a given Carbon date.
     */
    public function isScheduledForDate(CarbonInterface $date): bool
    {
        if (! $this->is_active) {
            return false;
        }

        if ($this->skip_date && $this->skip_date->isSameDay($date)) {
            return false;
        }

        $dayOfWeek = $date->dayOfWeek; // 0 (Sun) to 6 (Sat)
        $excluded = $this->excluded_days ?? [5];

        return ! in_array($dayOfWeek, $excluded, true);
    }
}
