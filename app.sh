#!/bin/bash

# Allowed Arguments
fresh=false
start=true
stop=false
composer=false
supervisor=false
restart=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  --fresh)
    fresh=true
    composer=true
    stop=true
    shift
    ;;
  --restart)
    start=false
    restart=true
    shift
    ;;
  --composer)
    composer=true
    start=false
    shift
    ;;
  --start)
    stop=true
    start=true
    shift
    ;;
  --stop)
    stop=true
    start=false
    shift
    ;;
  --supervisor)
    supervisor=true
    start=false
    shift
    ;;
  *)
    echo "Invalid argument: $1"
    exit 1
    ;;
  esac
done

# Restart
if [[ $restart == true ]]; then
  docker-compose restart
fi

# Remove services if stop provided
if [[ $stop == true ]]; then
  docker-compose down
fi

# Composer
if [[ $composer == true ]]; then
  echo -e '\033[32mRunning composer install...\033[0m'
  docker run -it --rm -u "$(id -u):$(id -g)" -v $(pwd):/app composer install --ignore-platform-reqs
fi

# Start services
if [[ $start == true ]]; then
  echo -e '\033[32mRunning services...\033[0m'
  UID=$(id -u) GID=$(id -g) docker-compose up --force-recreate --build -d
fi

# Key generate
if [[ $fresh == true ]]; then
  echo -e '\033[32mGenerating Laravel app key...\033[32m'
  docker-compose exec app php artisan key:generate
fi

# Updating queue/cron supervisor handlers after code changes
if [[ $supervisor == true ]]; then
   echo -e '\033[32mReread and Update supervisor...\033[0m'
   docker-compose exec -T app supervisorctl -c /supervisord.conf reread
   docker-compose exec -T app supervisorctl -c /supervisord.conf update

   echo -e '\033[32mRestarting supervisor programs...\033[0m'
   docker-compose exec -T app supervisorctl -c /supervisord.conf restart queue:
fi
