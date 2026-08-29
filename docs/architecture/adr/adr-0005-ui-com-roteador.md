# ADR-0005 — A camada de UI tem roteador: hallmark e taste são métodos rivais

- Status: aceito
- Data: 2026-08-28

## Contexto

O anvil adota duas famílias de skill de design que atacam o mesmo problema —
interface que não parece gerada por LLM — por métodos incompatíveis:

| | hallmark | taste |
|---|---|---|
| Como decide | catálogo estrutural: 1 de 21 macroestruturas + 1 de 20 temas OKLCH + arquétipos de nav (N1a–N13) e footer (Ft1–Ft8) | 3 dials numéricos: `DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY` |
| Design system | **inventa** os tokens, emite `tokens.css` | **roteia para sistema oficial** — Material, Fluent, Carbon, shadcn. *"Never invent CSS for things that have a package"* |
| Memória | `.hallmark/log.json`, rotaciona contra os 3 últimos builds | rotação declarada, sem estado em disco |
| Carga | progressiva: 107 arq, ~5–7 por build | monolítico: 1.206 l num arquivo |
| Escopo | qualquer UI, inclusive componente isolado com 8 estados | só landing, portfólio, redesign |
| Gate | 58 portas do slop-test | 80 checkboxes de pre-flight |

Sobrepõem-se no catálogo de vícios: ambos banem em-dash, ambos proíbem a paleta
bege/latão que todo LLM produz, ambos exigem rotação. Mas **se os dois
dispararem no mesmo pedido a instrução é contraditória** — um manda emitir OKLCH
próprio, o outro proíbe escrever CSS quando existe pacote oficial.

Há ainda um terceiro nível, que não é método: os presets de estilo (brutalist,
minimalist, soft, stitch), que são especificações de fonte, paleta e layout —
tema, não processo.

## Decisão

Uma skill roteadora, `anvil-ui`, que **escolhe um método e só um**:

```
anvil-ui/                 roteador
├─ método
│  anvil-ui-hallmark/     107 arq · SKILL 558 l + references 9.194 l
│  anvil-ui-taste/        1.206 l
│  anvil-ui-redesign/     178 l
└─ preset
   anvil-ui-brutalist/ 92 l  -minimalist/ 85 l  -soft/ 98 l  -stitch/ 184 l
```

O despacho:

- **tem código existente?** → `redesign`, que é audit-first
- **landing ou portfólio num projeto que já usa um design system?** → `taste`
- **produto novo, componente isolado, ou partir de uma referência visual?** →
  `hallmark`, que é o único com o verbo `study` e o único que cobre componente

Um preset pode ser aplicado por cima, depois. Presets não conflitam entre si com
o método porque não decidem processo, só aparência.

Precedente: o `mosk-ui-expert` já era esse roteador — *"premium pages, plus the
Hallmark anti-slop flow (hallmark · audit · redesign · study)"*.

## Consequências

**A favor.** Nenhuma sessão recebe duas instruções contraditórias. Os dois
métodos permanecem íntegros, sem tentativa de fundir catálogos que não se
encaixam.

**Contra.** Uma camada de indireção a mais, e o roteador precisa ser mantido
quando um método mudar de escopo. Se o `taste` passar a cobrir dashboard, a
regra de despacho envelhece em silêncio.

**Verificação.** Três pedidos — redesign de página existente, landing num projeto
com shadcn, componente isolado — precisam despachar para redesign, taste e
hallmark respectivamente, e **nunca dois ao mesmo tempo**.
