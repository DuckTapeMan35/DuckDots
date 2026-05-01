glide.prefs.set("browser.startup.homepage", "file:///home/duck/.cache/StartTree/index.html");
glide.o.newtab_url = "file:///home/duck/.cache/StartTree/index.html";

// ========== GLOBAL INITIALISATION ==========
let is_fully_initialized = false;
const compactState = new Map<number, boolean>();

// ========== PER‑WINDOW STATE ==========
interface WindowState {
  lastTabIds: string;
  refreshGeneration: number;
  debouncedRefresh: ReturnType<typeof createDebounce> & { cancel: () => void };
  compactModeHandlers?: {
    hoverTrigger: HTMLElement;
    toolboxMouseEnter: (e: Event) => void;
    toolboxMouseLeave: (e: Event) => void;
  };
}
const windowStates = new Map<number, WindowState>();

// Clean up when window closes
browser.windows.onRemoved.addListener((windowId: number) => {
  const state = windowStates.get(windowId);
  if (state) {
    state.debouncedRefresh.cancel();
    if (state.compactModeHandlers) {
      const { hoverTrigger, toolboxMouseEnter, toolboxMouseLeave } = state.compactModeHandlers;
      hoverTrigger?.remove();
      const toolbox = document.getElementById("navigator-toolbox");
      if (toolbox) {
        toolbox.removeEventListener("mouseenter", toolboxMouseEnter);
        toolbox.removeEventListener("mouseleave", toolboxMouseLeave);
      }
    }
    windowStates.delete(windowId);
  }
});

// ========== SAFE STYLE ADDITION ==========
function addStyleOnce(css: string, id: string) {
  if (!glide.styles.get(id)) glide.styles.add(css, { id });
}

// ========== COLORS ==========
async function set_colors() {
  try {
    await glide.include("colors.glide.ts");
    browser.theme.update({
      colors: {
        frame: glide.g.color0,
        tab_background_text: glide.g.color15,
        toolbar: glide.g.color1,
        toolbar_text: glide.g.color0,
        tab_line: glide.g.color0,
        toolbar_field: glide.g.color0,
        toolbar_field_text: glide.g.color15,
      },
    });
    update_status_bar_theme();
  } catch (e) {
    console.error("Failed to load colors:", e);
  }
}

async function unmap_tabs() {
  for (let i = 1; i <= 9; i++) {
    try { glide.keymaps.del("normal", `<leader>${i}`); } catch {}
  }
}
async function map_tabs() {
  const tabs = await glide.tabs.query({});
  tabs.forEach((tab, index) => {
    const tab_index = index + 1;
    if (tab_index > 9) return;
    glide.keymaps.set("normal", `<leader>${tab_index}`, () => {
      browser.tabs.update(tab.id, { active: true });
    });
  });
}

const COLOR_FILE_PATH = "/home/duck/.config/glide/colors.glide.ts";
async function start_file_watcher() {
  const proc = await glide.process.spawn(
    "inotifywait", ["-m", "-e", "modify", "--format", "%e", COLOR_FILE_PATH],
    { check_exit_code: false }
  );
  (async () => {
    for await (const line of proc.stdout.lines()) {
      if (line === "MODIFY") await set_colors();
    }
  })();
  proc.wait().then(() => setTimeout(start_file_watcher, 1000));
}

// ========== COMPACT MODE ==========
async function toggle_compact_mode() {
  const win = await browser.windows.getCurrent();
  const windowId = win.id!;
  const state = getWindowState(windowId);
  const compactModeActive = !compactState.get(windowId);
  compactState.set(windowId, compactModeActive);

  if (compactModeActive) {
    if (state.compactModeHandlers) {
      const old = state.compactModeHandlers;
      old.hoverTrigger?.remove();
      const toolbox = document.getElementById("navigator-toolbox");
      if (toolbox) {
        toolbox.removeEventListener("mouseenter", old.toolboxMouseEnter);
        toolbox.removeEventListener("mouseleave", old.toolboxMouseLeave);
      }
      state.compactModeHandlers = undefined;
    }

    let hoverTrigger = document.getElementById("compact-mode-hover-trigger");
    const toolbox = document.getElementById("navigator-toolbox");

    if (!hoverTrigger) {
      hoverTrigger = DOM.create_element("div", { id: "compact-mode-hover-trigger" }) as HTMLElement;
      document.body.appendChild(hoverTrigger);
    }

    let isHoveringTrigger = false;
    let isHoveringToolbox = false;
    let hideTimeout: number | null = null;

    const reveal = () => {
      if (hideTimeout) clearTimeout(hideTimeout);
      addStyleOnce(`
        #navigator-toolbox { transform: translateY(0) !important; opacity: 1 !important; }
        #TabsToolbar { visibility: visible !important; display: flex !important; }
      `, "compact-mode-reveal");
    };

    const scheduleHide = () => {
      if (hideTimeout) clearTimeout(hideTimeout);
      hideTimeout = setTimeout(() => {
        if (!isHoveringTrigger && !isHoveringToolbox) {
          glide.styles.remove("compact-mode-reveal");
        }
      }, 150);
    };

    const onTriggerEnter = () => { isHoveringTrigger = true; reveal(); };
    const onTriggerLeave = () => { isHoveringTrigger = false; scheduleHide(); };
    hoverTrigger.addEventListener("mouseenter", onTriggerEnter);
    hoverTrigger.addEventListener("mouseleave", onTriggerLeave);

    const onToolboxEnter = () => { isHoveringToolbox = true; reveal(); };
    const onToolboxLeave = () => { isHoveringToolbox = false; scheduleHide(); };
    if (toolbox) {
      toolbox.addEventListener("mouseenter", onToolboxEnter);
      toolbox.addEventListener("mouseleave", onToolboxLeave);
    }

    state.compactModeHandlers = {
      hoverTrigger,
      toolboxMouseEnter: onToolboxEnter,
      toolboxMouseLeave: onToolboxLeave,
    };

    addStyleOnce(`
      #compact-mode-hover-trigger {
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        height: 12px !important;
        z-index: 999999 !important;
        background: transparent !important;
        pointer-events: auto !important;
      }
      #navigator-toolbox {
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        transform: translateY(-100%) !important;
        opacity: 0 !important;
        transition: transform 0.2s ease, opacity 0.2s ease !important;
        z-index: 999998 !important;
      }
      #titlebar,
      #TabsToolbar,
      #nav-bar,
      #PersonalToolbar,
      #toolbar-menubar,
      .titlebar-buttonbox-container,
      .titlebar-spacer, #sidebar-box,
      #sidebar-splitter, findbar, #statuspanel,
      #notifications-toolbar, #glide-status-bar,
      #glide-mode-left-bar {
        display: none !important;
      }
      :root { --shimmer-top-bottom-browser-margin: 0 !important; }
      #browser, #appcontent, #tabbrowser-tabbox { margin: 0 !important; padding: 0 !important; top: 0 !important; }
      html, body { margin: 0 !important; padding: 0 !important; }
    `, "compact-mode");
  } else {
    if (state.compactModeHandlers) {
      const { hoverTrigger, toolboxMouseEnter, toolboxMouseLeave } = state.compactModeHandlers;
      hoverTrigger?.remove();
      const toolbox = document.getElementById("navigator-toolbox");
      if (toolbox) {
        toolbox.removeEventListener("mouseenter", toolboxMouseEnter);
        toolbox.removeEventListener("mouseleave", toolboxMouseLeave);
      }
      state.compactModeHandlers = undefined;
    }
    glide.styles.remove("compact-mode");
    glide.styles.remove("compact-mode-reveal");
  }
}

// ========== KEYMAPPINGS ==========
glide.autocmds.create("KeyStateChanged", ({ mode, sequence, partial }) => {
  if (mode === "normal" && sequence[0] === "<leader>" && partial) {
    unmap_tabs(); map_tabs();
  }
});
glide.o.switch_mode_on_focus = false;
glide.keymaps.set("normal", "<leader>q", "tab_close");
glide.keymaps.set("normal", "<leader>n", "tab_new");
glide.keymaps.set("normal", "<leader><Right>", "tab_next");
glide.keymaps.set("normal", "<C-Right>", "tab_next");
glide.keymaps.set("normal", "<leader><left>", "tab_prev");
glide.keymaps.set("normal", "<C-Left>", "tab_prev");
glide.keymaps.set("normal", "<leader><S-Right>", "forward");
glide.keymaps.set("normal", "<leader><S-Left>", "back");
glide.keymaps.set("normal", "<leader>R", "config_reload");
glide.keymaps.set("normal", "<leader>gh", () => { browser.tabs.update({ url: glide.o.newtab_url }); });
glide.keymaps.set("normal", "<leader>p", async () => set_colors());
glide.keymaps.set("normal", "<leader>m", toggle_compact_mode);

// ========== STATUS BAR HELPERS ==========
const status_bar_id = "glide-status-bar";
const mode_colors: Record<keyof GlideModes, string> = {
  command: "--glide-mode-command", hint: "--glide-mode-hint", ignore: "--glide-mode-ignore",
  insert: "--glide-mode-insert", normal: "--glide-mode-normal", "op-pending": "--glide-mode-op-pending",
  visual: "--glide-mode-visual",
};
const fallback_mode_color = "--glide-fallback-mode";

function update_status_bar_theme() {
  const style_id = "glide-status-bar-theme-vars";
  let style = document.getElementById(style_id) as HTMLStyleElement | null;
  if (!style) {
    style = DOM.create_element("style", { id: style_id }) as HTMLStyleElement;
    document.head.appendChild(style);
  }
  const bg = glide.g?.color0 ?? "#1a1a1a";
  const color0 = glide.g?.color0 ?? "#000000";
  const color15 = glide.g?.color15 ?? "#ffffff";
  const tabColors = [
    glide.g?.color1 ?? "#2aa198", glide.g?.color2 ?? "#859900", glide.g?.color3 ?? "#b58900",
    glide.g?.color4 ?? "#268bd2", glide.g?.color5 ?? "#6c71c4", glide.g?.color6 ?? "#d33682",
  ];
  function hexToRgb(hex: string): [number, number, number] {
    const h = hex.startsWith("#") ? hex.slice(1) : hex;
    return [parseInt(h.slice(0,2),16), parseInt(h.slice(2,4),16), parseInt(h.slice(4,6),16)];
  }
  function getLuminance(hex: string): number {
    const [r, g, b] = hexToRgb(hex);
    const rs = r / 255, gs = g / 255, bs = b / 255;
    const gamma = (c: number) => c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    return 0.2126 * gamma(rs) + 0.7152 * gamma(gs) + 0.0722 * gamma(bs);
  }
  let tabTextColorRules = "";
  for (let i = 0; i < tabColors.length; i++) {
    const color = tabColors[i];
    if (!color) continue;
    const luminance = getLuminance(color);
    const textColor = luminance > 0.5 ? color0 : color15;
    tabTextColorRules += ` --glide-tab${i+1}-text-color: ${textColor};`;
  }
  style.textContent = `
    :root {
      --glide-bg: ${bg}; --glide-color0: ${color0}; --glide-color15: ${color15};
      --glide-mode-bg: ${glide.g?.color4 ?? "#268bd2"}; --glide-mode-fg: ${glide.g?.color15 ?? "#ffffff"};
      --glide-tab1-bg: ${tabColors[0]}; --glide-tab2-bg: ${tabColors[1]}; --glide-tab3-bg: ${tabColors[2]};
      --glide-tab4-bg: ${tabColors[3]}; --glide-tab5-bg: ${tabColors[4]}; --glide-tab6-bg: ${tabColors[5]};
      ${tabTextColorRules}
    }
  `;
  const extraStyleId = "glide-tab-text-colors";
  if (!glide.styles.get(extraStyleId)) {
    glide.styles.add(`
      .glide-tab-color-1 .glide-tab-number, .glide-tab-color-1 .glide-tab-favicon-text, .glide-tab-color-1 .glide-tab-title { color: var(--glide-tab1-text-color); }
      .glide-tab-color-2 .glide-tab-number, .glide-tab-color-2 .glide-tab-favicon-text, .glide-tab-color-2 .glide-tab-title { color: var(--glide-tab2-text-color); }
      .glide-tab-color-3 .glide-tab-number, .glide-tab-color-3 .glide-tab-favicon-text, .glide-tab-color-3 .glide-tab-title { color: var(--glide-tab3-text-color); }
      .glide-tab-color-4 .glide-tab-number, .glide-tab-color-4 .glide-tab-favicon-text, .glide-tab-color-4 .glide-tab-title { color: var(--glide-tab4-text-color); }
      .glide-tab-color-5 .glide-tab-number, .glide-tab-color-5 .glide-tab-favicon-text, .glide-tab-color-5 .glide-tab-title { color: var(--glide-tab5-text-color); }
      .glide-tab-color-6 .glide-tab-number, .glide-tab-color-6 .glide-tab-favicon-text, .glide-tab-color-6 .glide-tab-title { color: var(--glide-tab6-text-color); }
    `, { id: extraStyleId });
  }
}

async function set_browser_theme() {
  try {
    await glide.include("colors.glide.ts");
    if (glide.g) {
      browser.theme.update({
        colors: {
          frame: glide.g.color0, tab_background_text: glide.g.color15, toolbar: glide.g.color1,
          toolbar_text: glide.g.color0, tab_line: glide.g.color0, toolbar_field: glide.g.color0,
          toolbar_field_text: glide.g.color15,
        },
      });
    }
  } catch (e) { console.error("Failed to load colors:", e); }
}

function create_status_bar_shell(): HTMLElement {
  return DOM.create_element("div", {
    id: status_bar_id,
    children: [DOM.create_element("div", { className: "glide-status-segment glide-status-mode-segment", children: [DOM.create_element("span", { className: "glide-status-mode-indicator", textContent: "nor" })] })],
  }) as HTMLElement;
}
function ensure_status_bar(): HTMLElement {
  let status_bar = document.getElementById(status_bar_id) as HTMLElement | null;
  if (!status_bar) {
    status_bar = create_status_bar_shell();
    document.getElementById("browser")?.appendChild(status_bar);
  }
  return status_bar;
}

function get_mode_short_name(mode: string): string {
  const map: Record<string,string> = { command:"com", hint:"hin", ignore:"ign", insert:"ins", normal:"nor", "op-pending":"opp", visual:"vis" };
  return map[mode] ?? mode.slice(0,3).toLowerCase();
}
function update_mode_indicator() {
  const status_bar = document.getElementById(status_bar_id);
  if (!status_bar) return;
  const indicator = status_bar.querySelector(".glide-status-mode-indicator") as HTMLElement | null;
  const segment = status_bar.querySelector(".glide-status-mode-segment") as HTMLElement | null;
  if (!indicator || !segment) return;
  indicator.textContent = get_mode_short_name(glide.ctx.mode);
  const colorVar = mode_colors[glide.ctx.mode as keyof GlideModes] ?? fallback_mode_color;
  segment.style.backgroundColor = `var(${colorVar})`;
  indicator.style.color = `var(--glide-bg)`;
}

function get_tab_color_class(index: number): string {
  return `glide-tab-color-${(index % 6) + 1}`;
}
function create_text_fallback(tab: any): HTMLElement {
  const title = tab.title || "Untitled";
  const displayText = title.trim().split(/\s+/).slice(0,3).map((w: string) => w[0]).join("");
  return DOM.create_element("span", { className: "glide-tab-favicon-text", textContent: displayText, attributes: { title, "aria-label": `Favicon fallback for ${title}` } }) as HTMLElement;
}
function create_favicon_element(tab: any): HTMLElement {
  const hasValidFavicon = tab.favIconUrl && tab.favIconUrl.trim() !== "" && !tab.favIconUrl.startsWith("chrome://") && !tab.favIconUrl.startsWith("about:");
  if (!hasValidFavicon) return create_text_fallback(tab);
  const img = DOM.create_element("img", { className: "glide-tab-favicon", attributes: { src: tab.favIconUrl, alt: "", "aria-hidden": "true" } }) as HTMLImageElement;
  img.onerror = () => { const parent = img.parentElement; if (parent) parent.replaceChild(create_text_fallback(tab), img); };
  return img;
}
function updateExistingTabElements(all_tabs: any[], active_tab_id: number | undefined) {
  const status_bar = document.getElementById(status_bar_id);
  if (!status_bar) return;
  const segments = Array.from(status_bar.querySelectorAll(".glide-tab-segment")) as HTMLElement[];
  
  if (segments.length > all_tabs.length) {
    for (let i = all_tabs.length; i < segments.length; i++) {
      segments[i]?.remove();
    }
  }
  
  for (let i = 0; i < segments.length && i < all_tabs.length; i++) {
    const segment = segments[i];
    const tab = all_tabs[i];
    if (!segment || !tab) continue;
    const is_active = tab.id === active_tab_id;
    if (is_active) segment.classList.add("active");
    else segment.classList.remove("active");
    segment.setAttribute("aria-selected", is_active ? "true" : "false");
    segment.setAttribute("title", `${i+1}: ${tab.title || "Untitled"}`);
    const numSpan = segment.querySelector(".glide-tab-number") as HTMLElement | null;
    if (numSpan && numSpan.textContent !== String(i+1)) numSpan.textContent = String(i+1);
    const existingImg = segment.querySelector(".glide-tab-favicon") as HTMLImageElement | null;
    const existingTextFallback = segment.querySelector(".glide-tab-favicon-text") as HTMLElement | null;
    const existingTitleSpan = segment.querySelector(".glide-tab-title") as HTMLElement | null;
    const hasValidFavicon = tab.favIconUrl && !tab.favIconUrl.startsWith("chrome://") && !tab.favIconUrl.startsWith("about:");
    if (hasValidFavicon) {
      if (existingImg && existingImg.src !== tab.favIconUrl) existingImg.src = tab.favIconUrl;
      else if (!existingImg) {
        const newImg = create_favicon_element(tab);
        if (existingTextFallback) existingTextFallback.replaceWith(newImg);
        else if (existingTitleSpan) segment.insertBefore(newImg, existingTitleSpan);
        else segment.appendChild(newImg);
      }
      if (existingTitleSpan) existingTitleSpan.remove();
    } else {
      if (!existingTextFallback) {
        const newFallback = create_text_fallback(tab);
        if (existingImg) existingImg.replaceWith(newFallback);
        else if (existingTitleSpan) segment.insertBefore(newFallback, existingTitleSpan);
        else segment.appendChild(newFallback);
      } else {
        const newDisplay = tab.title?.trim().split(/\s+/).slice(0,3).map((w: string) => w[0]).join("") || "?";
        if (existingTextFallback.textContent !== newDisplay) existingTextFallback.textContent = newDisplay;
        existingTextFallback.setAttribute("title", tab.title || "Untitled");
      }
      if (!existingTitleSpan && tab.title) {
        const titleSpan = DOM.create_element("span", { className: "glide-tab-title", textContent: tab.title.length > 20 ? tab.title.substring(0,20)+"..." : tab.title }) as HTMLElement;
        segment.appendChild(titleSpan);
      } else if (existingTitleSpan && tab.title) {
        const newTitle = tab.title.length > 20 ? tab.title.substring(0,20)+"..." : tab.title;
        if (existingTitleSpan.textContent !== newTitle) existingTitleSpan.textContent = newTitle;
      }
    }
    const newColorClass = get_tab_color_class(i);
    for (let c = 1; c <= 6; c++) segment.classList.remove(`glide-tab-color-${c}`);
    segment.classList.add(newColorClass);
  }
}

function createNewTabSegment(): HTMLElement {
  const newTabSegment = DOM.create_element("div", {
    className: "glide-status-segment glide-new-tab-segment",
    attributes: { title: "New Tab (Ctrl+T)", "aria-label": "New Tab", role: "button", tabindex: "0" },
    children: [DOM.create_element("span", { className: "glide-new-tab-icon", textContent: "+" })],
  }) as HTMLElement;
  newTabSegment.addEventListener("click", async (e) => { e.stopPropagation(); try { await browser.tabs.create({}); } catch(err) { console.error(err); } });
  newTabSegment.addEventListener("keydown", (e) => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); newTabSegment.click(); } });
  return newTabSegment;
}

// ========== PER‑WINDOW REFRESH LOGIC ==========
async function refresh_tabs_list_for_window(windowId: number) {
  try {
    const win = await browser.windows.get(windowId).catch(() => null);
    if (!win) return;

    const raw_tabs = await browser.tabs.query({ windowId });
    const all_tabs = raw_tabs
      .filter((t: any) => t.id != null)
      .sort((a: any, b: any) => (a.index ?? 0) - (b.index ?? 0));

    let active_tab_id: number | undefined;
    try {
      active_tab_id = (await glide.tabs.active()).id;
    } catch {
      const [active] = await browser.tabs.query({ active: true, windowId });
      active_tab_id = active?.id;
    }

    const status_bar = ensure_status_bar();
    if (!status_bar) return;

    const state = getWindowState(windowId);
    const newTabIds = all_tabs.map((t: any) => t.id).join(",");
    if (newTabIds === state.lastTabIds && all_tabs.length > 0) {
      updateExistingTabElements(all_tabs, active_tab_id);
      let newTabBtn = status_bar.querySelector(".glide-new-tab-segment") as HTMLElement | null;
      if (!newTabBtn) status_bar.appendChild(createNewTabSegment());
      return;
    }

    state.lastTabIds = newTabIds;
    const modeSegment = status_bar.querySelector(".glide-status-mode-segment");
    status_bar.innerHTML = "";
    if (modeSegment) status_bar.appendChild(modeSegment);

    for (let i = 0; i < all_tabs.length; i++) {
      const tab = all_tabs[i];
      if (!tab) continue;

      const is_active = tab.id === active_tab_id;
      const colorClass = get_tab_color_class(i);
      const tab_segment = DOM.create_element("div", {
        className: `glide-status-segment glide-tab-segment ${colorClass}${is_active ? " active" : ""}`,
        attributes: { role: "tab", "aria-selected": is_active ? "true" : "false", title: `${i+1}: ${tab.title || "Untitled"}`, "data-tab-id": String(tab.id) },
      }) as HTMLElement;
      tab_segment.appendChild(DOM.create_element("span", { className: "glide-tab-number", textContent: String(i+1) }));
      tab_segment.appendChild(create_favicon_element(tab));
      const hasValidFavicon = tab.favIconUrl && !tab.favIconUrl.startsWith("chrome://") && !tab.favIconUrl.startsWith("about:");
      if (!hasValidFavicon) {
        tab_segment.appendChild(DOM.create_element("span", { className: "glide-tab-title", textContent: (tab.title || "Untitled").length > 20 ? (tab.title || "Untitled").substring(0,20)+"..." : (tab.title || "Untitled") }));
      }
      const tab_id = tab.id;
      tab_segment.addEventListener("click", async () => { try { await browser.tabs.update(tab_id, { active: true }); } catch(e) { console.error(e); } });
      tab_segment.addEventListener("contextmenu", async (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (typeof tab.id === "number") {
          try { await browser.tabs.remove(tab.id); } catch(err) { console.error(err); }
        }
      });
      status_bar.appendChild(tab_segment);
    }
    status_bar.appendChild(createNewTabSegment());
  } catch (e) {
    if (!String(e).includes("NS_ERROR_NOT_INITIALIZED")) console.error("refresh_tabs_list_for_window:", e);
  }
}

// Debounce factory (per window)
function createDebounce<T extends (...args: any[]) => any>(fn: T, delay: number): T & { cancel: () => void } {
  let timer: ReturnType<typeof setTimeout> | undefined;
  const debounced = async function(this: any, ...args: Parameters<T>) {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => { fn.apply(this, args); }, delay);
  } as T & { cancel: () => void };
  debounced.cancel = () => { if (timer) clearTimeout(timer); };
  return debounced;
}

function getWindowState(windowId: number): WindowState {
  let state = windowStates.get(windowId);
  if (!state) {
    state = {
      lastTabIds: "",
      refreshGeneration: 0,
      debouncedRefresh: createDebounce(refresh_tabs_list_for_window, 50),
    };
    windowStates.set(windowId, state);
  }
  return state;
}

// ========== PER‑WINDOW LISTENER SETUP ==========
function setupTabListenersForWindow(windowId: number) {
  const state = getWindowState(windowId);
  const debounced = state.debouncedRefresh;

  const onActivated = () => debounced(windowId);
  const onUpdated = (_tabId: number, changeInfo: any) => {
    if (changeInfo.url || changeInfo.title || changeInfo.favIconUrl) {
      debounced(windowId);
    }
  };
  const onMoved = () => debounced(windowId);
  const onReplaced = () => debounced(windowId);

  // Handle tab creation scoped to this window
  const onCreated = (tab: Browser.Tabs.Tab) => {
    if (tab.windowId === windowId) {
      refresh_tabs_list_for_window(windowId).catch(console.error);
      update_mode_indicator();
    }
  };

  // Handle tab removal scoped to this window — windowId is safely captured by
  // closure so there is no risk of removeInfo.windowId being undefined/stale.
  const onRemoved = (_tabId: number, removeInfo: { windowId: number; isWindowClosing: boolean }) => {
    if (removeInfo.isWindowClosing || removeInfo.windowId !== windowId) return;
    debounced.cancel();                   // cancel any in-flight debounce
    const st = windowStates.get(windowId);
    if (st) st.lastTabIds = "";           // force full rebuild on next refresh
    ensure_status_bar();
    refresh_tabs_list_for_window(windowId).catch(console.error);
    update_mode_indicator();
  };

  browser.tabs.onActivated.addListener(onActivated);
  browser.tabs.onUpdated.addListener(onUpdated);
  browser.tabs.onMoved.addListener(onMoved);
  browser.tabs.onReplaced.addListener(onReplaced);
  browser.tabs.onCreated.addListener(onCreated);
  browser.tabs.onRemoved.addListener(onRemoved);

  const onWindowRemoved = (closedWindowId: number) => {
    if (closedWindowId === windowId) {
      browser.tabs.onActivated.removeListener(onActivated);
      browser.tabs.onUpdated.removeListener(onUpdated);
      browser.tabs.onMoved.removeListener(onMoved);
      browser.tabs.onReplaced.removeListener(onReplaced);
      browser.tabs.onCreated.removeListener(onCreated);
      browser.tabs.onRemoved.removeListener(onRemoved);
      browser.windows.onRemoved.removeListener(onWindowRemoved);
      const st = windowStates.get(windowId);
      if (st) {
        st.debouncedRefresh.cancel();
        if (st.compactModeHandlers) {
          const { hoverTrigger, toolboxMouseEnter, toolboxMouseLeave } = st.compactModeHandlers;
          hoverTrigger?.remove();
          const toolbox = document.getElementById("navigator-toolbox");
          if (toolbox) {
            toolbox.removeEventListener("mouseenter", toolboxMouseEnter);
            toolbox.removeEventListener("mouseleave", toolboxMouseLeave);
          }
        }
        windowStates.delete(windowId);
      }
    }
  };
  browser.windows.onRemoved.addListener(onWindowRemoved);
}

// ========== AUTOCMDS ==========
glide.autocmds.create("ConfigLoaded", async () => {
  if (!is_fully_initialized) {
    is_fully_initialized = true;
    await set_colors();
    start_file_watcher();
    await set_browser_theme();
    update_status_bar_theme();

    addStyleOnce(`
      #browser { position: relative !important; }
      #glide-status-bar {
        --seg-h: 28px; --seg-notch: 10px;
        position: fixed; bottom: 0; left: 0; right: 0; height: var(--seg-h);
        display: flex; align-items: stretch; z-index: 10000;
        font-family: "Fira Code", monospace; font-size: 12px; line-height: var(--seg-h);
        box-shadow: 0 -1px 3px rgba(0,0,0,0.3); overflow-x: auto; overflow-y: hidden;
        background-color: var(--glide-bg);
      }
      #glide-status-bar::-webkit-scrollbar { height: 3px; }
      #glide-status-bar::-webkit-scrollbar-track { background: var(--glide-bg); }
      #glide-status-bar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 0; }
      #glide-status-bar .glide-status-segment {
        position: relative; display: flex; align-items: center; gap: 6px;
        padding: 0 12px 0 10px; white-space: nowrap; flex-shrink: 0;
        clip-path: polygon(0 0, calc(100% - var(--seg-notch)) 0, 100% 50%, calc(100% - var(--seg-notch)) 100%, 0 100%, var(--seg-notch) 50%);
        margin-right: calc(var(--seg-notch) * -1);
      }
      #glide-status-bar .glide-status-mode-segment {
        clip-path: polygon(0 0, calc(100% - var(--seg-notch)) 0, 100% 50%, calc(100% - var(--seg-notch)) 100%, 0 100%) !important;
        background-color: var(--glide-bg); font-weight: bold; text-transform: uppercase;
        letter-spacing: 1px; min-width: 52px; justify-content: center;
      }
      #glide-status-bar .glide-status-mode-indicator { transition: color 0.15s ease; }
      #glide-status-bar .glide-tab-segment { cursor: pointer; transition: filter 0.15s ease; }
      #glide-status-bar .glide-tab-segment:hover { filter: brightness(0.92); }
      #glide-status-bar .glide-tab-segment.active { font-weight: bold; background-image: linear-gradient(rgba(255,255,255,0.05), rgba(255,255,255,0.05)); }
      #glide-status-bar .glide-tab-segment:last-of-type { margin-right: 0; }
      #glide-status-bar .glide-tab-color-1 { background-color: var(--glide-tab1-bg); }
      #glide-status-bar .glide-tab-color-2 { background-color: var(--glide-tab2-bg); }
      #glide-status-bar .glide-tab-color-3 { background-color: var(--glide-tab3-bg); }
      #glide-status-bar .glide-tab-color-4 { background-color: var(--glide-tab4-bg); }
      #glide-status-bar .glide-tab-color-5 { background-color: var(--glide-tab5-bg); }
      #glide-status-bar .glide-tab-color-6 { background-color: var(--glide-tab6-bg); }
      #glide-status-bar .glide-tab-number { font-size: 14px; opacity: 0.8; min-width: 12px; padding-left: 4px; line-height: 1; }
      #glide-status-bar .glide-tab-favicon { width: 14px; height: 14px; border-radius: 2px; flex-shrink: 0; }
      #glide-status-bar .glide-tab-favicon-text {
        width: 14px;
        height: 14px;
        flex-shrink: 0;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        font-weight: 600;
        border-radius: 2px;
        background-color: rgba(0,0,0,0.2);
        text-transform: uppercase;
      }
      #glide-status-bar .glide-tab-title { font-size: 12px; }
      #glide-status-bar .glide-new-tab-segment {
        background-color: var(--glide-bg);
        color: rgba(255,255,255,0.6);
        cursor: pointer;
        transition: color 0.15s ease, background-color 0.15s ease;
        min-width: 42px;
        justify-content: center;
        clip-path: polygon(0 0, calc(100% - var(--seg-notch)) 0, 100% 50%, calc(100% - var(--seg-notch)) 100%, 0 100%, var(--seg-notch) 50%);
        margin-right: 0;
      }
      #glide-status-bar .glide-new-tab-segment:hover { background-color: rgba(255,255,255,0.18); color: var(--glide-color15); }
      #glide-status-bar .glide-new-tab-icon { font-size: 22px; line-height: 1; transition: transform 0.2s ease; }
      #glide-status-bar .glide-new-tab-segment:hover .glide-new-tab-icon { transform: scale(1.2); }
      #browser { padding-bottom: 28px; }
    `, "glide-status-bar-styles");
    addStyleOnce(`#TabsToolbar { visibility: collapse !important; }`, "glide-hide-native-tabs");
  }

  const win = await browser.windows.getCurrent();
  if (win.id) {
    setupTabListenersForWindow(win.id);
    await refresh_tabs_list_for_window(win.id);
    update_mode_indicator();
  }
});

glide.autocmds.create("WindowLoaded", async () => {
  try {
    const win = await browser.windows.getCurrent();
    const windowId = win.id!;
    ensure_status_bar();
    await refresh_tabs_list_for_window(windowId);
    update_mode_indicator();
    setupTabListenersForWindow(windowId);
  } catch (e) {
    console.error("WindowLoaded setup failed", e);
  }
});

glide.autocmds.create("ModeChanged", "*", () => update_mode_indicator());
glide.autocmds.create("UrlEnter", /.*/, async () => {
  ensure_status_bar();
  const win = await browser.windows.getCurrent();
  if (win.id) await refresh_tabs_list_for_window(win.id);
  update_mode_indicator();
});
