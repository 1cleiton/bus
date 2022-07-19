#!/bin/bash
set -e

echo "Restarting memcached"
/etc/init.d/memcached restart

if [[ $COMMAND = "celeryworker" ]]; then
    echo "Running Celery Worker"
    exec celery worker -E -A bus --loglevel=info

elif [[ $COMMAND = "celerypriorityworker" ]]; then
    echo "Running Celery Priority Worker"
    exec celery worker -E -A bus -n priority -Q priority --loglevel=info --pool=solo

elif [[ $COMMAND = "celerybeat" ]]; then
    echo "Running Celery Beat"
    exec celery beat -A bus --loglevel=debug --pidfile=/tmp/celerybeat.pid --scheduler django_celery_beat.schedulers:DatabaseScheduler

elif [[ $COMMAND = "celeryflower" ]]; then
    echo "Running Celery Flower"
    exec celery flower -A bus --basic_auth=adminbus:flowerbusadm1 --loglevel=info

elif [[ $COMMAND = "uwsgi" ]]; then
    echo "Running uWSGI Server"
    exec uwsgi --ini uwsgi.ini

elif [[ $COMMAND = "daphne" ]]; then
    echo "Running with daphne"
    exec daphne -b 0.0.0.0 -p 80 bus.asgi:application

elif [[ $COMMAND = "gunicorn" ]]; then
    echo "Running with gunicorn"
    exec gunicorn bus.asgi:application -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:80 --threads 3 --reload --access-logfile access.log --error-logfile error.log --log-level error --keep-alive 3 --max-requests 5000 --worker-connections=1000

elif [[ $COMMAND = "test" ]]; then
    echo "Running tests"
    exec python -W ignore::RuntimeWarning manage.py test --failfast --parallel

elif [[ $COMMAND = "nginx" ]]; then
    echo "Running nginx"
    exec nginx

else
    echo "Running manage.py runserver"
    exec python manage.py migrate
    exec python manage.py runserver 0:8000
fi
