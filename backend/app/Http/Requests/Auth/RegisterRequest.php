<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:100', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'locale' => ['nullable', 'in:ar,en'],

            // First vehicle optional fields
            'make' => ['nullable', 'string', 'max:50'],
            'model' => ['nullable', 'string', 'max:50'],
            'year' => ['nullable', 'integer', 'between:1950,2030'],
            'color_name' => ['nullable', 'string', 'max:30'],
            'color_hex' => ['nullable', 'string', 'max:7'],
            'plate_letters' => ['nullable', 'string', 'max:20'],
            'plate_numbers' => ['nullable', 'string', 'max:10'],
        ];
    }
}
