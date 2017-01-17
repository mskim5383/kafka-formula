{% set p = salt['pillar.get']('kafka', {}) %}
{% set pc = p.get('config', {}) %}
{% set g = salt['grains.get']('kafka', {}) %}
{% set gc = g.get('config', {}) %}

# {%- set java_home         = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}
{%- set java_home = '/usr/lib/jvm/jre' %}

# these are global - hence pillar-only
{%- set uid               = p.get('uid', '6031') %}
{%- set prefix            = p.get('prefix', '/usr/lib') %}

{%- set version           = g.get('version', p.get('version', '0.10.1.1')) %}
# TODO: Scala version
{%- set scala_version     = '2.11' %}
{%- set version_name      = 'kafka_' + scala_version + '-' + version %}
{%- set default_url       = 'http://apache.mirror.cdnetworks.com/kafka/' + version + '/' + version_name + '.tgz' %}
{%- set source_url        = g.get('source_url', p.get('source_url', default_url)) %}
{%- set default_md5s = {
  "0.10.1.1": "c32c75ff9b23cd6b64717f9eb5b4eb87"
  }
%}

{%- set source_md5       = p.get('source_md5', default_md5s.get(version, '00000000000000000000000000000000')) %}

# This tells the state whether or not to restart the service on configuration change
{%- set restart_on_change = p.get('restart_on_config', 'True') %}

{%- set alt_config           = salt['grains.get']('kafka:config:directory', '/etc/kafka/conf') %}
{%- set real_config          = alt_config + '-' + version %}
{%- set alt_home             = prefix + '/kafka' %}
{%- set real_home            = alt_home + '_' + scala_version + '-' + version %}
{%- set real_config_src      = real_home + '/conf' %}
{%- set real_config_dist     = alt_config + '.dist' %}

{%- set heap_initial_size = gc.get('heap_initial_size', pc.get('heap_initial_size', '1G')) %}
{%- set heap_max_size = gc.get('heap_max_size', pc.get('heap_max_size', '1G')) %}

{%- set chroot_path = gc.get('chroot_path', pc.get('chroot_path', 'kafka')) %}

{%- set targeting_method  = g.get('targeting_method', p.get('targeting_method', 'grain')) %}
{%- set hosts_target      = g.get('hosts_target', p.get('hosts_target', 'roles:kafka')) %}

{%- set broker_hosts = salt.mine.get(hosts_target, 'network.get_hostname', targeting_method).values() | sort () %}

{%- set brokers_with_ids = {} %}
{%- for i in range(broker_hosts | length()) %}
  {%- do brokers_with_ids.update({ broker_hosts[i] : i }) %}
{%- endfor %}

{%- set broker_id = brokers_with_ids.get(salt.network.get_hostname(), '') %}

{%- set config_properties = gc.get('properties', pc.get('properties', {})) %}

{%- set kafka = {} %}
{%- do kafka.update({
  'uid': uid,
  'version' : version,
  'version_name': version_name,
  'source_url': source_url,
  'source_md5': source_md5,
  'prefix' : prefix,
  'alt_config' : alt_config,
  'real_config' : real_config,
  'alt_home' : alt_home,
  'real_home' : real_home,
  'real_config_src' : real_config_src,
  'real_config_dist' : real_config_dist,
  'java_home' : java_home,
  'heap_initial_size' : heap_initial_size,
  'heap_max_size'     : heap_max_size,
  'chroot_path'       : chroot_path,
  'broker_id'         : broker_id,
  'config_properties' : config_properties,
  'restart_on_change': restart_on_change,
}) %}
