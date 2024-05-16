<div align="center">
	<p>
	<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 /><br />
	<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/EMPCPlatformStarterKitsImage.png?sanitize=true" width=350/><br />
	<h2>ghs-tools-action</h2>
	<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/ThoughtWorks-DPS/gha-tools-action/.github%2Fworkflows%2Fdevelopment-build.yaml"> <img alt="GitHub Release" src="https://img.shields.io/github/v/release/ThoughtWorks-DPS/gha-tools-action"> <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
	</p>
</div>

GitHub Action for authoring actions and building job container images

Provides four workflows:  
1. static-code-analysis
2. release-version
3. job-container-dev-release
4. publish-container

### static-code-analysis workflow  

Performs the following actions.  
1. yamllint
2. shellcheck
3. ossf/scorecard and upload results to repo security dashboard

### release-version workflow  

Generates a github release based on the current git tag with --generates-notes flag. Includes the full SHA in the release title for easier secure consumption.  

### job-container-dev-release  

runs on gha-container-builder:latest  

Performs the following actions. (see links for action paramters and details)  
1. [Install](install/action.yaml) specific versions of dependencies (optional)
2. Call local action = ./.github/actions/before-static-analysis with instance: value (optional)
3. [Hadoline](hadolint/action.yaml) Dockerfile
4. Call local action = ./.github/actions/before-build with instance: value (optional)
5. Set [opencontainer](set-labels/action.yaml) date and version labels based on build (optional)
6. [Build](build/action.yaml) image
7. Perform [snyk](snyk-scan/action.yaml):cli image scan (optional)
8. Perform [trivy](trivy-scan/action.yaml) image scan (optional)
9. Perform [grype](grype-scan/action.yaml) image scan (optional)
10. Runtime configuration test using [bats](bats-test/action.yaml) (optional)
11. Call local action = ./.github/actions/after-build with instance: value (optional)
12. Push image to registry

### publish-container

runs on gha-container-builder:latest.  

Performs the following actions. (see links for action paramters and details)  
1. [Install](install/action.yaml) specific versions of dependencies (optional)
2. Call local action = ./.github/actions/before-build with instance: value (optional)
3. [Pull](pull/action.yaml) copy of current commit development image to be published with tag release
4. [Tag](tag/action.yaml) development image with current tag as release version
5. Tag development image with custom tag as additional release version, E.g., latest (optional)
6. [Push](push/action.yaml) release version(s) to registry
7. Call local action = ./.github/actions/after-build with instance: value (optional)
8. [Sign](sign/action.yaml) release image using Cosign and cosign-generated key (optional)
9. Generate [sbom](sbom/action.yaml) using Syft, push to registry using Oras (optional)
10. Generate release notes using [Gren](https://github.com/ThoughtWorks-DPS/common-actions) (optional)

## Action Development Usage  

Create a workflow that will be triggered on a push to any branch. Call the gha-tools-action static-code-analysis workflow to analyze your action. This worklow should call a local integration-test workflow if the static code analysis is successful.  

Ex:  
```yaml
# yamllint disable rule:line-length
# yamllint disable rule:truthy
---
name: static code analysis

on:
  push:
    branches:
      - "*"
    tags:
      - "!*"

permissions:
  contents: read
  security-events: write   # write permissions needed for ossf/scorecard

jobs:

  static-code-analysis:
    name: static code analysis
    uses: ThoughtWorks-DPS/gha-tools-action/.github/workflows/static-code-analysis.yaml@main
    secrets:
      OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }} # optional

  integration-tests:
    name: integration test
    uses: ./.github/workflows/integration-tests.yaml
    needs: static-code-analysis
    secrets:
      OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
```


Ex: integration-test.yaml
```yaml
# yamllint disable rule:line-length
# yamllint disable rule:truthy
---
name: integration tests

on:
  workflow_call:

    secrets:
      OP_SERVICE_ACCOUNT_TOKEN:
        description: 1password vault services account token
        required: false

permissions:
  contents: read

jobs:

  integration-tests:
    name: action integration tests
    runs-on: ubuntu-latest

    steps:
      - name: checkout code
        uses: actions/checkout@0ad4b8fadaa221de15dcec353f45205ec38ea70b         # v4.1.4

      - name: run <your-action>/<action-folder>@main         # for each action in your solution, path not needed if single action
        uses: <your-org>/<your-action>/<action-folder>@main  # always @main since this is ci
        with:
          parameters: <value>

      - name: test the results                               # generally you will need to use the action then test what happened
        shell: bash
        run: |
          <script.sh to test results>

      ...  <repeat for each actions or workflow as needed>
```

Add a release workflow triggered by git tag.  

Ex:  
```yaml
# yamllint disable rule:line-length
# yamllint disable rule:truthy
---
name: release version

on:
  push:
    branches:
      - "!*"
    tags:
      - "*"

permissions:         # write needed for generating release & notes
  contents: write
  issues: write

jobs:

  release-version:
    name: release version
    uses: ThoughtWorks-DPS/gha-tools-action/.github/workflows/release-version.yaml@v2
    secrets:
      OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
    with:
      release-message: New release of my-action

  # you may want to add  notifications on success or failure
```
## Job Container Usage

Create a workflow that will be triggered on a push to any branch. Call the gha-tools-action job-container-dev-release workflow to perform static code analysis, security scans, build and push development release of job container image. Use before-static-analysis local action to load secrets.  

Workflow will use the twdps/gha-container-builder job container by default. This container has the dependencies already installed. 

```yaml
# yamllint disable rule:line-length
# yamllint disable rule:truthy
---
run-name: development build and release

on:
  push:
    branches:
      - "*"
    tags:
      - "!*"

jobs:

  dev-release:
    name: development build and release
    uses: ThoughtWorks-DPS/gha-tools-action/.github/workflows/job-container-dev-release.yaml@main
    secrets:
      OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
    with:
      image: twdps/gha-container-base-image
      op-version: 2.28.0
      snyk-version: 1.1291.0
      bats-version: 1.11.0
      hadolint-version: 2.12.0
      before-static-analysis: true
      snyk-scan: true
      snyk-severity-threshold: medium
      snyk-organization: twdps
      bats-test: true
      bats-run-container-name: gha-container-base-image
      bats-entry-point: /bin/ash
      bats-test-path: test/gha-container-base-image.bats
```

Create publish workflow triggered by git tag.  

```yaml
# yamllint disable rule:line-length
# yamllint disable rule:truthy
---
run-name: publish image

on:
  push:
    branches:
      - "!*"
    tags:
      - "*"

jobs:

  publish:
    name: publish image
    uses: ThoughtWorks-DPS/gha-tools-action/.github/workflows/publish-container.yaml@main
    secrets:
      OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
    with:
      image: twdps/gha-container-base-image
      op-version: 2.28.0
      cosign-version: 2.2.4
      syft-version: 1.4.1
      oras-version: 1.1.0
      sign-image: true
      sbom: true
      gren: true
      before-publish: true
```


### Development

Currently, has broad 1password support. Vault and Teller are installable, but still in development.  