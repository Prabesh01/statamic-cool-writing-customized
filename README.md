## One-Time Setup

- `cp .env.example .env`
```
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com
```
- ./setup.sh
- sudo chown -R $USER:$USER storage bootstrap/cache
- Create super user: `docker compose exec cms php artisan statamic:make:user`

## Running it

- Simply do `docker compose up -d` and 
- Visit: http://localhost:8000/cp
