# ---------- builder: resolve and install locked dependencies ----------
FROM python:3.11-slim AS builder

WORKDIR /build

RUN pip install --no-cache-dir --upgrade pip poetry poetry-plugin-export

COPY pyproject.toml ./
RUN pip install --upgrade pip
RUN pip install poetry poetry-plugin-export

RUN poetry export -f requirements.txt --only main --without-hashes -o requirements.txt \
 && pip install --no-cache-dir -r requirements.txt --target=/install

# ---------- runtime ----------
FROM python:3.11-slim

ARG MODULE=src

# Lambda Web Adapter: lets a normal HTTP server (uvicorn) run on Lambda
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/opt/deps:/var/task \
    PORT=8000 \
    AWS_LWA_PORT=8000

WORKDIR /var/task

COPY --from=builder /install /opt/deps
COPY ${MODULE} ./${MODULE}

EXPOSE 8000

# Adjust "src.server:app" to your module path and ASGI app object.
# For FastMCP, the ASGI app is typically mcp.streamable_http_app().
CMD ["python", "-m", "uvicorn", "src.server:app", "--host", "0.0.0.0", "--port", "8000"]