// Guarda de merge do anvil no omp.
//
// O omp não executa os hooks PreToolUse do .claude/settings.json. Este hook faz a
// ponte: intercepta o tool `bash`, entrega o comando ao guard-spec-merge.sh no
// formato do hook do Claude e bloqueia quando ele sai com 2, com a saída de erro
// como motivo. Qualquer outro código deixa passar, como o Claude Code trata o hook
// que falha sem ser 2. A regra continua no validate.sh ship-ready, numa fonte só.
//
// Só o tool `bash` é interceptado: comando disparado pelo `eval` escapa, como
// escapa do hook do Claude o que não passa pelo Bash.
//
// Instalado pelo /anvil-update em .omp/hooks/pre/. Não edite a cópia instalada:
// o próximo update a reescreve.
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";
import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";

// O script que o update mantém em dia, e não a cópia do boot em .claude/hooks/.
const GUARDA = ".claude/skills/anvil-docs/scripts/guard-spec-merge.sh";

export default function guardSpecMerge(pi: HookAPI): void {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;
		const command = String(event.input.command ?? "");

		// A raiz do projeto, como o $CLAUDE_PROJECT_DIR do Claude Code.
		const topo = spawnSync("git", ["rev-parse", "--show-toplevel"], { cwd: ctx.cwd, encoding: "utf8" });
		const raiz = topo.status === 0 ? topo.stdout.trim() : ctx.cwd;
		const guarda = join(raiz, GUARDA);
		if (!existsSync(guarda)) return;

		const r = spawnSync("bash", [guarda], {
			cwd: raiz,
			input: JSON.stringify({ tool_name: "Bash", tool_input: { command } }),
			env: { ...process.env, CLAUDE_PROJECT_DIR: raiz },
			encoding: "utf8",
		});
		if (r.status === 2) return { block: true, reason: r.stderr.trim() };
	});
}
