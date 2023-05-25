<?php

namespace App\Http\Controllers;

use App\Jobs\HandleUpdate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Redis;

class StatsController extends Controller
{
    /**
     * @param string $countryCode
     * @return Response
     */
    public function update(string $countryCode): Response
    {
        $this->dispatch(new HandleUpdate($countryCode));

        return response()->noContent();
    }

    /**
     * @return JsonResponse
     */
    public function get(): JsonResponse
    {
        $stats = Redis::hgetall('counts');

        return response()->json($stats);
    }
}
