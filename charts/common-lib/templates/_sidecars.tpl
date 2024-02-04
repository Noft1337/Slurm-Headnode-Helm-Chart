{{/* vim: set filetype=mustache: */}}

{{/*
##
## filebeat sidecar related functions ##
##
*/}}
{{/*
Returns filebeat sidecar service id
*/}}
{{- define "common-lib.sidecars.filebeat.serviceId" -}}
{{- printf "%s-%s-filebeat" (include "common-lib.names.pipelinePrefixName" .) (include "common-lib.names.name" .)  }}
{{- end }}
{{/*
Creates filebeat sidecar configMap
*/}}
{{- define "common-lib.sidecars.filebeat.createConfigMap" -}}
{{- if (.Values.global.temple_config.loggers.file.enable | default false) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common-lib.sidecars.filebeat.serviceId" . }}-config
  labels:
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
data:
  filebeat.yml: |
    filebeat:
      inputs:
        - type: log
          paths:
            - "{{ .Values.global.temple_config.loggers.file.path }}"
          json.messagway_key: {{ include "common-lib.sidecars.filebeat.serviceId" . }}-log
          json.keys_under_root: true
    output:
      elasticsearch:
        hosts:
          - "{{ .Values.global.temple_config.elasticsearch_hostname }}"
{{- end }}
{{- end }}
{{/*
Return filebeat sidecar container volumes block
*/}}
{{- define "common-lib.sidecars.filebeat.volumes" -}}
{{- if (.Values.global.temple_config.loggers.file.enable | default false) }}
volumes:
  - name: {{ .Chart.Name }}-filebeat-logs-volume-mount
  - name: {{ .Chart.Name }}-filebeat-config-volume-mount
    configMap:
      name: {{ include "common-lib.sidecars.filebeat.serviceId" . }}-config
      items:
        - key: filebeat.yml
          path: filebeat.yml
{{- end }}
{{- end }}
{{/*
Return filebeat sidecar container logs volumeMount block
*/}}
{{- define "common-lib.sidecars.filebeat.volumeMounts.logs" -}}
{{- if (.Values.global.temple_config.loggers.file.enable | default false) }}
volumeMounts:
  - name: {{ .Chart.Name }}-filebeat-logs-volume-mount
    mountPath: {{ .Values.global.temple_config.loggers.file.path }}
{{- end }}
{{- end }}
{{/*
Return filebeat sidecar container config volumeMount block
*/}}
{{- define "common-lib.sidecars.filebeat.volumeMounts.config" -}}
{{- if (.Values.global.temple_config.loggers.file.enable | default false) }}
volumeMounts:
  - name: {{ .Chart.Name }}-filebeat-config-volume-mount
    mountPath: /usr/share/filebeat/filebeat.yml
    subPath: filebeat.yml
{{- end }}
{{- end }}
{{/*
Return filebeat sidecar container block
*/}}
{{- define "common-lib.sidecars.filebeat.container" -}}
{{- if (.Values.global.temple_config.loggers.file.enable | default false) }}
- name: {{ .Chart.Name }}-filebeat
  securityContext:
    {{- toYaml .Values.securityContext | nindent 4 }}
  image: "{{ .Values.global.sidecars.filebeat.image.repository }}:{{ .Values.global.sidecars.filebeat.image.tag }}"
  imagePullPolicy: {{ .Values.global.sidecars.filebeat.image.pullPolicy }}
  {{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.sidecars.filebeat.volumeMounts.logs" .) "dict2" (include "common-lib.sidecars.filebeat.volumeMounts.config" .) "mkey" "volumeMounts") | nindent 2 }}
  resources:
    {{- toYaml .Values.global.sidecars.filebeat.resources | nindent 4 }}
{{- end }}
{{- end }}
{{/*
##
## filebeat sidecar related functions ##
##
*/}}


{{/*
##
## dind sidecar related functions ##
##
*/}}
{{/*
Return dind sidecar container volumes block
*/}}
{{- define "common-lib.sidecars.dind.volumes" -}}
volumes:
  - name: {{ .Chart.Name }}-dind-var-run-volume-mount
    emptyDir: {}
{{- end }}
{{/*
Return dind sidecar container volumeMount block
*/}}
{{- define "common-lib.sidecars.dind.volumeMounts" -}}
volumeMounts:
  - name: {{ .Chart.Name }}-dind-var-run-volume-mount
    mountPath: /var/run
{{- end }}
{{/*
Return dind sidecar container block
*/}}
{{- define "common-lib.sidecars.dind.container" -}}
- name: {{ .Chart.Name }}-dind
  securityContext:
    {{- toYaml .Values.global.sidecars.dind.securityContext | nindent 4 }}
  image: "{{ .Values.global.sidecars.dind.image.repository }}:{{ .Values.global.sidecars.dind.image.tag }}"
  imagePullPolicy: {{ .Values.global.sidecars.dind.image.pullPolicy }}
  {{- include "common-lib.sidecars.dind.volumeMounts" . | nindent 2 }}
  resources:
    {{- toYaml .Values.global.sidecars.dind.resources | nindent 4 }}
{{- end }}
{{/*
##
## dind sidecar related functions ##
##
*/}}
