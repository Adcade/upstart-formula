{% macro vertxservice(name, main_class, classpath, jar_file, service_account="root", log_path="/var/log", java_opts={}, running=false) -%}

{% set java_opts_str = "" %}
{% for k, v in java_opts.items() %}
  {% set java_opts_str = java_opts_str ~ " -" ~ k ~ "=" ~ v  %}
{% endfor%}

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
        {%- if java_opts_str %}
        env:
          JAVA_OPTS:   "{{ java_opts_str }}"
        {% endif -%}

{%- if running %}
{{ name }}:
  service.running:
    - watch:
      - file: /etc/init/{{ name }}.conf
{% endif -%}

{%- endmacro %}
