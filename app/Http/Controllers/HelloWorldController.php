<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
class HelloWorldController extends Controller
{
    public function index()
    {
        $message = DB::table('messages')->first();
        return response()->json(['message' => $message ? $message->text : 'No message found']);
    }
}
