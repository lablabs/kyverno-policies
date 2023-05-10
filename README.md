# kyverno-policies Helm chart

[<img src="https://lablabs.io/static/ll-logo.png" width=350px>](https://lablabs.io/)

We help companies build, run, deploy and scale software and infrastructure by embracing the right technologies and principles. Check out our website at <https://lablabs.io/>

---

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

## Chart values
Check out current available values in the chart [README.md](charts/kyverno-policies/README.md)

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

## Contributing and reporting issues
Feel free to create an issue in this repository if you have questions, suggestions or feature requests.

### Validation, linters and pull-requests

We want to provide high quality code and modules. For this reason we are using
several [pre-commit hooks](.pre-commit-config.yaml). A pull-request to the
master branch will trigger these validations and lints automatically. Please
check your code before you create pull-requests. See
[pre-commit documentation](https://pre-commit.com/) and
[GitHub Actions documentation](https://docs.github.com/en/actions) for further
details.

## License
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
