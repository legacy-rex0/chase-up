<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;
use Illuminate\Http\Request;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Handle proxy headers for proper HTTPS detection
        $this->handleProxyHeaders();
        
        // Set URL scheme based on forwarded headers
        $this->setUrlScheme();
    }

    /**
     * Configure trusted proxies to handle forwarded headers
     */
    private function handleProxyHeaders(): void
    {
        // Trust all proxies - adjust this in production to specific IPs
        $proxies = ['*']; // In production, use specific proxy IPs like ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']
        
        $headers = Request::HEADER_X_FORWARDED_FOR | Request::HEADER_X_FORWARDED_HOST | Request::HEADER_X_FORWARDED_PORT | Request::HEADER_X_FORWARDED_PROTO;
        
        // Set trusted proxies if we have forwarded headers
        if (request()->hasHeader('X-Forwarded-Proto') || 
            request()->hasHeader('X-Forwarded-For') ||
            request()->hasHeader('X-Forwarded-Host')) {
            
            request()->setTrustedProxies($proxies, $headers);
        }
    }

    /**
     * Set URL scheme based on forwarded protocol
     */
    private function setUrlScheme(): void
    {
        // Check if request came through HTTPS proxy
        if (request()->hasHeader('X-Forwarded-Proto')) {
            $protocol = request()->header('X-Forwarded-Proto');
            if ($protocol === 'https') {
                URL::forceScheme('https');
            }
        }
        
        // Alternative: Check HTTPS server variable set by nginx
        if (request()->server('HTTPS') === 'on') {
            URL::forceScheme('https');
        }
    }
}