#####################################################################################################
# Stage 1: Build
#####################################################################################################
FROM python:3.14-alpine@sha256:f6a589d43c42b9e7f7dc67a12d37132491f362859a5d750607710cc56da3bc72 AS build

WORKDIR /build

COPY app/requirements.txt .

RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install \
    --no-cache-dir \
    -r requirements.txt

#####################################################################################################
# Stage 2: Runtime
#####################################################################################################
FROM python:3.14-alpine@sha256:f6a589d43c42b9e7f7dc67a12d37132491f362859a5d750607710cc56da3bc72 AS runtime

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

COPY --from=build /opt/venv /opt/venv

COPY app/app.py .

RUN   addgroup -S -g 10001 appgroup \
      && adduser -S -D -H -u 10001 -G appgroup appuser

LABEL org.opencontainers.image.title="greeting-app" \
      org.opencontainers.image.description="A MultiPlatform (amd64 & arm64) compartible containerised Python greeting application"

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/healthz',timeout=2).read()"]

CMD ["gunicorn", \
     "--bind", "0.0.0.0:8080", \
     "--workers", "2", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--worker-tmp-dir", "/dev/shm", \
     "--graceful-timeout", "25", \
     "app:app"]
