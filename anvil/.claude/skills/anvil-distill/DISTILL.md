# A destilação

Você recebeu o sistema de referência, a funcionalidade — sem ela, a destilação
cobre o sistema inteiro — e o caminho do documento.
Leia o código, escreva o documento e devolva o caminho e três linhas.

## Invariante: política de escrita

A destilação escreve **um arquivo**: o documento, dentro de `docs/`, criando a
pasta `discovery/` se ela faltar. O sistema de referência e o código do projeto
são **somente leitura** — nenhum arquivo editado, criado, movido ou apagado neles,
e nenhum comando que os altere: `git pull`, `checkout`, instalador de dependência,
build, formatter, nem executar o sistema de referência ou os testes do projeto, que
deixam cache como `.pytest_cache` e `.unlazy/`. Comando git de leitura — `log`,
`show`, `rev-parse`, `ls-tree`, `status` — é livre.

## A stack do projeto

Leia do código: manifestos (`package.json`, `pyproject.toml`, `go.mod`,
`Gemfile`, `composer.json`, `Cargo.toml` e afins), configuração e imports dos
módulos que a tradução vai tocar. As rules em `.claude/rules/*.md` servem de
atalho para saber onde olhar, nunca de fonte. Quando rule e código divergem, vale
o código, e a divergência vai para a Tradução para a stack, com o ponteiro dos
dois lados.

## Ponteiro

Um ponteiro é `caminho:N` ou `caminho:N-M`, sempre com o caminho inteiro a partir
da raiz do projeto. O **trecho** é o bloco cercado logo abaixo do ponteiro, com as
linhas N a M copiadas **literalmente**: sem reticências, sem reindentar, sem juntar
trechos. Um trecho longo vira dois ponteiros.

Os trechos da origem ficam em Ponteiros verificáveis, e os do projeto em Tradução
para a stack. Nas outras seções, o ponteiro aparece como **menção**, sem bloco, e
toda menção cai dentro de um trecho do documento: o mesmo intervalo ou parte dele.
Um intervalo que nenhum trecho cobre é paráfrase, não ponteiro.

## As seis seções

O documento tem exatamente estas seções, nesta ordem:

1. **Origem** — o sistema, onde está e a versão:
   - *submodule* — `git ls-tree HEAD <pasta>` devolve uma entrada `commit`: a
     versão é esse pin. Se `git -C <pasta> rev-parse HEAD` difere dele, registre
     os dois e diga que os ponteiros valem para o checkout;
   - *repositório próprio* — `git -C <pasta> rev-parse --show-toplevel` devolve a
     própria pasta: a versão é o `rev-parse HEAD` dela. Numa pasta que não é
     repositório, o mesmo comando devolve a raiz do projeto, e o commit seria o do
     projeto;
   - *nenhum dos dois* — declare que não há versão verificável.
2. **Mapa da funcionalidade** — os seams: por onde o dado entra, por onde passa e
   por onde sai, cada seam com a sua menção.
3. **Ponteiros verificáveis** — os trechos da origem que sustentam o mapa e a
   tradução.
4. **Tradução para a stack** — primeiro a stack lida, com os trechos de onde saiu.
   Depois, cada conceito da origem, com a menção do seu trecho, em uma de quatro
   classes:
   - *equivalente direto* — com o trecho do equivalente que já existe no projeto;
   - *equivalente com adaptação* — o trecho do equivalente e o que difere;
   - *sem equivalente* — vira pergunta em Perguntas abertas;
   - *não portar* — o motivo fica em O que não portar.
5. **O que não portar** — acoplamento, dependência e decisão que eram da stack de
   origem, cada um com a sua menção.
6. **Perguntas abertas** — o que só o usuário decide, pronto para levar ao grill.

## Pronto

O documento está pronto quando **cada** ponteiro foi reaberto depois de escrito:
o trecho bate com as linhas, e a menção cai dentro de um trecho. Então devolva só
isto:

```text
<caminho do documento>
<três linhas: o que a funcionalidade faz na origem; quanto dela tem equivalente no projeto; a decisão mais importante em aberto>
```
