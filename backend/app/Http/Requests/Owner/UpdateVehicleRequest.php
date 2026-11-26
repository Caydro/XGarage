<?php

namespace App\Http\Requests\Owner;

use Illuminate\Foundation\Http\FormRequest;

class UpdateVehicleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'make' => ['sometimes', 'required', 'string', 'max:50'],
            'model' => ['sometimes', 'required', 'string', 'max:50'],
            'year' => ['nullable', 'integer', 'between:1950,2030'],
            'color_name' => ['sometimes', 'required', 'string', 'max:30'],
            'color_hex' => ['sometimes', 'required', 'string', 'max:7'],
            'plate_letters' => ['sometimes', 'required', 'string', 'max:20'],
            'plate_numbers' => ['sometimes', 'required', 'string', 'max:10'],
            'special_notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
