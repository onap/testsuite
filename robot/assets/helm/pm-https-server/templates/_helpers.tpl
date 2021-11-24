{{/*
Expand the name of the chart.
*/}}
{{- define "pmhttpsserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common namespace
*/}}
{{- define "pmhttpsserver.namespace" -}}
  {{- default .Release.Namespace .Values.nsPrefix -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pmhttpsserver.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pmhttpsserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pmhttpsserver.labels" -}}
helm.sh/chart: {{ include "pmhttpsserver.chart" . }}
{{ include "pmhttpsserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pmhttpsserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pmhttpsserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pmhttpsserver.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pmhttpsserver.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define dns names in certificate
*/}}
{{- define "pmhttpsserver.dnsNames" -}}
{{- range $.Values.certificates.dnsNames }}
- {{ . }}
{{- end }}
{{- end }}
