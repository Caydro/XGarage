<?php

namespace App\Http\Requests\Employee;

use Illuminate\Foundation\Http\FormRequest;

class UpdateVehicleStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:parked,preparing,washing,ready_at_gate,checked_out'],
            'wash_status' => ['nullable', 'in:not_needed,pending,in_progress,completed'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
