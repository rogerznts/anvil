---
name: anvil-next
description: Sugere um prompt curto para continuar o trabalho em uma nova sessão.
argument-hint: "foco opcional da próxima sessão"
disable-model-invocation: true
---

# Próximo passo

Transforme o momento atual num prompt que possa ser colado numa sessão nova. Isto é um **roteamento**, não um handoff completo.

## 1. Reconstrua o momento

Identifique, nesta ordem:

1. o objetivo ainda vivo e o próximo resultado inacabado;
2. os artefatos canônicos que já guardam contexto;
3. decisões, erros observados e restrições que existem só na conversa;
4. as skills que realmente mudam a forma do próximo trabalho.

Argumentos do usuário definem o foco da próxima sessão. Faça apenas leituras pontuais de artefatos já implicados no trabalho; o prompt deve mandar a sessão nova ler o restante na fonte.

## 2. Escolha a rota

Se houver uma rota claramente superior, siga sem perguntar. Se houver de duas a quatro rotas materialmente diferentes e a escolha depender da intenção do usuário, apresente um único menu curto. Cada opção deve nomear a skill, o resultado que entrega e a recomendada.

Skills alternativas só entram quando revelam uma rota plausível e menos óbvia, não como catálogo. Se nenhuma skill se aplicar, escreva um prompt direto.

Use somente nomes exatos do inventário de skills disponível no contexto ou citados pelos artefatos; não deduza aliases.

## 3. Escreva o prompt

Entregue um único bloco de código, pronto para copiar, com no máximo **120 palavras**. Inclua somente:

- a skill a invocar, logo no início;
- o resultado pretendido e a primeira ação concreta;
- os menores caminhos ou identificadores suficientes para recuperar o contexto;
- o contexto volátil que ainda não está nesses artefatos;
- o critério de conclusão ou a verificação esperada.

Depois do bloco, acrescente `Alternativas:` com no máximo duas linhas apenas quando houver rotas não óbvias úteis. Cada linha segue `<skill> — <quando preferir>`.

Referencie artefatos existentes em vez de recapitulá-los. Omita fatos que a sessão nova descobrirá lendo os caminhos indicados e qualquer segredo ou dado pessoal. Se 120 palavras não preservarem o estado operacional, responda somente: `Use anvil-handoff nesta sessão antes de abrir a próxima.`
