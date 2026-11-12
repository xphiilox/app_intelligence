FROM ubuntu:24.04

# Ubuntu security package revision; runtime is CPython 3.12.3.
ARG PYTHON_DEB_VERSION=3.12.3-1ubuntu0.17
ARG TORCH_VERSION=2.8.0
ARG DJANGO_VERSION=5.2.19
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       python3.12=${PYTHON_DEB_VERSION} python3.12-venv=${PYTHON_DEB_VERSION} \
       bash ca-certificates curl libstdc++6 \
    && useradd --uid 1001 --create-home --shell /bin/bash developer \
    && rm -rf /var/lib/apt/lists/*

# CPU PyTorch for Python development inside the container.
RUN python3.12 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir torch==${TORCH_VERSION} --index-url https://download.pytorch.org/whl/cpu \
    && /opt/venv/bin/pip install --no-cache-dir numpy==2.2.6 \
    && /opt/venv/bin/python -c "import sys, torch; assert sys.version_info[:3] == (3, 12, 3); assert torch.__version__.split('+')[0] == '2.8.0'; assert torch.version.cuda is None" \
    && chown -R developer:developer /opt/venv

RUN /opt/venv/bin/pip install --no-cache-dir Django==${DJANGO_VERSION}

WORKDIR /var/www/html
ENV PATH=/opt/venv/bin:$PATH VIRTUAL_ENV=/opt/venv PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 HOME=/home/developer
USER developer
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
