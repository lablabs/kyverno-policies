{{/*
Expand the name of the chart.
*/}}
{{- define "kyverno-policies.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kyverno-policies.fullname" -}}
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
{{- define "kyverno-policies.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Render a value that contains template. Based on https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_tplvalues.tpl
Usage:
{{ include "kyverno-policies.extraManifests" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "kyverno-policies.extraManifests" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Check if a particular policy is enabled.
Usage:
{{ include "kyverno-policies.enabled" (list $name $category $) }}
*/}}
{{- define "kyverno-policies.enabled" -}}
{{- $name := index . 0 }}
{{- $category := index . 1 }}
{{- $ := index . 2 }}
{{- $policyValues := get $.Values.policies $name }}
{{- $categoryValues := get $.Values.policyCategories $category }}
{{- if hasKey $policyValues "enabled" }}
    {{- if and true (index $policyValues "enabled") }}
        {{- index $policyValues "enabled" }}
        {{- else }}
    {{- end }}
{{- else if hasKey $categoryValues "enabled" }}
    {{- if and true (index $categoryValues "enabled") }}
        {{- index $categoryValues "enabled" }}
        {{- else }}
    {{- end }}
{{- else }}
{{- end }}
{{- end -}}

{{/*
Render default policy settings https://kyverno.io/docs/writing-policies/policy-settings/.
{{ include "kyverno-policies.policySettings" (list $name $category $) }}
*/}}
{{- define "kyverno-policies.policySettings" -}}
{{- $name := index . 0 }}
{{- $category := index . 1 }}
{{- $ := index . 2 }}
{{- $policyValues := get $.Values.policies $name }}
{{- $categoryValues := get $.Values.policyCategories $category }}
  validationFailureAction: {{ coalesce $policyValues.validationFailureAction $categoryValues.validationFailureAction $.Values.validationFailureAction }}
  validationFailureActionOverrides: {{ toYaml (coalesce $policyValues.validationFailureActionOverrides $categoryValues.validationFailureActionOverrides $.Values.validationFailureActionOverrides) | nindent 4 }}
{{- if hasKey $policyValues "background" }}
  background: {{ $policyValues.background }}
{{- else if hasKey $categoryValues "background" }}
  background: {{ $categoryValues.background }}
{{- else }}
  background: {{ $.Values.background }}
{{- end }}
  failurePolicy: {{ coalesce $policyValues.failurePolicy $categoryValues.failurePolicy $.Values.failurePolicy }}
{{- end -}}
