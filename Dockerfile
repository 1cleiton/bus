FROM python:3.11.0b4-alpine3.16

# Creating workspace
ENV WORKSPACE=/usr/src/app
RUN mkdir -p $WORKSPACE
WORKDIR $WORKSPACE

# Project dependency
COPY requirements.txt requirements.txt
RUN poetry install --no-interaction && apt-get update && memcached && cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && apt-get clean --dry-run


# Copy project
COPY . $WORKSPACE

# Gunicorn
COPY gunicorn.socket /etc/systemd/system/
COPY gunicorn.service /etc/systemd/system/
COPY gunicorn.socket /lib/systemd/system/
COPY gunicorn.service /lib/systemd/system/
COPY gunicorn.socket /usr/bin/
COPY gunicorn.service /usr/bin/

RUN ln -s /etc/systemd/system/gunicorn.socket /etc/init.d/gunicorn.socket
RUN ln -s /etc/systemd/system//gunicorn.service /etc/init.d/gunicorn.service
RUN ln -s /usr/local/bin/gunicorn /etc/init.d/gunicorn

RUN python manage.py collectstatic --noinput --no-post-process

CMD ["./cmd.sh"]
