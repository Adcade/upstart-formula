{% macro vertxservice(name, main_class, classpath, jar_file, service_account="root", log_path="/var/log") -%}

{% set classpath = ".:" ~ jar_file ~ ":" ~ classpath %}

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
        exec:            "$(which vertx) run {{ main_class }} -cp {{ classpath }}"

{{ name }}:
  service.running:
    - watch:
      - file: /etc/init/{{ name }}.conf

{%- endmacro %}
