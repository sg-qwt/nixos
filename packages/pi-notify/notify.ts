import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_settled", async (event) => {
    if (event.aborted) {
      return;
    }

    await pi.exec("bash", [
      "-c",
      `(command -v pw-cat >/dev/null 2>&1 && pw-cat -p @sound@ || true)`,
    ]);
  });
}
