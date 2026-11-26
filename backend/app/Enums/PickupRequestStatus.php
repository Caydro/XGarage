<?php

namespace App\Enums;

enum PickupRequestStatus: string
{
    case SCHEDULED = 'scheduled';
    case PREPARING = 'preparing';
    case WASHING = 'washing';
    case READY_AT_GATE = 'ready_at_gate';
    case COMPLETED = 'completed';
    case CANCELLED = 'cancelled';
}
