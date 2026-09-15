import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"

const CHATGPT_BASE_URL = (
  process.env.CHATGPT_BASE_URL || "https://chatgpt.com/backend-api"
).replace(/\/+$/, "")
const OPENAI_AUTH_CLAIM = "https://api.openai.com/auth"
const OPENAI_PROFILE_CLAIM = "https://api.openai.com/profile"
const FIVE_HOUR_SECONDS = 5 * 60 * 60
const WEEK_SECONDS = 7 * 24 * 60 * 60

function isOpenAICodexProvider(provider: string | undefined) {
  return (
    provider === "openai-codex" || /^openai-codex-\d+$/.test(provider || "")
  )
}

function decodeJwtPayload(token: string) {
  const parts = token.split(".")
  if (parts.length < 2) return {}

  try {
    return JSON.parse(Buffer.from(parts[1], "base64url").toString("utf8"))
  } catch {
    return {}
  }
}

function getTokenMetadata(token: string) {
  const payload = decodeJwtPayload(token)
  const auth =
    payload && typeof payload === "object"
      ? payload[OPENAI_AUTH_CLAIM]
      : undefined
  const profile =
    payload && typeof payload === "object"
      ? payload[OPENAI_PROFILE_CLAIM]
      : undefined

  return {
    accountId:
      auth && typeof auth.chatgpt_account_id === "string"
        ? auth.chatgpt_account_id
        : undefined,
    planType:
      auth && typeof auth.chatgpt_plan_type === "string"
        ? auth.chatgpt_plan_type
        : undefined,
    email:
      profile && typeof profile.email === "string" ? profile.email : undefined,
  }
}

function asRecord(value: unknown) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return undefined
  }

  return Object.fromEntries(Object.entries(value))
}

function normalizeWindow(value: unknown) {
  const record = asRecord(value)
  if (!record) return undefined

  const usedPercent =
    typeof record.used_percent === "number" ? record.used_percent : undefined
  const windowSeconds =
    typeof record.limit_window_seconds === "number"
      ? record.limit_window_seconds
      : undefined
  const resetAt =
    typeof record.reset_at === "number" ? record.reset_at : undefined

  if (usedPercent === undefined || windowSeconds === undefined) return undefined
  return { usedPercent, windowSeconds, resetAt }
}

function parseUsageSnapshot(data: unknown) {
  const raw = asRecord(data)
  const rateLimit = asRecord(raw?.rate_limit)
  const windows = [
    normalizeWindow(rateLimit?.primary_window),
    normalizeWindow(rateLimit?.secondary_window),
  ].filter(Boolean)

  return {
    planType: typeof raw?.plan_type === "string" ? raw.plan_type : undefined,
    email: typeof raw?.email === "string" ? raw.email : undefined,
    fiveHour: windows.find(
      (window) => Math.abs(window.windowSeconds - FIVE_HOUR_SECONDS) <= 120,
    ),
    weekly: windows.find(
      (window) => Math.abs(window.windowSeconds - WEEK_SECONDS) <= 120,
    ),
    fetchedAt: Date.now(),
  }
}

function formatUsedPercent(window: { usedPercent: number } | undefined) {
  if (!window) return "?%"
  return `${Math.round(Math.max(0, Math.min(100, window.usedPercent)))}%`
}

function formatRemainingPercent(window: { usedPercent: number } | undefined) {
  if (!window) return "?%"
  return `${Math.round(Math.max(0, Math.min(100, 100 - window.usedPercent)))}%`
}

function formatResetLong(resetAt: number | undefined) {
  if (!resetAt) return "unknown"

  const minutes = Math.max(0, Math.round((resetAt * 1000 - Date.now()) / 60000))
  const days = Math.floor(minutes / (60 * 24))
  const hours = Math.floor((minutes % (60 * 24)) / 60)
  const mins = minutes % 60

  if (days > 0) return `in ${days}d ${hours}h`
  if (hours > 0) return `in ${hours}h ${mins}m`
  return `in ${mins}m`
}

function calculatePacePercentValue(
  window:
    | { usedPercent: number; windowSeconds: number; resetAt: number | undefined }
    | undefined,
) {
  if (!window || !window.resetAt || !window.windowSeconds) return Number.NaN

  const nowSec = Date.now() / 1000
  const windowStart = window.resetAt - window.windowSeconds
  if (nowSec < windowStart) return Number.NaN

  const elapsedSec = Math.min(window.windowSeconds, nowSec - windowStart)
  const elapsedPercent = (elapsedSec / window.windowSeconds) * 100

  if (elapsedPercent < 0.1) return Number.NaN
  return window.usedPercent - elapsedPercent
}

function formatPacePercent(
  window:
    | { usedPercent: number; windowSeconds: number; resetAt: number | undefined }
    | undefined,
) {
  const pace = calculatePacePercentValue(window)

  if (Number.isNaN(pace)) {
    if (!window || !window.resetAt || !window.windowSeconds) return "?%"

    const windowStart = window.resetAt - window.windowSeconds
    if (Date.now() / 1000 < windowStart) return "?% (not started)"
    return "?% (starting)"
  }

  if (Math.abs(pace) < 0.1) return "0% (on pace)"

  const roundedPace = Math.round(Math.abs(pace))
  return pace > 0 ? `${roundedPace}% (deficit)` : `${roundedPace}% (reserve)`
}

function buildUsageDetails(
  snapshot: ReturnType<typeof parseUsageSnapshot>,
  provider: string,
) {
  const lines = [
    `provider: ${provider}`,
    `plan: ${snapshot.planType || "unknown"}`,
  ]
  if (snapshot.email) lines.push(`email: ${snapshot.email}`)
  lines.push(
    `5-hour: ${formatUsedPercent(snapshot.fiveHour)} used, ${formatRemainingPercent(snapshot.fiveHour)} left, resets ${formatResetLong(snapshot.fiveHour?.resetAt)}`,
    `weekly: ${formatUsedPercent(snapshot.weekly)} used, ${formatRemainingPercent(snapshot.weekly)} left, resets ${formatResetLong(snapshot.weekly?.resetAt)}`,
    `pace: ${formatPacePercent(snapshot.weekly)}`,
  )
  lines.push(`fetched: ${new Date(snapshot.fetchedAt).toLocaleString()}`)
  lines.push(`endpoint: ${CHATGPT_BASE_URL}/wham/usage`)
  return lines
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("codex-usage", {
    description: "Show ChatGPT Codex 5-hour and weekly usage limits",
    handler: async (_args, ctx) => {
      const model = ctx.model
      const provider = model?.provider
      if (!isOpenAICodexProvider(provider)) {
        pi.sendMessage({
          customType: "codex-usage",
          content: "ChatGPT limits are only available for openai-codex models.",
          display: true,
        })
        return
      }

      const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model)
      if (!auth.ok || !auth.apiKey) {
        const reason = auth.ok
          ? "no API key was returned"
          : auth.error || "authentication failed"
        pi.sendMessage({
          customType: "codex-usage",
          content: `Could not load ChatGPT usage limits.\nreason: ${reason}`,
          display: true,
        })
        return
      }

      const tokenMetadata = getTokenMetadata(auth.apiKey)
      const headers = {
        Authorization: `Bearer ${auth.apiKey}`,
        Accept: "application/json",
        "User-Agent": "pi-codex-usage",
        ...(tokenMetadata.accountId
          ? { "chatgpt-account-id": tokenMetadata.accountId }
          : {}),
      }

      try {
        const response = await fetch(`${CHATGPT_BASE_URL}/wham/usage`, {
          headers,
          signal: AbortSignal.timeout(15000),
        })
        if (!response.ok) {
          const body = (await response.text()).replace(/\s+/g, " ").slice(0, 500)
          const status = `${response.status} ${response.statusText}`.trim()
          throw new Error(
            `usage request failed: ${status}${body ? `: ${body}` : ""}`,
          )
        }

        const snapshot = parseUsageSnapshot(await response.json())
        if (!snapshot.email && tokenMetadata.email) {
          snapshot.email = tokenMetadata.email
        }
        if (!snapshot.planType && tokenMetadata.planType) {
          snapshot.planType = tokenMetadata.planType
        }

        pi.sendMessage({
          customType: "codex-usage",
          content: buildUsageDetails(snapshot, provider).join("\n"),
          display: true,
        })
      } catch (error) {
        const reason = error instanceof Error ? error.message : String(error)
        pi.sendMessage({
          customType: "codex-usage",
          content: `Could not load ChatGPT usage limits.\nreason: ${reason}`,
          display: true,
        })
      }
    },
  })
}
