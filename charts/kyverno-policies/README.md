# kyverno-policies

Helm chart for deployment of Kyverno policies

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Description
Helm chart to deploy Kyverno policies.
Policy categories:
- **bestPractices** - Policies which validate and enforce Kubernetes best practices
- **podSecurityBaseline** - https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline
- **podSecurityRestricted** - https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted
- **other** - All other policies, may be split into separate categories in the future
- **sample** - Policies that showcase a certain Kyverno functionality

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
# All policies within the category will be deployed
policyCategories:
  myCategory:
    enabled: true
````

#### Disable a policy
In case you want to deploy an entire category except for just a few policies, you can explicitly disable the unwanted
policies by setting their `enabled` value to `false`.
````yaml
# Category myCategory is enabled
policyCategories:
  myCategory:
    enabled: true

# The policy myPolicy is part of myCategory. By setting enabled: false, it will not be deployed even if the category is enabled.
policies:
  myPolicy:
    enabled: false
````
The following table shows the results of possible combinations for the `enabled` values on the policy(p) and category(c) level.
`true` means policy will be deployed, `false` means policy will not be deployed. Policy value has precedence over category value.

| enabled     | true(c) | false(c) | no value(c) |
|-------------|---------|----------|-------------|
| true(p)     | true    | true     | true        |
| false(p)    | false   | false    | false       |
| no value(p) | true    | false    | false       |

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

### Deploy custom policie
If you have custom policie you would like to deploy as part of the Helm release, provide their manifests in `.Values.extraManifests`:
````yaml
extraManifests:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    metadata: # metadata
    spec: # spec
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

{{- if include "kyverno-policies.enabled" (list $name $category $) }}
# The policy goes here
{{- end }}
````
4. Provide useful [Kyverno annotations](https://github.com/kyverno/policies/wiki/Kyverno-annotations)
5. [Policy settings](https://kyverno.io/docs/writing-policies/policy-settings/) are rendered via the kyverno-policies.policySettings template within _helpers.tpl. If your policy setting is not listed yet, add it there with appropriate overrides.
6. Add the `rules` block
````yaml
  rules:
{{- if $policyValues.rulesOverride }}
{{ toYaml $policyValues.rulesOverride | indent 4 }}
{{- else }}
# Your rules go here
{{- end }}
````
7. Allow override of the `exclude` block within your rules (if appropriate)
````yaml
{{- if $policyValues.exclude }}
      exclude: {{ toYaml $policyValues.exclude | nindent 8 }}
{{- end }}
````
8. Add your policy and/or category to values.yaml
````yaml
policyCategories:
  myCategory: {}

policies:
  myPolicy: {}
````
9. Document your changes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| background | bool | `true` | Default background policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| extraManifests | list | `[]` | List of extra manifests to deploy. Can be used to deploy your custom policies. |
| failurePolicy | string | `"Fail"` | Default failurePolicy policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| fullnameOverride | string | `""` | fullnameOverride |
| nameOverride | string | `""` | nameOverride |
| policies | object | `{"blockStaleImages":{},"checkServiceAccount":{"background":false},"disableAutomountServiceAccountToken":{},"disablePodAutomountServiceAccountToken":{},"disableServiceDiscovery":{},"disallowAllSecrets":{},"disallowCapabilitiesStrict":{},"disallowDefaultNamespace":{},"disallowEmptyIngressHost":{},"disallowHostNamespaces":{},"disallowHostPath":{},"disallowHostPorts":{},"disallowPrivilegeEscalation":{},"disallowPrivilegedContainers":{},"disallowProcMount":{},"disallowSELinux":{},"preventNakedPods":{},"protectNodeTaints":{"background":false},"requireEncryptionAwsLoadBalancers":{},"requireLabels":{},"requireRoRootFs":{},"requireRunAsNonRoot":{},"requireRunAsNonRootUser":{},"restrictAppArmor":{},"restrictImageRegistries":{},"restrictIngressWildcard":{},"restrictNodePort":{},"restrictSeccompStrict":{},"restrictServiceExternalIps":{},"restrictSysctls":{},"restrictVolumeTypes":{}}` | Used to enable and override individual policies. Policy override takes precedence over category override. Policy name matches its filename. |
| policyCategories | object | `{"bestPractices":{},"other":{},"podSecurityBaseline":{},"podSecurityRestricted":{},"sample":{}}` | Used to enable policies in bulk per category. May override policy attributes for the entire category. |
| validationFailureAction | string | `"Audit"` | Default validationFailureAction policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |
| validationFailureActionOverrides | list | `[]` | Default validationFailureActionOverrides policy setting according to https://kyverno.io/docs/writing-policies/policy-settings/ |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Labyrinth Labs | <contact@lablabs.io> | <https://lablabs.io> |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
