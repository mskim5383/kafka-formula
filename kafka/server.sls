{%- from 'kafka/settings.sls' import kafka with context %}
{%- from 'zookeeper/settings.sls' import zk with context %}

include:
  - kafka

clear-kafka-folder:
  file.absent:
    - name: '/etc/kafka'

/etc/kafka:
  file.directory:
    - user: root
    - group: root
    - require:
      - file: clear-kafka-folder

move-kafka-dist-conf:
  cmd.run:
    - name: mv -f {{ kafka.real_home }}/config {{ kafka.real_config }}
    - unless: test -L {{ kafka.real_home }}/config
    - require:
      - file: /etc/kafka

kafka-config-link:
  alternatives.install:
    - name: 'kafka-config-link'
    - link: {{ kafka.alt_config }}
    - path: {{ kafka.real_config }}
    - priority: 30
    - onlyif: test -d {{ kafka.real_config }} && test ! -L {{ kafka.alt_config }}
    - require:
      - file: {{ kafka.alt_config }}
      - file: {{ kafka.real_home}}/config

{{ kafka.alt_config }}:
  file.symlink:
    - target: {{ kafka.real_config }}
    - require:
      - cmd: move-kafka-dist-conf

{{ kafka.real_home }}/config:
  file.symlink:
    - target: {{ kafka.real_config }}
    - require:
      - cmd: move-kafka-dist-conf

# TODO: context
kafka-config:
  file.managed:
    - name: {{ kafka.real_config }}/server.properties
    - source: salt://kafka/files/server.properties
    - template: jinja
    - context:
      zookeepers: {{ zk.connection_string }}
    - require:
      - cmd: install-kafka-dist
      - cmd: move-kafka-dist-conf

kafka-environment:
  file.managed:
    - name: /etc/default/kafka
    - source: salt://kafka/files/kafka.default
    - template: jinja

{%- if grains.get('systemd') %}
# TODO: systemd
kafka-service-script:
  file.managed:
    - name: /lib/systemd/system/kafka.service
    - source: salt://kafka/files/kafka.service.systemd
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{%- else %}

kafka-service-script:
  file.managed:
    - name: /etc/init.d/kafka
    - source: salt://kafka/files/kafka.init.d
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      alt_config: {{ kafka.alt_config }}
      alt_home: {{ kafka.alt_home }}
{%- endif %}

{% if kafka.restart_on_change %}
kafka-service:
  service.running:
    - name: kafka
    - enable: true
    - require:
      - alternatives: install-kafka-dist
      - alternatives: kafka-config-link
      - file: kafka-environment
      - file: kafka-service-script
{%- endif %}
