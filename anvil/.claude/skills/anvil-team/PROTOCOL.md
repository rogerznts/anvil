# Protocolo da Equipe

Escrito para o papel. O Leader lê para saber o que despachar e o que cobrar.

O arquivo do seu papel diz o que é seu. Este diz o que vale para todos: a
delegação que você recebe, o retorno que você deve e a conduta entre papéis.

## A delegação

A delegação é o `prompt` com que o Leader despachou você. Tem sempre esta forma:

```markdown
# Delegação · {papel} · spec {NNN} · ticket {NN}[ · gate]

## Objetivo
{o resultado que deve existir, em uma ou duas frases}

## Contexto
- Spec: `docs/specs/{NNN}-{tipo}-{nome}/spec.md`
- Ticket: `docs/specs/{NNN}-{tipo}-{nome}/issues/{NN}-{slug}.md`
- Base: `{branch}` em `{sha}`
- {ADR, arquivo:linha, commit, comentário do ticket, retorno anterior; ponteiros}
- Equipe: `{name}` ({papel}, {autor|gate}), … ou "ninguém"
- Protocolo: `{caminho absoluto}`        ← só em worktree

## Skills
`{skill}`, {por quê}   |   à escolha do papel, entre as primárias

## Escopo
Dentro: {…}
Fora: {…}

## Política de escrita
{somente leitura | documentação em {caminhos} | protótipo descartável em {caminho} | código em {caminhos} | leitura no checkout, escrita só em {diretório fora de qualquer checkout}}
Não toque: `docs/specs/**/issues/*.md`, o Leader escreve o ticket.
Commit: {não | sim, no branch atual | sim, no branch do worktree}

## Critério de pronto
- [ ] {observável}

## Retorno
Primeira linha: {PRONTO | APROVADO ou REPROVADO}.
Seções exigidas: {…}
```

- **Todo o contexto chega na delegação**, em ponteiros. O que faltar e não se
  descobrir lendo ou rodando vira `BLOQUEADO`, dizendo o que falta.
- **O `mission-control.md` da spec é do Leader**, e você não o lê. O que ele tem e
  você precisa já veio copiado no Contexto. O `SKILL.md` da `anvil-team` também é
  do Leader: não o leia nem o carregue.
- **A linha `Equipe` é quem existe para você.** Fale só com os names dela. Name
  fora dela não se inventa; "ninguém" quer dizer que você trabalha só.
- **`· gate` no título** faz de você gate. Ver [Gates](#gates).
- **A linha `Protocolo:`** só aparece quando você roda num worktree, onde
  `.claude/skills/` não existe. É o caminho absoluto deste arquivo.

## O retorno

A sua última mensagem é o retorno, e chega a quem despachou você. Forma:

```markdown
{PALAVRA}, {uma linha}

### Registro no ticket
**{Papel}, {AAAA-MM-DD}, {entrega | gate {Tester|Review}, rodada {n}}: {PALAVRA}.**
{critérios de aceite e findings; cada finding com id e severidade}

### Alterações
### Evidência
### Riscos
### Divergências
### Perguntas
### Laterais
```

- **Primeira linha.** Delegação comum: `PRONTO`, `BLOQUEADO` ou `PERGUNTA`.
  Delegação `gate`: `APROVADO`, `REPROVADO`, `BLOQUEADO` ou `PERGUNTA`. Aprovar
  com finding não bloqueante é `APROVADO`. Mensagem final sem uma dessas palavras
  não é entrega: o Leader não a registra e pede o retorno por `SendMessage`.
- **Retorno repetido.** O mesmo retorno emitido de novo, sem trabalho novo, o
  Leader não registra outra vez.
- **Severidade.** `bloqueante` · `relevante` · `sugestão` · `pergunta`. Os ids
  são os que a skill produzir; sem ids, `F1`, `F2`…
- **Finding.** Específico, acionável e apoiado em evidência: id, severidade,
  localização (`arquivo:linha`, ou passos mínimos de repro), condição, impacto e
  correção esperada. Finding de comportamento traz também o esperado, o observado,
  o ambiente e os dados relevantes, e o determinismo, quando se sabe. Preferência
  sem fonte de verdade que a sustente não é finding.
- **Seções.** Só as que têm conteúdo, nesta ordem. Registro no ticket é o texto
  que o Leader anexa ao ticket, literal. Laterais diz com quem você falou, sobre o
  quê, e o que ficou acertado ou em aberto.

## Gates

- **Tester e Review são gate só quando o título da delegação diz `gate`.** Sem
  isso, a entrega volta `PRONTO` como qualquer outra.
- **O veredito existe só no retorno do gate.** Mensagem lateral não aprova nem
  reprova.
- **O autor não controla o gate que avalia o trabalho dele.** Conversa lateral
  esclarece finding e não muda veredito. Avaliação que mudou só vale numa rodada
  nova, que o Leader despacha.
- **Finding é evidência a investigar.** O autor corrige o que procede. O que não
  procede vai na seção Divergências do próprio retorno, na forma de
  [Divergências](#divergências), e chega ao Leader ao lado do veredito. O gate
  continua valendo.
- **Papel nunca despacha agente `anvil-team-*`.** Só o Leader despacha papel. Os
  subagentes que as suas skills abrem por conta própria são da skill, e seguem
  liberados.

## Skills

- **Carregue a skill real** pela Skill tool e siga o `SKILL.md` dela. O campo
  Skills diz qual, ou deixa a escolha entre as primárias do seu papel. Reproduzir
  de memória o que a skill faz não é seguir a skill.
- **Skills primárias são roteamento preferencial**, não whitelist. Uma skill que
  chama outra segue a composição dela.
- **Subagente que a sua skill abre vai com `run_in_background: false`**, mesmo
  quando a skill manda background. Várias chamadas na mesma mensagem continuam em
  paralelo, e o retorno só sai depois do resultado de cada uma. Resultado de
  subagente em background não chega a quem já encerrou o turno.
- **Fora essa exceção, o protocolo de uma skill vence este** quando os dois
  conflitam.
- **Skill ausente, ou recusada pela trava de invocação:** retorno `BLOQUEADO`,
  dizendo qual. Instalar ou reinstalar o anvil é decisão do usuário.

## Fontes de verdade

Em divergência, vale o estado atual e verificável, nesta ordem:

1. comportamento real do sistema e código atual;
2. spec atual;
3. tickets, bloqueadores e `Status:`;
4. ADRs e documentação arquitetural atual;
5. `docs/architecture/context.md` e linguagem de domínio;
6. `CLAUDE.md`, `AGENTS.md`, `.claude/rules/` e demais regras locais;
7. artefatos atuais do projeto;
8. skills e documentação do anvil;
9. comunicação atual entre papéis;
10. memória de sessões anteriores, quando houver.

Memória é histórico, não estado: não sobrescreve em silêncio uma decisão mais
recente. Em conflito, investigue e exponha a divergência. O Mission Control não é
fonte de verdade.

## Comunicação

- **Fale com os names da linha `Equipe` por `SendMessage`.** Dentro do agente ela
  é ferramenta diferida: carregue com `ToolSearch`, query `select:SendMessage`,
  antes do primeiro envio.
- **Texto comum da sua resposta não chega a outro papel.** Só `SendMessage`
  chega.
- **Quando um colega da Equipe responde melhor uma dúvida, pergunte a ele.** A
  opinião de quem está na Equipe se pede, não se simula.
- **Não encerre à espera de resposta lateral.** Espere dentro do turno, seguindo no
  que não depende dela, porque a mensagem chega entre uma ferramenta e outra; ou
  devolva com o que tem e ponha o que ficou pendente em Laterais. Encerrar esperando, com
  `sleep` em background, não é retorno.
- **Conversa lateral não passa pelo Leader.** O que nasceu nela e importa —
  finding, repro, divergência, acordo — vai na seção Laterais do retorno, e é assim
  que chega a ele.
- **Erro de entrega de `SendMessage` não se repete.** Retorno `BLOQUEADO`, com o
  name e o erro.

## Ownership de escrita

- **Um escritor por região.** A Política de escrita é a fronteira: escreva só onde
  ela dá, e nada em `somente leitura`.
- **`Status:` e `## Comments` de ticket são do Leader.** O que você quer no ticket
  vai na seção Registro no ticket.
- **Sobreposição descoberta no meio do trabalho** — precisar escrever fora da
  fronteira, ou achar outro escritor na mesma região: pare e devolva `BLOQUEADO`,
  dizendo a região. Quem escolhe a saída é o Leader.
- **Em worktree**, antes da primeira escrita, confira que o `HEAD` contém o sha da
  Base (`git merge-base --is-ancestor {sha} HEAD`). Não contendo, devolva
  `BLOQUEADO` sem escrever.

## Verificação

"Pronto" não é evidência. Verifique o artefato real, com a prova que a tarefa
pede: código, diff, teste, typecheck, build, execução, logs, screenshot,
critérios de aceite, spec, ticket, ADR, revisão, comportamento observado. Sempre
que der, prove que funciona, e ponha a prova na seção Evidência.

## Divergências

Conflito se resolve por evidência, não por hierarquia. Quando você discorda de
outro papel:

1. identifique exatamente a afirmação em conflito;
2. identifique a fonte de verdade que se aplica;
3. reproduza ou verifique, quando der;
4. envolva outro papel da Equipe, se precisar;
5. persistindo, escreva a divergência na seção Divergências do retorno, com a
   evidência dos dois lados.

## Perguntas e autonomia

Vira `PERGUNTA` a decisão que é do usuário: intenção de produto, preferência,
requisito ausente, trade-off de negócio, informação indisponível, ação
irreversível relevante. A pergunta vai na seção Perguntas, pronta para o Leader
levar ao usuário, e a resposta volta a você por `SendMessage`, na mesma sessão.

O que se descobre lendo o código, rodando, pesquisando, prototipando, testando ou
perguntando a um colega da Equipe você descobre, e segue.

Trabalho interno, reversível e investigativo avança com evidência suficiente, sem
pedir confirmação trivial.

## Contexto

Proteja a janela de contexto. Cite arquivo, linha, commit e comentário em vez de
colar documento, e deixe na fonte canônica o que já tem uma.
