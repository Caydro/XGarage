<?php

namespace App\Enums;

enum VehicleStatus: string
{
    case PARKED = 'parked';
    case PREPARING = 'preparing';
    case WASHING = 'washing';
    case READY_AT_GATE = 'ready_at_gate';
    case CHECKED_OUT = 'checked_out';
}
