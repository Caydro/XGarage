<?php

namespace App\Http\Requests\Employee;

use Illuminate\Foundation\Http\FormRequest;

class UpdateVehicleSpotRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'parking_spot' => ['required', 'string', 'max:20'],
            'key_hook_number' => ['nullable', 'string', 'max:20'],
        ];
    }
}
