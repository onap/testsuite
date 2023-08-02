{{- define "smoke.test" }}
{{/* Define smoke test template */}}
apiVersion: tests.testkube.io/v3
kind: Test
metadata:
  name: {{ .testName }}
spec:
  type: {{ .Values.smokeTests.executor.type }}
  executionRequest:
    args:
    - $(TESTNAME)
    envs:
      TESTNAME: {{ .onapTestName }}
      PYTHONPATH: $PYTHONPATH:/data/repo/configuration/{{ .testName }}
      ONAP_PYTHON_SDK_SETTINGS: "{{ .testName }}-configuration"
      {{- if .Values.slackNotifications.enabled }}
      SLACK_TOKEN: "{{ .Values.slackNotifications.slackConfig.token }}"
      SLACK_URL: {{ .Values.slackNotifications.slackConfig.baseUrl }}
      SLACK_CHANNEL: "{{ .Values.slackNotifications.slackConfig.channel }}"
      {{- end }}
    artifactRequest:
      storageClassName: {{ .Values.storage.class }}
      volumeMountPath: /tmp
    activeDeadlineSeconds: 1800
    jobTemplate: |
      apiVersion: batch/v1
      kind: Job
      spec:
        template:
          metadata:
            labels:
              sidecar.istio.io/inject: "false"
          spec:
            serviceAccountName: default
            containers:
              - name: {{ printf "\"{{ .Name }}\"" }}
                image: {{ printf "{{ .Image }}" }}
                imagePullPolicy: Always
  content:
    type: git-file
    repository:
      type: git
      uri: https://gerrit.onap.org/r/testsuite
      branch: master
      path: /testkube/
{{ end -}}
