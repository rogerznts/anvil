---
name: anvil-open-pr
description: Opens a Pull Request to the project's branch base on its forge — GitHub with `gh` or Gitea with `tea` —, as the resolver says. Auto-detects branch type, generates PR text, applies label and assignee automatically.
---

# Open Pull Request

Your goal is to open a Pull Request on the project's forge, to its branch base,
generating clear, professional, and well-structured PR text that facilitates
efficient code reviews.

The PR text, the label, the assignee and the `PR:` line are written once, below;
only the command block changes between the forges — `gh` on GitHub, `tea` on
Gitea.

---

## Workflow

### Step 0 — Resolve the branch base and the forge

Run, from the project root:

```bash
bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh --pr
```

It reads the `## Git` section of `.claude/rules/anvil.md` and detects what the
section doesn't declare. The answer comes in `key: value` lines: `base:` (the
branch base), `forge:` (`github`, `gitea` or `nenhum`), `remote:`, `host:` (the
real host of the remote), `repo:` (`org/repo`) and, on Gitea, `login:` (the `tea`
login that matches the real host — the resolver looks it up only with `--pr`).
Each refusal comes as `refusal: <field>: <reason>`, naming the field it hits —
`base`, `forge` or `login` —, after the values it did resolve.

- **Exit `2`, with `refusal:` lines:** stop here. A PR needs the branch base, the
  forge, the repo and, on Gitea, the login, so any refusal stops it. Tell the user
  each reason as it came — it says what to declare or fix — and call neither `gh`
  nor `tea`.
- **`forge: nenhum`:** there is no forge to open a PR on. Stop and say so: the
  project closes by local merge into the branch base.
- **`forge: github`** or **`forge: gitea`:** keep `<base>`, `<repo>` and, on Gitea,
  `<login>`. Every step below uses them.

Never let a CLI guess the server. Every `gh` call takes `--repo <repo>`, and every
`tea` call takes `--login <login> --repo <repo>`: without them, `tea` falls back to
its default login when none matches the remote, and the PR lands on the wrong
server.

The CLI must be authenticated: `gh auth login` on GitHub; on Gitea, the login the
resolver found — when none matches, its refusal names the `tea login` to run.

---

### Step 1 — Identify the branch and type

- Use the current git branch as the **source** (head), `<branch>`.
- Auto-detect the branch type from its name prefix. Anvil spec branches are
  `{tipo}/{NNN}-{nome}` (e.g. `fix/013-carrinho-vazio`), so the prefix **is**
  the type:
  - `feature/` → **Feature**
  - `fix/` (or the legacy `bugfix/`) → **Bugfix**
  - `hotfix/` → **Hotfix**
  - `refactor/`, `gmud/`, `experimental/` → **Feature**
  - Legacy shape `{NNN}-{tipo}-{nome}` (e.g. `013-fix-carrinho`) → read the
    type from the **second** segment
  - Otherwise → treat as **Feature**
- The **target** is always the branch base, `<base>`: one PR, whatever the type,
  hotfix included. Taking a hotfix further — to a production branch, when the
  branch base is a `develop` — is the operator's step, outside the toolkit.

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
base sem arquivar, que é exatamente o buraco que a guarda de merge existe para
fechar. Antes do PR, o move entra no diff que o revisor já vai olhar.

Liste os tickets. Todos devem estar `resolved` — se algum não estiver, a guarda
de merge vai bloquear o `pr create`, do `gh` ou do `tea`, e ela está certa: o
padrão é **um PR por spec**, e uma spec com ticket aberto não terminou. Ela
bloqueia também quando a spec ainda não está sob `archive/`.

```bash
ls "$SPEC_DIR"issues/*.md
grep -L 'Status:.*resolved' "$SPEC_DIR"issues/*.md   # se voltar algo, pare aqui
bash ~/.claude/skills/anvil-docs/scripts/validate.sh ship-ready   # o que a guarda vai ver
```

### Step 2 — Read the diff

Run:
```bash
git log <base>..<branch> --oneline
git diff <base>..<branch> --stat
```

- Alert the user if debug logs (`console.log`, `var_dump`, `dd()`) or temporary test code are present.

---

### Step 3 — Generate the PR text

**Title:** Conventional Commits format (e.g., `feat(module): short description`, `fix(module): short description`).

**Body**, the same for every type:

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
o `pr create` quando `issues/` não tem nenhum `Status:` diferente de `resolved`.
Se ela bloquear, a spec não terminou — feche o que falta ou reveja o recorte, que
pode estar grande demais para uma spec só.

A seção `## Spec` é **omitida** num branch sem número.

**Por que caminho e não `closes #47`:** os tickets são arquivo no repositório, não
issue no servidor, então não há número para fechar. O caminho é a referência
estável, e resolve no diff deste próprio PR.

**Use o caminho sob `archive/`**, que é onde a spec está desde o Step 1.5 e onde
ela vai continuar depois do merge. Citar `docs/specs/<spec-dir>/` deixaria o
corpo do PR apontando para um lugar que já não existe.

- The PR title, body and commit messages must be in English. What you tell the
  user in the chat follows the project's communication language, not this rule.
- Be clear and professional.

---

### Step 4 — Determine the label

List the labels the forge has:

- **GitHub:** `gh label list --repo <repo>`
- **Gitea:** `tea labels list --login <login> --repo <repo>`

Auto-suggest based on branch type:

| Branch type | Suggested label |
|-------------|-----------------|
| Feature     | `Kind/Feature`, `enhancement` (or equivalent) |
| Bugfix      | `Kind/Bug`, `bug` (or equivalent) |
| Hotfix      | `Kind/Hot`, `bug` (or equivalent) |

- Match against the labels the list returned — never a label it didn't.
- If a clear match exists, inform the user and proceed. If not, show the list and ask the user to choose.

---

### Step 5 — Determine the assignee

The assignee is whoever opens the PR, the user the CLI is authenticated as:

- **GitHub:** `@me`.
- **Gitea:** the `user` of the login `<login>` in `tea login list --output json`.

---

### Step 6 — Create the PR

One PR, to `<base>`. Run the block of the resolver's forge.

**GitHub:**
```bash
gh pr create \
  --repo <repo> \
  --base <base> \
  --head <branch> \
  --title "<title>" \
  --body "<body>" \
  --label "<label>" \
  --assignee @me
```

The PR URL is what `gh pr create` prints on stdout.

**Gitea:**
```bash
tea pr create \
  --login <login> \
  --repo <repo> \
  --base <base> \
  --head <branch> \
  --title "<title>" \
  --description "<body>" \
  --labels "<label>" \
  --assignees "<user>" \
  --output json
```

The PR URL is the `url` field of the JSON object `tea pr create` prints.

---

### Step 6.5 — Link the tickets back to the PR

The PR now points at the tickets. Point the tickets back, so someone reading a
ticket months later finds where it landed without searching the log.

For each ticket this PR closes, add a line under `**Status:**` and its
`**Review:**` lines, with the URL from Step 6:

```markdown
**PR:** <url>
```

Ticket that already has a `**PR:**` line gets **a second one**, not a replacement:
a ticket reworked across two PRs has two, and the history is the point.

Commit the change to the branch **before** returning the URL, so the link exists
in the PR's own diff.

Os tickets já estão sob `docs/specs/archive/` neste ponto, e escrever neles aqui
não fere a imutabilidade da spec arquivada: ela começa quando o merge chega ao
branch base. Até lá é tudo o mesmo PR, ainda em revisão.

### Step 7 — Return the URL

Show the user the PR URL from Step 6, with its base, `<base>`.

---

## Notes

- The resolver decides the forge, the branch base, the repo and the `tea` login; the skill never guesses them from the remote by itself.
- `gh` and `tea` resolve label names and usernames themselves — no ID lookups needed.
- Never skip label selection — always use the forge's label list to validate names.
- Branch type is always auto-detected from the branch name — never ask. In anvil spec branches the prefix is the type (`fix/013-…`); in the legacy shape it is the second segment (`013-fix-…`).
