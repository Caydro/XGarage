<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('make', 50);
            $table->string('model', 50);
            $table->unsignedSmallInteger('year')->nullable();
            $table->string('color_name', 30)->default('Black');
            $table->string('color_hex', 7)->default('#0F0E13');
            $table->string('plate_letters', 20);
            $table->string('plate_numbers', 10);
            $table->string('plate_full_normalized', 50)->index();
            $table->string('plate_image_path', 255)->nullable();
            $table->string('parking_spot', 20)->nullable();
            $table->string('key_hook_number', 20)->nullable();
            $table->text('special_notes')->nullable();
            $table->string('current_status', 30)->default('parked')->index();
            $table->boolean('is_inside_garage')->default(true)->index();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
