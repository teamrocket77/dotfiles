# Kubernetes / Helm YAML validation workflow

A focused cheat-sheet for the schema-validation workflow in this config — how plain
k8s YAML and Helm templates get validated against the right (CRD) schema, and the
commands/keys that drive it. (This is a workflow note, not full config docs.)

## TL;DR

| Key          | Command          | What it does                                                        |
|--------------|------------------|---------------------------------------------------------------------|
| `<leader>ya` | `:YamlCrdsAttach`| Make the current buffer a validated k8s-yaml buffer (name + attach). |
| `<leader>hr` | `:HelmT`         | Render **this** Helm template + validate. *(helm buffers only)*     |
| `<leader>hp` | `:HelmPick`      | Pick a template → pick values → render + validate. *(global)*       |
| —            | `:YamlCrdsSync`  | Download/refresh the datreeio CRD schema cache.                     |
| —            | `:YamlCrdsFind`  | Fuzzy-find a cached CRD schema by filename.                        |
| —            | `:YamlCrdsGrep`  | Live-grep inside cached CRD schemas.                              |

When a schema is attached, the statusline shows a `⎈ <schema>` chip (e.g.
`⎈ externalsecret_v1beta1`, or `⎈ kubernetes` for built-in kinds).

## First-time setup

Run `:YamlCrdsSync` once to download the [datreeio/CRDs-catalog] into the cache
(`stdpath("cache")/yaml-crds`, ~20 MB download / ~215 MB on disk). Opening any Helm
chart template also warms it automatically. No network is needed at edit time once
the cache is warm. Refresh later (new upstream CRDs) with `:YamlCrdsSync` again.

Requirements: `helm` on `PATH`, and `yamlls` (installed via mason).

## How it works

There are **two** schema paths, because Helm templates and plain YAML are served by
different language servers:

1. **Plain YAML k8s docs** (`ft=yaml`) → the outer **yamlls** client.
   `lua/plugins/yaml-crds.lua` reads the first `apiVersion`/`kind` in the buffer and
   binds the matching cached CRD schema to *that buffer* (falling back to yamlls'
   bundled `kubernetes` schema for built-in kinds). This happens automatically on
   `FileType yaml`.

2. **Helm chart templates** (`ft=helm`) → **helm_ls**'s *embedded* yamlls, which the
   outer client can't reach. That path uses a static per-template glob table in
   `lua/plugins/mason.lua` (`M.helm_config`).

`:HelmT` / `:HelmPick` bridge the gap: they render a single template to concrete
YAML with `helm template --show-only`, drop it into a normal `yaml` buffer, and run
`:YamlCrdsAttach` — so the rendered output flows through path (1) and gets validated
by content, no static table needed.

`:YamlCrdsAttach` is the reusable primitive underneath: it names the buffer if
unnamed (yamlls binds schemas by `file://` URI), sets `ft=yaml`, and attaches the
schema by content. It's filetype-agnostic, so it also works on piped input:

```sh
helm template <release> <chart> --show-only templates/externalsecret.yaml \
  | nvim - -c YamlCrdsAttach
```

(the `-` reads stdin into the buffer; `-c` runs the command after it loads).

## Rendering (`:HelmT` / `:HelmPick`)

- `:HelmT` works on the current Helm template buffer; `:HelmPick` first lets you pick
  a template file under the cwd (`find … -path '*/templates/*'`), so it works from
  the dashboard / anywhere.
- Both then let you pick a `values*.y{,a}ml` file from the chart (or `<default
  values.yaml>` to render with the chart's own values), via `mini.pick`. Esc cancels.
- The rendered buffer is **`acwrite`** and named `<chart>-<template>.rendered.yaml`:
  it validates live, and `:w` (or `:w <path>`) saves it on demand — nothing is
  written to disk unless you ask.

## Caveats

- **Multi-doc:** yamlls binds one schema per file, keyed off the *first* document. A
  template that emits several resources (e.g. a `range` loop) only gets the first
  doc validated. `--show-only` on a single-resource template avoids this.
- **Render errors:** charts needing `helm dependency build` or `.Capabilities`
  surface their error as a `vim.notify`, not a buffer.
- **Off-catalog / wrong guess:** for a k8s doc whose CRD isn't in the catalog, add a
  modeline `# yaml-language-server: $schema=<URL>` to point yamlls at a schema
  directly.

## Where it lives

- `lua/plugins/yaml-crds.lua` — content-based attach, the datreeio cache, and
  `:YamlCrds*` commands. Exposes `M.attach(bufnr)` and sets `vim.b.crd_schema`.
- `lua/plugins/helm-render.lua` — shared render logic + global `:HelmPick`/`<leader>hp`.
- `ftplugin/helm.lua` — buffer-local `:HelmT`/`<leader>hr` (delegates to the module).
- `lua/plugins/mason.lua` — `M.helm_config` (helm_ls static CRD glob table) and
  `M.yaml_config` (yamlls / SchemaStore / GitLab CI schema).
- `lua/plugins/mini.lua` — statusline `⎈ <schema>` chip (reads `vim.b.crd_schema`).

[datreeio/CRDs-catalog]: https://github.com/datreeio/CRDs-catalog
