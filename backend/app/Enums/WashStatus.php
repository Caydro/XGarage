<?php

namespace App\Enums;

enum WashStatus: string
{
    case NOT_NEEDED = 'not_needed';
    case PENDING = 'pending';
    case IN_PROGRESS = 'in_progress';
    case COMPLETED = 'completed';
}
