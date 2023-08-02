{{- define "sidecar.killer" }}
{{/*
{{ include "sidecarKiller" (dict "containerName" "containerNameToCheck" "Values" .Values) }}
*/}}
- name: sidecar-killer
  image: {{ .Values.serviceMesh.sidecarKiller.image }}
  command: ["/bin/sh", "-c"]
  args: ["echo \"waiting 10s for istio side cars to be up\"; sleep 10s; /app/ready.py --service-mesh-check {{ .containerName }} -t 45;"]
  env:
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
{{ end -}}
