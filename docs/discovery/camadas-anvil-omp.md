# Camadas do anvil com o omp — desenho do fluxo

Desenho do que o grill de 2026-09-23 decidiu a partir de
[adaptar-omp-ao-anvil.md](./adaptar-omp-ao-anvil.md). A decisão está no
[ADR-0011](../architecture/adr/adr-0011-omp-como-harness-com-camada-propria.md) —
o omp é harness de primeira classe, com camada própria. Nada disto está
implementado ainda.

**A automação só existe no omp.** A condução do planejamento (`anvil-plan`) e a
da implementação (`anvil-run`) moram na camada omp. No Claude Code e no Codex o
fluxo continua manual, como hoje, e a lista de skills que eles veem não muda.

## 1. As camadas e onde cada coisa mora

```mermaid
flowchart TB
    subgraph nucleo["NÚCLEO — o mesmo para todos os harnesses"]
        direction TB
        S[".claude/skills/<br/>as skills de hoje, nenhuma nova"]
        AG[".agents/skills/<br/>symlinks → .claude/skills<br/>gerados a partir do lock"]
        D["docs/agents/<br/>issue-tracker.md · verification.md"]
        E["docs/specs/NNN/issues/*.md<br/>Blocked by · Status · Review:<br/><b>o estado</b>"]
        R["CLAUDE.md + .claude/rules/*.md"]
        L[".claude/anvil.lock<br/>skill: · agent: · <b>omp:</b>"]
    end

    subgraph cc["CLAUDE CODE — manual"]
        H1[".claude/settings.json<br/>PreToolUse → guard-spec-merge.sh"]
    end

    subgraph cx["CODEX — manual"]
        X1["lê .agents/skills<br/>sem guarda de merge, como hoje"]
    end

    subgraph omp["CAMADA OMP — só se detectado · automação"]
        direction TB
        O1[".omp/rules/anvil-harness.md<br/>alwaysApply: Skill tool → skill://<br/>sub-agent → task"]
        O2[".omp/hooks/pre/anvil-guard-spec-merge.ts"]
        O3[".omp/agents/anvil-implementer.md<br/>autoloadSkills: implement · tdd · code-review"]
        O4[".omp/skills/<br/>anvil-plan · anvil-run · anvil-omp (manual)<br/>trava de invocação"]
    end

    cc -->|lê| nucleo
    cx -->|lê| nucleo
    omp -->|lê| nucleo
    AG -.->|aponta para| S
    O2 -->|chama o mesmo script| H1
```

No payload, a camada omp não mora em `.omp/` nem é skill: viaja como material
dentro da `anvil-update`, em `anvil/.claude/skills/anvil-update/.omp-layer/`.
O boot e o update a copiam para `.omp/` quando o omp é detectado. O espelho
`.agents/skills` deixa de vir pronto no payload: o `reset-install.sh` o gera, um
symlink por linha `skill:` do lock, e remove os órfãos junto. O omp também lê
`.agents/skills`, mas deduplica por caminho real, então os symlinks não viram
duplicata.

## 2. Instalação e update — como a camada chega ao projeto

```mermaid
flowchart TD
    A["npx degit rogerznts/anvil/anvil . --force<br/>só copia: .claude/skills/<br/>a camada omp vem dentro da anvil-update"] --> B{"Harness?"}
    B -->|Claude Code ou Codex| C["/anvil-boot"]
    B -->|omp| C2["/skill:anvil-boot"]
    C --> DET
    C2 --> DET

    U["/anvil-update → reset-install.sh<br/>(cópia nova do payload)"] --> DET

    DET{"detecção<br/>command -v omp<br/>OU ~/.omp/ existe<br/>OU lock já tem linha omp:"}
    DET -->|não| N["instala o núcleo<br/>+ gera .agents/skills a partir do lock<br/>+ hook do Claude no settings.json"]
    DET -->|sim| Y["tudo o que o 'não' instala<br/>+ copia .omp-layer/ → .omp/"]
    Y --> LK["lock ganha omp: rules/anvil-harness.md<br/>omp: hooks/pre/… · agents/anvil-implementer.md<br/>omp: skills/anvil-plan · anvil-run · anvil-omp"]
    LK --> ORF["update seguinte:<br/>omp: no lock que saiu do payload → órfão, remove<br/>omp: que continua → substitui"]

    style DET fill:#fff6e0,stroke:#c90
    style Y fill:#eaf6ec,stroke:#3a3
```

A detecção é **pegajosa**. Se o dev A tem omp e o dev B não, o update do B
encontra linhas `omp:` no lock e mantém a camada. A ausência do binário nunca
remove nada.

## 3. Planejamento na mesma janela, conduzido pela `anvil-plan` — só no omp

É a ideia do `/anvil-plan` do discovery (l. 88–116, *"automático entre os gates
humanos"*). A skill mora em `.omp/skills/anvil-plan` e tem trava de invocação:
só o operador a chama, uma vez, com `/skill:anvil-plan <pedido inicial>`. Ela
conduz `grill → to-spec → to-tickets` na mesma janela. Entre uma etapa e outra,
faz a sugestão: propõe a próxima etapa ou um desvio, e só carrega com o sim do
operador.

No Claude Code e no Codex continua como hoje: o operador chama `/anvil-grill`,
`/anvil-to-spec` e `/anvil-to-tickets` à mão, na mesma janela.

```mermaid
flowchart TD
    START["/skill:anvil-plan &lt;pedido inicial&gt;<br/>chamado uma vez"] --> READ["lê a conversa e o disco<br/>spec.md existe? issues/ existe?"]
    READ -->|"nada feito"| G["anvil-grill<br/>pausa: entendimento confirmado"]
    READ -.->|"retomada: spec.md existe"| SG2

    G --> SG1{"sugestão<br/>to-spec ou um desvio?"}
    SG1 -->|"sim: to-spec"| SP["anvil-to-spec<br/>pausa: seams"]
    SP --> SG2{"sugestão<br/>to-tickets ou um desvio?"}
    SG2 -->|"sim: to-tickets"| TK["anvil-to-tickets<br/>pausa: granularidade"]

    SG1 -->|desvio| DESV["desvio, com o sim do operador<br/>fato desconhecido → anvil-research<br/>só se responde vendo → anvil-prototype<br/>depende de outra pessoa → anvil-to-questionnaire<br/>grande demais → anvil-wayfinder<br/>tem tela sem fluxo → anvil-ui<br/>forma de módulos aberta → anvil-architect"]
    SG2 -->|desvio| DESV
    DESV -.->|"volta à etapa de onde saiu"| G
    DESV -.-> SP

    SG1 -->|não| STOP["para<br/>/skill:anvil-plan de novo retoma<br/>pela conversa e pelo disco"]
    SG2 -->|não| STOP

    TK --> RUNX["fim da janela<br/>/clear → /skill:anvil-run NNN"]

    style SG1 fill:#fff6e0,stroke:#c90
    style SG2 fill:#fff6e0,stroke:#c90
    style RUNX fill:#eaf6ec,stroke:#3a3
```

As etapas e as pausas de cada skill continuam as mesmas. O que entra é o
condutor: o operador não precisa saber a ordem, os nomes nem os desvios, e cada
transição continua sendo decisão dele. A etapa não é guardada em campo nenhum;
sai da conversa e do disco, como manda o
[ADR-0003](../architecture/adr/adr-0003-sem-maquina-de-fases.md). A
`mosk-suggestion` morreu justamente por ler um `current_phase`.

O limite: nenhum harness garante que a instrução de conduzir continue viva numa
conversa longa. Se ela se perder, chamar `/skill:anvil-plan` de novo recupera o
ponto.

Duas diferenças em relação ao discovery: a transição pede sim em vez de ser
automática, e o condutor conhece os desvios, não só a rota principal.

## 4. Uma execução do começo ao fim no omp

No Claude Code e no Codex continua como hoje: um `/anvil-implement` por ticket,
cada um numa sessão nova, com o `/anvil-next` na passagem.

```mermaid
flowchart TD
    PL["Planejamento — seção 3<br/>/skill:anvil-plan"]

    PL -->|"docs/specs/041/issues/01…NN.md"| RUN["/skill:anvil-run 041<br/>sessão principal = supervisor<br/>profundidade 0"]

    RUN --> FR["lê os tickets do disco<br/>frontier = Status ≠ resolved<br/>e todos os Blocked by resolved<br/>e não travado"]
    FR --> Q{"frontier vazio?"}
    Q -->|não| PICK["pega UM ticket<br/>(em série)"]
    PICK --> IMPL["task → anvil-implementer<br/>profundidade 1 · contexto novo"]

    subgraph impl["dentro do implementer — skills vendorizadas sem mudança"]
        direction TB
        I1["anvil-implement"] --> I2["anvil-tdd"]
        I2 --> I3["anvil-code-review"]
        I3 --> AX1["eixo Standards<br/>profundidade 2"]
        I3 --> AX2["eixo Spec<br/>profundidade 2"]
        AX1 --> AGG["agrega verbatim<br/>Review: round=N; verdict=…"]
        AX2 --> AGG
        AGG --> ST{"P1?"}
        ST -->|não| RS["Status: resolved · commit"]
        ST -->|"sim, rodada 1"| CL["Status: claimed<br/>corrige → rodada 2 (diff)"]
        CL --> I3
        ST -->|"sim, rodada 2"| TR["fica claimed<br/>= travado"]
    end

    IMPL --> I1
    RS --> FR
    TR --> FR

    Q -->|sim| FIM{"todos resolved?"}
    FIM -->|sim| REL["relatório + próximo passo:<br/>/skill:anvil-browser-qa<br/>depois /anvil-docs archive e PR"]
    FIM -->|não| REL2["relatório: tickets travados,<br/>o P1 aberto e os tickets que dependem dele<br/>→ decisão do humano"]

    style PL fill:#f8f8f6,stroke:#bbb
    style impl fill:#f8f8f6,stroke:#bbb
    style TR fill:#fdecea,stroke:#c33
    style REL fill:#eaf6ec,stroke:#3a3
```

"Travado" não é status novo: é o que se lê da última linha `Review:`, na rodada 2
com `fail`. A terceira rodada é do humano, como manda o
[ADR-0010](../architecture/adr/adr-0010-verificacao-tem-criterio-de-parada.md).
Se o supervisor morrer, basta rodar `/skill:anvil-run 041` de novo: ele recalcula
tudo a partir do disco.

## 5. A guarda de merge

```mermaid
flowchart LR
    subgraph c["Claude Code"]
        C1["Bash: git merge …"] --> C2["PreToolUse hook"]
    end
    subgraph o["omp"]
        O1["bash: git merge …"] --> O2["tool_call event<br/>.omp/hooks/pre/*.ts"]
        O2 -->|"monta JSON no formato Claude<br/>pi.exec"| SH
    end
    C2 --> SH["guard-spec-merge.sh<br/>→ validate.sh ship-ready"]
    SH -->|exit 0| OK["libera"]
    SH -->|exit 2| NO["bloqueia<br/>ticket aberto ou spec não arquivada"]
    NO -.->|"omp: {block:true, reason}"| O1
    NO -.->|"Claude: exit 2"| C1

    style NO fill:#fdecea,stroke:#c33
    style OK fill:#eaf6ec,stroke:#3a3
```

A regra fica numa fonte só, `validate.sh`. O que muda entre os harnesses é só
como o bloqueio volta ao agente. Continua existindo um furo conhecido: um
`git merge` disparado pelo `eval` passa pela guarda. É o mesmo tipo de furo que o
hook do Claude já tem com tudo o que não passa pelo Bash. O Codex segue sem
guarda, como hoje.
