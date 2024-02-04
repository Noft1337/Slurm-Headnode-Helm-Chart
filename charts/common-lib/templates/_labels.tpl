{{/* vim: set filetype=mustache: */}}

{{/*
Common labels
*/}}
{{- define "common-lib.labels.labels" -}}
helm.sh/chart: {{ include "common-lib.names.chart" . }}
{{ include "common-lib.labels.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common-lib.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common-lib.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
