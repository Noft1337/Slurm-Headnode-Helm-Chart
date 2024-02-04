{{/* vim: set filetype=mustache: */}}

{{/*
When deploying slurm, returns the base image repository if it was provided in global section
*/}}
{{- define "slurm.image.repository" -}}
{{- if and (and .Values.global .Values.global.slurm) (and .Values.global.slurm.image .Values.global.slurm.image.repository) }}
{{- printf (toString .Values.global.slurm.image.repository) }}
{{- else }}
{{- printf (toString .Values.image.repository) }}
{{- end }}
{{- end }}

{{/*
When deploying slurm, returns the base image tag if it was provided in global section
*/}}
{{- define "slurm.image.tag" -}}
{{- if and (and .Values.global .Values.global.slurm) (and .Values.global.slurm.image .Values.global.slurm.image.tag) }}
{{- printf (toString .Values.global.slurm.image.tag) }}
{{- else }}
{{- printf (toString .Values.image.tag) }}
{{- end }}
{{- end }}

{{/*
When deploying slurm, returns the base image pullPolicy if it was provided in global section
*/}}
{{- define "slurm.image.pullPolicy" -}}
{{- if and (and .Values.global .Values.global.slurm) (and .Values.global.slurm.image .Values.global.slurm.image.pullPolicy) }}
{{- printf (toString .Values.global.slurm.image.pullPolicy) }}
{{- else }}
{{- printf (toString .Values.image.pullPolicy) }}
{{- end }}
{{- end }}

{{/*
When deploying slurm, returns the hostname of the slurm controller.
*/}}
{{- define "slurm.hosts.slurmctld" -}}
{{- if .Values.slurmctld.nodeSelector -}}
{{- index .Values.slurmctld.nodeSelector "kubernetes.io/hostname" }}
{{- else -}}
{{ .Release.Name }}-slurmctld-0.{{ .Release.Name }}-slurmctld.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}
{{- end }}

{{/*
When deploying slurm, returns the hostname of the slurm dbd.
*/}}
{{- define "slurm.hosts.slurmdbd" -}}
{{- if .Values.slurmdbd.nodeSelector -}}
{{- index .Values.slurmdbd.nodeSelector "kubernetes.io/hostname" }}
{{- else -}}
{{ .Release.Name }}-slurmdbd
{{- end }}
{{- end }}


{{/*
Helper function to format a slurm property.

Expects to receive a dict parameter with `name` and `value` keys.
*/}}
{{- define "slurm.formatProperty" -}}
{{- $delimiter := "=" }}
{{- with .delimiter }}
{{- $delimiter = . }}
{{- end }}
{{- printf "%v%v" .name $delimiter }}
{{- if kindIs "float64" .value }}
{{- int .value }}
{{- else if kindIs "slice" .value }}
{{- join "," .value }}
{{- else if kindIs "map" .value }}
{{- $subProperties := list }}
{{- range $subName, $subValue := .value }}
{{- $subProperties = append $subProperties (include "slurm.formatProperty" (dict "name" $subName "value" $subValue "delimiter" ":")) }}
{{- end }}
{{- join "," $subProperties }}
{{- else }}
{{- .value }}
{{- end }}
{{- end }}

{{/*
Helper function to format slurm properties.
*/}}
{{- define "slurm.formatProperties" -}}
{{- range $name, $value := . }}
{{- printf " %v" (include "slurm.formatProperty" (dict "name" $name "value" $value)) }}
{{- end }}
{{- end }}

{{/*
Helper function to produce a cartesean multiplication of 2 lists.

Output is in `yaml` format.
*/}}
{{- define "slurm.product" -}}
{{- $result := list }}
{{- $a := .a }}
{{- $b := .b }}
{{- range $i := $a }}
{{- range $j := $b }}
{{- $result = append $result (list $i $j) }}
{{- end }}
{{- end }}
{{- $result | toYaml }}
{{- end }}

{{/*
Helper function to format a node host.
*/}}
{{- define "slurm.formatHost" -}}
{{- $formats := .formats }}
{{- range $i, $param := .args }}
{{- printf (index $formats ($i | int)) ($param | int) }}
{{- end }}
{{- end }}

{{/*
Helper function to expand a range specification.

Output is in `yaml` format.
*/}}
{{- define "slurm.expandRange" -}}
{{- $result := untilStep (.start | int) (.end | default .start | add1 | int) 1 }}
{{- range .exclude }}
{{- $result = mustWithout $result (int .) }}
{{- end }}
{{- $result | toYaml }}
{{- end }}

{{/*
Helper function to expand a node range specification.

Output is in `yaml` format.
*/}}
{{- define "slurm.expandNodeRange" -}}
{{- $prefix := .prefix }}
{{- $formats := list }}
{{- $product := list }}
{{- $hosts := list }}
{{- range $i, $param := .parameters }}
{{- $formats = append $formats $param.format }}
{{- end }}
{{- if eq (len .parameters) 1 }}
{{- else }}
{{- $a := index .parameters 0 | include "slurm.expandRange" | fromYamlArray }}
{{- $b := index .parameters 1 | include "slurm.expandRange" | fromYamlArray }}
{{- $product = include "slurm.product" (dict "a" $a "b" $b) | fromYamlArray }}
{{- end }}
{{- range $product }}
{{- $hosts = append $hosts (include "slurm.formatHost" (dict "args" . "formats" $formats) | printf "%v%v" $prefix) }}
{{- end }}
{{- $hosts | toYaml }}
{{- end }}

{{/*
Helper function to compress a node range specification.
*/}}
{{- define "slurm.compressNodeRange" -}}
{{ .prefix -}}
{{- range .parameters }}
{{- printf (printf "[%v-%v]" .format .format) (int .start) (int .end) }}
{{- end }}
{{- end }}

{{/*
Helper function to format slurm plugin lists.
*/}}
{{- define "slurm.formatPluginList" -}}
{{- $prefix := .prefix }}
{{- $plugins := list }}
{{- range .types }}
{{- $plugins = append $plugins (printf "%v/%v" $prefix .) }}
{{- end }}
{{- join "," $plugins }}
{{- end }}
