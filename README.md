# Greeting Container

**DWP DevOps Technical Assessment — Containerisation & CI/CD**

A secure, multi-platform container solution for the supplied Python greeting application, with automated testing, vulnerability scanning and controlled releases.

---


> **Note:** The supplied `app/` directory and its dependencies have not been modified.

---

##  Solution Overview

| Component | Implementation |
| :--- | :--- |
| **Containerisation** | Multi-stage Docker build |
| **Runtime** | Gunicorn, non-root user |
| **Architectures** | AMD64 and ARM64 |
| **Code quality** | Hadolint, Ruff |
| **Testing** | Pytest, HTTP smoke tests, health checks |
| **Security scanning** | Trivy — HIGH/CRITICAL |
| **Supply chain** | SBOM, provenance, SHA-256 verification |
| **Registry** | GitHub Container Registry (GHCR) |
| **Automation** | GitHub Actions, Dependabot |

---

##  CI/CD Pipeline

The pipeline separates **automated validation** from **controlled publishing**.

### Continuous Integration

Every pull request targeting `main` triggers:

1. **Linting** — Hadolint and Ruff.
2. **Testing** — Pytest and container smoke tests.
3. **Build** — Multi-platform OCI image for AMD64 and ARM64.
4. **Security** — Trivy vulnerability scanning.
5. **Supply chain** — SBOM and build provenance.
6. **Verification** — Image integrity and checksums.

### Controlled Release

A manually triggered workflow:

- Retrieves the previously validated image artifact.
- Verifies its SHA-256 checksum and source commit.
- Publishes a versioned image to GHCR.
- Verifies the published image digest.

**Build once. Validate once. Publish the verified artifact.**

---

##  Security & Maintenance

| Control | Purpose |
| :--- | :--- |
| **Non-root execution** | Reduce container privileges |
| **Runtime hardening** | Restrict container permissions |
| **Trivy** | Detect HIGH/CRITICAL vulnerabilities |
| **SBOM** | Document software components |
| **Build provenance** | Provide traceability |
| **Dependabot** | Propose dependency updates |
| **SHA-pinned Actions** | Pin CI actions to immutable revisions |
| **Branch protection** | Require validated changes before merging |

Dependabot checks Docker base images and GitHub Actions on a scheduled basis.

All proposed dependency updates are validated through CI before being reviewed and merged.

---

##  Release Strategy

Container images use **versioned tags** to support reproducible deployments and controlled rollbacks.

The release process publishes the **already-tested OCI image**, rather than rebuilding it.

This ensures the published image matches the artifact validated during CI.

---

##  Original DWP Assessment Instructions

The original assessment requirements are preserved below.

---

############################################################################################################

############################################################################################################

# DevOps Interview Task (Part 1): Containerize

**This is a take-home task.** Please submit by the date given when the task was
issued.

## Overview

You are given a small web application (`app/`). A working `Dockerfile` is
provided, but it was written quickly and does **not** follow container best
practices. Your job is to refactor it into a production-quality image and push
it to a container registry.

You do **not** need to modify the application code.

## What we provide

Clone this repository into your local account.

> **Do Not** fork this repository. Clone it and re-push it into your local account.

The following is provided as part of this repository:

```text
Dockerfile            # a working but non-production Dockerfile — improve it
app/
  app.py              # a minimal Python Flask web app (do not modify)
  requirements.txt    # the app's dependencies (do not modify)
```

The application:

-   Listens on the port given by the `PORT` environment variable (default `8080`).
-   Reads a `GREETING` environment variable used in its response.
-   Exposes `GET /`, `GET /healthz`, and `GET /info`.


