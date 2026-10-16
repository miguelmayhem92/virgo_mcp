FROM python:3.11-slim as builder 

ARG ROOT="modules"
ARG MODULE="momentum"
ARG SERVICE="ranking"
ARG COMMON="common"
ARG TESTS="test"
# set to launch remote container
ARG SECRET_NAME  

ENV MODULE_PATH="${ROOT}/${MODULE}"
ENV COMMON_PATH="${ROOT}/${COMMON}"
ENV SERVICE_PATH="${ROOT}/${MODULE}/${SERVICE}"
ENV TEST_PATH="${ROOT}/${MODULE}/${SERVICE}/${TESTS}"

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ENV SECRET_NAME=${SECRET_NAME}

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

WORKDIR /app

COPY ./${MODULE}/pyproject.toml .

RUN pip install --upgrade pip
RUN pip install poetry poetry-plugin-export

RUN poetry export -f requirements.txt --only main --without-hashes -o requirements.txt
RUN pip install --no-cache-dir \
    --no-deps \
    -r requirements.txt --target=/app/asset-layer/modules

