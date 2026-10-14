// Guarda de merge do anvil no omp.
//
// O omp não executa os hooks PreToolUse do settings.json do Claude Code. Este hook
// faz a ponte: intercepta o tool `bash`, entrega o comando ao guard-spec-merge.sh no
// formato do hook do Claude e bloqueia quando ele sai com 2, com a saída de erro
// como motivo. Qualquer outro código deixa passar, como o Claude Code trata o hook
// que falha sem ser 2, e a saída de erro, se houver, vira aviso. A regra continua no
// validate.sh ship-ready, numa fonte só.
//
// Só age em projeto anvil, o que tem a rule .claude/rules/anvil.md que o boot
// escreve: fora dele, deixa passar sem dizer nada. Num projeto anvil, a guarda
// ausente da instalação de usuário é aviso, nunca passagem silenciosa.
//
// Só o tool `bash` é interceptado: comando disparado pelo `eval` escapa, como
// escapa do hook do Claude o que não passa pelo Bash.
//
// Instalado pelo /anvil-update em ~/.omp/agent/hooks/pre/. Não edite a cópia instalada:
// o próximo update a reescreve.
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { HookAPI, HookContext } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";

// O script da instalação de usuário, relativo ao HOME
const GUARDA = ".claude/skills/anvil-docs/scripts/guard-spec-merge.sh";
const MARCADOR = ".claude/rules/anvil.md";

function avisa(ctx: HookContext, mensagem: string) {
	ctx.ui.notify(mensagem, "warning");
	return { additionalContext: `Aviso da guarda de merge do anvil, repasse ao usuário: ${mensagem}` };
}

export default function guardSpecMerge(pi: HookAPI): void {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;
		const command = String(event.input.command ?? "");

		// A raiz do projeto, como o $CLAUDE_PROJECT_DIR do Claude Code.
		const topo = spawnSync("git", ["rev-parse", "--show-toplevel"], { cwd: ctx.cwd, encoding: "utf8" });
		const raiz = topo.status === 0 ? topo.stdout.trim() : ctx.cwd;
		if (!existsSync(join(raiz, MARCADOR))) return;

		const guarda = join(homedir(), GUARDA);
		if (!existsSync(guarda)) {
			return avisa(ctx, `guarda de merge desligada: ${guarda} não existe, e nenhum merge deste projeto é verificado. Reinstale o anvil com /anvil-update.`);
		}

		const r = spawnSync("bash", [guarda], {
			cwd: raiz,
			input: JSON.stringify({ tool_name: "Bash", tool_input: { command } }),
			env: { ...process.env, CLAUDE_PROJECT_DIR: raiz },
			encoding: "utf8",
		});
		if (r.status === 2) return { block: true, reason: r.stderr.trim() };
		if (r.status !== 0 && r.stderr.trim()) return avisa(ctx, r.stderr.trim());
	});
}
