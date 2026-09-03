import json
import re
import socket
import subprocess
import time
from collections import defaultdict
from datetime import datetime, timezone

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.rgb import Color
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)
from kitty.utils import color_as_int

timer_id = None

ICON = "  "
RIGHT_MARGIN = 1
REFRESH_TIME = 5  # seconds between forced tab-bar redraws (clock / VPN / DnD)

icon_fg = as_rgb(color_as_int(Color(255, 250, 205)))
icon_bg = as_rgb(color_as_int(Color(47, 61, 68)))
# OR icon_bg = as_rgb(0x2f3d44)
# --- left prefix (program name + hostname + keyboard-mode indicator) ---
# Short, tmux-style local hostname (strip any DNS suffix), first 5 chars —
# same source tmux's #h uses. Cached at module load.
HOSTNAME = socket.gethostname().split(".")[0][:6]

# Pritunl VPN badge: when a CLI profile is connected, show its env in place of the
# hostname. list -j is cached with a short TTL so the client isn't spawned on every
# tab-bar redraw. Only CLI-started connections show here — GUI-started ones live in
# a separate profile store.
PRITUNL_BIN = "/Applications/Pritunl.app/Contents/Resources/pritunl-client"
VPN_TTL = 10  # seconds
_vpn_cache = {"ts": -VPN_TTL, "env": ""}


def _env_from_name(name: str) -> str:
    # "vincent.cradler-gov (devops) cli" -> "gov"; "vincent.cradler-ussf cli" -> "ussf".
    # Drop a trailing " cli" tag and any " (server)" parenthetical, then take the
    # segment after the last dash.
    name = re.sub(r"\s*\bcli\b\s*$", "", name)
    name = re.sub(r"\s*\([^)]*\)", "", name).strip()
    if "-" in name:
        name = name.rsplit("-", 1)[-1]
    return name.strip()


def _vpn_env() -> str:
    # Env label of the connected pritunl CLI profile, or "" if none/unavailable.
    # Wrapped defensively: a missing or hung client must never break the tab bar.
    now = time.monotonic()
    if now - _vpn_cache["ts"] < VPN_TTL:
        return _vpn_cache["env"]
    _vpn_cache["ts"] = now
    env = ""
    try:
        result = subprocess.run(
            [PRITUNL_BIN, "list", "-j"], capture_output=True, timeout=2
        )
        if result.returncode == 0 and result.stdout:
            for p in json.loads(result.stdout.decode("utf-8")):
                if p.get("connected") or p.get("status") == "Connected":
                    env = _env_from_name(p.get("name", ""))
                    break
    except Exception:
        env = ""
    _vpn_cache["env"] = env
    return env


def _c(color) -> int:
    # kitty Color -> tab-bar rgb int.
    return as_rgb(color_as_int(color))


def _theme():
    # Colors derived live from the active kitty theme (current-theme.conf) via
    # the ANSI palette, so the bar tracks whatever theme is loaded — including
    # after a `load-config`. Returns a dict of ready-to-use tab-bar rgb ints.
    o = get_options()
    bg = _c(o.background)
    return {
        # badges: theme background as text on an ANSI accent block
        "prog_fg": bg, "prog_bg": _c(o.color4),     # blue accent
        "host_fg": _c(o.color6), "host_bg": bg,     # cyan on bar bg
        "vpn_fg": bg, "vpn_bg": _c(o.color2),       # dark on green = VPN connected
        "pass_fg": bg, "pass_bg": _c(o.color1),     # loud red = shortcuts off
        "win_fg": bg, "win_bg": _c(o.color3),       # amber = leader mode
        # tabs: active tab is a saturated accent block (tmux current-window
        # style) so it pops off the near-black bar; inactive tabs are bright
        # text on the bar bg. active_tab_background (#4d4d4d) was too close to
        # the bar bg to read as "selected".
        "tab_afg": bg, "tab_abg": _c(o.color2),          # dark on green
        "tab_ifg": _c(o.foreground), "tab_ibg": bg,       # light on bar bg
        # right status
        "clock": _c(o.color6),
        "utc": _c(o.color8),
        "dnd": _c(o.color5),
        "sep": _c(o.color8),
    }


# cells = [
#     (Color(113, 115, 116), dnd),
#     (Color(135, 192, 149), clock),
#     (Color(113, 115, 116), utc),
# ]


def calc_draw_spaces(*args) -> int:
    length = 0
    for i in args:
        if not isinstance(i, str):
            i = str(i)
        length += len(i)
    return length


def _draw_icon(screen: Screen, index: int) -> int:
    if index != 1:
        return 0

    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.draw(ICON)
    screen.cursor.fg, screen.cursor.bg = fg, bg
    screen.cursor.x = len(ICON)
    return screen.cursor.x


def _keyboard_mode() -> str:
    # '' == normal, 'winmode' == ctrl+a leader, 'passthrough' == shortcuts off.
    # Wrapped defensively: a kitty API change should degrade to "no badge",
    # never crash the whole tab bar.
    try:
        return get_boss().mappings.current_keyboard_mode_name
    except Exception:
        return ""


def _draw_left_prefix(screen: Screen, index: int) -> int:
    # Draw the prefix once, ahead of the first tab. Returns its cell width so
    # draw_tab can offset the first tab's title-truncation accounting.
    if index != 1:
        return 0

    t = _theme()
    screen.cursor.x = 0
    screen.cursor.bold = True
    screen.cursor.fg, screen.cursor.bg = t["prog_fg"], t["prog_bg"]
    screen.draw(" kitty ")
    screen.cursor.bold = False

    vpn = _vpn_env()
    if vpn:
        screen.cursor.fg, screen.cursor.bg = t["vpn_fg"], t["vpn_bg"]
        screen.draw(f"  {vpn} ")
    else:
        screen.cursor.fg, screen.cursor.bg = t["host_fg"], t["host_bg"]
        screen.draw(f" @{HOSTNAME} ")

    mode = _keyboard_mode()
    if mode == "passthrough":
        screen.cursor.fg, screen.cursor.bg = t["pass_fg"], t["pass_bg"]
        screen.draw(" ⌨ shortcuts off ")
    elif mode == "winmode":
        screen.cursor.fg, screen.cursor.bg = t["win_fg"], t["win_bg"]
        screen.draw(" ⌨ winmode ")

    # reset attributes before the tab titles are drawn
    screen.cursor.bold = screen.cursor.italic = False
    screen.cursor.fg = 0
    screen.cursor.bg = 0
    return screen.cursor.x


TITLE_CAP = 18  # max title chars for a rendered (named) tab


def _active_index() -> int:
    # 1-based index of the active tab, or -1 if it can't be determined.
    try:
        tm = get_boss().active_tab_manager
        return tm.active_tab_idx + 1 if tm is not None else -1
    except Exception:
        return -1


def _tab_flags(tab: TabBarData) -> str:
    # tmux-style #F flags: * current, Z zoomed, ! bell/attention, # activity.
    flags = ""
    if getattr(tab, "layout_name", "") == "stack":
        flags += "Z"
    if tab.needs_attention:
        flags += "!"
    elif getattr(tab, "has_activity_since_last_focus", False):
        flags += "#"
    if tab.is_active:
        flags += "*"
    return flags


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # tmux window-list style: the active tab and its immediate neighbours
    # (index ±1) show "index:name"; every other tab shows just its number.
    # Theme-derived colors (re-asserted here because the left prefix reset them
    # to the default for tab 1, and to give the active tab a high-contrast
    # accent block against the near-black bar).
    th = _theme()
    if tab.is_active:
        screen.cursor.bg, screen.cursor.fg = th["tab_abg"], th["tab_afg"]
    else:
        screen.cursor.bg, screen.cursor.fg = th["tab_ibg"], th["tab_ifg"]
    screen.cursor.bold = screen.cursor.italic = tab.is_active

    active = _active_index()
    named = tab.is_active or (active > 0 and abs(index - active) <= 1)
    flags = _tab_flags(tab)

    if named:
        title = tab.title or ""
        if len(title) > TITLE_CAP:
            title = title[: TITLE_CAP - 1] + "…"
        label = f" {index}:{title}{flags} "
    else:
        label = f" {index}{flags} "

    screen.draw(label)
    end = screen.cursor.x

    # reset to bar background and add a one-cell gap between tabs
    screen.cursor.bold = screen.cursor.italic = False
    screen.cursor.fg = 0
    screen.cursor.bg = 0
    if not is_last:
        screen.draw(" ")
    return end


def _get_dnd_status():
    # Best-effort: the helper lives outside this repo and may not exist. Never
    # let its absence take down the tab bar — just report "no status".
    try:
        result = subprocess.run(
            "~/.dotfiles/bin/dnd -k", shell=True, capture_output=True
        )
    except Exception:
        return ""

    if result.returncode != 0 or not result.stdout:
        return ""

    return result.stdout.decode("utf-8").strip()


# more handy kitty tab_bar things:
# REF: https://github.com/kovidgoyal/kitty/discussions/4447#discussioncomment-2183440
def _draw_right_status(screen: Screen, is_last: bool) -> int:
    if not is_last:
        return 0
    # global timer_id
    # if timer_id is None:
    #     timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

    draw_attributed_string(Formatter.reset, screen)

    t = _theme()
    clock = datetime.now().strftime("%H:%M")
    utc = datetime.now(timezone.utc).strftime(" (UTC %H:%M)")
    dnd = _get_dnd_status()

    cells = []
    if dnd != "":
        cells.append((t["dnd"], dnd))
        cells.append((t["sep"], " ⋮ "))

    cells.append((t["clock"], clock))
    cells.append((t["utc"], utc))

    # right_status_length = calc_draw_spaces(dnd + " " + clock + " " + utc)

    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[1]))

    draw_spaces = screen.columns - screen.cursor.x - right_status_length

    if draw_spaces > 0:
        screen.draw(" " * draw_spaces)

    screen.cursor.fg = 0
    for color, status in cells:
        screen.cursor.fg = color  # as_rgb(color_as_int(color))
        screen.draw(status)
    screen.cursor.bg = 0

    if screen.columns - screen.cursor.x > right_status_length:
        screen.cursor.x = screen.columns - right_status_length

    return screen.cursor.x


# REF: https://github.com/kovidgoyal/kitty/discussions/4447#discussioncomment-1940795
# def _redraw_tab_bar():
#     tm = get_boss().active_tab_manager
#     if tm is not None:
#         tm.mark_tab_bar_dirty()


def _redraw_tab_bar(_) -> None:
    # Timer callback: mark the tab bar dirty so kitty repaints it even without a
    # keyboard/focus event, keeping the clock and VPN badge current.
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:

    # Register a repeating timer once so the bar refreshes on a cadence rather
    # than only on input events — there's always live info (clock, VPN) to show.
    global timer_id
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

    # Left prefix replaces the old single-glyph icon: program name, hostname,
    # and (only when active) a keyboard-mode badge. Its width shifts where the
    # first tab's title begins, so feed it into `before` to keep the title
    # truncation math correct for tab 1.
    prefix_w = _draw_left_prefix(screen, index)
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before + prefix_w,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        screen,
        is_last,
    )

    return screen.cursor.x


# # pyright: reportMissingImports=false

# # REF: https://github.com/kovidgoyal/kitty/discussions/4447#discussioncomment-3240635
# import subprocess
# from datetime import datetime, timezone
# from pprint import pprint

# # from kitty.boss import get_boss
# from kitty.fast_data_types import Screen, add_timer, get_boss, get_options
# from kitty.rgb import Color
# from kitty.tab_bar import (
#     DrawData,
#     ExtraData,
#     Formatter,
#     TabBarData,
#     as_rgb,
#     draw_attributed_string,
#     draw_title,
# )
# from kitty.utils import color_as_int

# opts = get_options()
# icon_fg = as_rgb(color_as_int(Color(255, 250, 205)))
# icon_bg = as_rgb(color_as_int(Color(47, 61, 68)))
# # OR icon_bg = as_rgb(0x2f3d44)
# bat_text_color = as_rgb(0x999F93)
# clock_color = as_rgb(0x7FBBB3)
# utc_color = as_rgb(color_as_int(Color(113, 115, 116)))

# # BATTERY_CMD = "pmset -g batt | awk -F '; *' 'NR==2 { print $2 }'"
# SEPARATOR_SYMBOL, SOFT_SEPARATOR_SYMBOL = ("", "")
# RIGHT_MARGIN = 1
# REFRESH_TIME = 5
# ICON = "  "
# UNPLUGGED_ICONS = {
#     10: "",
#     20: "",
#     30: "",
#     40: "",
#     50: "",
#     60: "",
#     70: "",
#     80: "",
#     90: "",
#     100: "",
# }
# PLUGGED_ICONS = {
#     1: "",
# }
# UNPLUGGED_COLORS = {
#     15: as_rgb(color_as_int(opts.color1)),
#     16: as_rgb(color_as_int(opts.color15)),
# }
# PLUGGED_COLORS = {
#     15: as_rgb(color_as_int(opts.color1)),
#     16: as_rgb(color_as_int(opts.color6)),
#     99: as_rgb(color_as_int(opts.color6)),
#     100: as_rgb(0xA7C080),
# }


# def _draw_icon(screen: Screen, index: int) -> int:
#     if index != 1:
#         return 0
#     fg, bg = screen.cursor.fg, screen.cursor.bg
#     screen.cursor.fg = icon_fg
#     screen.cursor.bg = icon_bg
#     screen.draw(ICON)
#     screen.cursor.fg, screen.cursor.bg = fg, bg
#     screen.cursor.x = len(ICON)
#     return screen.cursor.x


# def _draw_left_status(
#     draw_data: DrawData,
#     screen: Screen,
#     tab: TabBarData,
#     before: int,
#     max_title_length: int,
#     index: int,
#     is_last: bool,
#     extra_data: ExtraData,
# ) -> int:
#     if screen.cursor.x >= screen.columns - right_status_length:
#         return screen.cursor.x
#     tab_bg = screen.cursor.bg
#     tab_fg = screen.cursor.fg
#     default_bg = as_rgb(int(draw_data.default_bg))
#     if extra_data.next_tab:
#         next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
#         needs_soft_separator = next_tab_bg == tab_bg
#     else:
#         next_tab_bg = default_bg
#         needs_soft_separator = False
#     if screen.cursor.x <= len(ICON):
#         screen.cursor.x = len(ICON)
#     # screen.draw(" ")
#     screen.cursor.bg = tab_bg

#     # @REF: https://github.com/kovidgoyal/kitty/discussions/4447#discussioncomment-3459140
#     # title = f"{opts.os_window_class}{tab.title}"
#     # tab = TabBarData(
#     #     title,
#     #     tab.is_active,
#     #     tab.needs_attention,
#     #     tab.num_windows,
#     #     tab.num_window_groups,
#     #     tab.layout_name,
#     #     tab.has_activity_since_last_focus,
#     #     tab.active_fg,
#     #     tab.active_bg,
#     #     tab.inactive_fg,
#     #     tab.inactive_bg,
#     # )
#     # pprint(dir(tab))
#     # pprint(vars(screen))
#     draw_title(draw_data, screen, tab, index)

#     if not needs_soft_separator:
#         # screen.draw(" ")
#         screen.cursor.fg = tab_bg
#         screen.cursor.bg = next_tab_bg
#         # screen.draw(SEPARATOR_SYMBOL)
#     else:
#         prev_fg = screen.cursor.fg
#         if tab_bg == tab_fg:
#             screen.cursor.fg = default_bg
#         elif tab_bg != default_bg:
#             c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
#             c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
#             if c1 < c2:
#                 screen.cursor.fg = default_bg
#         # screen.draw(" " + SOFT_SEPARATOR_SYMBOL)
#         screen.cursor.fg = prev_fg
#     end = screen.cursor.x
#     return end


# def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
#     if not is_last:
#         return 0
#     draw_attributed_string(Formatter.reset, screen)
#     screen.cursor.x = screen.columns - right_status_length
#     screen.cursor.fg = 0
#     for color, status in cells:
#         screen.cursor.fg = color
#         screen.draw(status)
#     screen.cursor.bg = 0
#     return screen.cursor.x


# def _redraw_tab_bar(_):
#     tm = get_boss().active_tab_manager
#     if tm is not None:
#         tm.mark_tab_bar_dirty()


# def get_battery_cells() -> list:
#     s_result = subprocess.run(
#         "~/.dotfiles/bin/btry -s", shell=True, capture_output=True
#     )
#     status = ""

#     if s_result.stderr:
#         raise subprocess.CalledProcessError(
#             returncode=s_result.returncode, cmd=s_result.args, stderr=s_result.stderr
#         )

#     if s_result.stdout:
#         status = s_result.stdout.decode("utf-8").strip()

#     p_result = subprocess.run(
#         "~/.dotfiles/bin/btry -p", shell=True, capture_output=True
#     )
#     percent = ""

#     if p_result.stderr:
#         raise subprocess.CalledProcessError(
#             returncode=p_result.returncode, cmd=p_result.args, stderr=p_result.stderr
#         )

#     if p_result.stdout:
#         percent = int(p_result.stdout.decode("utf-8").strip())

#     if status == "Discharging \n":
#         # TODO: declare the lambda once and don't repeat the code
#         icon_color = UNPLUGGED_COLORS[
#             min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#         ]
#         icon = UNPLUGGED_ICONS[
#             min(UNPLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
#         ]
#     elif status == "Not charging \n":
#         icon_color = UNPLUGGED_COLORS[
#             min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#         ]
#         icon = PLUGGED_ICONS[min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))]
#     else:
#         icon_color = PLUGGED_COLORS[
#             min(PLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#         ]
#         icon = PLUGGED_ICONS[min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))]

#     percent_cell = (bat_text_color, " " + str(percent) + "%")
#     icon_cell = (icon_color, icon)
#     return [icon_cell, percent_cell]


# timer_id = None
# right_status_length = -1


# def draw_tab(
#     draw_data: DrawData,
#     screen: Screen,
#     tab: TabBarData,
#     before: int,
#     max_title_length: int,
#     index: int,
#     is_last: bool,
#     extra_data: ExtraData,
# ) -> int:
#     # pprint(vars(get_boss()))
#     global timer_id
#     global right_status_length
#     # if timer_id is None:
#     #     timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

#     date = datetime.now().strftime("%d.%m.%Y")
#     clock = datetime.now().strftime("%H:%M")
#     utc = datetime.now(timezone.utc).strftime(" (UTC %H:%M)")

#     cells = get_battery_cells()
#     cells.append((as_rgb(color_as_int(opts.color255)), " ⋮ "))
#     cells.append((clock_color, clock))
#     cells.append((utc_color, utc))

#     right_status_length = RIGHT_MARGIN
#     for cell in cells:
#         right_status_length += len(str(cell[1]))

#     _draw_icon(screen, index)
#     _draw_left_status(
#         draw_data,
#         screen,
#         tab,
#         before,
#         max_title_length,
#         index,
#         is_last,
#         extra_data,
#     )
#     _draw_right_status(
#         screen,
#         is_last,
#         cells,
#     )
#     return screen.cursor.x
