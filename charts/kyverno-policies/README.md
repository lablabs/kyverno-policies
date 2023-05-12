# kyverno-policies

Helm chart for deployment of Kyverno policies

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Description
Helm chart to deploy Kyverno policies.
Policy categories:
- **podSecurityBaseline** - https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline
- **podSecurityRestricted** - https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted
- **other**

## Installation
````shell
helm repo add kyverno-policies https://lablabs.github.io/kyverno-policies/
helm install kyverno-policies kyverno-policies/kyverno-policies
````

## How-to
### Enable or disable policies
#### Enable a policy
````yaml
policies:
  myPolicy:
    enabled: true
````
#### Enable a category
````yaml
policyCategories:
  myCategory:
    enabled: true
````
#### Enable all policies
````yaml
enableAll: true
````
#### Disable a policy or category
If you want to explicitly disable policies or entire categories - even if a higher level is enabled - set the `.disabled` value.
````yaml
# All policies are enabled
enableAll: true

# All policies within the category myCategory will not be deployed
policyCategories:
  myCategory:
    disabled: true

# The policy myPolicy will not be deployed
# If both disabled and enabled are specified, disabling takes precedence
policies:
  myPolicy:
    disabled: true
    enabled: true
````

### Set attributes
#### Set `validationFailureAction for a policy
````yaml
policies:
  myPolicy:
    validationFailureAction: Enforce
````
#### Set validationFailureAction for a category
````yaml
policyCategories:
  myCategory:
    validationFailureAction: Enforce
````
#### Set exclude block for a policy
````yaml
# Excludes namespace kube-system from rule validation
policies:
  myPolicy:
    exclude:
      any:
        - resources:
            namespaces:
              - kube-system
````
#### Override policy rules
In case you want to override the entire `rules` block of a particular policy, set `.Values.policies.myPolicy.rulesOverride`.
````yaml
# Excludes namespace kube-system from rule validation
policies:
  myPolicy:
    rulesOverride:
      - name: my-rule
        match: ...
````

### Value priority
Most values are overridden in the following order of priority, from highest to lowest:
1. Policy
2. Category
3. Chart
#### Example
````yaml
# All policies are enabled
enableAll: true

# Chart setting
validationFailureAction: Audit

# Category setting
# All policies within myCategory will have validationFailureAction set to Enforce
policyCategories:
  myCategory:
    validationFailureAction: Enforce

# Even if myPolicy is part of myCategory, validationFailureAction will be Audit
policies:
  myPolicy:
    validationFailureAction: Audit
````

### Deploy a custom policy
If you have a custom policy that you would like to deploy as part of the Helm release, provide its manifest in `.Values.extraManifests`:
````yaml
extraManifests:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    metadata: ...
    spec: ...
````

## Adding a new policy
1. Create your policy manifest. The policy should ideally be a ClusterPolicy
2. Place the policy template in its appropriate category directory
3. Override `$name` and `$category` variables. `$name` should match the file name, `category` should match the directory.
````yaml
{{- $name := "myPolicy" }}
{{- $category := "myCategory" }}
{{- $policyValues := get .Values.policies $name }}
{{- $categoryValues := get .Values.policyCategories $category }}

{{- if and (or $policyValues.enabled $categoryValues.enabled .Values.enableAll) (not (or $policyValues.disabled $categoryValues.disabled)) }}
...
{{- end }}
````
4. Provide useful [Kyverno annotations](https://github.com/kyverno/policies/wiki/Kyverno-annotations)
5. Allow override of default policy [settings](https://kyverno.io/docs/writing-policies/policy-settings/) in `spec` (if applicable).
````yaml
spec:
  validationFailureAction: {{ coalesce $policyValues.validationFailureAction $categoryValues.validationFailureAction .Values.validationFailureAction }}
  validationFailureActionOverrides: {{ toYaml (coalesce $policyValues.validationFailureActionOverrides $categoryValues.validationFailureActionOverrides .Values.validationFailureActionOverrides) | nindent 4 }}
{{- if hasKey $policyValues "background" }}
  background: {{ $policyValues.background }}
{{- else if hasKey $categoryValues "background" }}
  background: {{ $categoryValues.background }}
{{- else }}
  background: {{ .Values.background }}
{{- end }}
  failurePolicy: {{ coalesce $policyValues.failurePolicy $categoryValues.failurePolicy .Values.failurePolicy }}
````
6. Add the `rules` block
````yaml
  rules:
{{- if $policyValues.rulesOverride }}
{{ toYaml $policyValues.rulesOverride | indent 4 }}
{{- else }}
...
{{- end }}
````
7. Allow override of the `exclude` block within your rules (if appropriate)
````yaml
{{- if $policyValues.exclude }}
      exclude: {{ toYaml $policyValues.exclude | nindent 8 }}
{{- end }}
````
8. Add your policy and category to values.yaml
````yaml
policyCategories:
  myCategory:
    enabled: false

policies:
  myPolicy:
    enabled: false
````

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| background | bool | `true` | Default background policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| enableAll | bool | `false` | Used to enable all policies. Categories or policies with value .disabled will be excluded. |
| extraManifests | list | `[]` | List of extra manifests to deploy. Can be used to deploy your custom policies. |
| failurePolicy | string | `"Fail"` | Default failurePolicy policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| fullnameOverride | string | `""` | fullnameOverride |
| nameOverride | string | `""` | nameOverride |
| policies | object | `{"blockStaleImages":{"enabled":false},"checkServiceAccount":{"enabled":false},"disableAutomountServiceAccountToken":{"enabled":false},"disablePodAutomountServiceAccountToken":{"enabled":false},"disableServiceDiscovery":{"enabled":false},"disallowAllSecrets":{"enabled":false},"disallowCapabilitiesStrict":{"enabled":false},"disallowDefaultNamespace":{"enabled":false},"disallowEmptyIngressHost":{"enabled":false},"disallowHostNamespaces":{"enabled":false},"disallowHostPath":{"enabled":false},"disallowHostPorts":{"enabled":false},"disallowPrivilegeEscalation":{"enabled":false},"disallowPrivilegedContainers":{"enabled":false},"disallowProcMount":{"enabled":false},"disallowSELinux":{"enabled":false},"preventNakedPods":{"enabled":false},"protectNodeTaints":{"enabled":false},"requireEncryptionAwsLoadBalancers":{"enabled":false},"requireLabels":{"enabled":false},"requireRoRootFs":{"enabled":false},"requireRunAsNonRoot":{"enabled":false},"requireRunAsNonRootUser":{"enabled":false},"restrictAppArmor":{"enabled":false},"restrictImageRegistries":{"enabled":false},"restrictIngressWildcard":{"enabled":false},"restrictNodePort":{"enabled":false},"restrictSeccompStrict":{"enabled":false},"restrictServiceExternalIps":{"enabled":false},"restrictSysctls":{"enabled":false},"restrictVolumeTypes":{"enabled":false}}` | Used to enable and override individual policies. Policy override takes precedence over category override. Policy name matches its filename. |
| policyCategories | object | `{"other":{"enabled":false},"podSecurityBaseline":{"enabled":false},"podSecurityRestricted":{"enabled":false}}` | Used to enable policies in bulk per category. May override policy attributes for the entire category. |
| validationFailureAction | string | `"Audit"` | Default validationFailureAction policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| validationFailureActionOverrides | list | `[]` | Default validationFailureActionOverrides policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Labyrinth Labs | <contact@lablabs.io> | <https://lablabs.io> |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
