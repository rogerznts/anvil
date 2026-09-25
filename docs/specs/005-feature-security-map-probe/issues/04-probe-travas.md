# 04: O probe recusa, confirma e protege o banco

**Blocked by:** 02
**Status:** ready-for-agent

**What to build:** Um desenvolvedor roda `/anvil-security-probe` e, antes de qualquer teste, o probe passa pelas travas, nesta ordem:

1. `profile.md` e `map.md` presentes; sem eles, para e manda rodar o map, sem improvisar mapa;
2. alvo descoberto no ambiente local do repositório (scripts de dev, `.env`, compose) e resolvendo para loopback; nenhuma flag libera outro alvo;
3. servidor de dev respondendo; se não, diz como subi-lo;
4. mostra URL, banco e ferramentas que vai usar e espera confirmação explícita;
5. antes de teste que escreve, sugere banco descartável; se o usuário preferir o banco local, cria um dump e mostra o comando exato de restauração. Sem nenhuma das duas escolhas, roda só testes de leitura.

Este ticket entrega a skill com as travas. Nenhum teste de ataque ainda; a skill é autoral e traz `SOURCES.md`.

- [ ] Sem `profile.md` ou `map.md`, o probe recusa e aponta o `/anvil-security-map`
- [ ] Com um alvo que não resolve para loopback, o probe recusa, e nenhum argumento muda isso
- [ ] Com servidor fora do ar, o probe para e diz como subi-lo
- [ ] Com alvo local, o probe mostra URL, banco e ferramentas e só segue após confirmação
- [ ] O probe oferece banco descartável ou dump; escolhido o dump, ele é criado e o comando de restauração aparece
- [ ] Sem escolha de banco, o probe se restringe a testes de leitura
- [ ] A skill traz `SOURCES.md`
