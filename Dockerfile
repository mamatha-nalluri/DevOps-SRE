FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Test stage: development-only dependencies and tests never enter the runtime image.
FROM base AS test

COPY requirements-dev.txt /app/requirements-dev.txt
RUN python -m pip install --no-cache-dir -r requirements-dev.txt

COPY app/ /app/app/
COPY test/ /app/test/

RUN python -m pytest -v /app/test

# Runtime stage: only the application and Python runtime are included.
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN groupadd --system --gid 10001 appuser \
    && useradd --system --uid 10001 --gid appuser --no-create-home appuser

COPY --chown=10001:10001 app/app.py ./app.py

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthcheck', timeout=2)" || exit 1

CMD ["python", "-u", "app.py"]
