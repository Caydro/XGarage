<?php

namespace App\Http\Requests\Owner;

use Illuminate\Foundation\Http\FormRequest;

class UpsertDailyScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'pickup_time' => ['required', 'string', 'regex:/^([01][0-9]|2[0-3]):[0-5][0-9]$/'],
            'excluded_days' => ['required', 'array'],
            'excluded_days.*' => ['integer', 'between:0,6'],
            'include_wash' => ['required', 'boolean'],
            'wash_type' => ['required', 'in:none,exterior,full'],
            'is_active' => ['required', 'boolean'],
            'skip_date' => ['nullable', 'date_format:Y-m-d'],
        ];
    }
}
