# Verbo `archive` — fechar uma spec

Promove o que virou canônico e move a spec para `archive/`.

## Pré-condição

Todo ticket em `issues/` com `Status: resolved`. Se houver ticket aberto, **pare
e liste quais** — é a mesma checagem que o hook de merge faz, e adiantá-la aqui
poupa o usuário de descobrir no merge.

O usuário pode arquivar mesmo assim, se disser explicitamente. Nesse caso,
registre no relatório final quais tickets ficaram abertos.

## 1. Levantar as promoções

Varra `docs/specs/{id}/` atrás de arquivos com front-matter `promote:`.

```yaml
---
promote: docs/architecture/adr/adr-0007-coupon-service.md
promote_mode: copy
---
```

O front-matter precisa começar na coluna zero. Mapa raiz indentado não é lido —
reporte como erro, não ignore em silêncio.

`promote_mode` ausente: trate como `manual` e diga que assumiu isso.

## 2. Mostrar o plano

Tabela: *arquivo · destino · modo · o destino já existe?*

Espere aprovação. Promoção escreve na base do projeto, e a base é o que todo
mundo lê.

## 3. Aplicar

| modo | o que faz |
|---|---|
| `copy` | copia para o destino. **Se o destino existir, pergunte antes.** O destino tem que ficar byte a byte igual à origem |
| `append` | anexa o corpo, sem o front-matter, ao fim do destino. Se o destino não existir, crie |
| `manual` | não aplica. Imprime o arquivo, o destino sugerido e por quê. Padrão do `prd-delta.md` |

**Link relativo é a armadilha do `copy`.** O arquivo tem que ficar idêntico à
origem, então todo link dentro dele precisa resolver **no destino**, não onde ele
está hoje. Antes de copiar, confira os links e avise se algum quebra.

Sem `promote:`, o artefato congela dentro da spec arquivada. Isso é o padrão e
está certo — a maioria dos artefatos de spec é da spec.

## 4. Mover

`docs/specs/{id}/` → `docs/specs/archive/{id}/`.

Mova, não copie. A spec arquivada é imutável: mudança posterior no assunto abre
uma spec nova do tipo `extension`, ligada a esta.

## 5. Índice e relatório

Rode o verbo `index`.

Reporte: o que foi promovido e para onde · o que ficou congelado na spec · o que
saiu como `manual` e ainda espera o usuário · ticket aberto, se o usuário
arquivou mesmo assim.
