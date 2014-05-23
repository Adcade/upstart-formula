{% macro javaservice(name, main_class, classpath, jar_file, service_account="root", log_path="/var/log", java_opts={}) -%}

{% set xms = "256M" -%}
{% set xmx = "1G" -%}

{% if java_opts -%}
{% set xms  = java_opts.get("xms", xms) -%}
{% set xmx  = java_opts.get("xmx", xmx) -%}
{% endif -%}

{% set classpath = ".:" ~ jar_file ~ ":" ~ classpath %}
{% set java_opts = "-Xms " ~ xms ~ " -Xmx " ~ xmx ~ " -Djava.ext.dirs=lib" %}

/etc/init/{{ name }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 664
    - template: jinja
    - source: salt://upstart/templates/upstart.jinja
    - context:
        name:            {{ name }}
        log_file:        {{ log_path }}/{{ name }}-startup.log
        service_account: {{ service_account }}
        exec:            "$(which java) -cp {{ classpath }} {{ main_class }} {{ java_opts }}"

{{ name }}:
  service.running:
    - watch:
      - file: /etc/init/{{ name }}.conf

{%- endmacro %}
