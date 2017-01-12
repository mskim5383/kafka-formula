kafka-pkg-setup:
  pkgrepo.managed:
    {% set os_family = salt['grains.filter_by']({
      'Debian': 'Debian',
      'Ubuntu': 'Ubuntu',
      'RedHat': 'RedHat'
      }, default='Debian') %}
    {% if os_family == 'RedHat' %}
    - baseurl: http://packages.confluent.io/rpm/3.0
    - gpgcheck: 1
    - gpgkey: http://packages.confluent.io/rpm/3.0/archive.key
    - file: /etc/yum.repos.d/kafka-pkg-setup.repo
    {% elif os_family == 'Debian' or 'Ubuntu' %}
    - name: deb [arch=amd64] http://packages.confluent.io/deb/3.0 stable main
    - key_url: http://packages.confluent.io/deb/3.0/archive.key
    - file: /etc/apt/sources.list.d/kafka.list
    {% endif %}
    - require_in: 
      - pkg: confluent-kafka-2.11

  pkg.installed:
    - name: confluent-kafka-2.11
    - refresh: True

kafka-user:
  user.present:
    - name: kafka
    - shell: /bin/false
    - gid_from_name: True
    - createhome: False
    - system: True

/var/log/kafka:
  file.directory:
    - user: kafka
    - group: kafka
