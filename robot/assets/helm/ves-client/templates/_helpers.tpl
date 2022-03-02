{{/*
Expand the name of the chart.
*/}}
{{- define "ves-client.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ves-client.fullname" -}}
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
{{- define "ves-client.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ves-client.labels" -}}
helm.sh/chart: {{ include "ves-client.chart" . }}
{{ include "ves-client.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ves-client.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ves-client.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ves-client.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ves-client.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common namespace
*/}}
{{- define "ves-client.namespace" -}}
  {{- default .Release.Namespace .Values.nsPrefix -}}
{{- end -}}

{{/*
Define dns names in certificate
*/}}
{{- define "ves-client.dnsNames" -}}
{{- range $dnsName := $.Values.certificates.dnsNames }}
- {{ $dnsName }}
{{- end }}
{{- end }}

{{/*
Define dns names in certificate
*/}}
{{- define "ves-client.init" -}}
{{ if eq .Values.certMethod "wrongCert" }}
initContainers:
- name: {{ include "common.name" . }}-readiness
  env:
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
  image: {{ .Values.certInitializer.image }}
  imagePullPolicy: {{ .Values.pullPolicy | default .Values.pullPolicy }}
  volumeMounts:
    - name: {{ .Values.aafVolumeName }}
      mountPath: /opt/app/osaaf
{{- end }}
{{- end }}

{{- define "ves-client.containers" -}}
containers:
- env:
  - name: MONGO_HOSTNAME
    value: {{ .Values.config.mongoDbName | quote }}
  - name: USE_CERTIFICATE_FOR_AUTHORIZATION
    value: {{ .Values.config.useCerts | quote }}
  - name: STRICT_HOSTNAME_VERIFICATION
    value: {{ .Values.config.strictHost | quote }}
  name: {{ .Values.configMapName }}
  securityContext:
    {{- toYaml .Values.securityContext | nindent 12 }}
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  ports:
    - containerPort: {{ .Values.service.port }}
      protocol: TCP
  livenessProbe:
    httpGet:
      path: /simulator/config
      port: 5000
    initialDelaySeconds: 10
    periodSeconds: 30
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  readinessProbe:
    httpGet:
      path: /simulator/config
      port: 5000
    initialDelaySeconds: 60
    periodSeconds: 15
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  resources:
    {{- toYaml .Values.resources | nindent 12 }}
  volumeMounts:
    {{ if eq .Values.certMethod "wrongCert" }}
    - name: certstore
      mountPath: /app/store/cert.p12
      subPath: cert.p12
    - name: certstore
      mountPath: /app/store/p12.pass
      subPath: p12.pass
    - name: {{ .Values.aafVolumeName }}
      mountPath: /app/store
    {{- end }}
    {{ if eq .Values.certMethod "cmpv2" }}
    - name: certstore
      mountPath: /app/store
    {{- end }}

{{- define "ves-client.volumes" -}}
volumes:
{{ if or ( eq .Values.certMethod "cmpv2" ) ( eq .Values.certMethod "wrongCert" ) }}
    - name: certstore
      projected:
        sources:
          - secret:
              name: ves-client-secret-cmpv2
              items:
                - key: keystore.p12
                  path: cert.p12
                - key: p12.pass
                  path: p12.pass
                - key: p12.pass
                  path: truststore.pass
                - key: truststore.jks
                  path: trust.jks
    {{- end }}
    {{ if eq .Values.certMethod "wrongCert" }}
    {{ include "common.certInitializer.volumes" . | nindent 8 }}
    - name: {{ .Values.aafVolumeName }}
      emptyDir: {}
{{- end }}
