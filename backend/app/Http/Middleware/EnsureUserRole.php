<?php

namespace App\Http\Middleware;

use App\Traits\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserRole
{
    use ApiResponse;

    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return $this->errorResponse('Unauthenticated.', 401);
        }

        $userRole = is_object($user->role) ? $user->role->value : (string) $user->role;

        // Split comma-separated roles like role:employee,admin
        $allowedRoles = [];
        foreach ($roles as $roleGroup) {
            foreach (explode(',', $roleGroup) as $role) {
                $allowedRoles[] = trim($role);
            }
        }

        if (! in_array($userRole, $allowedRoles, true)) {
            return $this->errorResponse('Unauthorized role access.', 403);
        }

        return $next($request);
    }
}
