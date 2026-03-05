#!/usr/bin/env python3
# menu_plugin
PLUGIN_NAME="Murk Manager"
PLUGIN_FUNCTION="Simple file manager"
PLUGIN_DESCRIPTION="File manager with copy, move, delete, rename, search, permissions management, and custom text editor."
PLUGIN_AUTHOR="Star"
PLUGIN_VERSION="2.3"

import os
import shutil
import curses
import tempfile

START_DIR = os.path.realpath(".")

FILE_COLOR_MAP = {
    "sh": "yellow",
    "jpg": "brown", "jpeg": "brown", "png": "brown", "gif": "brown",
    "bmp": "brown", "svg": "brown", "ico": "brown", "tiff": "brown",
    "json": "cyan",
    "mp3": "purple", "mp4": "purple", "mov": "purple", "avi": "purple",
    "mkv": "purple", "flac": "purple", "wav": "purple", "ogg": "purple",
    "webm": "purple",
    "txt": "red", "log": "red",
}

def get_color(name, is_dir):
    if is_dir:
        return 2
    ext = name.rsplit(".", 1)[-1].lower() if "." in name else ""
    return {
        "yellow": 3, "brown": 3,
        "green": 4, "red": 5,
        "cyan": 6, "purple": 8
    }.get(FILE_COLOR_MAP.get(ext, "green"), 4)

def refresh_entries(path):
    try:
        items = os.listdir(path)
    except:
        return []
    return sorted(items, key=lambda x: (not os.path.isdir(os.path.join(path, x)), x.lower()))

def prompt(stdscr, text):
    curses.echo()
    stdscr.addstr(curses.LINES - 1, 0, " " * (curses.COLS - 1))
    stdscr.addstr(curses.LINES - 1, 0, text)
    stdscr.refresh()
    s = stdscr.getstr(curses.LINES - 1, len(text), curses.COLS - len(text) - 1)
    curses.noecho()
    return s.decode("utf-8", "ignore").strip()

def message(stdscr, text):
    stdscr.addstr(curses.LINES - 1, 0, " " * (curses.COLS - 1))
    stdscr.addstr(curses.LINES - 1, 0, text[:curses.COLS - 1])
    stdscr.refresh()
    stdscr.getch()

def view_file(stdscr, path):
    if not os.path.isfile(path):
        return
    stdscr.clear()
    stdscr.addstr(0, 0, f"Viewing: {path} (press any key)")
    try:
        with open(path, "r", errors="ignore") as f:
            lines = f.readlines()
    except:
        return
    max_y, max_x = stdscr.getmaxyx()
    for i, line in enumerate(lines[: max_y - 2]):
        stdscr.addstr(i + 1, 0, line[: max_x - 1])
    stdscr.refresh()
    stdscr.getch()

def edit_file(stdscr, path):
    if not os.path.isfile(path):
        return
    tmp = tempfile.NamedTemporaryFile(delete=False)
    tmp_path = tmp.name
    tmp.close()
    shutil.copy2(path, tmp_path)
    cursor = 0
    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, f"Editing: {path} (Enter=edit, x=save, q=quit)")
        stdscr.addstr(1, 0, "-" * (curses.COLS - 1))
        try:
            with open(tmp_path, "r", errors="ignore") as f:
                lines = f.readlines()
        except:
            break
        max_y, max_x = stdscr.getmaxyx()
        for i, line in enumerate(lines[: max_y - 4]):
            prefix = f"{i+1:3d}  "
            if i == cursor:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(i + 2, 0, (prefix + line.rstrip())[: max_x - 1])
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(i + 2, 0, (prefix + line.rstrip())[: max_x - 1])
        stdscr.refresh()
        ch = stdscr.getch()
        if ch == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif ch == curses.KEY_DOWN and cursor < len(lines) - 1:
            cursor += 1
        elif ch in (10, 13):
            new = prompt(stdscr, f"Line {cursor+1}: ")
            lines[cursor] = new + "\n"
            with open(tmp_path, "w") as f:
                f.writelines(lines)
        elif ch == ord("x"):
            shutil.copy2(tmp_path, path)
            break
        elif ch == ord("q"):
            break
    os.remove(tmp_path)

def search_files(stdscr, path):
    pat = prompt(stdscr, "Search: ")
    if not pat:
        return
    stdscr.clear()
    stdscr.addstr(0, 0, f"Results for: {pat}")
    row = 1
    for root, dirs, files in os.walk(path):
        for f in files:
            if pat.lower() in f.lower():
                if row < curses.LINES - 1:
                    stdscr.addstr(row, 0, os.path.join(root, f)[: curses.COLS - 1])
                    row += 1
    stdscr.addstr(curses.LINES - 1, 0, "Press any key")
    stdscr.refresh()
    stdscr.getch()

def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(2, curses.COLOR_BLUE, -1)
    curses.init_pair(3, curses.COLOR_YELLOW, -1)
    curses.init_pair(4, curses.COLOR_GREEN, -1)
    curses.init_pair(5, curses.COLOR_RED, -1)
    curses.init_pair(6, curses.COLOR_CYAN, -1)
    curses.init_pair(8, curses.COLOR_MAGENTA, -1)

    path = START_DIR
    cursor = 0
    entries = refresh_entries(path)

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, f"Murk Manager v{PLUGIN_VERSION} — cwd: {path}")
        stdscr.addstr(1, 0, "↑↓ move • ← parent • → enter • c copy • m move • d delete • e edit • n mkdir • r rename • s search • p perms • q quit")
        stdscr.addstr(2, 0, "-" * (curses.COLS - 1))
        max_y, max_x = stdscr.getmaxyx()
        body = max_y - 5
        for i, name in enumerate(entries[:body]):
            full = os.path.join(path, name)
            is_dir = os.path.isdir(full)
            indicator = "d" if is_dir else " "
            line = f"[{i+1:2d}] {indicator} {name}"
            color = curses.color_pair(get_color(name, is_dir))
            if i == cursor:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(3 + i, 0, line[: max_x - 1], color)
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(3 + i, 0, line[: max_x - 1], color)
        stdscr.refresh()
        ch = stdscr.getch()
        if ch == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif ch == curses.KEY_DOWN and cursor < len(entries) - 1:
            cursor += 1
        elif ch == curses.KEY_LEFT:
            parent = os.path.dirname(path)
            if parent and os.path.isdir(parent):
                path = parent
                entries = refresh_entries(path)
                cursor = 0
        elif ch == curses.KEY_RIGHT:
            if entries:
                full = os.path.join(path, entries[cursor])
                if os.path.isdir(full):
                    path = full
                    entries = refresh_entries(path)
                    cursor = 0
                else:
                    view_file(stdscr, full)
        elif ch == ord("q"):
            break
        elif ch == ord("n"):
            name = prompt(stdscr, "New dir: ")
            if name:
                os.mkdir(os.path.join(path, name))
                entries = refresh_entries(path)
        elif ch == ord("r"):
            old = entries[cursor]
            new = prompt(stdscr, f"Rename '{old}' to: ")
            if new:
                os.rename(os.path.join(path, old), os.path.join(path, new))
                entries = refresh_entries(path)
        elif ch == ord("c"):
            src = entries[cursor]
            dst = prompt(stdscr, f"Copy '{src}' to: ")
            if dst:
                s = os.path.join(path, src)
                d = os.path.join(path, dst)
                if os.path.isdir(s):
                    shutil.copytree(s, d)
                else:
                    shutil.copy2(s, d)
                entries = refresh_entries(path)
        elif ch == ord("m"):
            src = entries[cursor]
            dst = prompt(stdscr, f"Move '{src}' to: ")
            if dst:
                shutil.move(os.path.join(path, src), os.path.join(path, dst))
                entries = refresh_entries(path)
                cursor = min(cursor, len(entries) - 1)
        elif ch == ord("d"):
            tgt = entries[cursor]
            confirm = prompt(stdscr, f"Delete '{tgt}'? (y/n): ")
            if confirm.lower() == "y":
                full = os.path.join(path, tgt)
                if os.path.isdir(full):
                    shutil.rmtree(full)
                else:
                    os.remove(full)
                entries = refresh_entries(path)
                cursor = min(cursor, len(entries) - 1)
        elif ch == ord("e"):
            edit_file(stdscr, os.path.join(path, entries[cursor]))
            entries = refresh_entries(path)
        elif ch == ord("p"):
            tgt = entries[cursor]
            perms = prompt(stdscr, f"Permissions for '{tgt}': ")
            if perms:
                os.chmod(os.path.join(path, tgt), int(perms, 8))
        elif ch == ord("s"):
            search_files(stdscr, path)

if __name__ == "__main__":
    curses.wrapper(main)
