{%- from 'zookeeper/settings.sls' import zk with context %}

include:
  - kafka

kafka-systemd-unit:
  file.managed:
    - name: /lib/systemd/system/kafka.service
    - source: salt://kafka/files/kafka.service.systemd
    - makedirs: True

kafka-config:
  file.managed:
    - name: /etc/kafka/server.properties
    - source: salt://kafka/files/server.properties
    - template: jinja
    - context:
      zookeepers: {{ zk.connection_string }}
    - require:
      - pkg: confluent-kafka-2.11

kafka-environment:
  file.managed:
    - name: /etc/default/kafka
    - source: salt://kafka/files/kafka.default
    - template: jinja

kafka-service-script:
  file.managed:
    - name: /etc/init.d/kafka
    - source: salt://kafka/files/kafka.init.d
    - user: kafka
    - group: kafka
    - mode: 755
    - template: jinja

kafka-service:
  service.running:
    - name: kafka
    - enable: true
    - require:
      - pkg: confluent-kafka-2.11
      - file: kafka-config
      - file: kafka-environment
      - file: kafka-systemd-unit
      - file: kafka-service-script
