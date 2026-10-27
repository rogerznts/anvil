#!/usr/bin/env node
// audit-record.cjs — o verbo `security` do anvil-docs: deriva de uma execução da
// anvil-security-audit o registro da auditoria, em docs/security/.
//
// Uso, da raiz do projeto auditado:
//
//   node ~/.claude/skills/anvil-docs/scripts/audit-record.cjs <diretório da execução>
//
// Saída:
//   record: docs/security/audit-<data>-run-<N>.md   o registro gravado, sai com 0
//   refusal: <motivo>                               uma por problema, sai com 2,
//                                                   e nada é gravado
//
// O registro é derivado por código, e não redigido pelo modelo, porque a garantia
// de não divulgar uma vulnerabilidade depende de quais campos são lidos (ADR-0019).
// Só se leem três arquivos da execução, e deles só a lista branca:
//
//   run-metadata.json     run_id, profile, run_status e, com run_status incomplete,
//                         incomplete_reason; do source_ref, o commit, o sha ou o
//                         revision e o dirty ou o worktree_dirty, ou a string inteira
//   coverage-ledger.json  o status de cada unidade, só para contar
//   findings.json         o fingerprint, o verdict e o severity.overall_severity
//
// Nenhum outro campo entra no registro, nem o id de unidade do ledger. Os
// relatórios em Markdown da execução nunca são abertos. Antes de ler, os dois
// arquivos passam nos validadores da anvil-security-audit instalada ao lado.
//
// Identificador que entra no registro é ficha de letras, dígitos, `-` e `_`. O
// upstream aceita `/`, `.`, `:`, `@` e `+` no fingerprint, que ele deriva da
// fonte: um fingerprint assim pode trazer caminho de código, e a linha do achado
// leva no lugar dele a posição do achado no findings.json. O run_id e o
// incomplete_reason fora de ficha saem "não exibido".
//
// O upstream não fixa a forma do source_ref: dele só entram um SHA e o estado da
// árvore, e o que não se reconhece sai "não declarado em forma reconhecível".
// Dos campos do run-metadata.json, só o profile e o run_status, que o upstream
// enumera, recusam a execução.
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const AUDIT_SKILL = path.join(__dirname, "..", "..", "anvil-security-audit");
const RUN_FILES = ["run-metadata.json", "findings.json", "coverage-ledger.json"];
const VALIDATORS = [
  ["validate-findings.cjs", "findings.json"],
  ["validate-coverage-ledger.cjs", "coverage-ledger.json"],
];
const UNIT_STATES = ["covered", "candidate", "blocked", "deferred", "out_of_scope", "not_applicable", "in_progress", "planned"];
const VERDICTS = ["confirmed", "needs_validation", "rejected"];
const SEVERITIES = ["critical", "high", "medium", "low", "informational"];
const PROFILES = ["quick", "standard", "deep"];
const RUN_STATES = ["complete", "incomplete", "in_progress"];
const SAFE_ID = /^[A-Za-z0-9][A-Za-z0-9_-]*$/;
const SHA = /\b[0-9a-f]{7,64}\b/i;
const NOT_DECLARED = "não declarado em forma reconhecível";
const NOT_SHOWN = "não exibido";

function refuse(reasons, detail = "") {
  for (const reason of reasons) console.log(`refusal: ${reason}`);
  if (detail) process.stdout.write(detail);
  process.exit(2);
}

// Do source_ref, objeto ou string, sai só o SHA e o estado da árvore; null é o
// que não veio em forma reconhecível.
function sourceRef(value) {
  const sha = (text) => (typeof text === "string" ? SHA.exec(text)?.[0] ?? null : null);
  if (typeof value === "string") {
    return { commit: sha(value), dirty: /\bdirty\b/.test(value) ? true : /\bclean\b/.test(value) ? false : null };
  }
  const object = value !== null && typeof value === "object" ? value : {};
  return {
    commit: sha(["commit", "sha", "revision"].map((key) => object[key]).find((field) => typeof field === "string")),
    dirty: ["dirty", "worktree_dirty"].map((key) => object[key]).find((field) => typeof field === "boolean") ?? null,
  };
}

function readJson(runDir, name) {
  return JSON.parse(fs.readFileSync(path.join(runDir, name), "utf8"));
}

function projectRoot() {
  const git = spawnSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" });
  if (git.status !== 0) refuse(["fora de um repositório git"]);
  return git.stdout.trim();
}

function runDirectory(arg) {
  if (!arg) refuse(["uso: node audit-record.cjs <diretório da execução>"]);
  const runDir = path.resolve(arg);
  if (!fs.statSync(runDir, { throwIfNoEntry: false })?.isDirectory()) refuse([`${runDir} não é um diretório`]);
  const match = /^run-(\d+)$/.exec(path.basename(runDir));
  if (!match) refuse([`o nome do diretório da execução não é run-<N>: ${path.basename(runDir)}`]);
  const missing = RUN_FILES.filter((name) => !fs.statSync(path.join(runDir, name), { throwIfNoEntry: false })?.isFile());
  if (missing.length) refuse(missing.map((name) => `falta ${name} em ${runDir}`));
  return { runDir, runNumber: match[1] };
}

function validate(runDir) {
  const reasons = [];
  let detail = "";
  for (const [validator, file] of VALIDATORS) {
    const script = path.join(AUDIT_SKILL, validator);
    if (!fs.existsSync(script)) {
      reasons.push(`a anvil-security-audit não está instalada ao lado do anvil-docs: falta ${script}`);
      continue;
    }
    const result = spawnSync(process.execPath, [script, path.join(runDir, file)], { encoding: "utf8" });
    if (result.status !== 0) {
      reasons.push(`${validator} saiu com ${result.status ?? result.signal} sobre ${file}`);
      detail += `--- ${validator}\n${result.stdout}${result.stderr}`;
    }
  }
  if (reasons.length) refuse(reasons, detail);
}

// Ficha de letras, dígitos, `-` e `_`, ou null: o resto pode nomear um arquivo.
function token(value) {
  return typeof value === "string" && SAFE_ID.test(value) ? value : null;
}

function metadata(runDir) {
  let meta;
  try {
    meta = readJson(runDir, "run-metadata.json");
  } catch {
    refuse(["run-metadata.json não é JSON legível"]);
  }
  if (meta === null || typeof meta !== "object" || Array.isArray(meta)) refuse(["run-metadata.json não é um objeto JSON"]);
  const fields = {
    run_id: token(meta.run_id),
    ...sourceRef(meta.source_ref),
    profile: meta.profile,
    run_status: meta.run_status,
    incomplete_reason: meta.run_status === "incomplete" ? token(meta.incomplete_reason) : null,
  };
  const reasons = [];
  const check = (ok, field, expected) => ok || reasons.push(`run-metadata.json: ${field} deve ser ${expected}`);
  check(PROFILES.includes(fields.profile), "profile", PROFILES.join(", "));
  check(RUN_STATES.includes(fields.run_status), "run_status", RUN_STATES.join(", "));
  if (reasons.length) refuse(reasons);
  return fields;
}

function countBy(values, keys) {
  const counts = new Map(keys.map((key) => [key, 0]));
  for (const value of values) counts.set(value, (counts.get(value) ?? 0) + 1);
  return counts;
}

function table(header, counts) {
  const rows = [...counts].map(([key, count]) => `| \`${key}\` | ${count} |`);
  const total = [...counts.values()].reduce((sum, count) => sum + count, 0);
  return [`| ${header} | quantos |`, "|---|---|", ...rows, `| total | ${total} |`].join("\n");
}

function render({ runNumber, runDir, meta, unitStates, findings }) {
  const shown = (value) => (value === null ? NOT_SHOWN : `\`${value}\``);
  const status = meta.run_status === "incomplete"
    ? `\`incomplete\`, motivo ${shown(meta.incomplete_reason)}`
    : `\`${meta.run_status}\``;
  const confirmed = findings.filter((finding) => finding.verdict === "confirmed");
  const id = (finding, index) => (SAFE_ID.test(finding.fingerprint) ? `\`${finding.fingerprint}\`` : `_oculto, posição ${index + 1}_`);
  const rows = findings.map((finding, index) =>
    `| ${id(finding, index)} | \`${finding.verdict}\` | ${finding.severity ? `\`${finding.severity}\`` : "—"} |`);
  const hidden = findings.some((finding) => !SAFE_ID.test(finding.fingerprint));
  return [
    `# Registro da auditoria — run-${runNumber}`,
    "",
    "Gerado pelo verbo `security` do `anvil-docs` a partir de uma execução da",
    "`anvil-security-audit`. Não leva caminho de código, trecho de fonte, título,",
    "descrição nem reprodução de nenhum achado: o detalhe fica no diretório da",
    "execução, fora do git.",
    "",
    `- Execução: ${shown(meta.run_id)}`,
    `- Diretório da execução: \`${runDir}\``,
    `- Commit auditado: ${meta.commit === null ? NOT_DECLARED : `\`${meta.commit}\``}`,
    `- Árvore auditada: ${meta.dirty === null ? NOT_DECLARED : meta.dirty ? "suja" : "limpa"}`,
    `- Perfil: \`${meta.profile}\``,
    `- Estado da execução: ${status}`,
    "",
    "## Cobertura",
    "",
    "Unidades do coverage ledger por estado.",
    "",
    table("estado", countBy(unitStates, UNIT_STATES)),
    "",
    "## Achados",
    "",
    table("veredito", countBy(findings.map((finding) => finding.verdict), VERDICTS)),
    "",
    "Achados `confirmed` por severidade:",
    "",
    table("severidade", countBy(confirmed.map((finding) => finding.severity), SEVERITIES)),
    "",
    "## Lista de achados",
    "",
    ...(rows.length ? ["| fingerprint | veredito | severidade |", "|---|---|---|", ...rows] : ["Nenhum achado."]),
    ...(hidden
      ? ["", "Fingerprint com caractere fora de letras, dígitos, `-` e `_` pode trazer caminho de", "código e fica oculto: a linha leva a posição do achado no `findings.json` da execução."]
      : []),
    "",
  ].join("\n");
}

function recordPath(root, runNumber) {
  const dir = path.join(root, "docs", "security");
  const pattern = new RegExp(`^audit-\\d{4}-\\d{2}-\\d{2}-run-${runNumber}\\.md$`);
  const existing = fs.existsSync(dir) ? fs.readdirSync(dir).find((name) => pattern.test(name)) : undefined;
  return path.join(dir, existing ?? `audit-${new Date().toISOString().slice(0, 10)}-run-${runNumber}.md`);
}

const root = projectRoot();
const { runDir, runNumber } = runDirectory(process.argv[2]);
validate(runDir);
const meta = metadata(runDir);
const unitStates = readJson(runDir, "coverage-ledger.json").map((unit) => unit.status);
const findings = readJson(runDir, "findings.json").map((finding) => ({
  fingerprint: finding.fingerprint,
  verdict: finding.verdict,
  severity: finding.verdict === "confirmed" ? finding.severity.overall_severity : null,
}));

const file = recordPath(root, runNumber);
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, render({ runNumber, runDir, meta, unitStates, findings }));
console.log(`record: ${path.relative(root, file)}`);
