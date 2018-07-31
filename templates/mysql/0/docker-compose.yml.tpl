version: '2'
services:
  mysql-lb:
    image: rancher/lb-service-haproxy:v0.9.1
    ports:
      - ${mysql_lb_port}:${mysql_lb_port}
  mysql-data:
    labels:
        io.rancher.container.start_once: true
    network_mode: none
    image: rawmind/alpine-volume:0.0.2-1
    environment:
        - SERVICE_UID=999
        - SERVICE_GID=999
        - SERVICE_VOLUME=/var/lib/mysql
    volumes:
      - mysql-data-volume:/var/lib/mysql
  mysql:
    image: ${mysql_image}
    environment:
{{- if eq .Values.mysql_allow_empty_password "yes"}}
      MYSQL_ALLOW_EMPTY_PASSWORD: ${mysql_allow_empty_password}
{{- end}}
{{- if (.Values.mysql_database)}}
      MYSQL_DATABASE: ${mysql_database}
{{- end}}
{{- if eq .Values.mysql_onetime_password "yes"}}
      MYSQL_ONETIME_PASSWORD: ${mysql_onetime_password}
{{- end}}
{{- if (.Values.mysql_password)}}
      MYSQL_PASSWORD: ${mysql_password}
{{- end}}
{{- if eq .Values.mysql_random_root_password "yes"}}
      MYSQL_RANDOM_ROOT_PASSWORD: ${mysql_random_root_password}
{{- end}}
      MYSQL_ROOT_PASSWORD: ${mysql_root_password}
{{- if (.Values.mysql_user)}}
      MYSQL_USER: ${mysql_user}
{{- end}}
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: mysql-data
    volumes_from:
      - mysql-data

volumes:
  mysql-data-volume:
    driver: ${VOLUME_DRIVER}
    per_container: true