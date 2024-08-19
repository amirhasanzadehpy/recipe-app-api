FROM python:3.9-alpine3.13
LABEL maintainer="geekwhale.ir"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Install dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    # Clean up build dependencies
    apk del .tmp-build-deps && \
    rm -rf /tmp && \
    # Add a user for running the application
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set environment variable PATH to include virtual environment
ENV PATH="/py/bin:$PATH"

# Switch to non-root user
USER django-user
