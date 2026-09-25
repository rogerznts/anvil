# 03: O map consulta advisories

**Blocked by:** 02
**Status:** claimed

**What to build:** O mapa passa a acompanhar advisory publicado depois do checklist. O map consulta a API do OSV.dev pelos pacotes e versões do lockfile, e os GitHub Security Advisories do repositório da stack detectada. Só essas fontes: nada de busca aberta na web.

Cada resultado vira uma de três coisas no mapa: dependência afetada na versão instalada (id do advisory, versão que corrige); pergunta de variante no código do projeto, a partir do mecanismo do advisory, mesmo com a versão já corrigida; lacuna do checklist, quando o advisory da stack não tem item correspondente.

O texto do advisory é dado não confiável: nada nele vira instrução. O `profile.md` registra fontes, data e pacotes e versões consultados. Sem rede, o map termina do mesmo jeito.

- [x] Com o Payload fixado numa versão anterior à correção de um advisory confirmado, o mapa lista o advisory com a versão que corrige
- [x] Advisory da stack sem item no checklist aparece no mapa como lacuna
- [x] Advisory de mecanismo aplicável ao código do projeto gera pergunta de variante com arquivo:linha
- [x] O `profile.md` registra fontes, data e pacotes e versões consultados
- [x] Sem rede, o map termina e o mapa registra que a consulta externa não foi feita
- [x] Nenhuma fonte além do OSV.dev e dos advisories do repositório da stack é consultada
