import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (event, ctx) => {
    // Skip notification if the last message was aborted
    const lastMessage = event.messages[event.messages.length - 1];
    if (lastMessage?.role === "assistant" && (lastMessage as any).stopReason === "aborted") {
      return;
    }

    // Play sound and show notification when agent finishes
    await pi.exec("bash", [
      "-c",
      `(command -v pw-cat >/dev/null 2>&1 && pw-cat -p @sound@ || true)`,
    ]);
  });
}
