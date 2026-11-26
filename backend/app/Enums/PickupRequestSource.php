<?php

namespace App\Enums;

enum PickupRequestSource: string
{
    case MANUAL = 'manual';
    case DAILY_SCHEDULE = 'daily_schedule';
}
