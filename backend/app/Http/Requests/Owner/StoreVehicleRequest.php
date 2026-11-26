<?php

namespace App\Http\Requests\Owner;

use Illuminate\Foundation\Http\FormRequest;

class StoreVehicleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'make' => ['required', 'string', 'max:50'],
            'model' => ['required', 'string', 'max:50'],
            'year' => ['nullable', 'integer', 'between:1950,2030'],
            'color_name' => ['required', 'string', 'max:30'],
            'color_hex' => ['required', 'string', 'max:7'],
            'plate_letters' => ['required', 'string', 'max:20'],
            'plate_numbers' => ['required', 'string', 'max:10'],
            'special_notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
