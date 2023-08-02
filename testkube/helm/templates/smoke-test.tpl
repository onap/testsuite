{{- define "smoke.test" }}
{{/* Define smoke test template */}}
{{- $dot := default . .dot -}}
{{- $configurationName := default .onapTestName .configurationName }}
apiVersion: tests.testkube.io/v3
kind: Test
metadata:
  name: {{ .testName }}
spec:
  type: {{ $dot.Values.smokeTests.executor.type }}
  executionRequest:
    args:
    - $(TESTNAME)
    envs:
      TESTNAME: {{ .onapTestName }}
      PYTHONPATH: $PYTHONPATH:/data/repo/basic_configuration_settings
      ONAP_PYTHON_SDK_SETTINGS: "{{ $configurationName }}.{{ $configurationName }}_configuration"
      {{- if $dot.Values.slackNotifications.enabled }}
      SLACK_TOKEN: "{{ $dot.Values.slackNotifications.slackConfig.token }}"
      SLACK_URL: {{ $dot.Values.slackNotifications.slackConfig.baseUrl }}
      SLACK_CHANNEL: "{{ $dot.Values.slackNotifications.slackConfig.channel }}"
      {{- end }}
      {{- if $dot.Values.global.serviceMesh.enabled }}
      {{- range $key, $val := $dot.Values.serviceMesh.envVariable }}
      {{ $key }}: {{ $val | quote }}
      {{- end }}
      {{- end }}
    artifactRequest:
      storageClassName: {{ $dot.Values.storage.class }}
      volumeMountPath: {{ $dot.Values.storage.volumeMountPath }}
    activeDeadlineSeconds: 1800
    jobTemplate: |
      apiVersion: batch/v1
      kind: Job
      spec:
        template:
          spec:
            serviceAccountName: {{ $dot.Release.Name }}-tests-service-account
            containers:
            - name: {{ printf "\"{{ .Name }}\"" }}
              image: {{ printf "{{ .Image }}" }}
              imagePullPolicy: Always
            {{- if $dot.Values.global.serviceMesh.enabled }}
            {{ include "sidecarKiller" (dict "containerName" "{{ .Name }}" "Values" $dot.Values) | indent 12 | trim }}
            {{- end }}
    {{- if $dot.Values.global.serviceMesh.enabled }}
    scraperTemplate: |
      apiVersion: batch/v1
      kind: Job
      spec:
        template:
          spec:
            serviceAccountName: {{ $dot.Release.Name }}-tests-service-account
            containers:
            - name: {{ printf "\"{{ .Name }}-scraper\"" }}
              image: {{ printf "{{ .ScraperImage }}" }}
              imagePullPolicy: Always
              command:
              - "/bin/runner"
              - {{ printf "'{{ .Jsn }}'" }}
            {{ include "sidecarKiller" (dict "containerName" "{{ .Name }}-scraper" "Values" $dot.Values) | indent 12 | trim }}
    {{- end }}
  content:
    type: git-file
    repository:
      type: git
      uri: {{ $dot.Values.tests.configuration.uri }}
      branch: {{ $dot.Values.tests.configuration.branch }}
      path: {{ $dot.Values.tests.configuration.path }}
{{ end -}}