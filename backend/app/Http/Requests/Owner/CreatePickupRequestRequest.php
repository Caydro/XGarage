<?php

namespace App\Http\Requests\Owner;

use Illuminate\Foundation\Http\FormRequest;

class CreatePickupRequestRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'scheduled_for' => ['nullable', 'date'],
            'wants_wash' => ['required', 'boolean'],
            'wash_type' => ['nullable', 'in:none,exterior,full'],
            'owner_notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
