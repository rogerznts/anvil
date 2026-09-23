# 02: O boot mede o custo da verificação e o grava num lugar só

**What to build:** Depois do `/anvil-boot`, o `anvil.md` do projeto diz quanto a verificação custa: o comando, o tempo medido numa rodada real, a data, a máquina, e a instrução de que quem medir diferente corrige ali, no mesmo commit. É a única fonte do custo — `project.md` e `CLAUDE.md` dizem como rodar os testes e apontam para o `anvil.md` quando falam de custo. Quando o projeto adotar o laço curto, a seção comporta dois comandos, `laço` e `gate`, cada um com seu custo, nos termos do perfil de verificação. Se o comando não roda na instalação, fica gravado sem custo, com o motivo — número estimado não se grava. Num projeto adotado, o boot propõe o custo que falta sem trocar o comando já configurado, mostra a divergência quando o custo gravado difere do medido, e aponta custo repetido em outras rules, propondo trocar a repetição por um ponteiro.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Instalação nova: o `anvil.md` sai com comando, custo medido, data, máquina e a instrução de correção no mesmo commit.
- [ ] Comando que não roda: fica gravado sem custo, com o motivo.
- [ ] `anvil.md` existente sem custo: o boot propõe acrescentar e espera aprovação; o comando configurado não muda.
- [ ] Custo gravado divergente do medido: o boot mostra os dois e a troca espera aprovação.
- [ ] Custo repetido em `CLAUDE.md` ou em outra rule: o boot aponta e propõe o ponteiro, sem editar sozinho.
- [ ] O formato de `laço` e `gate` usa os termos do perfil do ticket 01.
- [ ] Exercitado num projeto descartável em `workspace/`, nos dois casos: instalação nova e projeto adotado com custo repetido.
- [ ] O `verify` sai limpo.
