{{/* vim: set filetype=mustache: */}}

{{/*
When deploying temple microservices, try .Values.global.temple_version as base image tag, 
if .Values.global.temple_version is empty, use the default .Values.image.tag.
*/}}
{{- define "common-lib.temple.Imagetag" -}}
{{- if and .Values.global .Values.global.temple_version }}
{{- printf (toString .Values.global.temple_version) }}
{{- else }}
{{- printf (toString .Values.image.tag) }}
{{- end }}
{{- end }}

{{/*
##
## temple config related functions ##
##
*/}}
{{/*
Return temple config env block
*/}}
{{- define "common-lib.temple.config.env" -}}
{{- if and (and .Values.global .Values.global.temple_config) .Values.global.temple_config.id }}
env:
- name: TEMPLE_CONFIG_FILE
  value: /opt/configs/{{ .Values.global.temple_config.id }}
{{- end }}
{{- end }}
{{/*
Return temple config env block merged with the charts env
*/}}
{{- define "common-lib.temple.config.env.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.env" .) "dict2" (include "common-lib.env.env" .) "mkey" "env") }}
{{- end }}
{{/*
Return temple config env block merged with the charts env and global env
*/}}
{{- define "common-lib.temple.config.env.withglobal.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.env.merged" .) "dict2" (include "common-lib.env.global.env" .) "mkey" "env") }}
{{- end }}
{{/*
Return temple config volumeMounts block
*/}}
{{- define "common-lib.temple.config.volumeMounts" -}}
{{- if and .Values.global .Values.global.temple_config }}
volumeMounts:
- name: temple-config-volume
  mountPath: /opt/configs
  readOnly: true
{{- end }}
{{- end }}
{{/*
Return temple config volumeMounts block merged with the charts volumeMounts
*/}}
{{- define "common-lib.temple.config.volumeMounts.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.volumeMounts" .) "dict2" (include "common-lib.volumes.volumeMounts" .) "mkey" "volumeMounts") }}
{{- end }}
{{/*
Return temple config volumeMounts block merged with the charts volumeMounts and global volumeMounts
*/}}
{{- define "common-lib.temple.config.volumeMounts.withglobal.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.volumeMounts.merged" .) "dict2" (include "common-lib.volumes.global.volumeMounts" .) "mkey" "volumeMounts") }}
{{- end }}
{{/*
Return temple config volumes block
*/}}
{{- define "common-lib.temple.config.volumes" -}}
{{- if and .Values.global .Values.global.temple_config }}
volumes:
- name: temple-config-volume
  configMap:
    name: {{ include "common-lib.names.pipelinePrefixName" . }}-temple-config
{{- end }}
{{- end }}
{{/*
Return temple config volumes block merged with the charts volumes
*/}}
{{- define "common-lib.temple.config.volumes.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.volumes" .) "dict2" (include "common-lib.volumes.volumes" .) "mkey" "volumes") }}
{{- end }}
{{/*
Return temple config volumes block merged with the charts volumes and global volumes
*/}}
{{- define "common-lib.temple.config.volumes.withglobal.merged" -}}
{{- include "common-lib.utils.merge.dicts" (dict "dict1" (include "common-lib.temple.config.volumes.merged" .) "dict2" (include "common-lib.volumes.global.volumes" .) "mkey" "volumes") }}
{{- end }}
{{/*
##
## temple config related functions ##
##
*/}}
