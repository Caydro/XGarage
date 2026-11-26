<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'role' => is_object($this->role) ? $this->role->value : $this->role,
            'locale' => $this->locale ?? 'ar',
            'avatar' => $this->avatar,
            'avatar_url' => $this->avatar_url,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
