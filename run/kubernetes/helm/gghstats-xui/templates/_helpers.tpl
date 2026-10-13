{{- define "gghstats-xui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gghstats-xui.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "gghstats-xui.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "gghstats-xui.backendName" -}}
{{- printf "%s-backend" (include "gghstats-xui.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gghstats-xui.uiName" -}}
{{- printf "%s-ui" (include "gghstats-xui.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gghstats-xui.labels" -}}
app.kubernetes.io/name: {{ include "gghstats-xui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
