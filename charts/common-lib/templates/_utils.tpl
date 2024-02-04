{{/* vim: set filetype=mustache: */}}

{{/*
Returns a merged dict by key,
Accepts 3 arguments, 2 dicts to be merged, and the related key.
*/}}
{{- define "common-lib.utils.merge.dicts" -}}
{{- $dict1 := index . "dict1" -}}
{{- $dict2 := index . "dict2" -}}
{{- $mkey := index . "mkey" -}}
{{- $dictList := list $dict1 $dict2  }}
{{- if gt (len (compact $dictList)) 0 -}}
{{ printf "%s" $mkey }}:
  {{- range $item := until (len $dictList) }}
    {{- with (fromYaml (index $dictList $item)) }}
      {{- range $key, $value := . }}
      {{- toYaml $value | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
