#!/bin/sh
# coding: utf-8
# brief: entrypoint script for airflow initialization

# Global defaults and back-compat
: "${AIRFLOW_HOME:="/usr/local/airflow"}"
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from
cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode();
print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Sequential}Executor}"

export \
    AIRFLOW_HOME \
    AIRFLOW__CORE__EXECUTOR \
    AIRFLOW__CORE__FERNET_KEY \
    AIRFLOW__CORE__LOAD_EXAMPLES

AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}${POSTGRES_EXTRAS}"
export AIRFLOW__CORE__SQL_ALCHEMY_CONN

# Check if the user has provided explicit Airflow configuration for the broker's connection to the database
if [ "$AIRFLOW__CORE__EXECUTOR" = "CeleryExecutor"  ]; then
    AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}${POSTGRES_EXTRAS}"
    export AIRFLOW__CELERY__RESULT_BACKEND
fi

airflow initdb \
 && airflow "$@"
