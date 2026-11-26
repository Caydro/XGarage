<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pickup_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_id')->constrained()->cascadeOnDelete();
            $table->foreignId('requested_by')->constrained('users')->cascadeOnDelete();
            $table->foreignId('handled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('source', 30)->default('manual');
            $table->dateTime('scheduled_for')->index();
            $table->boolean('wants_wash')->default(false);
            $table->string('wash_type', 20)->default('none');
            $table->string('wash_status', 30)->default('not_needed');
            $table->string('status', 30)->default('scheduled')->index();
            $table->text('owner_notes')->nullable();
            $table->dateTime('ready_at')->nullable();
            $table->dateTime('picked_up_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pickup_requests');
    }
};
