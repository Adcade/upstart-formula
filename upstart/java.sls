{% macro javaservice(name, main_class, classpath, jar_file, service_account="root", log_path="/var/log", java_opts={}, running=false) -%}

{% set default_opts = {
  "Xms": "256M",
  "Xmx": "1G"
} %}

{% set java_opts_str = "" %}
{% for k, v in java_opts.items() %}
  {% set java_opts_str = java_opts_str ~ " -" ~ k ~ "=" ~ v  %}
{% endfor %}
{% for k, v in default_opts.items() %}
  {% if k not in java_opts %}
    {% set java_opts_str = java_opts_str ~ " -" ~ k ~ "=" ~ v %}
  {% endif %}
{% endfor %}


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
        exec:            "$(which java) {{ java_opts_str }} -cp {{ classpath }} {{ main_class }}"

{% if running -%}
{{ name }}:
  service.running:
    - watch:
      - file: /etc/init/{{ name }}.conf
{% endif -%}

{%- endmacro %}
