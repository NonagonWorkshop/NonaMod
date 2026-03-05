#!/usr/bin/env python3
# menu_plugin
PLUGIN_NAME="Murk Manager V2 PY"
PLUGIN_FUNCTION="Not so simple file manager."
PLUGIN_DESCRIPTION="File manager with copy, move, delete, rename, search, permissions management, and custom text editor."
PLUGIN_AUTHOR="Star"
PLUGIN_VERSION="2.4"

import os
import shutil
import curses
import tempfile
import subprocess

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

def get_color_index(name, is_dir):
    if is_dir:
        return 2
    ext = name.rsplit(".", 1)[-1].lower() if "." in name else ""
    color_name = FILE_COLOR_MAP.get(ext, "green")
    return {
        "yellow": 3, "brown": 3,
        "green": 4,
        "red": 5,
        "cyan": 6,
        "purple": 8,
    }.get(color_name, 4)

def refresh_entries(path):
    try:
        items = os.listdir(path)
    except Exception:
        return []
    return sorted(items, key=lambda x: (not os.path.isdir(os.path.join(path, x)), x.lower()))

def prompt(stdscr, text):
    curses.echo()
    stdscr.move(curses.LINES - 1, 0)
    stdscr.clrtoeol()
    stdscr.addstr(curses.LINES - 1, 0, text[:curses.COLS - 1])
    stdscr.refresh()
    s = stdscr.getstr(curses.LINES - 1, len(text), curses.COLS - len(text) - 1)
    curses.noecho()
    return s.decode("utf-8", "ignore").strip()

def message(stdscr, text, wait=True):
    stdscr.move(curses.LINES - 1, 0)
    stdscr.clrtoeol()
    stdscr.addstr(curses.LINES - 1, 0, text[:curses.COLS - 1])
    stdscr.refresh()
    if wait:
        stdscr.getch()

def view_file(stdscr, path):
    if not os.path.isfile(path):
        return
    try:
        with open(path, "r", errors="ignore") as f:
            lines = f.readlines()
    except Exception as e:
        message(stdscr, f"Error: {e}")
        return
    offset = 0
    while True:
        stdscr.clear()
        max_y, max_x = stdscr.getmaxyx()
        stdscr.addstr(0, 0, f"Viewing: {path}  (↑/↓ scroll, q quit)")
        for i, line in enumerate(lines[offset:offset + max_y - 2]):
            stdscr.addstr(i + 1, 0, line[:max_x - 1])
        stdscr.refresh()
        ch = stdscr.getch()
        if ch == curses.KEY_UP and offset > 0:
            offset -= 1
        elif ch == curses.KEY_DOWN and offset < max(0, len(lines) - (max_y - 2)):
            offset += 1
        elif ch == ord("q"):
            break

def edit_file(stdscr, path):
    if not os.path.isfile(path):
        message(stdscr, "Not a file.")
        return
    tmp = tempfile.NamedTemporaryFile(delete=False)
    tmp_path = tmp.name
    tmp.close()
    shutil.copy2(path, tmp_path)
    cursor = 0
    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, f"Editing: {path} (↑/↓ move, Enter edit, x save, q quit)")
        stdscr.addstr(1, 0, "-" * (curses.COLS - 1))
        try:
            with open(tmp_path, "r", errors="ignore") as f:
                lines = f.readlines()
        except Exception as e:
            message(stdscr, f"Error: {e}")
            break
        max_y, max_x = stdscr.getmaxyx()
        visible = max_y - 4
        top = max(0, min(cursor - visible // 2, max(0, len(lines) - visible)))
        for i in range(visible):
            idx = top + i
            if idx >= len(lines):
                break
            prefix = f"{idx+1:3d}  "
            text = (prefix + lines[idx].rstrip())[:max_x - 1]
            if idx == cursor:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(2 + i, 0, text)
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(2 + i, 0, text)
        stdscr.refresh()
        ch = stdscr.getch()
        if ch == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif ch == curses.KEY_DOWN and cursor < len(lines) - 1:
            cursor += 1
        elif ch in (10, 13):
            new = prompt(stdscr, f"Line {cursor+1}: ")
            lines[cursor] = new + "\n"
            try:
                with open(tmp_path, "w", errors="ignore") as f:
                    f.writelines(lines)
            except Exception as e:
                message(stdscr, f"Error: {e}")
        elif ch == ord("x"):
            try:
                shutil.copy2(tmp_path, path)
                message(stdscr, "Saved.")
            except Exception as e:
                message(stdscr, f"Error: {e}")
            break
        elif ch == ord("q"):
            break
    try:
        os.remove(tmp_path)
    except Exception:
        pass

def search_files(stdscr, path):
    pat = prompt(stdscr, "Search pattern: ")
    if not pat:
        return
    stdscr.clear()
    stdscr.addstr(0, 0, f"Results for: {pat}")
    row = 1
    for root, dirs, files in os.walk(path):
        for f in files:
            if pat.lower() in f.lower():
                if row < curses.LINES - 1:
                    stdscr.addstr(row, 0, os.path.join(root, f)[:curses.COLS - 1])
                    row += 1
    stdscr.addstr(curses.LINES - 1, 0, "Press any key")
    stdscr.refresh()
    stdscr.getch()

def run_command_on(stdscr, path):
    cmd = prompt(stdscr, f"Run command on '{os.path.basename(path)}': ")
    if not cmd:
        return
    full_cmd = f"{cmd} '{path}'"
    try:
        subprocess.run(full_cmd, shell=True)
        message(stdscr, "Command finished.", wait=True)
    except Exception as e:
        message(stdscr, f"Error: {e}", wait=True)

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
    entries = refresh_entries(path)
    cursor = 0
    scroll = 0

    while True:
        stdscr.clear()
        max_y, max_x = stdscr.getmaxyx()
        stdscr.addstr(0, 0, f"Murk Manager v{PLUGIN_VERSION} — cwd: {path}"[:max_x - 1])
        stdscr.addstr(1, 0,
            "↑/↓ move • ← parent • → enter • c copy • m move • d delete • e edit • n mkdir • r rename • s search • p perms • ! cmd • q quit"
            [:max_x - 1]
        )
        stdscr.addstr(2, 0, "-" * (max_x - 1))

        body_rows = max_y - 5
        if cursor < scroll:
            scroll = cursor
        elif cursor >= scroll + body_rows:
            scroll = cursor - body_rows + 1

        for i in range(body_rows):
            idx = scroll + i
            if idx >= len(entries):
                break
            name = entries[idx]
            full = os.path.join(path, name)
            is_dir = os.path.isdir(full)
            indicator = "d" if is_dir else " "
            line = f"[{idx+1:2d}] {indicator} {name}"
            color = curses.color_pair(get_color_index(name, is_dir))
            if idx == cursor:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(3 + i, 0, line[:max_x - 1], color)
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(3 + i, 0, line[:max_x - 1], color)

        sel_name = entries[cursor] if entries else ""
        stdscr.addstr(max_y - 2, 0, f"Entries: {len(entries)}  Selected: {sel_name}"[:max_x - 1])
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
                scroll = 0
        elif ch == curses.KEY_RIGHT:
            if entries:
                full = os.path.join(path, entries[cursor])
                if os.path.isdir(full):
                    path = full
                    entries = refresh_entries(path)
                    cursor = 0
                    scroll = 0
                else:
                    view_file(stdscr, full)
        elif ch == ord("q"):
            break
        elif ch == ord("n"):
            name = prompt(stdscr, "New directory name: ")
            if name:
                try:
                    os.mkdir(os.path.join(path, name))
                    entries = refresh_entries(path)
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("r") and entries:
            old = entries[cursor]
            new = prompt(stdscr, f"Rename '{old}' to: ")
            if new:
                try:
                    os.rename(os.path.join(path, old), os.path.join(path, new))
                    entries = refresh_entries(path)
                    cursor = min(cursor, len(entries) - 1)
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("c") and entries:
            src = entries[cursor]
            dst = prompt(stdscr, f"Copy '{src}' to (path or name): ")
            if dst:
                try:
                    s = os.path.join(path, src)
                    d = dst if os.path.isabs(dst) else os.path.join(path, dst)
                    if os.path.isdir(s):
                        shutil.copytree(s, d)
                    else:
                        shutil.copy2(s, d)
                    entries = refresh_entries(path)
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("m") and entries:
            src = entries[cursor]
            dst = prompt(stdscr, f"Move '{src}' to (path or name): ")
            if dst:
                try:
                    s = os.path.join(path, src)
                    d = dst if os.path.isabs(dst) else os.path.join(path, dst)
                    shutil.move(s, d)
                    entries = refresh_entries(path)
                    cursor = min(cursor, len(entries) - 1)
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("d") and entries:
            tgt = entries[cursor]
            confirm = prompt(stdscr, f"Delete '{tgt}'? (y/n): ")
            if confirm.lower() == "y":
                try:
                    full = os.path.join(path, tgt)
                    if os.path.isdir(full):
                        shutil.rmtree(full)
                    else:
                        os.remove(full)
                    entries = refresh_entries(path)
                    cursor = min(cursor, len(entries) - 1)
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("e") and entries:
            edit_file(stdscr, os.path.join(path, entries[cursor]))
            entries = refresh_entries(path)
        elif ch == ord("p") and entries:
            tgt = entries[cursor]
            perms = prompt(stdscr, f"Permissions for '{tgt}' (e.g. 755): ")
            if perms:
                try:
                    os.chmod(os.path.join(path, tgt), int(perms, 8))
                except Exception as e:
                    message(stdscr, f"Error: {e}")
        elif ch == ord("s"):
            search_files(stdscr, path)
        elif ch == ord("!"):
            if entries:
                run_command_on(stdscr, os.path.join(path, entries[cursor]))

if __name__ == "__main__":
    curses.wrapper(main)
