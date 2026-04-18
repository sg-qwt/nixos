import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (event, _ctx) => {
    const lastMessage = event.messages[event.messages.length - 1];
    if (lastMessage?.role === "assistant" && (lastMessage as any).stopReason === "aborted") {
      return;
    }

    await pi.exec("bash", [
      "-c",
      `(command -v pw-cat >/dev/null 2>&1 && pw-cat -p @sound@ || true)`,
    ]);
  });
}
