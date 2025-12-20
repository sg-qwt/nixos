var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// node_modules/unenv/dist/runtime/_internal/utils.mjs
// @__NO_SIDE_EFFECTS__
function createNotImplementedError(name) {
  return new Error(`[unenv] ${name} is not implemented yet!`);
}
__name(createNotImplementedError, "createNotImplementedError");
// @__NO_SIDE_EFFECTS__
function notImplemented(name) {
  const fn = /* @__PURE__ */ __name(() => {
    throw /* @__PURE__ */ createNotImplementedError(name);
  }, "fn");
  return Object.assign(fn, { __unenv__: true });
}
__name(notImplemented, "notImplemented");
// @__NO_SIDE_EFFECTS__
function notImplementedClass(name) {
  return class {
    __unenv__ = true;
    constructor() {
      throw new Error(`[unenv] ${name} is not implemented yet!`);
    }
  };
}
__name(notImplementedClass, "notImplementedClass");

// node_modules/unenv/dist/runtime/node/internal/perf_hooks/performance.mjs
var _timeOrigin = globalThis.performance?.timeOrigin ?? Date.now();
var _performanceNow = globalThis.performance?.now ? globalThis.performance.now.bind(globalThis.performance) : () => Date.now() - _timeOrigin;
var nodeTiming = {
  name: "node",
  entryType: "node",
  startTime: 0,
  duration: 0,
  nodeStart: 0,
  v8Start: 0,
  bootstrapComplete: 0,
  environment: 0,
  loopStart: 0,
  loopExit: 0,
  idleTime: 0,
  uvMetricsInfo: {
    loopCount: 0,
    events: 0,
    eventsWaiting: 0
  },
  detail: void 0,
  toJSON() {
    return this;
  }
};
var PerformanceEntry = class {
  static {
    __name(this, "PerformanceEntry");
  }
  __unenv__ = true;
  detail;
  entryType = "event";
  name;
  startTime;
  constructor(name, options) {
    this.name = name;
    this.startTime = options?.startTime || _performanceNow();
    this.detail = options?.detail;
  }
  get duration() {
    return _performanceNow() - this.startTime;
  }
  toJSON() {
    return {
      name: this.name,
      entryType: this.entryType,
      startTime: this.startTime,
      duration: this.duration,
      detail: this.detail
    };
  }
};
var PerformanceMark = class PerformanceMark2 extends PerformanceEntry {
  static {
    __name(this, "PerformanceMark");
  }
  entryType = "mark";
  constructor() {
    super(...arguments);
  }
  get duration() {
    return 0;
  }
};
var PerformanceMeasure = class extends PerformanceEntry {
  static {
    __name(this, "PerformanceMeasure");
  }
  entryType = "measure";
};
var PerformanceResourceTiming = class extends PerformanceEntry {
  static {
    __name(this, "PerformanceResourceTiming");
  }
  entryType = "resource";
  serverTiming = [];
  connectEnd = 0;
  connectStart = 0;
  decodedBodySize = 0;
  domainLookupEnd = 0;
  domainLookupStart = 0;
  encodedBodySize = 0;
  fetchStart = 0;
  initiatorType = "";
  name = "";
  nextHopProtocol = "";
  redirectEnd = 0;
  redirectStart = 0;
  requestStart = 0;
  responseEnd = 0;
  responseStart = 0;
  secureConnectionStart = 0;
  startTime = 0;
  transferSize = 0;
  workerStart = 0;
  responseStatus = 0;
};
var PerformanceObserverEntryList = class {
  static {
    __name(this, "PerformanceObserverEntryList");
  }
  __unenv__ = true;
  getEntries() {
    return [];
  }
  getEntriesByName(_name, _type) {
    return [];
  }
  getEntriesByType(type) {
    return [];
  }
};
var Performance = class {
  static {
    __name(this, "Performance");
  }
  __unenv__ = true;
  timeOrigin = _timeOrigin;
  eventCounts = /* @__PURE__ */ new Map();
  _entries = [];
  _resourceTimingBufferSize = 0;
  navigation = void 0;
  timing = void 0;
  timerify(_fn, _options) {
    throw createNotImplementedError("Performance.timerify");
  }
  get nodeTiming() {
    return nodeTiming;
  }
  eventLoopUtilization() {
    return {};
  }
  markResourceTiming() {
    return new PerformanceResourceTiming("");
  }
  onresourcetimingbufferfull = null;
  now() {
    if (this.timeOrigin === _timeOrigin) {
      return _performanceNow();
    }
    return Date.now() - this.timeOrigin;
  }
  clearMarks(markName) {
    this._entries = markName ? this._entries.filter((e) => e.name !== markName) : this._entries.filter((e) => e.entryType !== "mark");
  }
  clearMeasures(measureName) {
    this._entries = measureName ? this._entries.filter((e) => e.name !== measureName) : this._entries.filter((e) => e.entryType !== "measure");
  }
  clearResourceTimings() {
    this._entries = this._entries.filter((e) => e.entryType !== "resource" || e.entryType !== "navigation");
  }
  getEntries() {
    return this._entries;
  }
  getEntriesByName(name, type) {
    return this._entries.filter((e) => e.name === name && (!type || e.entryType === type));
  }
  getEntriesByType(type) {
    return this._entries.filter((e) => e.entryType === type);
  }
  mark(name, options) {
    const entry = new PerformanceMark(name, options);
    this._entries.push(entry);
    return entry;
  }
  measure(measureName, startOrMeasureOptions, endMark) {
    let start;
    let end;
    if (typeof startOrMeasureOptions === "string") {
      start = this.getEntriesByName(startOrMeasureOptions, "mark")[0]?.startTime;
      end = this.getEntriesByName(endMark, "mark")[0]?.startTime;
    } else {
      start = Number.parseFloat(startOrMeasureOptions?.start) || this.now();
      end = Number.parseFloat(startOrMeasureOptions?.end) || this.now();
    }
    const entry = new PerformanceMeasure(measureName, {
      startTime: start,
      detail: {
        start,
        end
      }
    });
    this._entries.push(entry);
    return entry;
  }
  setResourceTimingBufferSize(maxSize) {
    this._resourceTimingBufferSize = maxSize;
  }
  addEventListener(type, listener, options) {
    throw createNotImplementedError("Performance.addEventListener");
  }
  removeEventListener(type, listener, options) {
    throw createNotImplementedError("Performance.removeEventListener");
  }
  dispatchEvent(event) {
    throw createNotImplementedError("Performance.dispatchEvent");
  }
  toJSON() {
    return this;
  }
};
var PerformanceObserver = class {
  static {
    __name(this, "PerformanceObserver");
  }
  __unenv__ = true;
  static supportedEntryTypes = [];
  _callback = null;
  constructor(callback) {
    this._callback = callback;
  }
  takeRecords() {
    return [];
  }
  disconnect() {
    throw createNotImplementedError("PerformanceObserver.disconnect");
  }
  observe(options) {
    throw createNotImplementedError("PerformanceObserver.observe");
  }
  bind(fn) {
    return fn;
  }
  runInAsyncScope(fn, thisArg, ...args) {
    return fn.call(thisArg, ...args);
  }
  asyncId() {
    return 0;
  }
  triggerAsyncId() {
    return 0;
  }
  emitDestroy() {
    return this;
  }
};
var performance = globalThis.performance && "addEventListener" in globalThis.performance ? globalThis.performance : new Performance();

// node_modules/@cloudflare/unenv-preset/dist/runtime/polyfill/performance.mjs
globalThis.performance = performance;
globalThis.Performance = Performance;
globalThis.PerformanceEntry = PerformanceEntry;
globalThis.PerformanceMark = PerformanceMark;
globalThis.PerformanceMeasure = PerformanceMeasure;
globalThis.PerformanceObserver = PerformanceObserver;
globalThis.PerformanceObserverEntryList = PerformanceObserverEntryList;
globalThis.PerformanceResourceTiming = PerformanceResourceTiming;

// node_modules/unenv/dist/runtime/node/console.mjs
import { Writable } from "node:stream";

// node_modules/unenv/dist/runtime/mock/noop.mjs
var noop_default = Object.assign(() => {
}, { __unenv__: true });

// node_modules/unenv/dist/runtime/node/console.mjs
var _console = globalThis.console;
var _ignoreErrors = true;
var _stderr = new Writable();
var _stdout = new Writable();
var log = _console?.log ?? noop_default;
var info = _console?.info ?? log;
var trace = _console?.trace ?? info;
var debug = _console?.debug ?? log;
var table = _console?.table ?? log;
var error = _console?.error ?? log;
var warn = _console?.warn ?? error;
var createTask = _console?.createTask ?? /* @__PURE__ */ notImplemented("console.createTask");
var clear = _console?.clear ?? noop_default;
var count = _console?.count ?? noop_default;
var countReset = _console?.countReset ?? noop_default;
var dir = _console?.dir ?? noop_default;
var dirxml = _console?.dirxml ?? noop_default;
var group = _console?.group ?? noop_default;
var groupEnd = _console?.groupEnd ?? noop_default;
var groupCollapsed = _console?.groupCollapsed ?? noop_default;
var profile = _console?.profile ?? noop_default;
var profileEnd = _console?.profileEnd ?? noop_default;
var time = _console?.time ?? noop_default;
var timeEnd = _console?.timeEnd ?? noop_default;
var timeLog = _console?.timeLog ?? noop_default;
var timeStamp = _console?.timeStamp ?? noop_default;
var Console = _console?.Console ?? /* @__PURE__ */ notImplementedClass("console.Console");
var _times = /* @__PURE__ */ new Map();
var _stdoutErrorHandler = noop_default;
var _stderrErrorHandler = noop_default;

// node_modules/@cloudflare/unenv-preset/dist/runtime/node/console.mjs
var workerdConsole = globalThis["console"];
var {
  assert,
  clear: clear2,
  // @ts-expect-error undocumented public API
  context,
  count: count2,
  countReset: countReset2,
  // @ts-expect-error undocumented public API
  createTask: createTask2,
  debug: debug2,
  dir: dir2,
  dirxml: dirxml2,
  error: error2,
  group: group2,
  groupCollapsed: groupCollapsed2,
  groupEnd: groupEnd2,
  info: info2,
  log: log2,
  profile: profile2,
  profileEnd: profileEnd2,
  table: table2,
  time: time2,
  timeEnd: timeEnd2,
  timeLog: timeLog2,
  timeStamp: timeStamp2,
  trace: trace2,
  warn: warn2
} = workerdConsole;
Object.assign(workerdConsole, {
  Console,
  _ignoreErrors,
  _stderr,
  _stderrErrorHandler,
  _stdout,
  _stdoutErrorHandler,
  _times
});
var console_default = workerdConsole;

// node_modules/wrangler/_virtual_unenv_global_polyfill-@cloudflare-unenv-preset-node-console
globalThis.console = console_default;

// node_modules/unenv/dist/runtime/node/internal/process/hrtime.mjs
var hrtime = /* @__PURE__ */ Object.assign(/* @__PURE__ */ __name(function hrtime2(startTime) {
  const now = Date.now();
  const seconds = Math.trunc(now / 1e3);
  const nanos = now % 1e3 * 1e6;
  if (startTime) {
    let diffSeconds = seconds - startTime[0];
    let diffNanos = nanos - startTime[0];
    if (diffNanos < 0) {
      diffSeconds = diffSeconds - 1;
      diffNanos = 1e9 + diffNanos;
    }
    return [diffSeconds, diffNanos];
  }
  return [seconds, nanos];
}, "hrtime"), { bigint: /* @__PURE__ */ __name(function bigint() {
  return BigInt(Date.now() * 1e6);
}, "bigint") });

// node_modules/unenv/dist/runtime/node/internal/process/process.mjs
import { EventEmitter } from "node:events";

// node_modules/unenv/dist/runtime/node/internal/tty/write-stream.mjs
var WriteStream = class {
  static {
    __name(this, "WriteStream");
  }
  fd;
  columns = 80;
  rows = 24;
  isTTY = false;
  constructor(fd) {
    this.fd = fd;
  }
  clearLine(dir3, callback) {
    callback && callback();
    return false;
  }
  clearScreenDown(callback) {
    callback && callback();
    return false;
  }
  cursorTo(x, y, callback) {
    callback && typeof callback === "function" && callback();
    return false;
  }
  moveCursor(dx, dy, callback) {
    callback && callback();
    return false;
  }
  getColorDepth(env2) {
    return 1;
  }
  hasColors(count3, env2) {
    return false;
  }
  getWindowSize() {
    return [this.columns, this.rows];
  }
  write(str, encoding, cb) {
    if (str instanceof Uint8Array) {
      str = new TextDecoder().decode(str);
    }
    try {
      console.log(str);
    } catch {
    }
    cb && typeof cb === "function" && cb();
    return false;
  }
};

// node_modules/unenv/dist/runtime/node/internal/tty/read-stream.mjs
var ReadStream = class {
  static {
    __name(this, "ReadStream");
  }
  fd;
  isRaw = false;
  isTTY = false;
  constructor(fd) {
    this.fd = fd;
  }
  setRawMode(mode) {
    this.isRaw = mode;
    return this;
  }
};

// node_modules/unenv/dist/runtime/node/internal/process/node-version.mjs
var NODE_VERSION = "22.14.0";

// node_modules/unenv/dist/runtime/node/internal/process/process.mjs
var Process = class _Process extends EventEmitter {
  static {
    __name(this, "Process");
  }
  env;
  hrtime;
  nextTick;
  constructor(impl) {
    super();
    this.env = impl.env;
    this.hrtime = impl.hrtime;
    this.nextTick = impl.nextTick;
    for (const prop of [...Object.getOwnPropertyNames(_Process.prototype), ...Object.getOwnPropertyNames(EventEmitter.prototype)]) {
      const value = this[prop];
      if (typeof value === "function") {
        this[prop] = value.bind(this);
      }
    }
  }
  // --- event emitter ---
  emitWarning(warning, type, code) {
    console.warn(`${code ? `[${code}] ` : ""}${type ? `${type}: ` : ""}${warning}`);
  }
  emit(...args) {
    return super.emit(...args);
  }
  listeners(eventName) {
    return super.listeners(eventName);
  }
  // --- stdio (lazy initializers) ---
  #stdin;
  #stdout;
  #stderr;
  get stdin() {
    return this.#stdin ??= new ReadStream(0);
  }
  get stdout() {
    return this.#stdout ??= new WriteStream(1);
  }
  get stderr() {
    return this.#stderr ??= new WriteStream(2);
  }
  // --- cwd ---
  #cwd = "/";
  chdir(cwd2) {
    this.#cwd = cwd2;
  }
  cwd() {
    return this.#cwd;
  }
  // --- dummy props and getters ---
  arch = "";
  platform = "";
  argv = [];
  argv0 = "";
  execArgv = [];
  execPath = "";
  title = "";
  pid = 200;
  ppid = 100;
  get version() {
    return `v${NODE_VERSION}`;
  }
  get versions() {
    return { node: NODE_VERSION };
  }
  get allowedNodeEnvironmentFlags() {
    return /* @__PURE__ */ new Set();
  }
  get sourceMapsEnabled() {
    return false;
  }
  get debugPort() {
    return 0;
  }
  get throwDeprecation() {
    return false;
  }
  get traceDeprecation() {
    return false;
  }
  get features() {
    return {};
  }
  get release() {
    return {};
  }
  get connected() {
    return false;
  }
  get config() {
    return {};
  }
  get moduleLoadList() {
    return [];
  }
  constrainedMemory() {
    return 0;
  }
  availableMemory() {
    return 0;
  }
  uptime() {
    return 0;
  }
  resourceUsage() {
    return {};
  }
  // --- noop methods ---
  ref() {
  }
  unref() {
  }
  // --- unimplemented methods ---
  umask() {
    throw createNotImplementedError("process.umask");
  }
  getBuiltinModule() {
    return void 0;
  }
  getActiveResourcesInfo() {
    throw createNotImplementedError("process.getActiveResourcesInfo");
  }
  exit() {
    throw createNotImplementedError("process.exit");
  }
  reallyExit() {
    throw createNotImplementedError("process.reallyExit");
  }
  kill() {
    throw createNotImplementedError("process.kill");
  }
  abort() {
    throw createNotImplementedError("process.abort");
  }
  dlopen() {
    throw createNotImplementedError("process.dlopen");
  }
  setSourceMapsEnabled() {
    throw createNotImplementedError("process.setSourceMapsEnabled");
  }
  loadEnvFile() {
    throw createNotImplementedError("process.loadEnvFile");
  }
  disconnect() {
    throw createNotImplementedError("process.disconnect");
  }
  cpuUsage() {
    throw createNotImplementedError("process.cpuUsage");
  }
  setUncaughtExceptionCaptureCallback() {
    throw createNotImplementedError("process.setUncaughtExceptionCaptureCallback");
  }
  hasUncaughtExceptionCaptureCallback() {
    throw createNotImplementedError("process.hasUncaughtExceptionCaptureCallback");
  }
  initgroups() {
    throw createNotImplementedError("process.initgroups");
  }
  openStdin() {
    throw createNotImplementedError("process.openStdin");
  }
  assert() {
    throw createNotImplementedError("process.assert");
  }
  binding() {
    throw createNotImplementedError("process.binding");
  }
  // --- attached interfaces ---
  permission = { has: /* @__PURE__ */ notImplemented("process.permission.has") };
  report = {
    directory: "",
    filename: "",
    signal: "SIGUSR2",
    compact: false,
    reportOnFatalError: false,
    reportOnSignal: false,
    reportOnUncaughtException: false,
    getReport: /* @__PURE__ */ notImplemented("process.report.getReport"),
    writeReport: /* @__PURE__ */ notImplemented("process.report.writeReport")
  };
  finalization = {
    register: /* @__PURE__ */ notImplemented("process.finalization.register"),
    unregister: /* @__PURE__ */ notImplemented("process.finalization.unregister"),
    registerBeforeExit: /* @__PURE__ */ notImplemented("process.finalization.registerBeforeExit")
  };
  memoryUsage = Object.assign(() => ({
    arrayBuffers: 0,
    rss: 0,
    external: 0,
    heapTotal: 0,
    heapUsed: 0
  }), { rss: /* @__PURE__ */ __name(() => 0, "rss") });
  // --- undefined props ---
  mainModule = void 0;
  domain = void 0;
  // optional
  send = void 0;
  exitCode = void 0;
  channel = void 0;
  getegid = void 0;
  geteuid = void 0;
  getgid = void 0;
  getgroups = void 0;
  getuid = void 0;
  setegid = void 0;
  seteuid = void 0;
  setgid = void 0;
  setgroups = void 0;
  setuid = void 0;
  // internals
  _events = void 0;
  _eventsCount = void 0;
  _exiting = void 0;
  _maxListeners = void 0;
  _debugEnd = void 0;
  _debugProcess = void 0;
  _fatalException = void 0;
  _getActiveHandles = void 0;
  _getActiveRequests = void 0;
  _kill = void 0;
  _preload_modules = void 0;
  _rawDebug = void 0;
  _startProfilerIdleNotifier = void 0;
  _stopProfilerIdleNotifier = void 0;
  _tickCallback = void 0;
  _disconnect = void 0;
  _handleQueue = void 0;
  _pendingMessage = void 0;
  _channel = void 0;
  _send = void 0;
  _linkedBinding = void 0;
};

// node_modules/@cloudflare/unenv-preset/dist/runtime/node/process.mjs
var globalProcess = globalThis["process"];
var getBuiltinModule = globalProcess.getBuiltinModule;
var { exit, platform, nextTick } = getBuiltinModule(
  "node:process"
);
var unenvProcess = new Process({
  env: globalProcess.env,
  hrtime,
  nextTick
});
var {
  abort,
  addListener,
  allowedNodeEnvironmentFlags,
  hasUncaughtExceptionCaptureCallback,
  setUncaughtExceptionCaptureCallback,
  loadEnvFile,
  sourceMapsEnabled,
  arch,
  argv,
  argv0,
  chdir,
  config,
  connected,
  constrainedMemory,
  availableMemory,
  cpuUsage,
  cwd,
  debugPort,
  dlopen,
  disconnect,
  emit,
  emitWarning,
  env,
  eventNames,
  execArgv,
  execPath,
  finalization,
  features,
  getActiveResourcesInfo,
  getMaxListeners,
  hrtime: hrtime3,
  kill,
  listeners,
  listenerCount,
  memoryUsage,
  on,
  off,
  once,
  pid,
  ppid,
  prependListener,
  prependOnceListener,
  rawListeners,
  release,
  removeAllListeners,
  removeListener,
  report,
  resourceUsage,
  setMaxListeners,
  setSourceMapsEnabled,
  stderr,
  stdin,
  stdout,
  title,
  throwDeprecation,
  traceDeprecation,
  umask,
  uptime,
  version,
  versions,
  domain,
  initgroups,
  moduleLoadList,
  reallyExit,
  openStdin,
  assert: assert2,
  binding,
  send,
  exitCode,
  channel,
  getegid,
  geteuid,
  getgid,
  getgroups,
  getuid,
  setegid,
  seteuid,
  setgid,
  setgroups,
  setuid,
  permission,
  mainModule,
  _events,
  _eventsCount,
  _exiting,
  _maxListeners,
  _debugEnd,
  _debugProcess,
  _fatalException,
  _getActiveHandles,
  _getActiveRequests,
  _kill,
  _preload_modules,
  _rawDebug,
  _startProfilerIdleNotifier,
  _stopProfilerIdleNotifier,
  _tickCallback,
  _disconnect,
  _handleQueue,
  _pendingMessage,
  _channel,
  _send,
  _linkedBinding
} = unenvProcess;
var _process = {
  abort,
  addListener,
  allowedNodeEnvironmentFlags,
  hasUncaughtExceptionCaptureCallback,
  setUncaughtExceptionCaptureCallback,
  loadEnvFile,
  sourceMapsEnabled,
  arch,
  argv,
  argv0,
  chdir,
  config,
  connected,
  constrainedMemory,
  availableMemory,
  cpuUsage,
  cwd,
  debugPort,
  dlopen,
  disconnect,
  emit,
  emitWarning,
  env,
  eventNames,
  execArgv,
  execPath,
  exit,
  finalization,
  features,
  getBuiltinModule,
  getActiveResourcesInfo,
  getMaxListeners,
  hrtime: hrtime3,
  kill,
  listeners,
  listenerCount,
  memoryUsage,
  nextTick,
  on,
  off,
  once,
  pid,
  platform,
  ppid,
  prependListener,
  prependOnceListener,
  rawListeners,
  release,
  removeAllListeners,
  removeListener,
  report,
  resourceUsage,
  setMaxListeners,
  setSourceMapsEnabled,
  stderr,
  stdin,
  stdout,
  title,
  throwDeprecation,
  traceDeprecation,
  umask,
  uptime,
  version,
  versions,
  // @ts-expect-error old API
  domain,
  initgroups,
  moduleLoadList,
  reallyExit,
  openStdin,
  assert: assert2,
  binding,
  send,
  exitCode,
  channel,
  getegid,
  geteuid,
  getgid,
  getgroups,
  getuid,
  setegid,
  seteuid,
  setgid,
  setgroups,
  setuid,
  permission,
  mainModule,
  _events,
  _eventsCount,
  _exiting,
  _maxListeners,
  _debugEnd,
  _debugProcess,
  _fatalException,
  _getActiveHandles,
  _getActiveRequests,
  _kill,
  _preload_modules,
  _rawDebug,
  _startProfilerIdleNotifier,
  _stopProfilerIdleNotifier,
  _tickCallback,
  _disconnect,
  _handleQueue,
  _pendingMessage,
  _channel,
  _send,
  _linkedBinding
};
var process_default = _process;

// node_modules/wrangler/_virtual_unenv_global_polyfill-@cloudflare-unenv-preset-node-process
globalThis.process = process_default;

// node_modules/hono/dist/compose.js
var compose = /* @__PURE__ */ __name((middleware, onError, onNotFound) => {
  return (context2, next) => {
    let index = -1;
    return dispatch(0);
    async function dispatch(i) {
      if (i <= index) {
        throw new Error("next() called multiple times");
      }
      index = i;
      let res;
      let isError = false;
      let handler;
      if (middleware[i]) {
        handler = middleware[i][0][0];
        context2.req.routeIndex = i;
      } else {
        handler = i === middleware.length && next || void 0;
      }
      if (handler) {
        try {
          res = await handler(context2, () => dispatch(i + 1));
        } catch (err) {
          if (err instanceof Error && onError) {
            context2.error = err;
            res = await onError(err, context2);
            isError = true;
          } else {
            throw err;
          }
        }
      } else {
        if (context2.finalized === false && onNotFound) {
          res = await onNotFound(context2);
        }
      }
      if (res && (context2.finalized === false || isError)) {
        context2.res = res;
      }
      return context2;
    }
    __name(dispatch, "dispatch");
  };
}, "compose");

// node_modules/hono/dist/request/constants.js
var GET_MATCH_RESULT = Symbol();

// node_modules/hono/dist/utils/body.js
var parseBody = /* @__PURE__ */ __name(async (request, options = /* @__PURE__ */ Object.create(null)) => {
  const { all = false, dot = false } = options;
  const headers = request instanceof HonoRequest ? request.raw.headers : request.headers;
  const contentType = headers.get("Content-Type");
  if (contentType?.startsWith("multipart/form-data") || contentType?.startsWith("application/x-www-form-urlencoded")) {
    return parseFormData(request, { all, dot });
  }
  return {};
}, "parseBody");
async function parseFormData(request, options) {
  const formData = await request.formData();
  if (formData) {
    return convertFormDataToBodyData(formData, options);
  }
  return {};
}
__name(parseFormData, "parseFormData");
function convertFormDataToBodyData(formData, options) {
  const form = /* @__PURE__ */ Object.create(null);
  formData.forEach((value, key) => {
    const shouldParseAllValues = options.all || key.endsWith("[]");
    if (!shouldParseAllValues) {
      form[key] = value;
    } else {
      handleParsingAllValues(form, key, value);
    }
  });
  if (options.dot) {
    Object.entries(form).forEach(([key, value]) => {
      const shouldParseDotValues = key.includes(".");
      if (shouldParseDotValues) {
        handleParsingNestedValues(form, key, value);
        delete form[key];
      }
    });
  }
  return form;
}
__name(convertFormDataToBodyData, "convertFormDataToBodyData");
var handleParsingAllValues = /* @__PURE__ */ __name((form, key, value) => {
  if (form[key] !== void 0) {
    if (Array.isArray(form[key])) {
      ;
      form[key].push(value);
    } else {
      form[key] = [form[key], value];
    }
  } else {
    if (!key.endsWith("[]")) {
      form[key] = value;
    } else {
      form[key] = [value];
    }
  }
}, "handleParsingAllValues");
var handleParsingNestedValues = /* @__PURE__ */ __name((form, key, value) => {
  let nestedForm = form;
  const keys = key.split(".");
  keys.forEach((key2, index) => {
    if (index === keys.length - 1) {
      nestedForm[key2] = value;
    } else {
      if (!nestedForm[key2] || typeof nestedForm[key2] !== "object" || Array.isArray(nestedForm[key2]) || nestedForm[key2] instanceof File) {
        nestedForm[key2] = /* @__PURE__ */ Object.create(null);
      }
      nestedForm = nestedForm[key2];
    }
  });
}, "handleParsingNestedValues");

// node_modules/hono/dist/utils/url.js
var splitPath = /* @__PURE__ */ __name((path) => {
  const paths = path.split("/");
  if (paths[0] === "") {
    paths.shift();
  }
  return paths;
}, "splitPath");
var splitRoutingPath = /* @__PURE__ */ __name((routePath) => {
  const { groups, path } = extractGroupsFromPath(routePath);
  const paths = splitPath(path);
  return replaceGroupMarks(paths, groups);
}, "splitRoutingPath");
var extractGroupsFromPath = /* @__PURE__ */ __name((path) => {
  const groups = [];
  path = path.replace(/\{[^}]+\}/g, (match, index) => {
    const mark = `@${index}`;
    groups.push([mark, match]);
    return mark;
  });
  return { groups, path };
}, "extractGroupsFromPath");
var replaceGroupMarks = /* @__PURE__ */ __name((paths, groups) => {
  for (let i = groups.length - 1; i >= 0; i--) {
    const [mark] = groups[i];
    for (let j = paths.length - 1; j >= 0; j--) {
      if (paths[j].includes(mark)) {
        paths[j] = paths[j].replace(mark, groups[i][1]);
        break;
      }
    }
  }
  return paths;
}, "replaceGroupMarks");
var patternCache = {};
var getPattern = /* @__PURE__ */ __name((label, next) => {
  if (label === "*") {
    return "*";
  }
  const match = label.match(/^\:([^\{\}]+)(?:\{(.+)\})?$/);
  if (match) {
    const cacheKey = `${label}#${next}`;
    if (!patternCache[cacheKey]) {
      if (match[2]) {
        patternCache[cacheKey] = next && next[0] !== ":" && next[0] !== "*" ? [cacheKey, match[1], new RegExp(`^${match[2]}(?=/${next})`)] : [label, match[1], new RegExp(`^${match[2]}$`)];
      } else {
        patternCache[cacheKey] = [label, match[1], true];
      }
    }
    return patternCache[cacheKey];
  }
  return null;
}, "getPattern");
var tryDecode = /* @__PURE__ */ __name((str, decoder) => {
  try {
    return decoder(str);
  } catch {
    return str.replace(/(?:%[0-9A-Fa-f]{2})+/g, (match) => {
      try {
        return decoder(match);
      } catch {
        return match;
      }
    });
  }
}, "tryDecode");
var tryDecodeURI = /* @__PURE__ */ __name((str) => tryDecode(str, decodeURI), "tryDecodeURI");
var getPath = /* @__PURE__ */ __name((request) => {
  const url = request.url;
  const start = url.indexOf(
    "/",
    url.charCodeAt(9) === 58 ? 13 : 8
  );
  let i = start;
  for (; i < url.length; i++) {
    const charCode = url.charCodeAt(i);
    if (charCode === 37) {
      const queryIndex = url.indexOf("?", i);
      const path = url.slice(start, queryIndex === -1 ? void 0 : queryIndex);
      return tryDecodeURI(path.includes("%25") ? path.replace(/%25/g, "%2525") : path);
    } else if (charCode === 63) {
      break;
    }
  }
  return url.slice(start, i);
}, "getPath");
var getPathNoStrict = /* @__PURE__ */ __name((request) => {
  const result = getPath(request);
  return result.length > 1 && result.at(-1) === "/" ? result.slice(0, -1) : result;
}, "getPathNoStrict");
var mergePath = /* @__PURE__ */ __name((base, sub, ...rest) => {
  if (rest.length) {
    sub = mergePath(sub, ...rest);
  }
  return `${base?.[0] === "/" ? "" : "/"}${base}${sub === "/" ? "" : `${base?.at(-1) === "/" ? "" : "/"}${sub?.[0] === "/" ? sub.slice(1) : sub}`}`;
}, "mergePath");
var checkOptionalParameter = /* @__PURE__ */ __name((path) => {
  if (path.charCodeAt(path.length - 1) !== 63 || !path.includes(":")) {
    return null;
  }
  const segments = path.split("/");
  const results = [];
  let basePath = "";
  segments.forEach((segment) => {
    if (segment !== "" && !/\:/.test(segment)) {
      basePath += "/" + segment;
    } else if (/\:/.test(segment)) {
      if (/\?/.test(segment)) {
        if (results.length === 0 && basePath === "") {
          results.push("/");
        } else {
          results.push(basePath);
        }
        const optionalSegment = segment.replace("?", "");
        basePath += "/" + optionalSegment;
        results.push(basePath);
      } else {
        basePath += "/" + segment;
      }
    }
  });
  return results.filter((v, i, a) => a.indexOf(v) === i);
}, "checkOptionalParameter");
var _decodeURI = /* @__PURE__ */ __name((value) => {
  if (!/[%+]/.test(value)) {
    return value;
  }
  if (value.indexOf("+") !== -1) {
    value = value.replace(/\+/g, " ");
  }
  return value.indexOf("%") !== -1 ? tryDecode(value, decodeURIComponent_) : value;
}, "_decodeURI");
var _getQueryParam = /* @__PURE__ */ __name((url, key, multiple) => {
  let encoded;
  if (!multiple && key && !/[%+]/.test(key)) {
    let keyIndex2 = url.indexOf(`?${key}`, 8);
    if (keyIndex2 === -1) {
      keyIndex2 = url.indexOf(`&${key}`, 8);
    }
    while (keyIndex2 !== -1) {
      const trailingKeyCode = url.charCodeAt(keyIndex2 + key.length + 1);
      if (trailingKeyCode === 61) {
        const valueIndex = keyIndex2 + key.length + 2;
        const endIndex = url.indexOf("&", valueIndex);
        return _decodeURI(url.slice(valueIndex, endIndex === -1 ? void 0 : endIndex));
      } else if (trailingKeyCode == 38 || isNaN(trailingKeyCode)) {
        return "";
      }
      keyIndex2 = url.indexOf(`&${key}`, keyIndex2 + 1);
    }
    encoded = /[%+]/.test(url);
    if (!encoded) {
      return void 0;
    }
  }
  const results = {};
  encoded ??= /[%+]/.test(url);
  let keyIndex = url.indexOf("?", 8);
  while (keyIndex !== -1) {
    const nextKeyIndex = url.indexOf("&", keyIndex + 1);
    let valueIndex = url.indexOf("=", keyIndex);
    if (valueIndex > nextKeyIndex && nextKeyIndex !== -1) {
      valueIndex = -1;
    }
    let name = url.slice(
      keyIndex + 1,
      valueIndex === -1 ? nextKeyIndex === -1 ? void 0 : nextKeyIndex : valueIndex
    );
    if (encoded) {
      name = _decodeURI(name);
    }
    keyIndex = nextKeyIndex;
    if (name === "") {
      continue;
    }
    let value;
    if (valueIndex === -1) {
      value = "";
    } else {
      value = url.slice(valueIndex + 1, nextKeyIndex === -1 ? void 0 : nextKeyIndex);
      if (encoded) {
        value = _decodeURI(value);
      }
    }
    if (multiple) {
      if (!(results[name] && Array.isArray(results[name]))) {
        results[name] = [];
      }
      ;
      results[name].push(value);
    } else {
      results[name] ??= value;
    }
  }
  return key ? results[key] : results;
}, "_getQueryParam");
var getQueryParam = _getQueryParam;
var getQueryParams = /* @__PURE__ */ __name((url, key) => {
  return _getQueryParam(url, key, true);
}, "getQueryParams");
var decodeURIComponent_ = decodeURIComponent;

// node_modules/hono/dist/request.js
var tryDecodeURIComponent = /* @__PURE__ */ __name((str) => tryDecode(str, decodeURIComponent_), "tryDecodeURIComponent");
var HonoRequest = class {
  static {
    __name(this, "HonoRequest");
  }
  raw;
  #validatedData;
  #matchResult;
  routeIndex = 0;
  path;
  bodyCache = {};
  constructor(request, path = "/", matchResult = [[]]) {
    this.raw = request;
    this.path = path;
    this.#matchResult = matchResult;
    this.#validatedData = {};
  }
  param(key) {
    return key ? this.#getDecodedParam(key) : this.#getAllDecodedParams();
  }
  #getDecodedParam(key) {
    const paramKey = this.#matchResult[0][this.routeIndex][1][key];
    const param = this.#getParamValue(paramKey);
    return param ? /\%/.test(param) ? tryDecodeURIComponent(param) : param : void 0;
  }
  #getAllDecodedParams() {
    const decoded = {};
    const keys = Object.keys(this.#matchResult[0][this.routeIndex][1]);
    for (const key of keys) {
      const value = this.#getParamValue(this.#matchResult[0][this.routeIndex][1][key]);
      if (value && typeof value === "string") {
        decoded[key] = /\%/.test(value) ? tryDecodeURIComponent(value) : value;
      }
    }
    return decoded;
  }
  #getParamValue(paramKey) {
    return this.#matchResult[1] ? this.#matchResult[1][paramKey] : paramKey;
  }
  query(key) {
    return getQueryParam(this.url, key);
  }
  queries(key) {
    return getQueryParams(this.url, key);
  }
  header(name) {
    if (name) {
      return this.raw.headers.get(name) ?? void 0;
    }
    const headerData = {};
    this.raw.headers.forEach((value, key) => {
      headerData[key] = value;
    });
    return headerData;
  }
  async parseBody(options) {
    return this.bodyCache.parsedBody ??= await parseBody(this, options);
  }
  #cachedBody = /* @__PURE__ */ __name((key) => {
    const { bodyCache, raw: raw2 } = this;
    const cachedBody = bodyCache[key];
    if (cachedBody) {
      return cachedBody;
    }
    const anyCachedKey = Object.keys(bodyCache)[0];
    if (anyCachedKey) {
      return bodyCache[anyCachedKey].then((body) => {
        if (anyCachedKey === "json") {
          body = JSON.stringify(body);
        }
        return new Response(body)[key]();
      });
    }
    return bodyCache[key] = raw2[key]();
  }, "#cachedBody");
  json() {
    return this.#cachedBody("text").then((text) => JSON.parse(text));
  }
  text() {
    return this.#cachedBody("text");
  }
  arrayBuffer() {
    return this.#cachedBody("arrayBuffer");
  }
  blob() {
    return this.#cachedBody("blob");
  }
  formData() {
    return this.#cachedBody("formData");
  }
  addValidatedData(target, data) {
    this.#validatedData[target] = data;
  }
  valid(target) {
    return this.#validatedData[target];
  }
  get url() {
    return this.raw.url;
  }
  get method() {
    return this.raw.method;
  }
  get [GET_MATCH_RESULT]() {
    return this.#matchResult;
  }
  get matchedRoutes() {
    return this.#matchResult[0].map(([[, route]]) => route);
  }
  get routePath() {
    return this.#matchResult[0].map(([[, route]]) => route)[this.routeIndex].path;
  }
};

// node_modules/hono/dist/utils/html.js
var HtmlEscapedCallbackPhase = {
  Stringify: 1,
  BeforeStream: 2,
  Stream: 3
};
var raw = /* @__PURE__ */ __name((value, callbacks) => {
  const escapedString = new String(value);
  escapedString.isEscaped = true;
  escapedString.callbacks = callbacks;
  return escapedString;
}, "raw");
var resolveCallback = /* @__PURE__ */ __name(async (str, phase, preserveCallbacks, context2, buffer) => {
  if (typeof str === "object" && !(str instanceof String)) {
    if (!(str instanceof Promise)) {
      str = str.toString();
    }
    if (str instanceof Promise) {
      str = await str;
    }
  }
  const callbacks = str.callbacks;
  if (!callbacks?.length) {
    return Promise.resolve(str);
  }
  if (buffer) {
    buffer[0] += str;
  } else {
    buffer = [str];
  }
  const resStr = Promise.all(callbacks.map((c) => c({ phase, buffer, context: context2 }))).then(
    (res) => Promise.all(
      res.filter(Boolean).map((str2) => resolveCallback(str2, phase, false, context2, buffer))
    ).then(() => buffer[0])
  );
  if (preserveCallbacks) {
    return raw(await resStr, callbacks);
  } else {
    return resStr;
  }
}, "resolveCallback");

// node_modules/hono/dist/context.js
var TEXT_PLAIN = "text/plain; charset=UTF-8";
var setDefaultContentType = /* @__PURE__ */ __name((contentType, headers) => {
  return {
    "Content-Type": contentType,
    ...headers
  };
}, "setDefaultContentType");
var Context = class {
  static {
    __name(this, "Context");
  }
  #rawRequest;
  #req;
  env = {};
  #var;
  finalized = false;
  error;
  #status;
  #executionCtx;
  #res;
  #layout;
  #renderer;
  #notFoundHandler;
  #preparedHeaders;
  #matchResult;
  #path;
  constructor(req, options) {
    this.#rawRequest = req;
    if (options) {
      this.#executionCtx = options.executionCtx;
      this.env = options.env;
      this.#notFoundHandler = options.notFoundHandler;
      this.#path = options.path;
      this.#matchResult = options.matchResult;
    }
  }
  get req() {
    this.#req ??= new HonoRequest(this.#rawRequest, this.#path, this.#matchResult);
    return this.#req;
  }
  get event() {
    if (this.#executionCtx && "respondWith" in this.#executionCtx) {
      return this.#executionCtx;
    } else {
      throw Error("This context has no FetchEvent");
    }
  }
  get executionCtx() {
    if (this.#executionCtx) {
      return this.#executionCtx;
    } else {
      throw Error("This context has no ExecutionContext");
    }
  }
  get res() {
    return this.#res ||= new Response(null, {
      headers: this.#preparedHeaders ??= new Headers()
    });
  }
  set res(_res) {
    if (this.#res && _res) {
      _res = new Response(_res.body, _res);
      for (const [k, v] of this.#res.headers.entries()) {
        if (k === "content-type") {
          continue;
        }
        if (k === "set-cookie") {
          const cookies = this.#res.headers.getSetCookie();
          _res.headers.delete("set-cookie");
          for (const cookie of cookies) {
            _res.headers.append("set-cookie", cookie);
          }
        } else {
          _res.headers.set(k, v);
        }
      }
    }
    this.#res = _res;
    this.finalized = true;
  }
  render = /* @__PURE__ */ __name((...args) => {
    this.#renderer ??= (content) => this.html(content);
    return this.#renderer(...args);
  }, "render");
  setLayout = /* @__PURE__ */ __name((layout) => this.#layout = layout, "setLayout");
  getLayout = /* @__PURE__ */ __name(() => this.#layout, "getLayout");
  setRenderer = /* @__PURE__ */ __name((renderer) => {
    this.#renderer = renderer;
  }, "setRenderer");
  header = /* @__PURE__ */ __name((name, value, options) => {
    if (this.finalized) {
      this.#res = new Response(this.#res.body, this.#res);
    }
    const headers = this.#res ? this.#res.headers : this.#preparedHeaders ??= new Headers();
    if (value === void 0) {
      headers.delete(name);
    } else if (options?.append) {
      headers.append(name, value);
    } else {
      headers.set(name, value);
    }
  }, "header");
  status = /* @__PURE__ */ __name((status) => {
    this.#status = status;
  }, "status");
  set = /* @__PURE__ */ __name((key, value) => {
    this.#var ??= /* @__PURE__ */ new Map();
    this.#var.set(key, value);
  }, "set");
  get = /* @__PURE__ */ __name((key) => {
    return this.#var ? this.#var.get(key) : void 0;
  }, "get");
  get var() {
    if (!this.#var) {
      return {};
    }
    return Object.fromEntries(this.#var);
  }
  #newResponse(data, arg, headers) {
    const responseHeaders = this.#res ? new Headers(this.#res.headers) : this.#preparedHeaders ?? new Headers();
    if (typeof arg === "object" && "headers" in arg) {
      const argHeaders = arg.headers instanceof Headers ? arg.headers : new Headers(arg.headers);
      for (const [key, value] of argHeaders) {
        if (key.toLowerCase() === "set-cookie") {
          responseHeaders.append(key, value);
        } else {
          responseHeaders.set(key, value);
        }
      }
    }
    if (headers) {
      for (const [k, v] of Object.entries(headers)) {
        if (typeof v === "string") {
          responseHeaders.set(k, v);
        } else {
          responseHeaders.delete(k);
          for (const v2 of v) {
            responseHeaders.append(k, v2);
          }
        }
      }
    }
    const status = typeof arg === "number" ? arg : arg?.status ?? this.#status;
    return new Response(data, { status, headers: responseHeaders });
  }
  newResponse = /* @__PURE__ */ __name((...args) => this.#newResponse(...args), "newResponse");
  body = /* @__PURE__ */ __name((data, arg, headers) => this.#newResponse(data, arg, headers), "body");
  text = /* @__PURE__ */ __name((text, arg, headers) => {
    return !this.#preparedHeaders && !this.#status && !arg && !headers && !this.finalized ? new Response(text) : this.#newResponse(
      text,
      arg,
      setDefaultContentType(TEXT_PLAIN, headers)
    );
  }, "text");
  json = /* @__PURE__ */ __name((object, arg, headers) => {
    return this.#newResponse(
      JSON.stringify(object),
      arg,
      setDefaultContentType("application/json", headers)
    );
  }, "json");
  html = /* @__PURE__ */ __name((html, arg, headers) => {
    const res = /* @__PURE__ */ __name((html2) => this.#newResponse(html2, arg, setDefaultContentType("text/html; charset=UTF-8", headers)), "res");
    return typeof html === "object" ? resolveCallback(html, HtmlEscapedCallbackPhase.Stringify, false, {}).then(res) : res(html);
  }, "html");
  redirect = /* @__PURE__ */ __name((location, status) => {
    const locationString = String(location);
    this.header(
      "Location",
      !/[^\x00-\xFF]/.test(locationString) ? locationString : encodeURI(locationString)
    );
    return this.newResponse(null, status ?? 302);
  }, "redirect");
  notFound = /* @__PURE__ */ __name(() => {
    this.#notFoundHandler ??= () => new Response();
    return this.#notFoundHandler(this);
  }, "notFound");
};

// node_modules/hono/dist/router.js
var METHOD_NAME_ALL = "ALL";
var METHOD_NAME_ALL_LOWERCASE = "all";
var METHODS = ["get", "post", "put", "delete", "options", "patch"];
var MESSAGE_MATCHER_IS_ALREADY_BUILT = "Can not add a route since the matcher is already built.";
var UnsupportedPathError = class extends Error {
  static {
    __name(this, "UnsupportedPathError");
  }
};

// node_modules/hono/dist/utils/constants.js
var COMPOSED_HANDLER = "__COMPOSED_HANDLER";

// node_modules/hono/dist/hono-base.js
var notFoundHandler = /* @__PURE__ */ __name((c) => {
  return c.text("404 Not Found", 404);
}, "notFoundHandler");
var errorHandler = /* @__PURE__ */ __name((err, c) => {
  if ("getResponse" in err) {
    const res = err.getResponse();
    return c.newResponse(res.body, res);
  }
  console.error(err);
  return c.text("Internal Server Error", 500);
}, "errorHandler");
var Hono = class {
  static {
    __name(this, "Hono");
  }
  get;
  post;
  put;
  delete;
  options;
  patch;
  all;
  on;
  use;
  router;
  getPath;
  _basePath = "/";
  #path = "/";
  routes = [];
  constructor(options = {}) {
    const allMethods = [...METHODS, METHOD_NAME_ALL_LOWERCASE];
    allMethods.forEach((method) => {
      this[method] = (args1, ...args) => {
        if (typeof args1 === "string") {
          this.#path = args1;
        } else {
          this.#addRoute(method, this.#path, args1);
        }
        args.forEach((handler) => {
          this.#addRoute(method, this.#path, handler);
        });
        return this;
      };
    });
    this.on = (method, path, ...handlers) => {
      for (const p of [path].flat()) {
        this.#path = p;
        for (const m of [method].flat()) {
          handlers.map((handler) => {
            this.#addRoute(m.toUpperCase(), this.#path, handler);
          });
        }
      }
      return this;
    };
    this.use = (arg1, ...handlers) => {
      if (typeof arg1 === "string") {
        this.#path = arg1;
      } else {
        this.#path = "*";
        handlers.unshift(arg1);
      }
      handlers.forEach((handler) => {
        this.#addRoute(METHOD_NAME_ALL, this.#path, handler);
      });
      return this;
    };
    const { strict, ...optionsWithoutStrict } = options;
    Object.assign(this, optionsWithoutStrict);
    this.getPath = strict ?? true ? options.getPath ?? getPath : getPathNoStrict;
  }
  #clone() {
    const clone = new Hono({
      router: this.router,
      getPath: this.getPath
    });
    clone.errorHandler = this.errorHandler;
    clone.#notFoundHandler = this.#notFoundHandler;
    clone.routes = this.routes;
    return clone;
  }
  #notFoundHandler = notFoundHandler;
  errorHandler = errorHandler;
  route(path, app2) {
    const subApp = this.basePath(path);
    app2.routes.map((r) => {
      let handler;
      if (app2.errorHandler === errorHandler) {
        handler = r.handler;
      } else {
        handler = /* @__PURE__ */ __name(async (c, next) => (await compose([], app2.errorHandler)(c, () => r.handler(c, next))).res, "handler");
        handler[COMPOSED_HANDLER] = r.handler;
      }
      subApp.#addRoute(r.method, r.path, handler);
    });
    return this;
  }
  basePath(path) {
    const subApp = this.#clone();
    subApp._basePath = mergePath(this._basePath, path);
    return subApp;
  }
  onError = /* @__PURE__ */ __name((handler) => {
    this.errorHandler = handler;
    return this;
  }, "onError");
  notFound = /* @__PURE__ */ __name((handler) => {
    this.#notFoundHandler = handler;
    return this;
  }, "notFound");
  mount(path, applicationHandler, options) {
    let replaceRequest;
    let optionHandler;
    if (options) {
      if (typeof options === "function") {
        optionHandler = options;
      } else {
        optionHandler = options.optionHandler;
        if (options.replaceRequest === false) {
          replaceRequest = /* @__PURE__ */ __name((request) => request, "replaceRequest");
        } else {
          replaceRequest = options.replaceRequest;
        }
      }
    }
    const getOptions = optionHandler ? (c) => {
      const options2 = optionHandler(c);
      return Array.isArray(options2) ? options2 : [options2];
    } : (c) => {
      let executionContext = void 0;
      try {
        executionContext = c.executionCtx;
      } catch {
      }
      return [c.env, executionContext];
    };
    replaceRequest ||= (() => {
      const mergedPath = mergePath(this._basePath, path);
      const pathPrefixLength = mergedPath === "/" ? 0 : mergedPath.length;
      return (request) => {
        const url = new URL(request.url);
        url.pathname = url.pathname.slice(pathPrefixLength) || "/";
        return new Request(url, request);
      };
    })();
    const handler = /* @__PURE__ */ __name(async (c, next) => {
      const res = await applicationHandler(replaceRequest(c.req.raw), ...getOptions(c));
      if (res) {
        return res;
      }
      await next();
    }, "handler");
    this.#addRoute(METHOD_NAME_ALL, mergePath(path, "*"), handler);
    return this;
  }
  #addRoute(method, path, handler) {
    method = method.toUpperCase();
    path = mergePath(this._basePath, path);
    const r = { basePath: this._basePath, path, method, handler };
    this.router.add(method, path, [handler, r]);
    this.routes.push(r);
  }
  #handleError(err, c) {
    if (err instanceof Error) {
      return this.errorHandler(err, c);
    }
    throw err;
  }
  #dispatch(request, executionCtx, env2, method) {
    if (method === "HEAD") {
      return (async () => new Response(null, await this.#dispatch(request, executionCtx, env2, "GET")))();
    }
    const path = this.getPath(request, { env: env2 });
    const matchResult = this.router.match(method, path);
    const c = new Context(request, {
      path,
      matchResult,
      env: env2,
      executionCtx,
      notFoundHandler: this.#notFoundHandler
    });
    if (matchResult[0].length === 1) {
      let res;
      try {
        res = matchResult[0][0][0][0](c, async () => {
          c.res = await this.#notFoundHandler(c);
        });
      } catch (err) {
        return this.#handleError(err, c);
      }
      return res instanceof Promise ? res.then(
        (resolved) => resolved || (c.finalized ? c.res : this.#notFoundHandler(c))
      ).catch((err) => this.#handleError(err, c)) : res ?? this.#notFoundHandler(c);
    }
    const composed = compose(matchResult[0], this.errorHandler, this.#notFoundHandler);
    return (async () => {
      try {
        const context2 = await composed(c);
        if (!context2.finalized) {
          throw new Error(
            "Context is not finalized. Did you forget to return a Response object or `await next()`?"
          );
        }
        return context2.res;
      } catch (err) {
        return this.#handleError(err, c);
      }
    })();
  }
  fetch = /* @__PURE__ */ __name((request, ...rest) => {
    return this.#dispatch(request, rest[1], rest[0], request.method);
  }, "fetch");
  request = /* @__PURE__ */ __name((input, requestInit, Env, executionCtx) => {
    if (input instanceof Request) {
      return this.fetch(requestInit ? new Request(input, requestInit) : input, Env, executionCtx);
    }
    input = input.toString();
    return this.fetch(
      new Request(
        /^https?:\/\//.test(input) ? input : `http://localhost${mergePath("/", input)}`,
        requestInit
      ),
      Env,
      executionCtx
    );
  }, "request");
  fire = /* @__PURE__ */ __name(() => {
    addEventListener("fetch", (event) => {
      event.respondWith(this.#dispatch(event.request, event, void 0, event.request.method));
    });
  }, "fire");
};

// node_modules/hono/dist/router/reg-exp-router/node.js
var LABEL_REG_EXP_STR = "[^/]+";
var ONLY_WILDCARD_REG_EXP_STR = ".*";
var TAIL_WILDCARD_REG_EXP_STR = "(?:|/.*)";
var PATH_ERROR = Symbol();
var regExpMetaChars = new Set(".\\+*[^]$()");
function compareKey(a, b) {
  if (a.length === 1) {
    return b.length === 1 ? a < b ? -1 : 1 : -1;
  }
  if (b.length === 1) {
    return 1;
  }
  if (a === ONLY_WILDCARD_REG_EXP_STR || a === TAIL_WILDCARD_REG_EXP_STR) {
    return 1;
  } else if (b === ONLY_WILDCARD_REG_EXP_STR || b === TAIL_WILDCARD_REG_EXP_STR) {
    return -1;
  }
  if (a === LABEL_REG_EXP_STR) {
    return 1;
  } else if (b === LABEL_REG_EXP_STR) {
    return -1;
  }
  return a.length === b.length ? a < b ? -1 : 1 : b.length - a.length;
}
__name(compareKey, "compareKey");
var Node = class {
  static {
    __name(this, "Node");
  }
  #index;
  #varIndex;
  #children = /* @__PURE__ */ Object.create(null);
  insert(tokens, index, paramMap, context2, pathErrorCheckOnly) {
    if (tokens.length === 0) {
      if (this.#index !== void 0) {
        throw PATH_ERROR;
      }
      if (pathErrorCheckOnly) {
        return;
      }
      this.#index = index;
      return;
    }
    const [token, ...restTokens] = tokens;
    const pattern = token === "*" ? restTokens.length === 0 ? ["", "", ONLY_WILDCARD_REG_EXP_STR] : ["", "", LABEL_REG_EXP_STR] : token === "/*" ? ["", "", TAIL_WILDCARD_REG_EXP_STR] : token.match(/^\:([^\{\}]+)(?:\{(.+)\})?$/);
    let node;
    if (pattern) {
      const name = pattern[1];
      let regexpStr = pattern[2] || LABEL_REG_EXP_STR;
      if (name && pattern[2]) {
        if (regexpStr === ".*") {
          throw PATH_ERROR;
        }
        regexpStr = regexpStr.replace(/^\((?!\?:)(?=[^)]+\)$)/, "(?:");
        if (/\((?!\?:)/.test(regexpStr)) {
          throw PATH_ERROR;
        }
      }
      node = this.#children[regexpStr];
      if (!node) {
        if (Object.keys(this.#children).some(
          (k) => k !== ONLY_WILDCARD_REG_EXP_STR && k !== TAIL_WILDCARD_REG_EXP_STR
        )) {
          throw PATH_ERROR;
        }
        if (pathErrorCheckOnly) {
          return;
        }
        node = this.#children[regexpStr] = new Node();
        if (name !== "") {
          node.#varIndex = context2.varIndex++;
        }
      }
      if (!pathErrorCheckOnly && name !== "") {
        paramMap.push([name, node.#varIndex]);
      }
    } else {
      node = this.#children[token];
      if (!node) {
        if (Object.keys(this.#children).some(
          (k) => k.length > 1 && k !== ONLY_WILDCARD_REG_EXP_STR && k !== TAIL_WILDCARD_REG_EXP_STR
        )) {
          throw PATH_ERROR;
        }
        if (pathErrorCheckOnly) {
          return;
        }
        node = this.#children[token] = new Node();
      }
    }
    node.insert(restTokens, index, paramMap, context2, pathErrorCheckOnly);
  }
  buildRegExpStr() {
    const childKeys = Object.keys(this.#children).sort(compareKey);
    const strList = childKeys.map((k) => {
      const c = this.#children[k];
      return (typeof c.#varIndex === "number" ? `(${k})@${c.#varIndex}` : regExpMetaChars.has(k) ? `\\${k}` : k) + c.buildRegExpStr();
    });
    if (typeof this.#index === "number") {
      strList.unshift(`#${this.#index}`);
    }
    if (strList.length === 0) {
      return "";
    }
    if (strList.length === 1) {
      return strList[0];
    }
    return "(?:" + strList.join("|") + ")";
  }
};

// node_modules/hono/dist/router/reg-exp-router/trie.js
var Trie = class {
  static {
    __name(this, "Trie");
  }
  #context = { varIndex: 0 };
  #root = new Node();
  insert(path, index, pathErrorCheckOnly) {
    const paramAssoc = [];
    const groups = [];
    for (let i = 0; ; ) {
      let replaced = false;
      path = path.replace(/\{[^}]+\}/g, (m) => {
        const mark = `@\\${i}`;
        groups[i] = [mark, m];
        i++;
        replaced = true;
        return mark;
      });
      if (!replaced) {
        break;
      }
    }
    const tokens = path.match(/(?::[^\/]+)|(?:\/\*$)|./g) || [];
    for (let i = groups.length - 1; i >= 0; i--) {
      const [mark] = groups[i];
      for (let j = tokens.length - 1; j >= 0; j--) {
        if (tokens[j].indexOf(mark) !== -1) {
          tokens[j] = tokens[j].replace(mark, groups[i][1]);
          break;
        }
      }
    }
    this.#root.insert(tokens, index, paramAssoc, this.#context, pathErrorCheckOnly);
    return paramAssoc;
  }
  buildRegExp() {
    let regexp = this.#root.buildRegExpStr();
    if (regexp === "") {
      return [/^$/, [], []];
    }
    let captureIndex = 0;
    const indexReplacementMap = [];
    const paramReplacementMap = [];
    regexp = regexp.replace(/#(\d+)|@(\d+)|\.\*\$/g, (_, handlerIndex, paramIndex) => {
      if (handlerIndex !== void 0) {
        indexReplacementMap[++captureIndex] = Number(handlerIndex);
        return "$()";
      }
      if (paramIndex !== void 0) {
        paramReplacementMap[Number(paramIndex)] = ++captureIndex;
        return "";
      }
      return "";
    });
    return [new RegExp(`^${regexp}`), indexReplacementMap, paramReplacementMap];
  }
};

// node_modules/hono/dist/router/reg-exp-router/router.js
var emptyParam = [];
var nullMatcher = [/^$/, [], /* @__PURE__ */ Object.create(null)];
var wildcardRegExpCache = /* @__PURE__ */ Object.create(null);
function buildWildcardRegExp(path) {
  return wildcardRegExpCache[path] ??= new RegExp(
    path === "*" ? "" : `^${path.replace(
      /\/\*$|([.\\+*[^\]$()])/g,
      (_, metaChar) => metaChar ? `\\${metaChar}` : "(?:|/.*)"
    )}$`
  );
}
__name(buildWildcardRegExp, "buildWildcardRegExp");
function clearWildcardRegExpCache() {
  wildcardRegExpCache = /* @__PURE__ */ Object.create(null);
}
__name(clearWildcardRegExpCache, "clearWildcardRegExpCache");
function buildMatcherFromPreprocessedRoutes(routes) {
  const trie = new Trie();
  const handlerData = [];
  if (routes.length === 0) {
    return nullMatcher;
  }
  const routesWithStaticPathFlag = routes.map(
    (route) => [!/\*|\/:/.test(route[0]), ...route]
  ).sort(
    ([isStaticA, pathA], [isStaticB, pathB]) => isStaticA ? 1 : isStaticB ? -1 : pathA.length - pathB.length
  );
  const staticMap = /* @__PURE__ */ Object.create(null);
  for (let i = 0, j = -1, len = routesWithStaticPathFlag.length; i < len; i++) {
    const [pathErrorCheckOnly, path, handlers] = routesWithStaticPathFlag[i];
    if (pathErrorCheckOnly) {
      staticMap[path] = [handlers.map(([h]) => [h, /* @__PURE__ */ Object.create(null)]), emptyParam];
    } else {
      j++;
    }
    let paramAssoc;
    try {
      paramAssoc = trie.insert(path, j, pathErrorCheckOnly);
    } catch (e) {
      throw e === PATH_ERROR ? new UnsupportedPathError(path) : e;
    }
    if (pathErrorCheckOnly) {
      continue;
    }
    handlerData[j] = handlers.map(([h, paramCount]) => {
      const paramIndexMap = /* @__PURE__ */ Object.create(null);
      paramCount -= 1;
      for (; paramCount >= 0; paramCount--) {
        const [key, value] = paramAssoc[paramCount];
        paramIndexMap[key] = value;
      }
      return [h, paramIndexMap];
    });
  }
  const [regexp, indexReplacementMap, paramReplacementMap] = trie.buildRegExp();
  for (let i = 0, len = handlerData.length; i < len; i++) {
    for (let j = 0, len2 = handlerData[i].length; j < len2; j++) {
      const map = handlerData[i][j]?.[1];
      if (!map) {
        continue;
      }
      const keys = Object.keys(map);
      for (let k = 0, len3 = keys.length; k < len3; k++) {
        map[keys[k]] = paramReplacementMap[map[keys[k]]];
      }
    }
  }
  const handlerMap = [];
  for (const i in indexReplacementMap) {
    handlerMap[i] = handlerData[indexReplacementMap[i]];
  }
  return [regexp, handlerMap, staticMap];
}
__name(buildMatcherFromPreprocessedRoutes, "buildMatcherFromPreprocessedRoutes");
function findMiddleware(middleware, path) {
  if (!middleware) {
    return void 0;
  }
  for (const k of Object.keys(middleware).sort((a, b) => b.length - a.length)) {
    if (buildWildcardRegExp(k).test(path)) {
      return [...middleware[k]];
    }
  }
  return void 0;
}
__name(findMiddleware, "findMiddleware");
var RegExpRouter = class {
  static {
    __name(this, "RegExpRouter");
  }
  name = "RegExpRouter";
  #middleware;
  #routes;
  constructor() {
    this.#middleware = { [METHOD_NAME_ALL]: /* @__PURE__ */ Object.create(null) };
    this.#routes = { [METHOD_NAME_ALL]: /* @__PURE__ */ Object.create(null) };
  }
  add(method, path, handler) {
    const middleware = this.#middleware;
    const routes = this.#routes;
    if (!middleware || !routes) {
      throw new Error(MESSAGE_MATCHER_IS_ALREADY_BUILT);
    }
    if (!middleware[method]) {
      ;
      [middleware, routes].forEach((handlerMap) => {
        handlerMap[method] = /* @__PURE__ */ Object.create(null);
        Object.keys(handlerMap[METHOD_NAME_ALL]).forEach((p) => {
          handlerMap[method][p] = [...handlerMap[METHOD_NAME_ALL][p]];
        });
      });
    }
    if (path === "/*") {
      path = "*";
    }
    const paramCount = (path.match(/\/:/g) || []).length;
    if (/\*$/.test(path)) {
      const re = buildWildcardRegExp(path);
      if (method === METHOD_NAME_ALL) {
        Object.keys(middleware).forEach((m) => {
          middleware[m][path] ||= findMiddleware(middleware[m], path) || findMiddleware(middleware[METHOD_NAME_ALL], path) || [];
        });
      } else {
        middleware[method][path] ||= findMiddleware(middleware[method], path) || findMiddleware(middleware[METHOD_NAME_ALL], path) || [];
      }
      Object.keys(middleware).forEach((m) => {
        if (method === METHOD_NAME_ALL || method === m) {
          Object.keys(middleware[m]).forEach((p) => {
            re.test(p) && middleware[m][p].push([handler, paramCount]);
          });
        }
      });
      Object.keys(routes).forEach((m) => {
        if (method === METHOD_NAME_ALL || method === m) {
          Object.keys(routes[m]).forEach(
            (p) => re.test(p) && routes[m][p].push([handler, paramCount])
          );
        }
      });
      return;
    }
    const paths = checkOptionalParameter(path) || [path];
    for (let i = 0, len = paths.length; i < len; i++) {
      const path2 = paths[i];
      Object.keys(routes).forEach((m) => {
        if (method === METHOD_NAME_ALL || method === m) {
          routes[m][path2] ||= [
            ...findMiddleware(middleware[m], path2) || findMiddleware(middleware[METHOD_NAME_ALL], path2) || []
          ];
          routes[m][path2].push([handler, paramCount - len + i + 1]);
        }
      });
    }
  }
  match(method, path) {
    clearWildcardRegExpCache();
    const matchers = this.#buildAllMatchers();
    this.match = (method2, path2) => {
      const matcher = matchers[method2] || matchers[METHOD_NAME_ALL];
      const staticMatch = matcher[2][path2];
      if (staticMatch) {
        return staticMatch;
      }
      const match = path2.match(matcher[0]);
      if (!match) {
        return [[], emptyParam];
      }
      const index = match.indexOf("", 1);
      return [matcher[1][index], match];
    };
    return this.match(method, path);
  }
  #buildAllMatchers() {
    const matchers = /* @__PURE__ */ Object.create(null);
    Object.keys(this.#routes).concat(Object.keys(this.#middleware)).forEach((method) => {
      matchers[method] ||= this.#buildMatcher(method);
    });
    this.#middleware = this.#routes = void 0;
    return matchers;
  }
  #buildMatcher(method) {
    const routes = [];
    let hasOwnRoute = method === METHOD_NAME_ALL;
    [this.#middleware, this.#routes].forEach((r) => {
      const ownRoute = r[method] ? Object.keys(r[method]).map((path) => [path, r[method][path]]) : [];
      if (ownRoute.length !== 0) {
        hasOwnRoute ||= true;
        routes.push(...ownRoute);
      } else if (method !== METHOD_NAME_ALL) {
        routes.push(
          ...Object.keys(r[METHOD_NAME_ALL]).map((path) => [path, r[METHOD_NAME_ALL][path]])
        );
      }
    });
    if (!hasOwnRoute) {
      return null;
    } else {
      return buildMatcherFromPreprocessedRoutes(routes);
    }
  }
};

// node_modules/hono/dist/router/smart-router/router.js
var SmartRouter = class {
  static {
    __name(this, "SmartRouter");
  }
  name = "SmartRouter";
  #routers = [];
  #routes = [];
  constructor(init) {
    this.#routers = init.routers;
  }
  add(method, path, handler) {
    if (!this.#routes) {
      throw new Error(MESSAGE_MATCHER_IS_ALREADY_BUILT);
    }
    this.#routes.push([method, path, handler]);
  }
  match(method, path) {
    if (!this.#routes) {
      throw new Error("Fatal error");
    }
    const routers = this.#routers;
    const routes = this.#routes;
    const len = routers.length;
    let i = 0;
    let res;
    for (; i < len; i++) {
      const router = routers[i];
      try {
        for (let i2 = 0, len2 = routes.length; i2 < len2; i2++) {
          router.add(...routes[i2]);
        }
        res = router.match(method, path);
      } catch (e) {
        if (e instanceof UnsupportedPathError) {
          continue;
        }
        throw e;
      }
      this.match = router.match.bind(router);
      this.#routers = [router];
      this.#routes = void 0;
      break;
    }
    if (i === len) {
      throw new Error("Fatal error");
    }
    this.name = `SmartRouter + ${this.activeRouter.name}`;
    return res;
  }
  get activeRouter() {
    if (this.#routes || this.#routers.length !== 1) {
      throw new Error("No active router has been determined yet.");
    }
    return this.#routers[0];
  }
};

// node_modules/hono/dist/router/trie-router/node.js
var emptyParams = /* @__PURE__ */ Object.create(null);
var Node2 = class {
  static {
    __name(this, "Node");
  }
  #methods;
  #children;
  #patterns;
  #order = 0;
  #params = emptyParams;
  constructor(method, handler, children) {
    this.#children = children || /* @__PURE__ */ Object.create(null);
    this.#methods = [];
    if (method && handler) {
      const m = /* @__PURE__ */ Object.create(null);
      m[method] = { handler, possibleKeys: [], score: 0 };
      this.#methods = [m];
    }
    this.#patterns = [];
  }
  insert(method, path, handler) {
    this.#order = ++this.#order;
    let curNode = this;
    const parts = splitRoutingPath(path);
    const possibleKeys = [];
    for (let i = 0, len = parts.length; i < len; i++) {
      const p = parts[i];
      const nextP = parts[i + 1];
      const pattern = getPattern(p, nextP);
      const key = Array.isArray(pattern) ? pattern[0] : p;
      if (key in curNode.#children) {
        curNode = curNode.#children[key];
        if (pattern) {
          possibleKeys.push(pattern[1]);
        }
        continue;
      }
      curNode.#children[key] = new Node2();
      if (pattern) {
        curNode.#patterns.push(pattern);
        possibleKeys.push(pattern[1]);
      }
      curNode = curNode.#children[key];
    }
    curNode.#methods.push({
      [method]: {
        handler,
        possibleKeys: possibleKeys.filter((v, i, a) => a.indexOf(v) === i),
        score: this.#order
      }
    });
    return curNode;
  }
  #getHandlerSets(node, method, nodeParams, params) {
    const handlerSets = [];
    for (let i = 0, len = node.#methods.length; i < len; i++) {
      const m = node.#methods[i];
      const handlerSet = m[method] || m[METHOD_NAME_ALL];
      const processedSet = {};
      if (handlerSet !== void 0) {
        handlerSet.params = /* @__PURE__ */ Object.create(null);
        handlerSets.push(handlerSet);
        if (nodeParams !== emptyParams || params && params !== emptyParams) {
          for (let i2 = 0, len2 = handlerSet.possibleKeys.length; i2 < len2; i2++) {
            const key = handlerSet.possibleKeys[i2];
            const processed = processedSet[handlerSet.score];
            handlerSet.params[key] = params?.[key] && !processed ? params[key] : nodeParams[key] ?? params?.[key];
            processedSet[handlerSet.score] = true;
          }
        }
      }
    }
    return handlerSets;
  }
  search(method, path) {
    const handlerSets = [];
    this.#params = emptyParams;
    const curNode = this;
    let curNodes = [curNode];
    const parts = splitPath(path);
    const curNodesQueue = [];
    for (let i = 0, len = parts.length; i < len; i++) {
      const part = parts[i];
      const isLast = i === len - 1;
      const tempNodes = [];
      for (let j = 0, len2 = curNodes.length; j < len2; j++) {
        const node = curNodes[j];
        const nextNode = node.#children[part];
        if (nextNode) {
          nextNode.#params = node.#params;
          if (isLast) {
            if (nextNode.#children["*"]) {
              handlerSets.push(
                ...this.#getHandlerSets(nextNode.#children["*"], method, node.#params)
              );
            }
            handlerSets.push(...this.#getHandlerSets(nextNode, method, node.#params));
          } else {
            tempNodes.push(nextNode);
          }
        }
        for (let k = 0, len3 = node.#patterns.length; k < len3; k++) {
          const pattern = node.#patterns[k];
          const params = node.#params === emptyParams ? {} : { ...node.#params };
          if (pattern === "*") {
            const astNode = node.#children["*"];
            if (astNode) {
              handlerSets.push(...this.#getHandlerSets(astNode, method, node.#params));
              astNode.#params = params;
              tempNodes.push(astNode);
            }
            continue;
          }
          const [key, name, matcher] = pattern;
          if (!part && !(matcher instanceof RegExp)) {
            continue;
          }
          const child = node.#children[key];
          const restPathString = parts.slice(i).join("/");
          if (matcher instanceof RegExp) {
            const m = matcher.exec(restPathString);
            if (m) {
              params[name] = m[0];
              handlerSets.push(...this.#getHandlerSets(child, method, node.#params, params));
              if (Object.keys(child.#children).length) {
                child.#params = params;
                const componentCount = m[0].match(/\//)?.length ?? 0;
                const targetCurNodes = curNodesQueue[componentCount] ||= [];
                targetCurNodes.push(child);
              }
              continue;
            }
          }
          if (matcher === true || matcher.test(part)) {
            params[name] = part;
            if (isLast) {
              handlerSets.push(...this.#getHandlerSets(child, method, params, node.#params));
              if (child.#children["*"]) {
                handlerSets.push(
                  ...this.#getHandlerSets(child.#children["*"], method, params, node.#params)
                );
              }
            } else {
              child.#params = params;
              tempNodes.push(child);
            }
          }
        }
      }
      curNodes = tempNodes.concat(curNodesQueue.shift() ?? []);
    }
    if (handlerSets.length > 1) {
      handlerSets.sort((a, b) => {
        return a.score - b.score;
      });
    }
    return [handlerSets.map(({ handler, params }) => [handler, params])];
  }
};

// node_modules/hono/dist/router/trie-router/router.js
var TrieRouter = class {
  static {
    __name(this, "TrieRouter");
  }
  name = "TrieRouter";
  #node;
  constructor() {
    this.#node = new Node2();
  }
  add(method, path, handler) {
    const results = checkOptionalParameter(path);
    if (results) {
      for (let i = 0, len = results.length; i < len; i++) {
        this.#node.insert(method, results[i], handler);
      }
      return;
    }
    this.#node.insert(method, path, handler);
  }
  match(method, path) {
    return this.#node.search(method, path);
  }
};

// node_modules/hono/dist/hono.js
var Hono2 = class extends Hono {
  static {
    __name(this, "Hono");
  }
  constructor(options = {}) {
    super(options);
    this.router = options.router ?? new SmartRouter({
      routers: [new RegExpRouter(), new TrieRouter()]
    });
  }
};

// src/models.ts
var geminiCliModels = {
  "gemini-3-pro-preview": {
    maxTokens: 65536,
    contextWindow: 1048576,
    supportsImages: true,
    supportsPromptCache: false,
    inputPrice: 0,
    outputPrice: 0,
    description: "Google's Gemini 3.0 Pro Preview model via OAuth (free tier)",
    thinking: true
  },
  "gemini-3-flash-preview": {
    maxTokens: 65536,
    contextWindow: 1048576,
    supportsImages: true,
    supportsPromptCache: false,
    inputPrice: 0,
    outputPrice: 0,
    description: "Google's Gemini 3.0 Flash Preview model via OAuth (free tier)",
    thinking: true
  },
  "gemini-2.5-pro": {
    maxTokens: 65536,
    contextWindow: 1048576,
    supportsImages: true,
    supportsPromptCache: false,
    inputPrice: 0,
    outputPrice: 0,
    description: "Google's Gemini 2.5 Pro model via OAuth (free tier)",
    thinking: true
  },
  "gemini-2.5-flash": {
    maxTokens: 65536,
    contextWindow: 1048576,
    supportsImages: true,
    supportsPromptCache: false,
    inputPrice: 0,
    outputPrice: 0,
    description: "Google's Gemini 2.5 Flash model via OAuth (free tier)",
    thinking: true
  },
  "gemini-2.5-flash-lite": {
    maxTokens: 65536,
    contextWindow: 1048576,
    supportsImages: true,
    supportsPromptCache: false,
    inputPrice: 0,
    outputPrice: 0,
    description: "Google's Gemini 2.5 Flash Lite model via OAuth (free tier)",
    thinking: true
  }
};
var DEFAULT_MODEL = "gemini-3-flash-preview";
function getAllModelIds() {
  return Object.keys(geminiCliModels);
}
__name(getAllModelIds, "getAllModelIds");

// src/config.ts
var CODE_ASSIST_ENDPOINT = "https://cloudcode-pa.googleapis.com";
var CODE_ASSIST_API_VERSION = "v1internal";
var OAUTH_CLIENT_ID = "681255809395-oo8ft2oprdrnp9e3aqf6av3hmdib135j.apps.googleusercontent.com";
var OAUTH_CLIENT_SECRET = "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";
var OAUTH_REFRESH_URL = "https://oauth2.googleapis.com/token";
var TOKEN_BUFFER_TIME = 5 * 60 * 1e3;
var KV_TOKEN_KEY = "oauth_token_cache";
var OPENAI_CHAT_COMPLETION_OBJECT = "chat.completion.chunk";
var OPENAI_MODEL_OWNER = "google-gemini-cli";

// src/constants.ts
var REASONING_MESSAGES = [
  '\u{1F50D} **Analyzing the request: "{requestPreview}"**\n\n',
  "\u{1F914} Let me think about this step by step... ",
  "\u{1F4AD} I need to consider the context and provide a comprehensive response. ",
  "\u{1F3AF} Based on my understanding, I should address the key points while being accurate and helpful. ",
  "\u2728 Let me formulate a clear and structured answer.\n\n"
];
var REASONING_CHUNK_DELAY = 100;
var THINKING_CONTENT_CHUNK_SIZE = 15;
var DEFAULT_THINKING_BUDGET = -1;
var DEFAULT_TEMPERATURE = 0.7;
var AUTO_SWITCH_MODEL_MAP = {
  "gemini-2.5-pro": "gemini-2.5-flash",
  "gemini-3-pro-preview": "gemini-3-flash-preview"
};
var RATE_LIMIT_STATUS_CODES = [429, 503];
var REASONING_EFFORT_BUDGETS = {
  none: 0,
  low: 1024,
  medium: {
    flash: 12288,
    default: 16384
  },
  high: {
    flash: 24576,
    default: 32768
  }
};
var GEMINI_SAFETY_CATEGORIES = {
  HARASSMENT: "HARM_CATEGORY_HARASSMENT",
  HATE_SPEECH: "HARM_CATEGORY_HATE_SPEECH",
  SEXUALLY_EXPLICIT: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
  DANGEROUS_CONTENT: "HARM_CATEGORY_DANGEROUS_CONTENT"
};
var NATIVE_TOOLS_DEFAULTS = {
  ENABLE_GEMINI_NATIVE_TOOLS: false,
  ENABLE_GOOGLE_SEARCH: false,
  ENABLE_URL_CONTEXT: false,
  GEMINI_TOOLS_PRIORITY: "native_first",
  DEFAULT_TO_NATIVE_TOOLS: true,
  ALLOW_REQUEST_TOOL_CONTROL: true,
  ENABLE_INLINE_CITATIONS: false,
  INCLUDE_GROUNDING_METADATA: true,
  INCLUDE_SEARCH_ENTRY_POINT: false
};

// src/auth.ts
var AuthManager = class {
  static {
    __name(this, "AuthManager");
  }
  env;
  accessToken = null;
  constructor(env2) {
    this.env = env2;
  }
  /**
   * Initializes authentication using OAuth2 credentials with KV storage caching.
   */
  async initializeAuth() {
    if (!this.env.GCP_SERVICE_ACCOUNT) {
      throw new Error("`GCP_SERVICE_ACCOUNT` environment variable not set. Please provide OAuth2 credentials JSON.");
    }
    try {
      let cachedTokenData = null;
      try {
        const cachedToken = await this.env.GEMINI_CLI_KV.get(KV_TOKEN_KEY, "json");
        if (cachedToken) {
          cachedTokenData = cachedToken;
          console.log("Found cached token in KV storage");
        }
      } catch (kvError) {
        console.log("No cached token found in KV storage or KV error:", kvError);
      }
      if (cachedTokenData) {
        const timeUntilExpiry2 = cachedTokenData.expiry_date - Date.now();
        if (timeUntilExpiry2 > TOKEN_BUFFER_TIME) {
          this.accessToken = cachedTokenData.access_token;
          console.log(`Using cached token, valid for ${Math.floor(timeUntilExpiry2 / 1e3)} more seconds`);
          return;
        }
        console.log("Cached token expired or expiring soon");
      }
      const oauth2Creds = JSON.parse(this.env.GCP_SERVICE_ACCOUNT);
      const timeUntilExpiry = oauth2Creds.expiry_date - Date.now();
      if (timeUntilExpiry > TOKEN_BUFFER_TIME) {
        this.accessToken = oauth2Creds.access_token;
        console.log(`Original token is valid for ${Math.floor(timeUntilExpiry / 1e3)} more seconds`);
        await this.cacheTokenInKV(oauth2Creds.access_token, oauth2Creds.expiry_date);
        return;
      }
      console.log("All tokens expired, refreshing...");
      await this.refreshAndCacheToken(oauth2Creds.refresh_token);
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : String(e);
      console.error("Failed to initialize authentication:", e);
      throw new Error("Authentication failed: " + errorMessage);
    }
  }
  /**
   * Refresh the OAuth token and cache it in KV storage.
   */
  async refreshAndCacheToken(refreshToken) {
    console.log("Refreshing OAuth token...");
    const refreshResponse = await fetch(OAUTH_REFRESH_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        client_id: OAUTH_CLIENT_ID,
        client_secret: OAUTH_CLIENT_SECRET,
        refresh_token: refreshToken,
        grant_type: "refresh_token"
      })
    });
    if (!refreshResponse.ok) {
      const errorText = await refreshResponse.text();
      console.error("Token refresh failed:", errorText);
      throw new Error(`Token refresh failed: ${errorText}`);
    }
    const refreshData = await refreshResponse.json();
    this.accessToken = refreshData.access_token;
    const expiryTime = Date.now() + refreshData.expires_in * 1e3;
    console.log("Token refreshed successfully");
    console.log(`New token expires in ${refreshData.expires_in} seconds`);
    await this.cacheTokenInKV(refreshData.access_token, expiryTime);
  }
  /**
   * Cache the access token in KV storage.
   */
  async cacheTokenInKV(accessToken, expiryDate) {
    try {
      const tokenData = {
        access_token: accessToken,
        expiry_date: expiryDate,
        cached_at: Date.now()
      };
      const ttlSeconds = Math.floor((expiryDate - Date.now()) / 1e3) - 300;
      if (ttlSeconds > 0) {
        await this.env.GEMINI_CLI_KV.put(KV_TOKEN_KEY, JSON.stringify(tokenData), {
          expirationTtl: ttlSeconds
        });
        console.log(`Token cached in KV storage with TTL of ${ttlSeconds} seconds`);
      } else {
        console.log("Token expires too soon, not caching in KV");
      }
    } catch (kvError) {
      console.error("Failed to cache token in KV storage:", kvError);
    }
  }
  /**
   * Clear cached token from KV storage.
   */
  async clearTokenCache() {
    try {
      await this.env.GEMINI_CLI_KV.delete(KV_TOKEN_KEY);
      console.log("Cleared cached token from KV storage");
    } catch (kvError) {
      console.log("Error clearing KV cache:", kvError);
    }
  }
  /**
   * Get cached token info from KV storage.
   */
  async getCachedTokenInfo() {
    try {
      const cachedToken = await this.env.GEMINI_CLI_KV.get(KV_TOKEN_KEY, "json");
      if (cachedToken) {
        const tokenData = cachedToken;
        const timeUntilExpiry = tokenData.expiry_date - Date.now();
        return {
          cached: true,
          cached_at: new Date(tokenData.cached_at).toISOString(),
          expires_at: new Date(tokenData.expiry_date).toISOString(),
          time_until_expiry_seconds: Math.floor(timeUntilExpiry / 1e3),
          is_expired: timeUntilExpiry < 0
          // Removed token_preview for security
        };
      }
      return { cached: false, message: "No token found in cache" };
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : String(e);
      return { cached: false, error: errorMessage };
    }
  }
  /**
   * A generic method to call a Code Assist API endpoint.
   */
  async callEndpoint(method, body, isRetry = false) {
    await this.initializeAuth();
    const response = await fetch(`${CODE_ASSIST_ENDPOINT}/${CODE_ASSIST_API_VERSION}:${method}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.accessToken}`
      },
      body: JSON.stringify(body)
    });
    if (!response.ok) {
      if (response.status === 401 && !isRetry) {
        console.log("Got 401 error, clearing token cache and retrying...");
        this.accessToken = null;
        await this.clearTokenCache();
        await this.initializeAuth();
        return this.callEndpoint(method, body, true);
      }
      const errorText = await response.text();
      throw new Error(`API call failed with status ${response.status}: ${errorText}`);
    }
    return response.json();
  }
  /**
   * Get the current access token.
   */
  getAccessToken() {
    return this.accessToken;
  }
};

// src/utils/image-utils.ts
function validateImageUrl(imageUrl) {
  if (!imageUrl) {
    return { isValid: false, error: "Image URL is required" };
  }
  if (imageUrl.startsWith("data:image/")) {
    const [mimeTypePart, base64Part] = imageUrl.split(",");
    if (!base64Part) {
      return { isValid: false, error: "Invalid base64 image format" };
    }
    const mimeType = mimeTypePart.split(":")[1].split(";")[0];
    const format = mimeType.split("/")[1];
    const supportedFormats = ["jpeg", "jpg", "png", "gif", "webp"];
    if (!supportedFormats.includes(format.toLowerCase())) {
      return {
        isValid: false,
        error: `Unsupported image format: ${format}. Supported formats: ${supportedFormats.join(", ")}`
      };
    }
    try {
      atob(base64Part.substring(0, 100));
    } catch {
      return { isValid: false, error: "Invalid base64 encoding" };
    }
    return { isValid: true, mimeType, format };
  }
  if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
    try {
      new URL(imageUrl);
      return { isValid: true, mimeType: "image/jpeg" };
    } catch {
      return { isValid: false, error: "Invalid URL format" };
    }
  }
  return { isValid: false, error: "Image URL must be a base64 data URL or HTTP/HTTPS URL" };
}
__name(validateImageUrl, "validateImageUrl");

// src/helpers/generation-config-validator.ts
var GenerationConfigValidator = class {
  static {
    __name(this, "GenerationConfigValidator");
  }
  /**
   * Maps reasoning effort to thinking budget based on model type.
   * @param effort - The reasoning effort level
   * @param modelId - The model ID to determine if it's a flash model
   * @returns The corresponding thinking budget
   */
  static mapEffortToThinkingBudget(effort, modelId) {
    const isFlashModel = modelId.includes("flash");
    switch (effort) {
      case "none":
        return REASONING_EFFORT_BUDGETS.none;
      case "low":
        return REASONING_EFFORT_BUDGETS.low;
      case "medium":
        return isFlashModel ? REASONING_EFFORT_BUDGETS.medium.flash : REASONING_EFFORT_BUDGETS.medium.default;
      case "high":
        return isFlashModel ? REASONING_EFFORT_BUDGETS.high.flash : REASONING_EFFORT_BUDGETS.high.default;
      default:
        return DEFAULT_THINKING_BUDGET;
    }
  }
  /**
   * Type guard to check if a value is a valid EffortLevel.
   * @param value - The value to check
   * @returns True if the value is a valid EffortLevel
   */
  static isValidEffortLevel(value) {
    return typeof value === "string" && ["none", "low", "medium", "high"].includes(value);
  }
  /**
   * Creates safety settings configuration for Gemini API.
   * @param env - Environment variables containing safety thresholds
   * @returns Safety settings configuration
   */
  static createSafetySettings(env2) {
    const safetySettings = [];
    if (env2.GEMINI_MODERATION_HARASSMENT_THRESHOLD) {
      safetySettings.push({
        category: GEMINI_SAFETY_CATEGORIES.HARASSMENT,
        threshold: env2.GEMINI_MODERATION_HARASSMENT_THRESHOLD
      });
    }
    if (env2.GEMINI_MODERATION_HATE_SPEECH_THRESHOLD) {
      safetySettings.push({
        category: GEMINI_SAFETY_CATEGORIES.HATE_SPEECH,
        threshold: env2.GEMINI_MODERATION_HATE_SPEECH_THRESHOLD
      });
    }
    if (env2.GEMINI_MODERATION_SEXUALLY_EXPLICIT_THRESHOLD) {
      safetySettings.push({
        category: GEMINI_SAFETY_CATEGORIES.SEXUALLY_EXPLICIT,
        threshold: env2.GEMINI_MODERATION_SEXUALLY_EXPLICIT_THRESHOLD
      });
    }
    if (env2.GEMINI_MODERATION_DANGEROUS_CONTENT_THRESHOLD) {
      safetySettings.push({
        category: GEMINI_SAFETY_CATEGORIES.DANGEROUS_CONTENT,
        threshold: env2.GEMINI_MODERATION_DANGEROUS_CONTENT_THRESHOLD
      });
    }
    return safetySettings;
  }
  /**
   * Validates and corrects the thinking budget for a specific model.
   * @param modelId - The Gemini model ID
   * @param thinkingBudget - The requested thinking budget
   * @returns The corrected thinking budget
   */
  static validateThinkingBudget(modelId, thinkingBudget) {
    const modelInfo = geminiCliModels[modelId];
    if (modelInfo?.thinking) {
      if (thinkingBudget === 0) {
        console.log(`[GenerationConfig] Model '${modelId}' doesn't support thinking_budget: 0, using -1 instead`);
        return DEFAULT_THINKING_BUDGET;
      }
      if (thinkingBudget < -1) {
        console.log(
          `[GenerationConfig] Invalid thinking_budget: ${thinkingBudget} for model '${modelId}', using -1 instead`
        );
        return DEFAULT_THINKING_BUDGET;
      }
    }
    return thinkingBudget;
  }
  /**
   * Creates a validated generation config for a specific model.
   * @param modelId - The Gemini model ID
   * @param options - Generation options including thinking budget and OpenAI parameters
   * @param isRealThinkingEnabled - Whether real thinking is enabled
   * @param includeReasoning - Whether to include reasoning in response
   * @param env - Environment variables for safety settings
   * @returns Validated generation configuration
   */
  static createValidatedConfig(modelId, options = {}, isRealThinkingEnabled, includeReasoning) {
    const generationConfig = {
      temperature: options.temperature ?? DEFAULT_TEMPERATURE,
      maxOutputTokens: options.max_tokens,
      topP: options.top_p,
      stopSequences: typeof options.stop === "string" ? [options.stop] : options.stop,
      presencePenalty: options.presence_penalty,
      frequencyPenalty: options.frequency_penalty,
      seed: options.seed
    };
    if (options.response_format?.type === "json_object") {
      generationConfig.responseMimeType = "application/json";
    }
    const modelInfo = geminiCliModels[modelId];
    const isThinkingModel = modelInfo?.thinking || false;
    if (isThinkingModel) {
      let thinkingBudget = options.thinking_budget ?? DEFAULT_THINKING_BUDGET;
      const reasoning_effort = options.reasoning_effort || options.extra_body?.reasoning_effort || options.model_params?.reasoning_effort;
      if (reasoning_effort && this.isValidEffortLevel(reasoning_effort)) {
        thinkingBudget = this.mapEffortToThinkingBudget(reasoning_effort, modelId);
        if (reasoning_effort === "none") {
          includeReasoning = false;
        } else {
          includeReasoning = true;
        }
      }
      const validatedBudget = this.validateThinkingBudget(modelId, thinkingBudget);
      if (isRealThinkingEnabled && includeReasoning) {
        generationConfig.thinkingConfig = {
          thinkingBudget: validatedBudget,
          includeThoughts: true
          // Critical: This enables thinking content in response
        };
        console.log(`[GenerationConfig] Real thinking enabled for '${modelId}' with budget: ${validatedBudget}`);
      } else {
        generationConfig.thinkingConfig = {
          thinkingBudget: this.validateThinkingBudget(modelId, DEFAULT_THINKING_BUDGET),
          includeThoughts: false
          // Disable thinking visibility in response
        };
      }
    }
    Object.keys(generationConfig).forEach((key) => generationConfig[key] === void 0 && delete generationConfig[key]);
    return generationConfig;
  }
  static createValidateTools(options = {}) {
    const tools = [];
    let toolConfig = {};
    if (Array.isArray(options.tools) && options.tools.length > 0) {
      const functionDeclarations = options.tools.map((tool) => {
        let parameters = tool.function.parameters;
        if (parameters) {
          const before = parameters;
          parameters = Object.keys(parameters).filter((key) => !key.startsWith("$")).reduce(
            (after, key) => {
              after[key] = before[key];
              return after;
            },
            {}
          );
        }
        return {
          name: tool.function.name,
          description: tool.function.description,
          parameters
        };
      });
      tools.push({ functionDeclarations });
      if (options.tool_choice) {
        if (options.tool_choice === "auto") {
          toolConfig = { functionCallingConfig: { mode: "AUTO" } };
        } else if (options.tool_choice === "none") {
          toolConfig = { functionCallingConfig: { mode: "NONE" } };
        } else if (typeof options.tool_choice === "object" && options.tool_choice.function) {
          toolConfig = {
            functionCallingConfig: {
              mode: "ANY",
              allowedFunctionNames: [options.tool_choice.function.name]
            }
          };
        }
      }
    }
    return { tools, toolConfig };
  }
  static createFinalToolConfiguration(config2, options = {}) {
    if (config2.useCustomTools && config2.customTools && config2.customTools.length > 0) {
      const { toolConfig } = this.createValidateTools(options);
      return {
        tools: [
          {
            functionDeclarations: config2.customTools.map((t) => t.function)
          }
        ],
        toolConfig
      };
    }
    if (config2.useNativeTools && config2.nativeTools && config2.nativeTools.length > 0) {
      return {
        tools: config2.nativeTools.map((tool) => {
          if (tool.google_search) {
            return { google_search: tool.google_search };
          }
          if (tool.url_context) {
            return { url_context: tool.url_context };
          }
          return tool;
        }),
        toolConfig: void 0
        // Native tools don't use toolConfig in the same way
      };
    }
    return { tools: void 0, toolConfig: void 0 };
  }
};

// src/helpers/auto-model-switching.ts
var AutoModelSwitchingHelper = class {
  static {
    __name(this, "AutoModelSwitchingHelper");
  }
  env;
  constructor(env2) {
    this.env = env2;
  }
  /**
   * Checks if auto model switching is enabled via environment variable.
   */
  isEnabled() {
    return this.env.ENABLE_AUTO_MODEL_SWITCHING === "true";
  }
  /**
   * Gets the fallback model for the given original model.
   * Returns null if no fallback is configured for the model.
   */
  getFallbackModel(originalModel) {
    return AUTO_SWITCH_MODEL_MAP[originalModel] || null;
  }
  /**
   * Checks if the error message indicates a rate limit error that should trigger auto switching.
   */
  isRateLimitError(error3) {
    return error3 instanceof Error && (error3.message.includes("Stream request failed: 429") || error3.message.includes("Stream request failed: 503"));
  }
  /**
   * Checks if the HTTP status code indicates a rate limit error.
   */
  isRateLimitStatus(status) {
    return RATE_LIMIT_STATUS_CODES.includes(status);
  }
  /**
   * Determines if fallback should be attempted for the given model and conditions.
   */
  shouldAttemptFallback(originalModel) {
    return this.isEnabled() && this.getFallbackModel(originalModel) !== null;
  }
  /**
   * Creates a notification message for when a model switch occurs.
   */
  createSwitchNotification(originalModel, fallbackModel) {
    return `[Auto-switched from ${originalModel} to ${fallbackModel} due to rate limiting]

`;
  }
  /**
   * Handles rate limit fallback for non-streaming requests.
   * This method requires a stream content function to perform the actual retry.
   */
  async handleNonStreamingFallback(originalModel, systemPrompt, messages, options, streamContentFn) {
    const fallbackModel = this.getFallbackModel(originalModel);
    if (!fallbackModel || !this.isEnabled()) {
      return null;
    }
    console.log(`Got rate limit error for model ${originalModel}, switching to fallback model: ${fallbackModel}`);
    let content = "";
    let usage;
    content += this.createSwitchNotification(originalModel, fallbackModel);
    for await (const chunk of streamContentFn(fallbackModel, systemPrompt, messages, options)) {
      if (chunk.type === "text" && typeof chunk.data === "string") {
        content += chunk.data;
      } else if (chunk.type === "usage" && typeof chunk.data === "object") {
        usage = chunk.data;
      }
    }
    return { content, usage };
  }
};

// src/helpers/citations-processor.ts
var CitationsProcessor = class {
  static {
    __name(this, "CitationsProcessor");
  }
  enableInlineCitations;
  constructor(env2) {
    this.enableInlineCitations = env2.ENABLE_INLINE_CITATIONS === "true";
  }
  /**
   * Finds a "safe" insertion point for a citation to avoid breaking words or URLs.
   * It searches for the nearest whitespace or punctuation after the given index.
   */
  findSafeInsertionPoint(text, index) {
    if (index >= text.length) {
      return text.length;
    }
    const charAtIndex = text.charAt(index);
    if (/\s|[.,!?;:]/.test(charAtIndex)) {
      return index;
    }
    for (let i = index; i < text.length; i++) {
      const char = text.charAt(i);
      if (/\s|[.,!?;:]/.test(char)) {
        return i;
      }
    }
    return index;
  }
  processChunk(textChunk, metadata) {
    if (!this.enableInlineCitations) {
      return textChunk;
    }
    let citedTextChunk = textChunk;
    let offset = 0;
    if (metadata && metadata.groundingSupports && metadata.groundingChunks) {
      const sortedSupports = [...metadata.groundingSupports].sort(
        (a, b) => (a.segment?.startIndex ?? 0) - (b.segment?.startIndex ?? 0)
      );
      for (const support of sortedSupports) {
        const originalStartIndex = support.segment?.startIndex;
        const originalEndIndex = support.segment?.endIndex;
        if (originalStartIndex === void 0 || originalEndIndex === void 0 || !support.groundingChunkIndices?.length || originalStartIndex < 0 || // Ensure startIndex is not negative
        originalEndIndex > textChunk.length) {
          continue;
        }
        const citationLinks = support.groundingChunkIndices.map((i) => {
          const uri = metadata.groundingChunks[i]?.web?.uri;
          if (uri) {
            return `[${i + 1}](${uri})`;
          }
          return null;
        }).filter(Boolean);
        if (citationLinks.length > 0) {
          const citationString = citationLinks.join(", ");
          const insertionIndex = originalEndIndex + offset;
          const safeInsertionIndex = this.findSafeInsertionPoint(citedTextChunk, insertionIndex);
          citedTextChunk = citedTextChunk.slice(0, safeInsertionIndex) + citationString + citedTextChunk.slice(safeInsertionIndex);
          offset += citationString.length;
        }
      }
    }
    return citedTextChunk;
  }
  /**
   * Extracts search queries that were used to generate the grounded response.
   */
  extractSearchQueries(groundingMetadata) {
    return groundingMetadata.webSearchQueries || [];
  }
  /**
   * Extracts a structured list of sources with IDs, titles, and URIs.
   */
  extractSourceList(groundingMetadata) {
    return groundingMetadata.groundingChunks.map((chunk, index) => ({
      id: index + 1,
      title: chunk.web.title,
      uri: chunk.web.uri
    }));
  }
  /**
   * Generates search entry point HTML if available and enabled.
   */
  getSearchEntryPoint(groundingMetadata) {
    return groundingMetadata.searchEntryPoint?.renderedContent || null;
  }
  /**
   * Creates a summary of the grounding information for debugging/logging.
   */
  createGroundingSummary(groundingMetadata) {
    return {
      queryCount: groundingMetadata.webSearchQueries?.length || 0,
      sourceCount: groundingMetadata.groundingChunks?.length || 0,
      supportCount: groundingMetadata.groundingSupports?.length || 0,
      queries: this.extractSearchQueries(groundingMetadata),
      sources: this.extractSourceList(groundingMetadata)
    };
  }
};

// src/helpers/native-tools-manager.ts
var NativeToolsManager = class {
  static {
    __name(this, "NativeToolsManager");
  }
  envSettings;
  citationsProcessor;
  constructor(env2) {
    this.envSettings = this.parseEnvironmentSettings(env2);
    this.citationsProcessor = new CitationsProcessor(env2);
  }
  /**
   * Determines the final tool configuration based on environment settings,
   * request parameters, and tool compatibility rules.
   */
  determineToolConfiguration(customTools, requestParams, modelId) {
    if (!this.envSettings.enableNativeTools) {
      return this.createCustomOnlyConfig(customTools);
    }
    const searchAndUrlRequested = this.shouldEnableGoogleSearch(requestParams) || this.shouldEnableUrlContext(requestParams);
    if (searchAndUrlRequested) {
      return this.createSearchAndUrlConfig(requestParams, customTools, modelId);
    }
    return this.createCustomOnlyConfig(customTools);
  }
  /**
   * Creates the array of native tools to be sent to the Gemini API.
   */
  createNativeToolsArray(params, modelId) {
    const tools = [];
    if (this.shouldEnableGoogleSearch(params)) {
      if (!this.isLegacyModel(modelId)) {
        tools.push({ google_search: {} });
      }
    }
    if (this.shouldEnableUrlContext(params) && !this.shouldEnableGoogleSearch(params)) {
      tools.push({ url_context: {} });
    }
    return tools;
  }
  /**
   * Processes text to add inline citations if enabled.
   */
  processCitationsInText(text, groundingMetadata) {
    return this.citationsProcessor.processChunk(text, groundingMetadata);
  }
  createSearchAndUrlConfig(requestParams, customTools, modelId) {
    const nativeTools = this.createNativeToolsArray(requestParams, modelId);
    if (this.envSettings.priority === "native_first" || requestParams.nativeToolsPriority === "native") {
      return {
        useNativeTools: true,
        useCustomTools: false,
        nativeTools,
        priority: "native",
        toolType: "search_and_url"
      };
    } else if (this.envSettings.priority === "custom_first" && customTools.length > 0) {
      return this.createCustomOnlyConfig(customTools);
    } else {
      return {
        useNativeTools: true,
        useCustomTools: false,
        nativeTools,
        priority: "native",
        toolType: "search_and_url"
      };
    }
  }
  createCustomOnlyConfig(customTools) {
    return {
      useNativeTools: false,
      useCustomTools: true,
      nativeTools: [],
      customTools,
      priority: "custom",
      toolType: "custom_only"
    };
  }
  shouldEnableGoogleSearch(params) {
    if (params.enableSearch === false) return false;
    if (params.enableSearch === true) return true;
    return this.envSettings.enableGoogleSearch;
  }
  shouldEnableUrlContext(params) {
    if (params.enableUrlContext === false) return false;
    if (params.enableUrlContext === true) return true;
    return this.envSettings.enableUrlContext;
  }
  isLegacyModel(modelId) {
    return modelId.includes("gemini-1.5");
  }
  parseEnvironmentSettings(env2) {
    return {
      enableNativeTools: env2.ENABLE_GEMINI_NATIVE_TOOLS === "true",
      enableGoogleSearch: env2.ENABLE_GOOGLE_SEARCH === "true",
      enableUrlContext: env2.ENABLE_URL_CONTEXT === "true",
      priority: env2.GEMINI_TOOLS_PRIORITY || NATIVE_TOOLS_DEFAULTS.GEMINI_TOOLS_PRIORITY,
      defaultToNativeTools: env2.DEFAULT_TO_NATIVE_TOOLS !== "false",
      allowRequestControl: env2.ALLOW_REQUEST_TOOL_CONTROL !== "false",
      enableInlineCitations: env2.ENABLE_INLINE_CITATIONS === "true",
      includeGroundingMetadata: env2.INCLUDE_GROUNDING_METADATA !== "false",
      includeSearchEntryPoint: env2.INCLUDE_SEARCH_ENTRY_POINT === "true"
    };
  }
};

// src/gemini-client.ts
function isTextContent(content) {
  return content.type === "text" && typeof content.text === "string";
}
__name(isTextContent, "isTextContent");
var GeminiApiClient = class {
  static {
    __name(this, "GeminiApiClient");
  }
  env;
  authManager;
  projectId = null;
  autoSwitchHelper;
  constructor(env2, authManager) {
    this.env = env2;
    this.authManager = authManager;
    this.autoSwitchHelper = new AutoModelSwitchingHelper(env2);
  }
  /**
   * Discovers the Google Cloud project ID. Uses the environment variable if provided.
   */
  async discoverProjectId() {
    if (this.env.GEMINI_PROJECT_ID) {
      return this.env.GEMINI_PROJECT_ID;
    }
    if (this.projectId) {
      return this.projectId;
    }
    try {
      const initialProjectId = "default-project";
      const loadResponse = await this.authManager.callEndpoint("loadCodeAssist", {
        "metadata": {
          "ideType": "IDE_UNSPECIFIED",
          "platform": "PLATFORM_UNSPECIFIED",
          "pluginType": "GEMINI"
        }
      });
      if (loadResponse.cloudaicompanionProject) {
        this.projectId = loadResponse.cloudaicompanionProject;
        return loadResponse.cloudaicompanionProject;
      }
      throw new Error("Project ID discovery failed. Please set the GEMINI_PROJECT_ID environment variable.");
    } catch (error3) {
      const errorMessage = error3 instanceof Error ? error3.message : String(error3);
      console.error("Failed to discover project ID:", errorMessage);
      throw new Error(
        "Could not discover project ID. Make sure you're authenticated and consider setting GEMINI_PROJECT_ID."
      );
    }
  }
  /**
   * Parses a server-sent event (SSE) stream from the Gemini API.
   */
  async *parseSSEStream(stream) {
    const reader = stream.pipeThrough(new TextDecoderStream()).getReader();
    let buffer = "";
    let objectBuffer = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        if (objectBuffer) {
          try {
            yield JSON.parse(objectBuffer);
          } catch (e) {
            console.error("Error parsing final SSE JSON object:", e);
          }
        }
        break;
      }
      buffer += value;
      const lines = buffer.split("\n");
      buffer = lines.pop() || "";
      for (const line of lines) {
        if (line.trim() === "") {
          if (objectBuffer) {
            try {
              yield JSON.parse(objectBuffer);
            } catch (e) {
              console.error("Error parsing SSE JSON object:", e);
            }
            objectBuffer = "";
          }
        } else if (line.startsWith("data: ")) {
          objectBuffer += line.substring(6);
        }
      }
    }
  }
  /**
   * Converts a message to Gemini format, handling both text and image content.
   */
  messageToGeminiFormat(msg) {
    const role = msg.role === "assistant" ? "model" : "user";
    if (msg.role === "tool") {
      return {
        role: "user",
        parts: [
          {
            functionResponse: {
              name: msg.tool_call_id || "unknown_function",
              response: {
                result: typeof msg.content === "string" ? msg.content : JSON.stringify(msg.content)
              }
            }
          }
        ]
      };
    }
    if (msg.role === "assistant" && msg.tool_calls && msg.tool_calls.length > 0) {
      const parts = [];
      if (typeof msg.content === "string" && msg.content.trim()) {
        parts.push({ text: msg.content });
      }
      for (const toolCall of msg.tool_calls) {
        if (toolCall.type === "function") {
          parts.push({
            functionCall: {
              name: toolCall.function.name,
              args: JSON.parse(toolCall.function.arguments)
            }
          });
        }
      }
      return { role: "model", parts };
    }
    if (typeof msg.content === "string") {
      return {
        role,
        parts: [{ text: msg.content }]
      };
    }
    if (Array.isArray(msg.content)) {
      const parts = [];
      for (const content of msg.content) {
        if (content.type === "text") {
          parts.push({ text: content.text });
        } else if (content.type === "image_url" && content.image_url) {
          const imageUrl = content.image_url.url;
          const validation = validateImageUrl(imageUrl);
          if (!validation.isValid) {
            throw new Error(`Invalid image: ${validation.error}`);
          }
          if (imageUrl.startsWith("data:")) {
            const [mimeType, base64Data] = imageUrl.split(",");
            const mediaType = mimeType.split(":")[1].split(";")[0];
            parts.push({
              inlineData: {
                mimeType: mediaType,
                data: base64Data
              }
            });
          } else {
            parts.push({
              fileData: {
                mimeType: validation.mimeType || "image/jpeg",
                fileUri: imageUrl
              }
            });
          }
        }
      }
      return { role, parts };
    }
    return {
      role,
      parts: [{ text: String(msg.content) }]
    };
  }
  /**
   * Validates if the model supports images.
   */
  validateImageSupport(modelId) {
    return geminiCliModels[modelId]?.supportsImages || false;
  }
  /**
   * Validates image content and format using the shared validation utility.
   */
  validateImageContent(imageUrl) {
    const validation = validateImageUrl(imageUrl);
    return validation.isValid;
  }
  /**
   * Stream content from Gemini API.
   */
  async *streamContent(modelId, systemPrompt, messages, options) {
    await this.authManager.initializeAuth();
    const projectId = await this.discoverProjectId();
    const contents = messages.map((msg) => this.messageToGeminiFormat(msg));
    if (systemPrompt) {
      contents.unshift({ role: "user", parts: [{ text: systemPrompt }] });
    }
    const isThinkingModel = geminiCliModels[modelId]?.thinking || false;
    const isRealThinkingEnabled = this.env.ENABLE_REAL_THINKING === "true";
    const isFakeThinkingEnabled = this.env.ENABLE_FAKE_THINKING === "true";
    const streamThinkingAsContent = this.env.STREAM_THINKING_AS_CONTENT === "true";
    const includeReasoning = options?.includeReasoning || false;
    const req = {
      thinking_budget: options?.thinkingBudget,
      tools: options?.tools,
      tool_choice: options?.tool_choice,
      max_tokens: options?.max_tokens,
      temperature: options?.temperature,
      top_p: options?.top_p,
      stop: options?.stop,
      presence_penalty: options?.presence_penalty,
      frequency_penalty: options?.frequency_penalty,
      seed: options?.seed,
      response_format: options?.response_format
    };
    const generationConfig = GenerationConfigValidator.createValidatedConfig(
      modelId,
      req,
      isRealThinkingEnabled,
      includeReasoning
    );
    const nativeToolsManager = new NativeToolsManager(this.env);
    const nativeToolsParams = this.extractNativeToolsParams(options);
    const toolConfig = nativeToolsManager.determineToolConfiguration(options?.tools || [], nativeToolsParams, modelId);
    const { tools, toolConfig: finalToolConfig } = GenerationConfigValidator.createFinalToolConfiguration(
      toolConfig,
      options
    );
    let needsThinkingClose = false;
    if (isThinkingModel && isFakeThinkingEnabled && !includeReasoning) {
      yield* this.generateReasoningOutput(messages, streamThinkingAsContent);
      needsThinkingClose = streamThinkingAsContent;
    }
    const streamRequest = {
      model: modelId,
      project: projectId,
      request: {
        contents,
        generationConfig,
        tools,
        toolConfig: finalToolConfig
      }
    };
    const safetySettings = GenerationConfigValidator.createSafetySettings(this.env);
    if (safetySettings.length > 0) {
      streamRequest.request.safetySettings = safetySettings;
    }
    yield* this.performStreamRequest(
      streamRequest,
      needsThinkingClose,
      false,
      includeReasoning && streamThinkingAsContent,
      modelId,
      nativeToolsManager
    );
  }
  /**
   * Generates reasoning output for thinking models.
   */
  async *generateReasoningOutput(messages, streamAsContent = false) {
    const lastUserMessage = messages.filter((msg) => msg.role === "user").pop();
    let userContent = "";
    if (lastUserMessage) {
      if (typeof lastUserMessage.content === "string") {
        userContent = lastUserMessage.content;
      } else if (Array.isArray(lastUserMessage.content)) {
        userContent = lastUserMessage.content.filter(isTextContent).map((c) => c.text).join(" ");
      }
    }
    const requestPreview = userContent.substring(0, 100) + (userContent.length > 100 ? "..." : "");
    if (streamAsContent) {
      yield {
        type: "thinking_content",
        data: "<thinking>\n"
      };
      await new Promise((resolve) => setTimeout(resolve, REASONING_CHUNK_DELAY));
      const reasoningTexts = REASONING_MESSAGES.map((msg) => msg.replace("{requestPreview}", requestPreview));
      const fullReasoningText = reasoningTexts.join("");
      const chunks = [];
      let remainingText = fullReasoningText;
      while (remainingText.length > 0) {
        if (remainingText.length <= THINKING_CONTENT_CHUNK_SIZE) {
          chunks.push(remainingText);
          break;
        }
        let chunkEnd = THINKING_CONTENT_CHUNK_SIZE;
        const searchSpace = remainingText.substring(0, chunkEnd + 10);
        const goodBreaks = [" ", "\n", ".", ",", "!", "?", ";", ":"];
        for (const breakChar of goodBreaks) {
          const lastBreak = searchSpace.lastIndexOf(breakChar);
          if (lastBreak > THINKING_CONTENT_CHUNK_SIZE * 0.7) {
            chunkEnd = lastBreak + 1;
            break;
          }
        }
        chunks.push(remainingText.substring(0, chunkEnd));
        remainingText = remainingText.substring(chunkEnd);
      }
      for (const chunk of chunks) {
        yield {
          type: "thinking_content",
          data: chunk
        };
        await new Promise((resolve) => setTimeout(resolve, 50));
      }
    } else {
      const reasoningTexts = REASONING_MESSAGES.map((msg) => msg.replace("{requestPreview}", requestPreview));
      for (const reasoningText of reasoningTexts) {
        const reasoningData = { reasoning: reasoningText };
        yield {
          type: "reasoning",
          data: reasoningData
        };
        await new Promise((resolve) => setTimeout(resolve, REASONING_CHUNK_DELAY));
      }
    }
  }
  /**
   * Performs the actual stream request with retry logic for 401 errors and auto model switching for rate limits.
   */
  async *performStreamRequest(streamRequest, needsThinkingClose = false, isRetry = false, realThinkingAsContent = false, originalModel, nativeToolsManager) {
    const citationsProcessor = new CitationsProcessor(this.env);
    const response = await fetch(`${CODE_ASSIST_ENDPOINT}/${CODE_ASSIST_API_VERSION}:streamGenerateContent?alt=sse`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.authManager.getAccessToken()}`
      },
      body: JSON.stringify(streamRequest)
    });
    if (!response.ok) {
      if (response.status === 401 && !isRetry) {
        console.log("Got 401 error in stream request, clearing token cache and retrying...");
        await this.authManager.clearTokenCache();
        await this.authManager.initializeAuth();
        yield* this.performStreamRequest(
          streamRequest,
          needsThinkingClose,
          true,
          realThinkingAsContent,
          originalModel,
          nativeToolsManager
        );
        return;
      }
      if (this.autoSwitchHelper.isRateLimitStatus(response.status) && !isRetry && originalModel) {
        const fallbackModel = this.autoSwitchHelper.getFallbackModel(originalModel);
        if (fallbackModel && this.autoSwitchHelper.isEnabled()) {
          console.log(
            `Got ${response.status} error for model ${originalModel}, switching to fallback model: ${fallbackModel}`
          );
          const fallbackRequest = {
            ...streamRequest,
            model: fallbackModel
          };
          yield {
            type: "text",
            data: this.autoSwitchHelper.createSwitchNotification(originalModel, fallbackModel)
          };
          yield* this.performStreamRequest(
            fallbackRequest,
            needsThinkingClose,
            true,
            realThinkingAsContent,
            originalModel,
            nativeToolsManager
          );
          return;
        }
      }
      const errorText = await response.text();
      console.error(`[GeminiAPI] Stream request failed: ${response.status}`, errorText);
      throw new Error(`Stream request failed: ${response.status}`);
    }
    if (!response.body) {
      throw new Error("Response has no body");
    }
    let hasClosedThinking = false;
    let hasStartedThinking = false;
    for await (const jsonData of this.parseSSEStream(response.body)) {
      const candidate = jsonData.response?.candidates?.[0];
      if (candidate?.content?.parts) {
        for (const part of candidate.content.parts) {
          if (part.thought === true && part.text) {
            const thinkingText = part.text;
            if (realThinkingAsContent) {
              if (!hasStartedThinking) {
                yield {
                  type: "thinking_content",
                  data: "<thinking>\n"
                };
                hasStartedThinking = true;
              }
              yield {
                type: "thinking_content",
                data: thinkingText
              };
            } else {
              yield {
                type: "real_thinking",
                data: thinkingText
              };
            }
          } else if (part.text && part.text.includes("<think>")) {
            if (realThinkingAsContent) {
              const thinkingMatch = part.text.match(/<think>(.*?)<\/think>/s);
              if (thinkingMatch) {
                if (!hasStartedThinking) {
                  yield {
                    type: "thinking_content",
                    data: "<thinking>\n"
                  };
                  hasStartedThinking = true;
                }
                yield {
                  type: "thinking_content",
                  data: thinkingMatch[1]
                };
              }
              const nonThinkingContent = part.text.replace(/<think>.*?<\/think>/gs, "").trim();
              if (nonThinkingContent) {
                if (hasStartedThinking && !hasClosedThinking) {
                  yield {
                    type: "thinking_content",
                    data: "\n</thinking>\n\n"
                  };
                  hasClosedThinking = true;
                }
                yield { type: "text", data: nonThinkingContent };
              }
            } else {
              const thinkingMatch = part.text.match(/<think>(.*?)<\/think>/s);
              if (thinkingMatch) {
                yield {
                  type: "real_thinking",
                  data: thinkingMatch[1]
                };
              }
              const nonThinkingContent = part.text.replace(/<think>.*?<\/think>/gs, "").trim();
              if (nonThinkingContent) {
                yield { type: "text", data: nonThinkingContent };
              }
            }
          } else if (part.text && !part.thought && !part.text.includes("<think>")) {
            if ((needsThinkingClose || realThinkingAsContent && hasStartedThinking) && !hasClosedThinking) {
              yield {
                type: "thinking_content",
                data: "\n</thinking>\n\n"
              };
              hasClosedThinking = true;
            }
            let processedText = part.text;
            if (nativeToolsManager) {
              processedText = citationsProcessor.processChunk(
                part.text,
                jsonData.response?.candidates?.[0]?.groundingMetadata
              );
            }
            yield { type: "text", data: processedText };
          } else if (part.functionCall) {
            if ((needsThinkingClose || realThinkingAsContent && hasStartedThinking) && !hasClosedThinking) {
              yield {
                type: "thinking_content",
                data: "\n</thinking>\n\n"
              };
              hasClosedThinking = true;
            }
            const functionCallData = {
              name: part.functionCall.name,
              args: part.functionCall.args
            };
            yield {
              type: "tool_code",
              data: functionCallData
            };
          }
        }
      }
      if (jsonData.response?.usageMetadata) {
        const usage = jsonData.response.usageMetadata;
        const usageData = {
          inputTokens: usage.promptTokenCount || 0,
          outputTokens: usage.candidatesTokenCount || 0
        };
        yield {
          type: "usage",
          data: usageData
        };
      }
    }
  }
  /**
   * Get a complete response from Gemini API (non-streaming).
   */
  async getCompletion(modelId, systemPrompt, messages, options) {
    try {
      let content = "";
      let usage;
      const tool_calls = [];
      for await (const chunk of this.streamContent(modelId, systemPrompt, messages, options)) {
        if (chunk.type === "text" && typeof chunk.data === "string") {
          content += chunk.data;
        } else if (chunk.type === "usage" && typeof chunk.data === "object") {
          usage = chunk.data;
        } else if (chunk.type === "tool_code" && typeof chunk.data === "object") {
          const toolData = chunk.data;
          tool_calls.push({
            id: `call_${crypto.randomUUID()}`,
            type: "function",
            function: {
              name: toolData.name,
              arguments: JSON.stringify(toolData.args)
            }
          });
        }
      }
      return {
        content,
        usage,
        tool_calls: tool_calls.length > 0 ? tool_calls : void 0
      };
    } catch (error3) {
      if (this.autoSwitchHelper.isRateLimitError(error3)) {
        const fallbackResult = await this.autoSwitchHelper.handleNonStreamingFallback(
          modelId,
          systemPrompt,
          messages,
          options,
          this.streamContent.bind(this)
        );
        if (fallbackResult) {
          return fallbackResult;
        }
      }
      throw error3;
    }
  }
  extractNativeToolsParams(options) {
    return {
      enableSearch: this.extractBooleanParam(options, "enable_search"),
      enableUrlContext: this.extractBooleanParam(options, "enable_url_context"),
      enableNativeTools: this.extractBooleanParam(options, "enable_native_tools"),
      nativeToolsPriority: this.extractStringParam(
        options,
        "native_tools_priority",
        (v) => ["native", "custom", "mixed"].includes(v)
      )
    };
  }
  extractBooleanParam(options, key) {
    const value = options?.[key] ?? options?.extra_body?.[key] ?? options?.model_params?.[key];
    return typeof value === "boolean" ? value : void 0;
  }
  extractStringParam(options, key, guard) {
    const value = options?.[key] ?? options?.extra_body?.[key] ?? options?.model_params?.[key];
    if (typeof value === "string" && guard(value)) {
      return value;
    }
    return void 0;
  }
};

// src/stream-transformer.ts
function isReasoningData(data) {
  return typeof data === "object" && data !== null && ("reasoning" in data || "toolCode" in data);
}
__name(isReasoningData, "isReasoningData");
function isGeminiFunctionCall(data) {
  return typeof data === "object" && data !== null && "name" in data && "args" in data;
}
__name(isGeminiFunctionCall, "isGeminiFunctionCall");
function isUsageData(data) {
  return typeof data === "object" && data !== null && "inputTokens" in data && "outputTokens" in data;
}
__name(isUsageData, "isUsageData");
function isNativeToolResponse(data) {
  return typeof data === "object" && data !== null && "type" in data && "data" in data;
}
__name(isNativeToolResponse, "isNativeToolResponse");
function createOpenAIStreamTransformer(model) {
  const chatID = `chatcmpl-${crypto.randomUUID()}`;
  const creationTime = Math.floor(Date.now() / 1e3);
  const encoder = new TextEncoder();
  let firstChunk = true;
  let toolCallId = null;
  let toolCallName = null;
  let usageData;
  return new TransformStream({
    transform(chunk, controller) {
      const delta = {};
      let openAIChunk = null;
      switch (chunk.type) {
        case "text":
        case "thinking_content":
          if (typeof chunk.data === "string") {
            delta.content = chunk.data;
            if (firstChunk) {
              delta.role = "assistant";
              firstChunk = false;
            }
          }
          break;
        case "real_thinking":
          if (typeof chunk.data === "string") {
            delta.reasoning = chunk.data;
          }
          break;
        case "reasoning":
          if (isReasoningData(chunk.data)) {
            delta.reasoning = chunk.data.reasoning;
          }
          break;
        case "tool_code":
          if (isGeminiFunctionCall(chunk.data)) {
            const toolData = chunk.data;
            toolCallName = toolData.name;
            toolCallId = `call_${crypto.randomUUID()}`;
            delta.tool_calls = [
              {
                index: 0,
                id: toolCallId,
                type: "function",
                function: {
                  name: toolCallName,
                  arguments: JSON.stringify(toolData.args)
                }
              }
            ];
            if (firstChunk) {
              delta.role = "assistant";
              delta.content = null;
              firstChunk = false;
            }
          }
          break;
        case "native_tool":
          if (isNativeToolResponse(chunk.data)) {
            delta.native_tool_calls = [chunk.data];
          }
          break;
        case "grounding_metadata":
          if (chunk.data) {
            delta.grounding = chunk.data;
          }
          break;
        case "usage":
          if (isUsageData(chunk.data)) {
            usageData = chunk.data;
          }
          return;
      }
      if (Object.keys(delta).length > 0) {
        openAIChunk = {
          id: chatID,
          object: OPENAI_CHAT_COMPLETION_OBJECT,
          created: creationTime,
          model,
          choices: [
            {
              index: 0,
              delta,
              finish_reason: null,
              logprobs: null,
              matched_stop: null
            }
          ],
          usage: null
        };
        controller.enqueue(encoder.encode(`data: ${JSON.stringify(openAIChunk)}

`));
      }
    },
    flush(controller) {
      const finishReason = toolCallId ? "tool_calls" : "stop";
      const finalChunk = {
        id: chatID,
        object: OPENAI_CHAT_COMPLETION_OBJECT,
        created: creationTime,
        model,
        choices: [{ index: 0, delta: {}, finish_reason: finishReason }]
      };
      if (usageData) {
        finalChunk.usage = {
          prompt_tokens: usageData.inputTokens,
          completion_tokens: usageData.outputTokens,
          total_tokens: usageData.inputTokens + usageData.outputTokens
        };
      }
      controller.enqueue(encoder.encode(`data: ${JSON.stringify(finalChunk)}

`));
      controller.enqueue(encoder.encode("data: [DONE]\n\n"));
    }
  });
}
__name(createOpenAIStreamTransformer, "createOpenAIStreamTransformer");

// src/routes/openai.ts
var OpenAIRoute = new Hono2();
OpenAIRoute.get("/models", async (c) => {
  const modelData = getAllModelIds().map((modelId) => ({
    id: modelId,
    object: "model",
    created: Math.floor(Date.now() / 1e3),
    owned_by: OPENAI_MODEL_OWNER
  }));
  return c.json({
    object: "list",
    data: modelData
  });
});
OpenAIRoute.post("/chat/completions", async (c) => {
  try {
    console.log("Chat completions request received");
    const body = await c.req.json();
    const model = body.model || DEFAULT_MODEL;
    const messages = body.messages || [];
    const stream = body.stream !== false;
    const isRealThinkingEnabled = c.env.ENABLE_REAL_THINKING === "true";
    let includeReasoning = isRealThinkingEnabled;
    let thinkingBudget = body.thinking_budget ?? DEFAULT_THINKING_BUDGET;
    const generationOptions = {
      max_tokens: body.max_tokens,
      temperature: body.temperature,
      top_p: body.top_p,
      stop: body.stop,
      presence_penalty: body.presence_penalty,
      frequency_penalty: body.frequency_penalty,
      seed: body.seed,
      response_format: body.response_format
    };
    const reasoning_effort = body.reasoning_effort || body.extra_body?.reasoning_effort || body.model_params?.reasoning_effort;
    if (reasoning_effort) {
      includeReasoning = true;
      const isFlashModel = model.includes("flash");
      switch (reasoning_effort) {
        case "low":
          thinkingBudget = 1024;
          break;
        case "medium":
          thinkingBudget = isFlashModel ? 12288 : 16384;
          break;
        case "high":
          thinkingBudget = isFlashModel ? 24576 : 32768;
          break;
        case "none":
          thinkingBudget = 0;
          includeReasoning = false;
          break;
      }
    }
    const tools = body.tools;
    const tool_choice = body.tool_choice;
    console.log("Request body parsed:", {
      model,
      messageCount: messages.length,
      stream,
      includeReasoning,
      thinkingBudget,
      tools,
      tool_choice
    });
    if (!messages.length) {
      return c.json({ error: "messages is a required field" }, 400);
    }
    if (!(model in geminiCliModels)) {
      return c.json(
        {
          error: `Model '${model}' not found. Available models: ${getAllModelIds().join(", ")}`
        },
        400
      );
    }
    const hasImages = messages.some((msg) => {
      if (Array.isArray(msg.content)) {
        return msg.content.some((content) => content.type === "image_url");
      }
      return false;
    });
    if (hasImages && !geminiCliModels[model].supportsImages) {
      return c.json(
        {
          error: `Model '${model}' does not support image inputs. Please use a vision-capable model like gemini-2.5-pro or gemini-2.5-flash.`
        },
        400
      );
    }
    let systemPrompt = "";
    const otherMessages = messages.filter((msg) => {
      if (msg.role === "system") {
        if (typeof msg.content === "string") {
          systemPrompt = msg.content;
        } else if (Array.isArray(msg.content)) {
          const textContent = msg.content.filter((part) => part.type === "text").map((part) => part.text || "").join(" ");
          systemPrompt = textContent;
        }
        return false;
      }
      return true;
    });
    const authManager = new AuthManager(c.env);
    const geminiClient = new GeminiApiClient(c.env, authManager);
    try {
      await authManager.initializeAuth();
      console.log("Authentication successful");
    } catch (authError) {
      const errorMessage = authError instanceof Error ? authError.message : String(authError);
      console.error("Authentication failed:", errorMessage);
      return c.json({ error: "Authentication failed: " + errorMessage }, 401);
    }
    if (stream) {
      const { readable, writable } = new TransformStream();
      const writer = writable.getWriter();
      const openAITransformer = createOpenAIStreamTransformer(model);
      const openAIStream = readable.pipeThrough(openAITransformer);
      (async () => {
        try {
          console.log("Starting stream generation");
          const geminiStream = geminiClient.streamContent(model, systemPrompt, otherMessages, {
            includeReasoning,
            thinkingBudget,
            tools,
            tool_choice,
            ...generationOptions
          });
          for await (const chunk of geminiStream) {
            await writer.write(chunk);
          }
          console.log("Stream completed successfully");
          await writer.close();
        } catch (streamError) {
          const errorMessage = streamError instanceof Error ? streamError.message : String(streamError);
          console.error("Stream error:", errorMessage);
          await writer.write({
            type: "text",
            data: `Error: ${errorMessage}`
          });
          await writer.close();
        }
      })();
      console.log("Returning streaming response");
      return new Response(openAIStream, {
        headers: {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          Connection: "keep-alive",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization"
        }
      });
    } else {
      try {
        console.log("Starting non-streaming completion");
        const completion = await geminiClient.getCompletion(model, systemPrompt, otherMessages, {
          includeReasoning,
          thinkingBudget,
          tools,
          tool_choice,
          ...generationOptions
        });
        const response = {
          id: `chatcmpl-${crypto.randomUUID()}`,
          object: "chat.completion",
          created: Math.floor(Date.now() / 1e3),
          model,
          choices: [
            {
              index: 0,
              message: {
                role: "assistant",
                content: completion.content,
                tool_calls: completion.tool_calls
              },
              finish_reason: completion.tool_calls && completion.tool_calls.length > 0 ? "tool_calls" : "stop"
            }
          ]
        };
        if (completion.usage) {
          response.usage = {
            prompt_tokens: completion.usage.inputTokens,
            completion_tokens: completion.usage.outputTokens,
            total_tokens: completion.usage.inputTokens + completion.usage.outputTokens
          };
        }
        console.log("Non-streaming completion successful");
        return c.json(response);
      } catch (completionError) {
        const errorMessage = completionError instanceof Error ? completionError.message : String(completionError);
        console.error("Completion error:", errorMessage);
        return c.json({ error: errorMessage }, 500);
      }
    }
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error("Top-level error:", e);
    return c.json({ error: errorMessage }, 500);
  }
});

// src/routes/debug.ts
var DebugRoute = new Hono2();
DebugRoute.get("/cache", async (c) => {
  try {
    const authManager = new AuthManager(c.env);
    const cacheInfo = await authManager.getCachedTokenInfo();
    const sanitizedInfo = {
      status: "ok",
      cached: cacheInfo.cached,
      cached_at: cacheInfo.cached_at,
      expires_at: cacheInfo.expires_at,
      time_until_expiry_seconds: cacheInfo.time_until_expiry_seconds,
      is_expired: cacheInfo.is_expired,
      message: cacheInfo.message
      // Explicitly exclude token_preview and any other sensitive data
    };
    return c.json(sanitizedInfo);
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    return c.json(
      {
        status: "error",
        message: errorMessage
      },
      500
    );
  }
});
DebugRoute.post("/token-test", async (c) => {
  try {
    console.log("Token test endpoint called");
    const authManager = new AuthManager(c.env);
    await authManager.initializeAuth();
    console.log("Token test passed");
    return c.json({
      status: "ok",
      message: "Token authentication successful"
    });
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error("Token test error:", e);
    return c.json(
      {
        status: "error",
        message: errorMessage
        // Removed stack trace for security
      },
      500
    );
  }
});
DebugRoute.post("/test", async (c) => {
  try {
    console.log("Test endpoint called");
    const authManager = new AuthManager(c.env);
    const geminiClient = new GeminiApiClient(c.env, authManager);
    await authManager.initializeAuth();
    console.log("Auth test passed");
    const projectId = await geminiClient.discoverProjectId();
    console.log("Project discovery test passed");
    return c.json({
      status: "ok",
      message: "Authentication and project discovery successful",
      project_available: !!projectId
      // Removed actual projectId for security
    });
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error("Test endpoint error:", e);
    return c.json(
      {
        status: "error",
        message: errorMessage
        // Removed stack trace and detailed error message for security
      },
      500
    );
  }
});

// src/middlewares/auth.ts
var openAIApiKeyAuth = /* @__PURE__ */ __name(async (c, next) => {
  const publicEndpoints = ["/", "/health"];
  if (publicEndpoints.some((endpoint) => c.req.path === endpoint)) {
    await next();
    return;
  }
  if (c.env.OPENAI_API_KEY) {
    const authHeader = c.req.header("Authorization");
    if (!authHeader) {
      return c.json(
        {
          error: {
            message: "Missing Authorization header",
            type: "authentication_error",
            code: "missing_authorization"
          }
        },
        401
      );
    }
    const match = authHeader.match(/^Bearer\s+(.+)$/);
    if (!match) {
      return c.json(
        {
          error: {
            message: "Invalid Authorization header format. Expected: Bearer <token>",
            type: "authentication_error",
            code: "invalid_authorization_format"
          }
        },
        401
      );
    }
    const providedKey = match[1];
    if (providedKey !== c.env.OPENAI_API_KEY) {
      return c.json(
        {
          error: {
            message: "Invalid API key",
            type: "authentication_error",
            code: "invalid_api_key"
          }
        },
        401
      );
    }
  }
  await next();
}, "openAIApiKeyAuth");

// src/middlewares/logging.ts
var loggingMiddleware = /* @__PURE__ */ __name(async (c, next) => {
  const method = c.req.method;
  const path = c.req.path;
  const startTime = Date.now();
  const timestamp = (/* @__PURE__ */ new Date()).toISOString();
  let bodyLog = "";
  if (["POST", "PUT", "PATCH"].includes(method)) {
    try {
      const clonedReq = c.req.raw.clone();
      const body = await clonedReq.text();
      const truncatedBody = body.length > 500 ? body.substring(0, 500) + "..." : body;
      const maskedBody = truncatedBody.replace(/"(api_?key|token|authorization)":\s*"[^"]*"/gi, '"$1": "***"');
      bodyLog = ` - Body: ${maskedBody}`;
    } catch {
      bodyLog = " - Body: [unable to parse]";
    }
  }
  console.log(`[${timestamp}] ${method} ${path}${bodyLog} - Request started`);
  await next();
  const duration = Date.now() - startTime;
  const status = c.res.status;
  const endTimestamp = (/* @__PURE__ */ new Date()).toISOString();
  console.log(`[${endTimestamp}] ${method} ${path} - Completed with status ${status} (${duration}ms)`);
}, "loggingMiddleware");

// src/index.ts
var app = new Hono2();
app.use("*", loggingMiddleware);
app.use("*", async (c, next) => {
  c.header("Access-Control-Allow-Origin", "*");
  c.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  c.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (c.req.method === "OPTIONS") {
    c.status(204);
    return c.body(null);
  }
  await next();
});
app.use("/v1/*", openAIApiKeyAuth);
app.route("/v1", OpenAIRoute);
app.route("/v1/debug", DebugRoute);
app.route("/v1", DebugRoute);
app.get("/", (c) => {
  const requiresAuth = !!c.env.OPENAI_API_KEY;
  return c.json({
    name: "Gemini CLI OpenAI Worker",
    description: "OpenAI-compatible API for Google Gemini models via OAuth",
    version: "1.0.0",
    authentication: {
      required: requiresAuth,
      type: requiresAuth ? "Bearer token in Authorization header" : "None"
    },
    endpoints: {
      chat_completions: "/v1/chat/completions",
      models: "/v1/models",
      debug: {
        cache: "/v1/debug/cache",
        token_test: "/v1/token-test",
        full_test: "/v1/test"
      }
    },
    documentation: "https://github.com/gewoonjaap/gemini-cli-openai"
  });
});
app.get("/health", (c) => {
  return c.json({ status: "ok", timestamp: (/* @__PURE__ */ new Date()).toISOString() });
});
var index_default = app;
export {
  index_default as default
};
//# sourceMappingURL=index.js.map
