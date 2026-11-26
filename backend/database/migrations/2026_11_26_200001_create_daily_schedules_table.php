<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_id')->unique()->constrained()->cascadeOnDelete();
            $table->time('pickup_time');
            $table->json('excluded_days');
            $table->boolean('include_wash')->default(false);
            $table->string('wash_type', 20)->default('none');
            $table->boolean('is_active')->default(true)->index();
            $table->date('skip_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_schedules');
    }
};
