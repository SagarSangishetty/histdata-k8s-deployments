{{- define "histdata.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "histdata.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "histdata.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "histdata.labels" -}}
app.kubernetes.io/name: {{ include "histdata.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "histdata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "histdata.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "histdata.serviceAccountName" -}}
{{- default (include "histdata.fullname" .) .Values.serviceAccount.name }}
{{- end }}

