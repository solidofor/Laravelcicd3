<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\HelloWorldController;

Route::get('/', [HelloWorldController::class, 'index']);

Route::get('/welcome', function () {
    return view('welcome');
});
