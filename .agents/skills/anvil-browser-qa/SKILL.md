---
name: anvil-browser-qa
description: Cria uma checklist de QA no navegador e conduz a execução com o usuário ou autonomamente.
argument-hint: "spec, ticket, PR ou funcionalidade"
disable-model-invocation: true
---

# QA de browser

Transforme uma implementação concluída numa checklist executável e, depois de salvá-la, ofereça condução assistida ou execução autônoma. Durante o QA, registre defeitos; não altere a implementação testada.

## 1. Delimite

Use os argumentos como alvo. Leia o menor conjunto que revele o comportamento entregue: spec, tickets resolvidos, fluxo de UI e diff. Se houver mais de uma implementação candidata, apresente um menu curto antes de seguir.

Cada caso deve proteger um comportamento observável contra uma falha plausível. Cubra somente o que se aplica: jornada principal, validação e erro, permissões, persistência ou recarga, navegação, integração e regressão adjacente. Não preencha categorias só para aumentar a checklist.

## 2. Salve a checklist

Siga a convenção de QA do repositório. Na árvore do anvil:

- mudança ativa: `docs/specs/{id}/qa/browser-checklist.md`;
- sem spec ativa: `docs/qa/{slug}-browser-checklist.md`.

Use este formato:

```markdown
# QA de browser — <funcionalidade>

**Origem:** <spec, tickets, PR ou diff>
**Ambiente:** <URL ou a definir>
**Status:** pendente
**Modo:** a definir

## Pré-condições

- <estado, conta, dados e permissões necessários>

## Casos

### BQA-01 — <resultado observável>

- **Prioridade:** bloqueante | exploratório
- **Risco:** <falha que este caso detecta>
- **Passos:**
  1. <ação do usuário>
- **Esperado:** <estado observável>
- **Resultado:** pendente
- **Evidência:** pendente

## Resultado

<preenchido durante a execução>
```

## 3. Escolha o modo

Depois de escrever o arquivo, informe seu caminho e apresente um único menu:

1. **Acompanhar passo a passo** — o usuário opera o navegador; apresente um caso por vez, peça o observado e atualize resultado e evidência antes de avançar.
2. **Assumir os testes** — controle o navegador, execute os casos e atualize o documento. Recomende esta opção quando houver um navegador controlável e o fluxo não exigir efeitos destrutivos; nos demais casos, recomende acompanhamento.

Não execute nenhum caso antes da escolha.

## 4. Execução assistida

Apresente somente o próximo caso pendente, com pré-condição, passos e resultado esperado. Aceite relato ou imagem do usuário como evidência, esclareça divergências e registre imediatamente `passou`, `falhou` ou `bloqueado`. Ao terminar, preencha o resumo e mostre o caminho do documento.

## 5. Execução autônoma

Descubra a URL e o comando normal da aplicação no repositório antes de perguntar. Inicie o serviço quando necessário e selecione o primeiro controlador disponível nesta ordem:

1. **OMP:** use o `browser` do OMP por `Eval`. Observe antes de agir, verifique o estado depois e mostre no terminal um screenshot do resultado de cada caso, além do estado de qualquer falha.
2. **Browser do host:** use a integração semântica disponível, como Chrome for Claude, browser do Codex, Chrome DevTools/CDP ou relay. Leia a skill correspondente, preserve a sessão autenticada quando necessário e mostre um screenshot por caso.
3. **Playwright:** somente se nenhuma opção anterior existir. Explique a ausência dos controladores preferidos e peça autorização antes de usar ou instalar Playwright.

Percorra o fluxo como usuário: ações reais de navegação e formulário, sem atalhos por DOM ou requisições internas. Reobserve após navegação ou renderização. Salve evidências ao lado da checklist em `evidence/BQA-<n>.png` quando o controlador permitir e registre o caminho; caso contrário, registre que o screenshot foi exibido na sessão.

Use uma sessão já autenticada ou peça ao usuário que autentique; nunca copie credenciais para o documento. Peça autorização antes de pagamento, exclusão, envio externo ou outro efeito irreversível. Uma falha não autoriza corrigir o produto: capture o estado, registre o defeito e continue os casos independentes.

Conclua quando cada caso tiver resultado e evidência, o resumo trouxer totais e bloqueios, e os screenshots finais tiverem sido mostrados. Feche apenas as sessões de navegador abertas pela própria execução.
