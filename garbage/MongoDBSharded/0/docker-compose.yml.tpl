---
version: '2'

services:
  mongod:
    image: ${MONGO_VERSION}
    stdin_open: true
    tty: true
    volumes_from:
      - mongod-config
      - mongod-data
    labels:
      {{- if ne .Values.MONGOD_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${MONGOD_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: mongod-config, mongod-data
    environment:
      RS_NAME: '${MONGOD_RS_NAME}'
      MONGO_INITDB_ROOT_USERNAME: '${MONGO_INITDB_ROOT_USERNAME}'
      MONGO_INITDB_ROOT_PASSWORD: '${MONGO_INITDB_ROOT_PASSWORD}'
    {{- if and (eq .Values.MONGOS_ENABLED "true") (ne .Values.MONGOD_PORT "")}}
    ports:
      - '${MONGOD_PORT}:27017'
    {{- end}}
    entrypoint: /opt/rancher/bin/entrypoint-mongod.sh

  mongod-config:
    image: lgatica/mongo-config
    stdin_open: true
    tty: true
    volumes:
      - /run/secrets
      - /opt/rancher/bin
    environment:
      MONGODB_KEYFILE_SECRET: '${MONGODB_KEYFILE}'
    labels:
      {{- if ne .Values.MONGOD_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${MONGOD_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'

  {{- if .Values.MONGOD_VOLUME_PATH}}
  mongod-data:
    image: busybox
    labels:
      {{- if ne .Values.MONGOD_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${MONGOD_HOST_LABEL}
      {{- end}}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    volumes:
      - {{.Values.MONGOD_VOLUME_PATH}}:/data/db
    entrypoint: /bin/true
  {{- end}}

  {{- if eq .Values.ARBITER_ENABLED "true"}}
  arbiter:
    image: ${MONGO_VERSION}
    stdin_open: true
    tty: true
    volumes_from:
      - arbiter-config
      - arbiter-data
    labels:
      {{- if ne .Values.ARBITER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${ARBITER_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: arbiter-config, arbiter-data
    environment:
      RS_NAME: '${MONGOD_RS_NAME}'
      MONGO_INITDB_ROOT_USERNAME: '${MONGO_INITDB_ROOT_USERNAME}'
      MONGO_INITDB_ROOT_PASSWORD: '${MONGO_INITDB_ROOT_PASSWORD}'
    entrypoint: /opt/rancher/bin/entrypoint-arbiter.sh
    depends_on:
      - mongod

  arbiter-config:
    image: lgatica/mongo-config
    stdin_open: true
    tty: true
    volumes:
      - /run/secrets
      - /opt/rancher/bin
    environment:
      MONGODB_KEYFILE_SECRET: '${MONGODB_KEYFILE}'
    labels:
      {{- if ne .Values.ARBITER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${ARBITER_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'

  {{- if .Values.ARBITER_VOLUME_PATH}}
  arbiter-data:
    image: busybox
    labels:
      {{- if ne .Values.ARBITER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${ARBITER_HOST_LABEL}
      {{- end}}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    volumes:
      - {{.Values.ARBITER_VOLUME_PATH}}:/data/db
    entrypoint: /bin/true
  {{- end}}
  {{- end}}

  {{- if eq .Values.CONFIGSVR_ENABLED "true"}}
  configsvr:
    image: ${MONGO_VERSION}
    stdin_open: true
    tty: true
    volumes_from:
      - configsvr-config
      - configsvr-data
    labels:
      {{- if ne .Values.CONFIGSVR_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${CONFIGSVR_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always

      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: configsvr-config, configsvr-data
    environment:
      RS_NAME: '${CONFIGSVR_RS_NAME}'
      MONGO_INITDB_ROOT_USERNAME: '${MONGO_INITDB_ROOT_USERNAME}'
      MONGO_INITDB_ROOT_PASSWORD: '${MONGO_INITDB_ROOT_PASSWORD}'
    entrypoint: /opt/rancher/bin/entrypoint-configsvr.sh

  configsvr-config:
    image: lgatica/mongo-config
    stdin_open: true
    tty: true
    volumes:
      - /run/secrets
      - /opt/rancher/bin
    environment:
      MONGODB_KEYFILE_SECRET: '${MONGODB_KEYFILE}'
    labels:
      {{- if ne .Values.CONFIGSVR_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${CONFIGSVR_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'

  {{- if .Values.CONFIGSVR_VOLUME_PATH}}
  configsvr-data:
    image: busybox
    labels:
      {{- if ne .Values.CONFIGSVR_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${CONFIGSVR_HOST_LABEL}
      {{- end}}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    volumes:
      - {{.Values.CONFIGSVR_VOLUME_PATH}}:/data/db
    entrypoint: /bin/true
  {{- end}}
  {{- end}}

  {{- if eq .Values.MONGOS_ENABLED "true"}}
  mongos:
    image: ${MONGO_VERSION}
    stdin_open: true
    tty: true
    volumes_from:
      - mongos-config
    ports:
      - '${MONGOS_PORT}:27017'
    environment:
      MONGOD_RS_NAME: '${MONGOD_RS_NAME}'
      CONFIGSVR_RS_NAME: '${CONFIGSVR_RS_NAME}'
      MONGODB_DBNAME: '${MONGODB_DBNAME}'
      MONGO_INITDB_ROOT_USERNAME: '${MONGO_INITDB_ROOT_USERNAME}'
      MONGO_INITDB_ROOT_PASSWORD: '${MONGO_INITDB_ROOT_PASSWORD}'
    labels:
      {{- if ne .Values.MONGOS_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${MONGOS_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always

      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: mongos-config
    entrypoint: /opt/rancher/bin/entrypoint-mongos.sh
    depends_on:
      - mongod
      - configsvr

  mongos-config:
    image: lgatica/mongo-config
    stdin_open: true
    tty: true
    volumes:
      - /run/secrets
      - /opt/rancher/bin
    environment:
      MONGODB_KEYFILE_SECRET: '${MONGODB_KEYFILE}'
    labels:
      {{- if ne .Values.MONGOS_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${MONGOS_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
  {{- end}}
