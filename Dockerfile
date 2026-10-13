# Multi-stage build separates dependency installation from the runtime image.
# This improves build isolation and keeps the runtime environment minimal.
#####################################################################################################
# Stage 1: Build
#####################################################################################################
FROM python:3.12-alpine@sha256:1b668429b3511ab407d8e00648891631b0b1a4d7e15e3ca70f38ab5b91ad4ab4 AS build

WORKDIR /build

COPY app/requirements.txt .

RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install \
    --no-cache-dir \   
    -r requirements.txt

#####################################################################################################
# Stage 2: Runtime
#####################################################################################################
FROM python:3.12-alpine@sha256:1b668429b3511ab407d8e00648891631b0b1a4d7e15e3ca70f38ab5b91ad4ab4 AS runtime

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \    
    PATH="/opt/venv/bin:$PATH" 

LABEL org.opencontainers.image.title="greeting-app" \
      org.opencontainers.image.description="A containerised Python greeting application"
    

WORKDIR /app

COPY --from=build /opt/venv /opt/venv

RUN   addgroup -S -g 10001 appgroup \
      && adduser -S -D -H -u 10001 -G appgroup appuser 
         

COPY app/app.py .

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
