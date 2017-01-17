{%- from 'kafka/settings.sls' import kafka with context -%}

# TODO: remove(use root instead) or make kafka sudoer
kafka:
  group.present:
    - gid: {{ kafka.uid }}
  user.present:
    - uid: {{ kafka.uid }}
    - gid: {{ kafka.uid }}

kafka-directories:
  file.directory:
    - user: kafka
    - group: kafka
    - mode: 755
    - makedirs: True
    - names:
      - /var/run/kafka
      - /var/lib/kafka
      - /var/log/kafka

install-kafka-dist:
  file.managed:
    - name: /usr/local/src/{{ kafka.version_name }}.tgz
    - source: {{ kafka.source_url }}
      {%- if kafka.source_md5 != "" %}
    - source_hash: md5={{ kafka.source_md5 }}
      {%- else %}
    - skip_verify: True
      {%- endif %}
  cmd.run:
    - name: tar xzf /usr/local/src/{{ kafka.version_name }}.tgz --no-same-owner
    - cwd: {{ kafka.prefix }}
    - unless: test -d {{ kafka.real_home }}/lib
    - runas: root
    - require:
      - file: install-kafka-dist
  alternatives.install:
    - name: kafka-home-link
    - link: {{ kafka.alt_home }}
    - path: {{ kafka.real_home }}
    - onlyif: test -d {{ kafka.real_home }} %% test ! -L {{ kafka.alt_home }}
    - priority: 30
    - require:
      - file: {{ kafka.alt_home }}

{{ kafka.alt_home }}:
  file.symlink:
    - target: {{ kafka.real_home }}
    - require:
      - cmd: install-kafka-dist
