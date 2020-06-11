# Airflow Production docker-compose setup

## Acknowledgments

This repo is a culmination of the ideas and code from the following:
- Docker + Celery
    - [article](https://medium.com/@xnuinside/quick-tutorial-apache-airflow-with-3-celery-workers-in-docker-composer-9f2f3b445e4)
    - [repo](https://github.com/xnuinside/airflow_in_docker_compose)
- [Master + worker node setup
  article](https://medium.com/@khatri_chetan/how-to-setup-airflow-multi-node-cluster-with-celery-rabbitmq-cfde7756bb6a)
- [puckel/airflow](https://github.com/puckel/docker-airflow)

## Introduction

Production grade airflow docker-compose setup:
- celery backend
- rabbitmq (with dashboard)
- scalable number of nodes
- postgresql (needs external db, but you can configure a service for a local instance)

You can just copy paste the worker definition (in `docker-compose.yml`) as many times as you want, everything else should automagically work, provided
you've follwed the steps below.

## Setup

- First, copy the `env.example` and populate it with the relevant values.

```bash
cp -rv env.example .env # populate .env
```

- Then just run the docker-compose stack

```bash
docker-compose up --build -d
```


## UI

- Airflow Dashboard: `/airflow/`
- Flower UI: `/flower/`
- RabbitMQ Management Dashboard: `/` (currently there's an error with mounting to url prefix)

## Issues

### RabbitMQ

Sometimes the workers and other nodes are not able to connect to the rabbitmq instance inspite of the exact same credentials. In such a situation,
just reset the password for the user you've created and you should be good to go.

```bash
docker exec -it <rabbitmq_container_id> rabbitmqctl change_password $RABBIT_USER $RABBIT_PASSWORD
# verify once
docker exec -it <rabbitmq_container_id> rabbitmqctl authenticate_user $RABBIT_USER $RABBIT_PASSWORD
```

### `airflow.exceptions.AirflowTaskTimeout` error

WIP (I think changing the timeout config should help, please submit a PR if you've been able to fix this!)

