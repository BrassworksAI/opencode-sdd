# Plan: Agent Readiness Report Tooling

## Goal
Build a first-party readiness report generator that mirrors the signals surfaced in Factory’s Agent Readiness view, produces a full report via an agent skill slash command, and optionally renders an interactive web report. The system should be reproducible, transparent, and extensible for new checks.

## Outcomes
- A single command (agent skill) generates a complete readiness report for the repo.
- The report includes all checks, evidence, pass/fail/skip reasons, and inference notes.
- Optional static web report for interactive exploration.

## Scope (MVP)
- CLI/skill command to generate `docs/agent-readiness-report.md`.
- Check framework with a registry of validations and standardized outputs.
- Evidence capture: file paths and commands used to evaluate each check.
- Clear “why” and “how to remediate” content.

## Non-Goals (MVP)
- Recreating Factory’s exact UI.
- Cloud service integrations beyond GitHub APIs.
- Fully automated remediation.

## Architecture Overview

### 1. Agent Skill Entry Point
Use the Agent Skills model already present in `.agent/skills/`:
- `SKILL.md` describes the command, inputs, and outputs.
- `scripts/` contains the executable generator.
- `references/` contains schema docs and examples.

Proposed skill:
```
.agent/skills/agent-readiness/
  SKILL.md
  scripts/
    generate-readiness.ts
  references/
    checks.md
    report-schema.md
```

### 2. Generator Script
The generator script should:
- Load a registry of checks (YAML/JSON or TS module).
- Run checks in a deterministic order.
- Record evidence (file paths, command outputs, and timestamps).
- Emit a Markdown report and optional JSON artifact.

### 3. Check Registry
Define checks as data, not hardcoded logic:
```yaml
id: lint_configured
level: basic
title: Linter Configuration
description: Project has a linter configured to catch code quality issues
evidence:
  - type: file
    path: .golangci.yml
  - type: command
    cmd: rg -n "golangci-lint|go vet" .github .
evaluate:
  pass_if_any:
    - file_exists: .golangci.yml
    - command_contains: "golangci-lint"
remediate:
  - Add golangci-lint config
  - Add go vet in CI
```

This allows new checks without editing code and makes the results explainable.

### 4. Report Schema
Standardize output fields:
```
id
level
title
description
score: pass|fail|skip
why
evidence: [{type, detail}]
inference
```

Include a top-level summary:
- total pass percentage
- counts by category and level
- skipped reasons summary

### 5. Optional Web Report
Generate a static site from the JSON artifact:
- A simple static HTML/CSS/JS bundle is sufficient.
- Support filters by category, level, and status.
- Show evidence and “why” per check.

## Implementation Plan

### Phase 1: Foundations (MVP)
1. Add skill scaffold under `.agent/skills/agent-readiness/`.
2. Implement generator script (Node/Bun or Go) to:
   - Load checks registry.
   - Run checks and collect evidence.
   - Produce `docs/agent-readiness-report.md`.
3. Define the initial check set to mirror Factory’s 81 checks (start with the same titles/levels).
4. Add a `references/report-schema.md` and `references/checks.md`.

### Phase 2: Evidence Quality
1. Improve each check with concrete evidence collection.
2. Add GitHub API calls for:
   - branch protection
   - code scanning/secret scanning
   - PR/issue templates
3. Add “skipped” rationale logic to avoid false negatives.

### Phase 3: Interactive Report
1. Emit JSON alongside Markdown.
2. Add `docs/agent-readiness/` static site.
3. Add filters and drilldown by check.

### Phase 4: Validation and CI
1. Add CI workflow to run readiness checks on PRs.
2. Add a “delta report” for changes introduced by PRs.
3. Track historical readiness trends.

## Proposed Check Categories (aligned to Factory)
- Style & Validation
- Build System
- Testing
- Documentation
- Development Environment
- Debugging & Observability
- Security
- Task Discovery
- Product & Experimentation

## Check Design Guidance
- Prefer explicit evidence over heuristics.
- Every fail/skip should include:
  - the data it evaluated
  - what was missing
  - a remediation suggestion
- Keep checks deterministic and reproducible.

## Detailed Check Definitions
Each check should be defined with explicit signals, evaluation rules, skip logic, and evidence capture. Use these as the initial canonical definitions.

### Style & Validation

#### Linter Configuration (basic)
- Signals: lint config files, lint commands in CI/hooks (golangci-lint, staticcheck, go vet, eslint, ruff).
- Pass: any linter config present OR CI/hook runs linter.
- Fail: no linter config or lint command found.
- Evidence: paths for lint configs; command grep results.
- Remediate: add golangci-lint or go vet in CI/pre-commit.

#### Code Formatter (basic)
- Signals: formatter config, formatter run in CI/hooks (gofmt, goimports, prettier, black, rustfmt).
- Pass: gofmt/goimports (or equivalent) invoked in CI/hooks.
- Fail: no formatter invocation found.
- Evidence: CI files, hook scripts, task runner configs.
- Remediate: add gofmt/goimports in CI or pre-commit.

#### Pre-commit Hooks (basic)
- Signals: .pre-commit-config.yaml, husky, lefthook, lint-staged, git hooks.
- Pass: pre-commit hooks configured.
- Fail: no hook framework or hooks.
- Evidence: hook config paths.
- Remediate: add pre-commit tooling.

#### Naming Consistency (intermediate)
- Signals: lint rules for naming or docs describing conventions.
- Pass: explicit naming rules in lint config or docs.
- Fail: no naming rules or documented conventions.
- Evidence: lint config entries; docs references.
- Remediate: add naming conventions or lint rules.

#### Cyclomatic Complexity (advanced)
- Signals: complexity tooling (gocyclo, go-critic, sonar, etc.).
- Pass: complexity tool configured in CI or scripts.
- Fail: no complexity tooling found.
- Evidence: config files, CI steps.
- Remediate: add complexity analysis tool.

#### Large File Detection (intermediate)
- Signals: git LFS, pre-commit size checks, CI size validation.
- Pass: file size limits enforced by hooks/CI or LFS policies.
- Fail: no size checks.
- Evidence: hook scripts, CI steps, LFS config.
- Remediate: add size checks or LFS policies.

#### Dead Code Detection (intermediate)
- Signals: staticcheck, deadcode, unused detection.
- Pass: dead code tooling configured.
- Fail: no dead code tooling.
- Evidence: config and CI steps.
- Remediate: add staticcheck/deadcode in CI.

#### Duplicate Code Detection (intermediate)
- Signals: jscpd/CPD tooling, Sonar duplication rules, or equivalent.
- Pass: duplication detection tool configured.
- Fail: no duplication tooling.
- Evidence: tool config, CI steps.
- Remediate: add duplication detection.

#### Technical Debt Tracking (intermediate)
- Signals: TODO/FIXME scanning, issue linkage rules.
- Pass: TODO scanning in CI or documented process linking TODOs to issues.
- Fail: no TODO scanning or process.
- Evidence: CI steps, docs.
- Remediate: add TODO scanner or process.

#### Type Checker (basic)
- Signals: compiled language or type checker configured (tsc, mypy, pyright).
- Pass: Go build (type checking) or static type checker configured.
- Fail: untyped language with no type checker.
- Evidence: language detection, config files.
- Remediate: add type checker tooling.

#### Strict Typing (basic)
- Signals: strict mode enabled (TypeScript/mypy) or strictly typed language.
- Pass: strict typing defaults (Go) or explicit strict mode.
- Fail: no strict mode.
- Evidence: tsconfig/mypy config or language detection.
- Remediate: enable strict mode.

#### Code Modularization Enforcement (advanced)
- Signals: boundaries tooling (depguard, forbidigo, eslint boundaries, archunit).
- Pass: module boundary enforcement configured.
- Skip: repo size below threshold (configurable) or single-package repo.
- Fail: no modularization enforcement in larger repo.
- Evidence: tooling config; repo size metrics.
- Remediate: add boundary enforcement tooling.

#### N+1 Query Detection (advanced)
- Signals: ORM usage + N+1 detection tooling (Bullet, django-debug-toolbar, Hibernate stats, OpenTelemetry db spans).
- Pass: ORM instrumentation or detection tooling enabled.
- Skip: no ORM present or raw SQL only.
- Fail: ORM present but no N+1 detection.
- Evidence: dependency list and config.
- Remediate: add ORM plugin or profiler.

### Build System

#### Agentic Development (intermediate)
- Signals: git history with agent co-authorship, tags, or commit trailers.
- Pass: commits with known agent co-author patterns.
- Fail: no agent co-authorship evidence.
- Evidence: git log query results.
- Remediate: add agent co-author trailers.

#### Feature Flag Infrastructure (advanced)
- Signals: feature flag service SDKs or config (LaunchDarkly, Statsig, Unleash, Flagsmith, ConfigCat).
- Pass: known feature flag tooling in dependencies/config.
- Fail: no feature flag system.
- Evidence: dependency search; config files.
- Remediate: add feature flag infrastructure.

#### Release Notes Automation (intermediate)
- Signals: semantic-release, changesets, release-please, changelog automation.
- Pass: release notes generation configured.
- Fail: no automation.
- Evidence: config files or CI steps.
- Remediate: add changelog tooling.

#### Unused Dependencies Detection (intermediate)
- Signals: depcheck, go mod tidy in CI, npm/prune checks, cargo-udeps.
- Pass: unused dependency detection in CI.
- Fail: no unused dep detection.
- Evidence: CI steps, scripts.
- Remediate: add detection.

#### Release Automation (intermediate)
- Signals: CD workflows, deploy pipelines, GitOps (Argo CD, Flux), release tooling.
- Pass: automated release pipeline exists.
- Fail: no CD pipeline.
- Evidence: CI workflow files.
- Remediate: add release pipeline.

#### Build Command Documentation (basic)
- Signals: README or AGENTS docs listing build commands.
- Pass: explicit build command documentation.
- Fail: no build command docs.
- Evidence: docs excerpts.
- Remediate: document build commands.

#### Dependencies Pinned (basic)
- Signals: lockfiles (go.sum, package-lock.json, etc.).
- Pass: lockfile present.
- Fail: no lockfile for dependency manager.
- Evidence: lockfile paths.
- Remediate: commit lockfile.

#### VCS CLI Tools (basic)
- Signals: gh installed and authenticated.
- Pass: `gh auth status` returns authenticated.
- Fail: gh missing or unauthenticated.
- Evidence: command output.
- Remediate: install/authenticate gh.

#### Single Command Setup (intermediate)
- Signals: docs showing single command path to dev server.
- Pass: documented single command chain.
- Fail: no documented setup flow.
- Evidence: doc lines.
- Remediate: add setup instructions.

#### Automated PR Review Generation (basic)
- Signals: bots or workflows generating PR review comments (Danger, Reviewdog, custom checks).
- Pass: bot config or evidence in PRs.
- Skip: no PRs exist.
- Fail: PRs exist but no automation.
- Evidence: GitHub API, workflow config.
- Remediate: add PR review automation.

#### Fast CI Feedback (advanced)
- Signals: CI run durations.
- Pass: median CI duration < threshold (configurable, default 10m).
- Skip: no CI runs.
- Fail: CI exists but exceeds threshold.
- Evidence: GitHub Actions API.
- Remediate: optimize CI or split jobs.

#### Build Performance Tracking (advanced)
- Signals: build timing metrics recorded.
- Pass: build metrics or artifacts captured.
- Skip: no CI or metrics.
- Fail: CI exists but no metrics.
- Evidence: CI logs, metrics tooling.
- Remediate: add build timing capture.

#### Deployment Frequency (advanced)
- Signals: release tags or deploy workflows.
- Pass: releases/deploys >= threshold per week.
- Skip: no deploy workflows.
- Fail: deploys exist but below threshold.
- Evidence: releases list, workflow runs.
- Remediate: establish release cadence.

#### Progressive Rollout (advanced)
- Signals: canary or staged deployments.
- Pass: rollout tooling or config found.
- Skip: no deploy pipeline or non-infra repo.
- Fail: deploys exist but no rollout strategy.
- Evidence: deploy configs.
- Remediate: add canary/rollout.

#### Rollback Automation (advanced)
- Signals: rollback tooling, runbooks, or deploy configs.
- Pass: automated rollback exists.
- Skip: no deploy pipeline.
- Fail: deployments exist but no rollback.
- Evidence: deploy configs.
- Remediate: add rollback automation.

#### Monorepo Tooling (basic)
- Signals: Nx/Bazel/Turborepo, multiple package manifests.
- Pass: monorepo tooling configured when monorepo detected.
- Skip: single package repo.
- Fail: monorepo detected but no tooling.
- Evidence: manifest count and tool config.
- Remediate: add monorepo tooling.

#### Heavy Dependency Detection (advanced)
- Signals: bundle analysis tooling (webpack-bundle-analyzer, rollup-plugin-visualizer, turborepo analyze).
- Pass: bundle size analysis configured.
- Skip: non-bundled backend repo.
- Fail: frontend bundle present but no analysis.
- Evidence: bundler config, analyzer config.
- Remediate: add bundle analyzer.

#### Version Drift Detection (intermediate)
- Signals: multi-package repo and version alignment tooling.
- Pass: tooling to detect version drift.
- Skip: single package repo.
- Fail: multi-package repo without drift detection.
- Evidence: tool config.
- Remediate: add drift tooling.

#### Dead Feature Flag Detection (intermediate)
- Signals: feature flag system and stale flag tooling.
- Pass: stale flag detection configured.
- Skip: no feature flag system.
- Fail: feature flags exist but no stale detection.
- Evidence: tooling config.
- Remediate: add stale flag cleanup tools.

### Testing

#### Test Performance Tracking (advanced)
- Signals: test duration metrics, analytics (pytest --durations, go test -json, Buildkite/CI timing).
- Pass: test timings captured and reported.
- Fail: no timing capture.
- Evidence: CI logs or metrics.
- Remediate: add timing output or analytics.

#### Test Coverage Thresholds (basic)
- Signals: coverage gate in CI.
- Pass: min coverage enforced.
- Fail: no coverage thresholds.
- Evidence: CI config.
- Remediate: add coverage gates.

#### Unit Tests Exist (basic)
- Signals: *_test.go or equivalent unit test files.
- Pass: tests present.
- Fail: no test files.
- Evidence: file glob results.
- Remediate: add unit tests.

#### Integration Tests Exist (intermediate)
- Signals: integration test suites (Bruno, Postman, Newman, Playwright, Cypress).
- Pass: integration test artifacts present.
- Fail: no integration tests.
- Evidence: folder existence.
- Remediate: add integration tests.

#### Unit Tests Runnable (basic)
- Signals: test command documented and runnable.
- Pass: `go test ./...` succeeds or listable.
- Fail: no documented test command or command fails.
- Evidence: command output.
- Remediate: add test command in docs.

#### Test File Naming Conventions (intermediate)
- Signals: naming conventions enforceable by language or lint.
- Pass: language conventions or lint rules enforced.
- Fail: inconsistent naming without enforcement.
- Evidence: file patterns.
- Remediate: enforce naming conventions.

#### Test Isolation (advanced)
- Signals: parallelizable tests, isolation patterns.
- Pass: testing framework supports parallel execution and tests use isolation patterns.
- Fail: tests rely on shared state without isolation controls.
- Evidence: test config or code markers.
- Remediate: add isolation or parallelization support.

#### Flaky Test Detection (advanced)
- Signals: retry tracking or flaky detection tooling.
- Pass: flaky detection in CI.
- Skip: no CI or history.
- Fail: CI exists but no flaky detection.
- Evidence: CI config.
- Remediate: add flaky detection.

### Documentation

#### Automated Documentation Generation (basic)
- Signals: docs generation tools or workflows (Swagger/OpenAPI generators, Typedoc, Sphinx, MkDocs).
- Pass: doc generation configured.
- Fail: no doc generation.
- Evidence: CI/config.
- Remediate: add doc generation tooling.

#### API Schema Docs (intermediate)
- Signals: OpenAPI/Swagger or GraphQL schema files (openapi.yaml/json, schema.graphql).
- Pass: schema docs present.
- Fail: no schema docs.
- Evidence: schema file paths.
- Remediate: add schema docs.

#### Service Architecture Documented (intermediate)
- Signals: diagrams (.mermaid, .puml) or architecture docs.
- Pass: architecture docs present.
- Fail: none found.
- Evidence: doc paths.
- Remediate: add architecture docs.

#### AGENTS.md Freshness Validation (advanced)
- Signals: CI/hook validates AGENTS commands.
- Pass: validation step exists.
- Fail: no validation.
- Evidence: CI/hook config.
- Remediate: add AGENTS validation job.

#### AGENTS.md File (basic)
- Signals: AGENTS.md exists.
- Pass: file exists.
- Fail: file missing.
- Evidence: file path.
- Remediate: add AGENTS.md.

#### README File (basic)
- Signals: README.md exists.
- Pass: file exists.
- Fail: file missing.
- Evidence: file path.
- Remediate: add README.

#### Skills Configuration (intermediate)
- Signals: .agent/skills/ exists with valid skills (SKILL.md + metadata frontmatter).
- Pass: skills present and valid format.
- Fail: no skills or invalid format.
- Evidence: skill list, validation results.
- Remediate: add skills.

#### Documentation Freshness (intermediate)
- Signals: recent doc updates in git history.
- Pass: docs updated within threshold (default 180 days).
- Fail: docs stale.
- Evidence: git log timestamps.
- Remediate: update docs.

### Development Environment

#### Dev Container (basic)
- Signals: dev environment definitions (.devcontainer/devcontainer.json, devbox.json, flake.nix, devenv.nix, shell.nix, asdf, mise, direnv).
- Pass: any supported dev environment definition exists.
- Fail: no dev environment definition found.
- Evidence: config file paths.
- Remediate: add devcontainer, devbox, or nix flake/devenv config.

#### Environment Template (basic)
- Signals: .env.example or equivalent env template.
- Pass: env template exists.
- Fail: missing env template.
- Evidence: file path.
- Remediate: add env template.

#### Local Services Setup (basic)
- Signals: docker-compose, devbox services, Tilt, or docs for local dependencies.
- Pass: local services documented or compose file exists.
- Fail: no local service setup instructions.
- Evidence: docs or compose file.
- Remediate: add local setup instructions.

#### Database Schema (basic)
- Signals: migration files or schema definitions.
- Pass: schema definitions present.
- Fail: no schema files.
- Evidence: migration paths.
- Remediate: add schema files.

#### Devcontainer Runnable (intermediate)
- Signals: devcontainer build success in CI or local check.
- Pass: devcontainer builds.
- Skip: no devcontainer.
- Fail: build fails.
- Evidence: CI logs.
- Remediate: fix devcontainer.

### Debugging & Observability

#### Structured Logging (basic)
- Signals: structured logging library configured (zap, zerolog, logrus, slog).
- Pass: structured logger in dependencies and used.
- Fail: only stdlib logging.
- Evidence: dependency scan, code references.
- Remediate: add structured logging.

#### Distributed Tracing (intermediate)
- Signals: trace IDs, OpenTelemetry, or tracing middleware (Jaeger, Honeycomb, Datadog APM).
- Pass: tracing configured.
- Fail: no tracing.
- Evidence: dependency scan and config.
- Remediate: add tracing.

#### Metrics Collection (intermediate)
- Signals: Prometheus/Datadog/StatsD metrics instrumentation.
- Pass: metrics library and endpoint or exporter configured.
- Fail: no metrics.
- Evidence: dependency/config scan.
- Remediate: add metrics instrumentation.

#### Error Tracking Contextualized (basic)
- Signals: Sentry/Bugsnag/Rollbar/Honeycomb configured.
- Pass: error tracking config present.
- Fail: none configured.
- Evidence: config and dependency scan.
- Remediate: add error tracking.

#### Alerting Configured (intermediate)
- Signals: alerting tool configs or incident integrations (PagerDuty, OpsGenie, Slack alerts).
- Pass: alerting config present.
- Fail: no alerting.
- Evidence: configs or docs.
- Remediate: add alerting.

#### Runbooks Documented (basic)
- Signals: incident runbooks in docs.
- Pass: runbook docs present.
- Fail: no runbooks.
- Evidence: doc paths.
- Remediate: add runbooks.

#### Deployment Observability (advanced)
- Signals: deploy notifications or dashboards (Datadog deploy markers, Honeycomb markers, Slack notifications).
- Pass: deploy observability configured.
- Fail: no deployment observability.
- Evidence: config/docs.
- Remediate: add deployment observability.

#### Health Checks (intermediate)
- Signals: /health endpoint or equivalent check.
- Pass: health endpoint exists.
- Fail: no health endpoint.
- Evidence: routes or docs.
- Remediate: add health endpoint.

#### Code Quality Metrics Dashboard (advanced)
- Signals: code quality dashboards (SonarCloud, Codecov, Snyk, LGTM).
- Pass: dashboards configured.
- Skip: no CI or scanning platforms.
- Fail: CI present but no quality dashboards.
- Evidence: config, badges, or API checks.
- Remediate: add quality dashboard.

#### Circuit Breakers (advanced)
- Signals: circuit breaker library or config (goresilience, resilience4j, hystrix-like).
- Pass: circuit breaker usage for external deps.
- Skip: no external service dependencies.
- Fail: external deps exist with no circuit breakers.
- Evidence: dependency scan.
- Remediate: add circuit breaker.

#### Profiling Instrumentation (advanced)
- Signals: profiling/pprof/APM configuration (pprof endpoints, Datadog profiler, Pyroscope).
- Pass: profiling enabled.
- Skip: no profiling tooling and no CI for profiling.
- Fail: performance critical system with no profiling.
- Evidence: config/dependencies.
- Remediate: add profiling.

### Security

#### Branch Protection (basic)
- Signals: GitHub branch protection rules.
- Pass: branch protection configured.
- Fail: protection missing.
- Evidence: GitHub API response.
- Remediate: enable branch protection.

#### CODEOWNERS File (basic)
- Signals: CODEOWNERS file exists.
- Pass: file exists in root or .github.
- Fail: file missing.
- Evidence: file path.
- Remediate: add CODEOWNERS.

#### Dependency Update Automation (basic)
- Signals: Dependabot, Renovate, or Updatecli config.
- Pass: config present.
- Fail: missing config.
- Evidence: config files.
- Remediate: add Dependabot/Renovate.

#### Sensitive Data Log Scrubbing (intermediate)
- Signals: log redaction/masking tooling (Sentry PII, log filters, middleware).
- Pass: scrubbing configured.
- Fail: no scrubbing.
- Evidence: logger config or code references.
- Remediate: add log scrubbing.

#### Gitignore Comprehensive (basic)
- Signals: .gitignore patterns for secrets and artifacts.
- Pass: .env, build artifacts, IDE files ignored.
- Fail: missing critical ignore patterns.
- Evidence: .gitignore content.
- Remediate: update .gitignore.

#### Secrets Management (basic)
- Signals: env vars usage, .env ignored, secret storage (Doppler, 1Password, Vault, AWS/GCP secret managers).
- Pass: secrets not committed, env vars documented.
- Fail: secrets committed or no management.
- Evidence: .gitignore, docs.
- Remediate: add secret management guidance.

#### Secret Scanning (intermediate)
- Signals: GitHub secret scanning enabled.
- Pass: secret scanning enabled.
- Skip: no GitHub access or feature disabled.
- Fail: GitHub access present but secret scanning disabled.
- Evidence: GitHub API response.
- Remediate: enable secret scanning.

#### Automated Security Review Generation (basic)
- Signals: security review bot or code scanning alerts (CodeQL, Snyk, Trivy).
- Pass: automated security review configured.
- Skip: no code scanning alerts or PRs.
- Fail: no automation and scans not configured.
- Evidence: GitHub API.
- Remediate: enable code scanning/review bot.

#### DAST Scanning (advanced)
- Signals: DAST tools configured in CI (OWASP ZAP, Burp, StackHawk).
- Pass: DAST configured.
- Skip: no CI/deploy pipeline.
- Fail: CI exists but no DAST.
- Evidence: CI config.
- Remediate: add DAST tooling.

#### PII Handling (intermediate)
- Signals: PII detection or policy docs.
- Pass: PII handling documented and tools configured if applicable.
- Skip: no user data/PII usage.
- Fail: PII likely but no handling.
- Evidence: docs and data model scan.
- Remediate: add PII handling policy.

#### Privacy Compliance (advanced)
- Signals: GDPR/CCPA compliance docs or tooling.
- Pass: compliance artifacts present.
- Skip: no end-user data collection.
- Fail: user data present but no compliance docs.
- Evidence: docs/policy files.
- Remediate: add compliance policies.

### Task Discovery

#### Issue Templates (basic)
- Signals: .github/ISSUE_TEMPLATE/ or config.
- Pass: issue templates exist.
- Fail: missing templates.
- Evidence: file paths.
- Remediate: add issue templates.

#### Issue Labeling System (basic)
- Signals: consistent labels and usage.
- Pass: labels exist and used.
- Fail: no labels or no issues to verify.
- Evidence: GitHub API labels list.
- Remediate: define label taxonomy.

#### PR Templates (basic)
- Signals: pull_request_template.md.
- Pass: PR template exists.
- Fail: missing template.
- Evidence: file path.
- Remediate: add PR template.

#### Backlog Health (advanced)
- Signals: open issues with activity and clear titles.
- Pass: issue set meets freshness/quality thresholds.
- Skip: no open issues.
- Fail: issues stale or low quality.
- Evidence: GitHub API issue data.
- Remediate: clean up backlog.

### Product & Experimentation

#### Product Analytics Instrumentation (intermediate)
- Signals: analytics SDKs configured (Mixpanel, Amplitude, PostHog, GA4, Heap).
- Pass: Mixpanel/Amplitude/PostHog/GA4 configured.
- Fail: no analytics instrumentation.
- Evidence: dependency/config scan.
- Remediate: add analytics instrumentation.

#### Error to Insight Pipeline (advanced)
- Signals: Sentry/Jira/GitHub integration or automated issue creation (Sentry rules, OpsGenie/Jira, GitHub issue automation).
- Pass: error-to-issue automation configured.
- Fail: no integration.
- Evidence: integration config or webhook setup.
- Remediate: add error-to-issue pipeline.

## Skill Command UX
Example usage:
```
/agent-readiness
```

Expected output:
- Writes `docs/agent-readiness-report.md`.
- Prints summary counts and pass rate.

## Recommendation: Tooling Stack
- Generator: Node/Bun (fast iteration, good file/JSON support)
- GitHub API: `gh` CLI or direct REST with token
- Report: Markdown + optional JSON for UI

## Risks / Tradeoffs
- Heuristic checks can be noisy; prioritize explicit evidence.
- GitHub API calls require auth and rate limits.
- Strict parity with Factory may require proprietary logic; replicate behavior, not exact implementation.

## Deliverables
- `.agent/skills/agent-readiness/SKILL.md`
- `.agent/skills/agent-readiness/scripts/generate-readiness.ts`
- `.agent/skills/agent-readiness/references/checks.md`
- `docs/agent-readiness-report.md` (generated)
- Optional: `docs/agent-readiness/index.html` (static viewer)
