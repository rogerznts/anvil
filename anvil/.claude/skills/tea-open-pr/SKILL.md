---
name: tea-open-pr
description: Opens a Pull Request on Gitea using the `tea` CLI. Auto-detects branch type, generates PR text, applies label and assignee automatically.
---

# Open Pull Request (tea)

Your goal is to open a Pull Request on Gitea using the `tea` CLI, generating clear, professional, and well-structured PR text that facilitates efficient code reviews.

## Prerequisites

`tea` must be configured with a login for this server. If not yet done, run:

```bash
tea login add --name=<alias> --url=<gitea-url> --token=<your-token>
```

When run inside a git repository that has a Gitea remote, `tea` auto-detects the login and repo — no flags or env vars needed.

---

## Workflow

### Step 1 — Identify the branches and type

- Use the current git branch as the **source** (head).
- Auto-detect the branch type from its name prefix. Anvil spec branches are
  `{tipo}/{NNN}-{nome}` (e.g. `fix/013-carrinho-vazio`), so the prefix **is**
  the type:
  - `feature/` → **Feature**
  - `fix/` (or the legacy `bugfix/`) → **Bugfix**
  - `hotfix/` → **Hotfix**
  - `refactor/`, `gmud/`, `experimental/` → **Feature** (single PR to integration)
  - Legacy shape `{NNN}-{tipo}-{nome}` (e.g. `013-fix-carrinho`) → read the
    type from the **second** segment
  - Otherwise → treat as **Feature**
- Based on the type, determine targets:
  - **Feature / Bugfix** → single PR to the integration branch (typically `hml` or `develop`)
  - **Hotfix** → two PRs: first to the stable branch (typically `main`), second to the integration branch

Confirm with the user which base branches apply if the repo does not follow the `main`/`hml` pattern.

---

### Step 1.5 — Resolve the spec, if the branch has one

A branch with a number carries a spec. Resolve the folder **by numeric prefix**,
never by string equality — the branch is `{type}/{NNN}-{name}` and the folder is
`{NNN}-{type}-{name}`, two different strings on purpose.

Procure nos **dois** lugares: neste ponto do fluxo a spec já foi arquivada, e é
`docs/specs/archive/` que tem a pasta.

```bash
NUM=$(git rev-parse --abbrev-ref HEAD | sed -nE 's|^[a-z]+/([0-9]{3})-.*|\1|p')
[ -n "$NUM" ] && SPEC_DIR=$(ls -d docs/specs/"$NUM"-*/ docs/specs/archive/"$NUM"-*/ 2>/dev/null | head -1)
```

No number (`chore/`, `docs/`, `ci/`) means no spec, and Steps 3 and 6.5 skip the
spec parts. Number but no folder: say so — the branch claims a spec that doesn't
exist.

**O `/anvil-docs archive` roda antes deste passo, não depois do merge.** Ele
promove o ADR e move a spec para `archive/`; as duas coisas são mudança em
arquivo e precisam de um commit. Depois do merge não sobra branch onde commitar
— seria um segundo PR só para mover pasta, e no intervalo a spec fica no branch
padrão sem arquivar, que é exatamente o buraco que a guarda de merge existe para
fechar. Antes do PR, o move entra no diff que o revisor já vai olhar.

Liste os tickets. Todos devem estar `resolved` — se algum não estiver, a guarda
de merge vai bloquear o `tea pr create`, e ela está certa: o padrão é **um PR por
spec**, e uma spec com ticket aberto não terminou. Ela bloqueia também quando a
spec ainda não está sob `archive/`.

```bash
ls "$SPEC_DIR"issues/*.md
grep -L 'Status:.*resolved' "$SPEC_DIR"issues/*.md   # se voltar algo, pare aqui
bash .claude/skills/anvil-docs/scripts/validate.sh ship-ready   # o que a guarda vai ver
```

### Step 2 — Read the diff

Run:
```bash
git log <integration-branch>..<head> --oneline
git diff <integration-branch>..<head> --stat
```

(Use `<stable-branch>..<head>` for hotfix.)

- Alert the user if debug logs (`console.log`, `var_dump`, `dd()`) or temporary test code are present.

---

### Step 3 — Generate the PR text

**Title:** Conventional Commits format (e.g., `feat(module): short description`, `fix(module): short description`).

**Body (Standard PR — Feature / Bugfix / Hotfix → stable branch):**

```
## Summary

- <bullet: what this PR does, high level>

## Details

**How:** <explanation of how the changes were implemented>

- <bullet per relevant change group>

**Why:** <motivation, business rule, or problem being solved>

## Impact

- <bullet: effect on the user or system>

## Spec

`docs/specs/archive/<spec-dir>/spec.md`

Tickets:
- `issues/01-<slug>.md` — <ticket title>
- `issues/02-<slug>.md` — <ticket title>
- `issues/03-<slug>.md` — <ticket title>
```

**Um PR por spec, não por ticket.** Uma spec tem N tickets; abrir um PR para cada
produziria uma enxurrada de PRs de uma linha, e o revisor perderia a unidade que
faz sentido revisar — a mudança inteira.

Por isso todos os tickets da seção estão fechados: a **guarda de merge** só libera
`tea pr create` quando `issues/` não tem nenhum `Status:` diferente de `resolved`.
Se ela bloquear, a spec não terminou — feche o que falta ou reveja o recorte, que
pode estar grande demais para uma spec só.

A seção `## Spec` é **omitida** num branch sem número.

**Por que caminho e não `closes #47`:** os tickets são arquivo no repositório, não
issue no servidor, então não há número para fechar. O caminho é a referência
estável, e resolve no diff deste próprio PR.

**Use o caminho sob `archive/`**, que é onde a spec está desde o Step 1.5 e onde
ela vai continuar depois do merge. Citar `docs/specs/<spec-dir>/` deixaria o
corpo do PR apontando para um lugar que já não existe.

**Body (Hotfix → integration branch — always use exactly this):**

```
Applying hotfix changes to the integration branch.
```

- All text must be in English.
- Be clear and professional.

---

### Step 4 — Determine the label

Run to list available labels:
```bash
tea labels list
```

Auto-suggest based on branch prefix:

| Branch prefix | Suggested label |
|---------------|-----------------|
| `feature/`    | `Kind/Feature` (or equivalent) |
| `bugfix/`     | `Kind/Bug` (or equivalent) |
| `hotfix/`     | `Kind/Hot` (or equivalent) |

- Match against the actual labels returned by `tea labels list`.
- If a clear match exists, inform the user and proceed. If not, show the list and ask the user to choose.
- The same label applies to **both PRs** on a hotfix.

---

### Step 5 — Determine the assignee

Ask the user who to assign, or skip if unneeded. `tea` accepts usernames directly — no ID lookups required.

---

### Step 6 — Create the PR(s)

**Feature / Bugfix — single PR to integration branch:**
```bash
tea pr create \
  --title "<title>" \
  --description "<body>" \
  --base <integration-branch> \
  --labels "<label-name>" \
  --assignees "<username>"
```

**Hotfix — two PRs:**

First, PR to stable branch:
```bash
tea pr create \
  --title "<title>" \
  --description "<standard body>" \
  --base <stable-branch> \
  --labels "<label-name>" \
  --assignees "<username>"
```

Then, PR to integration branch:
```bash
tea pr create \
  --title "<title>" \
  --description "Applying hotfix changes to the integration branch." \
  --base <integration-branch> \
  --labels "<label-name>" \
  --assignees "<username>"
```

`tea` auto-detects the repo from the git remote. Use `--login <alias>` if you have multiple logins configured.

---

### Step 6.5 — Link the tickets back to the PR

The PR now points at the tickets. Point the tickets back, so someone reading a
ticket months later finds where it landed without searching the log.

For each ticket this PR closes, add a line right under `**Status:**`:

```markdown
**PR:** https://gitea.exemplo/org/repo/pulls/51
```

Ticket that already has a `**PR:**` line gets **a second one**, not a replacement:
a ticket reworked across two PRs has two, and the history is the point.

Commit the change to the branch **before** returning the URL, so the link exists
in the PR's own diff.

Os tickets já estão sob `docs/specs/archive/` neste ponto, e escrever neles aqui
não fere a imutabilidade da spec arquivada: ela começa quando o merge chega ao
branch padrão. Até lá é tudo o mesmo PR, ainda em revisão.

On a hotfix, which opens two PRs, use the URL of the **first** — the one to the
stable branch, where the fix actually lands.

### Step 7 — Return the URL(s)

`tea pr create` outputs the PR URL on success. Show it to the user:

- **Feature / Bugfix:** the single PR URL
- **Hotfix:** both PR URLs with their respective targets

---

## Notes

- `tea` resolves label names and assignee usernames automatically — no ID lookups needed.
- `tea` auto-detects server and repo from the git remote when run inside the repository.
- For hotfixes, both PRs share the same title and label, but have different bodies and base branches.
- Never skip label selection — always use `tea labels list` to validate names.
- Branch type is always auto-detected from the branch name — never ask. In anvil spec branches the prefix is the type (`fix/013-…`); in the legacy shape it is the second segment (`013-fix-…`).
