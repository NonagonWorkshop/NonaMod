#!/bin/bash

get_largest_cros_blockdev() {
    local largest size dev_name tmp_size remo
    size=0
    for blockdev in /sys/block/*; do
        dev_name="${blockdev##*/}"
        echo "$dev_name" | grep -q '^\(loop\|ram\)' && continue
        tmp_size=$(cat "$blockdev"/size)
        remo=$(cat "$blockdev"/removable)
        if [ "$tmp_size" -gt "$size" ] && [ "${remo:-0}" -eq 0 ]; then
            case "$(doas sfdisk -l -o name "/dev/$dev_name" 2>/dev/null)" in
                *STATE*KERN-A*ROOT-A*KERN-B*ROOT-B*)
                    largest="/dev/$dev_name"
                    size="$tmp_size"
                    ;;
            esac
        fi
    done
    echo "$largest"
}

traps() {
    set +e
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
    trap 'echo \"${last_command}\" command failed with exit code $? - press a key to exit.' EXIT
    trap '' INT
}

mushm_info() {
    echo -ne "\033]0;mushm\007"
    if [ ! -f /mnt/stateful_partition/custom_greeting ]; then
        cat <<-EOF
Welcome to mushm, A Custom Developer Shell for MurkMod

If you ended up here by accident, don’t worry! Simply close this tab and you’ll be good to go.

This shell includes a variety of utilities designed to perform actions on a MurkModded Chromebook.

Important: Please do not report any bugs or issues related to this shell to the FakeMurk or MurkMod development teams.
It’s an independent tool and not officially supported by them.

EOF
    else
        cat /mnt/stateful_partition/custom_greeting
    fi
}

doas() {
    ssh -tt -p 1337 -i /rootkey -oStrictHostKeyChecking=no root@127.0.0.1 "$@"
}

runjob() {
    clear
    trap 'kill -2 $! >/dev/null 2>&1' INT
    (
        # shellcheck disable=SC2068
        $@
    )
    trap '' INT
    clear
}

runpy() {
    clear
    trap 'kill -2 $! >/dev/null 2>&1' INT
    (
        doas "sudo -i -u chronos -- bash -l -c 'clear; python3 \"$@\"'"
    ) &
    wait $!
    trap '' INT
    clear
}


swallow_stdin() {
    while read -t 0 notused; do
        read input
    done
}

edit() {
    if doas which nano 2>/dev/null; then
        doas nano "$@"
    else
        doas vi "$@"
    fi
}

locked_main() {
    traps
    mushm_info
    while true; do
        echo -ne "\033]0;mushm\007"
        cat <<-EOF
(1) Emergency Revert & Re-Enroll
(2) Soft Disable Extensions
(3) Hard Disable Extensions
(4) Hard Enable Extensions
(5) Enter Admin Mode (Password-Protected)
EOF
        
        swallow_stdin
        read -r -p "> (1-6): " choice
        case "$choice" in
        1) runjob revert ;;
        2) runjob softdisableext ;;
        3) runjob harddisableext ;;
        4) runjob hardenableext ;;
        5) runjob prompt_passwd ;;
        fgter) runjob dev_fix ;;


        *) echo && echo "Invalid option" && echo ;;
        esac
    done
}

main() {
    traps
    mushm_info
    while true; do
        echo -ne "\033]0;mushm\007"
        cat <<-EOF
(1) Root Shell                     (25) Firmware Utility
(2) Chronos Shell                  (26) Check for updates Murkmod
(3) Crosh                          (27) Check for updates MushM
(4) Plugins                        (28) Backup Manager
(5) Install plugins                (29) [EXPERIMENTAL] Install Arch Chroot
(6) Uninstall plugins              (30) [EXPERIMENTAL] Install Gento Dev Env
(7) Powerwash                      
(8) Emergency Revert & Re-Enroll
(9) Soft Disable Extensions
(10) Hard Disable Extensions
(11) Hard Enable Extensions
(12) Automagically Disable Extensions
(13) Install Crouton
(14) Start Crouton
(15) Enable dev_boot_usb
(16) Disable dev_boot_usb
(17) Set mushm password
(18) Remove mushm password
(19) Reboot (wait 5s)
(20) [EXPERIMENTAL] Install Gentoo Bootstrap (dev_install)
(21) [EXPERIMENTAL] Update ChromeOS
(22) [EXPERIMENTAL] Update Emergency Backup
(23) [EXPERIMENTAL] Restore Emergency Backup Backup
(24) [EXPERIMENTAL] Install Chromebrew
EOF
        
        swallow_stdin
        read -r -p "> (1-32): " choice
        case "$choice" in
        1) runjob doas bash ;;
        2) runjob doas "cd /home/chronos; sudo -i -u chronos" ;;
        3) runjob /usr/bin/crosh.old ;;
        4) runjob show_plugins ;;
        5) runjob install_plugins ;;
        6) runjob uninstall_plugins ;;
        7) runjob powerwash ;;
        8) runjob revert ;;
        9) runjob softdisableext ;;
        10) runjob harddisableext ;;
        11) runjob hardenableext ;;
        12) runjob autodisableexts ;;
        13) runjob install_crouton ;;
        14) runjob run_crouton ;;
        15) runjob enable_dev_boot_usb ;;
        16) runjob disable_dev_boot_usb ;;
        17) runjob set_passwd ;;
        18) runjob remove_passwd ;;
        19) runjob reboot ;;
        20) runjob attempt_dev_install ;;
        21) runjob attempt_chromeos_update ;;
        22) runjob attempt_backup_update ;;
        23) runjob attempt_restore_backup_backup ;;
        24) runjob attempt_chromebrew_install ;;
        25) runjob run_firmware_util ;;
        26) runjob do_updates && exit 0 ;;
        27) runjob do_mushm_update ;;
        28) runpy /mnt/stateful_partition/murkmod/python/util/backup/backup_manager.py ;;
        29) runjob arch ;;
        30) runjob gento ;;
        670) runjob games ;;
        400) runjob do_dev_updates && exit 0 ;;
        101) runjob hard_disable_nokill ;;
        111) runjob hard_enable_nokill ;;
        112) runjob ext_purge ;;
        113) runjob list_plugins ;;
        114) runjob install_plugin_legacy ;;
        115) runjob uninstall_plugin_legacy ;;
        201) runjob api_read_file ;;
        202) runjob api_write_file ;;
        203) runjob api_append_file ;;
        204) runjob api_touch_file ;;
        205) runjob api_create_dir ;;
        206) runjob api_rm_file ;;
        207) runjob api_rm_dir ;;
        208) runjob api_ls_dir ;;
        209) runjob api_cd ;;
    
        *) echo && echo "Invalid option." && echo ;;
        esac
    done
}

arch() {
doas "bash <(curl -fsSL https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/Chard_Installer.sh)"
}

gento() {
doas "bash <(curl -fsSL https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/Chard_Installer.sh)"
}

games() {
        traps
    echo "Welcome to the Games Menu! Select an option
    (1) Bashcraft (REQUIRES PYTHON)
    (2) Tetris
    (MORE WILL BE ADDED IN FUTURE)
    "

    swallow_stdin
    read -r -p "> (1 - 2): " CHOOESGAM

    
    case "$CHOOESGAM" in
    1) echo "still working on the pythong shit." ;;
    2) runpy teteris_py ;;

    *) echo && echo "No options for that, some will be added soon!" && echo ;;

    esac
}

teteris_py() {
    #!/usr/bin/env python

import sys
import select
import tty
import termios
import random
import os
import time
import fcntl
if (sys.hexversion >> 16) >= 0x202:
    FCNTL = fcntl
else:
    import FCNTL
import contextlib

PLAYFIELD_W = 10
PLAYFIELD_H = 20
PLAYFIELD_X = 30
PLAYFIELD_Y = 1
BORDER_COLOR = 'yellow'

HELP_X = 58
HELP_Y = 1
HELP_COLOR = 'cyan'

SCORE_X = 1
SCORE_Y = 2
SCORE_COLOR = 'green'

NEXT_X = 14
NEXT_Y = 11

GAMEOVER_X = 1
GAMEOVER_Y = PLAYFIELD_H + 3

INITIAL_MOVE_DOWN_DELAY = 1.0
DELAY_FACTOR = 0.8
LEVEL_UP = 20

NEXT_EMPTY_CELL = "  "
PLAYFIELD_EMPTY_CELL = " ."
FILLED_CELL = "[]"

class TetrisScreen:
    def __init__(self):
        self.s = ''
        self.no_color = False
        self.color = {
            'red': 1,
            'green': 2,
            'yellow': 3,
            'blue': 4,
            'fuchsia': 5,
            'cyan': 6,
            'white': 7
        }

    def xyprint(self, x, y, s):
        self.s += "\x1b[{0};{1}H{2}".format(y, x, s)

    def flush(self):
        sys.stdout.write(self.s)
        sys.stdout.flush()
        self.s = ''

    def puts(self, s):
        self.s += s

    def clear_screen(self):
        self.s += "\x1b[2J"

    def show_cursor(self):
        self.s += "\x1b[?25h"

    def hide_cursor(self):
        self.s += "\x1b[?25l"

    def set_fg(self, c):
        if self.no_color:
            return
        self.s += "\x1b[3{0}m".format(self.color.get(c, 7))

    def set_bg(self, c):
        if self.no_color:
            return
        self.s += "\x1b[4{0}m".format(self.color.get(c, 7))

    def reset_colors(self):
        self.s += "\x1b[0m"

    def set_bold(self):
        self.s += "\x1b[1m"

    def get_random_color(self):
        k = list(self.color.keys())
        random.shuffle(k)
        return k[0]

    def toggle_color(self):
        self.no_color ^= True

class TetrisScreenItem(object):
    def __init__(self, screen):
        self.visible = True
        self.screen = screen

    def show(self):
        if self.visible:
            self.draw(True)

    def hide(self):
        if self.visible:
            self.draw(False)

    def toggle(self):
        self.visible ^= True
        self.draw(self.visible)

class TetrisHelp(TetrisScreenItem):
    def __init__(self, screen):
        super(TetrisHelp, self).__init__(screen)
        self.color = HELP_COLOR
        self.text = [
            "  Use cursor keys",
            "       or",
            "    s: rotate",
            "a: left,  d: right",
            "    space: drop",
            "      q: quit",
            "  c: toggle color",
            "n: toggle show next",
            "h: toggle this help"
        ]

    def draw(self, visible):
        self.screen.set_bold()
        self.screen.set_fg(self.color)
        i = 0
        for s in self.text:
            if not visible:
                s = ' ' * len(s)
            self.screen.xyprint(HELP_X, HELP_Y + i, s)
            i += 1
        self.screen.reset_colors()

class TetrisPlayField:
    def __init__(self, screen):
        self.screen = screen
        self.cells = [[None] * PLAYFIELD_W for i in range(0, PLAYFIELD_H)]

    def show(self):
        y = 0
        for row in self.cells:
            self.screen.xyprint(PLAYFIELD_X, PLAYFIELD_Y + y, "")
            y += 1
            for cell in row:
                if cell == None:
                    self.screen.puts(PLAYFIELD_EMPTY_CELL)
                else:
                    self.screen.set_fg(cell)
                    self.screen.set_bg(cell)
                    self.screen.puts(FILLED_CELL)
                    self.screen.reset_colors()

    def flatten_piece(self, piece):
        for cell in piece.get_cells():
            self.cells[cell[1]][cell[0]] = piece.color

    def process_complete_lines(self):
        cells = [row for row in self.cells if None in row]
        complete_lines = PLAYFIELD_H - len(cells)
        if complete_lines > 0:
            self.cells = [[None] * PLAYFIELD_W for i in range(0, complete_lines)] + cells
        return complete_lines

    def draw_border(self):
        self.screen.set_bold()
        self.screen.set_fg(BORDER_COLOR)
        for y in range(0, PLAYFIELD_H):
            # 2 because border is 2 characters thick
            self.screen.xyprint(PLAYFIELD_X - 2, PLAYFIELD_Y + y, "<|")
            # 2 because each cell on play field is 2 characters wide
            self.screen.xyprint(PLAYFIELD_X + PLAYFIELD_W * 2, PLAYFIELD_Y+ y, "|>")
        y = 0
        for s in ['==', '\/']:
            self.screen.xyprint(PLAYFIELD_X, PLAYFIELD_Y + PLAYFIELD_H + y, s * PLAYFIELD_W)
            y += 1
        self.screen.reset_colors()

    def position_ok(self, cells):
        return all(
            (0 <= x < PLAYFIELD_W) and
            (0 <= y < PLAYFIELD_H) and
            self.cells[y][x] is None
            for x, y in cells
        )

class TetrisPiece(TetrisScreenItem):
    configurations = [
        # 0123
        # 4567
        # 89ab
        # cdef
        [0x1256], # square
        [0x159d, 0x4567], # line
        [0x4512, 0x0459], # s
        [0x0156, 0x1548], # z
        [0x159a, 0x8456, 0x0159, 0x2654], # l
        [0x1598, 0x0456, 0x2159, 0xa654], # inverted l
        [0x1456, 0x1596, 0x4569, 0x4159]  # t
    ]

    def __init__(self, screen, origin, visible):
        super(TetrisPiece, self).__init__(screen)
        self.color = screen.get_random_color()
        self.data = random.choice(self.configurations)
        self.symmetry = len(self.data)
        self.position = 0, 0, random.randint(0, self.symmetry - 1)
        self.origin = origin
        self.visible = visible
        self.empty_cell = NEXT_EMPTY_CELL

    def get_cells(self, new_position=None):
        x, y, z = new_position or self.position
        data = self.data[z]
        return [[int(x) + ((data >> (i * 4)) & 3), int(y) + ((data >> (i * 4 + 2)) & 3)] for i in range(0, 4)]

    def draw(self, visible):
        if visible:
            self.screen.set_fg(self.color)
            self.screen.set_bg(self.color)
            s = FILLED_CELL
        else:
            s = self.empty_cell
        for cell in self.get_cells():
            self.screen.xyprint(self.origin[0] + cell[0] * 2, self.origin[1] + cell[1], s)
        self.screen.reset_colors()

    def set_xy(self, x, y):
        self.position = x, y, self.position[2]

    def new_position(self, dx, dy, dz):
        x, y, z = self.position
        return x + dx, y + dy, (z + dz) % self.symmetry

class TetrisScore:
    def __init__(self, screen, tetris_input_processor):
        self.screen = screen
        self.tetris_input_processor = tetris_input_processor
        self.score = 0
        self.level = 1
        self.lines_completed = 0

    def update(self, complete_lines):
        self.lines_completed += complete_lines
        self.score += (complete_lines * complete_lines)
        if self.score > LEVEL_UP * self.level:
            self.level += 1
            self.tetris_input_processor.decrease_delay()
        self.show()

    def show(self):
        self.screen.set_bold()
        self.screen.set_fg(SCORE_COLOR)
        self.screen.xyprint(SCORE_X, SCORE_Y,     "Lines completed: {0}".format(self.lines_completed))
        self.screen.xyprint(SCORE_X, SCORE_Y + 1, "Level:           {0}".format(self.level))
        self.screen.xyprint(SCORE_X, SCORE_Y + 2, "Score:           {0}".format(self.score))
        self.screen.reset_colors()

class TetrisController:

    def __init__(self, screen, tetris_input_processor):
        self.screen = screen
        self.next_piece_visible = True
        self.running = True
        self.help = TetrisHelp(screen)
        self.score = TetrisScore(screen, tetris_input_processor)
        self.play_field = TetrisPlayField(screen)
        self.get_next_piece()
        self.get_current_piece()
        self.redraw_screen()
        screen.flush()

    def get_current_piece(self):
        self.next_piece.hide()
        self.current_piece = self.next_piece
        self.current_piece.set_xy((PLAYFIELD_W - 4) / 2, 0)
        if not self.play_field.position_ok(self.current_piece.get_cells()):
            self.cmd_quit()
            return
        self.current_piece.visible = True
        self.current_piece.empty_cell = PLAYFIELD_EMPTY_CELL
        self.current_piece.origin = (PLAYFIELD_X, PLAYFIELD_Y)
        self.current_piece.show()
        self.get_next_piece()

    def get_next_piece(self):
        self.next_piece = TetrisPiece(
            self.screen,
            (NEXT_X, NEXT_Y),
            self.next_piece_visible,
        )
        self.next_piece.show()

    def redraw_screen(self):
        self.screen.clear_screen()
        self.screen.hide_cursor()
        self.play_field.draw_border()
        for o in [self.help, self.play_field, self.score, self.next_piece, self.current_piece]:
            o.show()

    def cmd_quit(self):
        self.running = False
        self.screen.xyprint(GAMEOVER_X, GAMEOVER_Y, "Game over!")
        self.screen.xyprint(GAMEOVER_X, GAMEOVER_Y + 1, "")
        self.screen.show_cursor()

    def process_fallen_piece(self):
        self.play_field.flatten_piece(self.current_piece)
        complete_lines = self.play_field.process_complete_lines()
        if complete_lines > 0:
            self.score.update(complete_lines)
            self.play_field.show()

    def move(self, dx, dy, dz):
        position = self.current_piece.new_position(dx, dy, dz)
        if self.play_field.position_ok(self.current_piece.get_cells(position)):
            self.current_piece.hide()
            self.current_piece.position = position
            self.current_piece.show()
            return True
        return (dy == 0)

    def cmd_right(self):
        self.move(1, 0, 0)

    def cmd_left(self):
        self.move(-1, 0, 0)

    def cmd_rotate(self):
        self.move(0, 0, 1)

    def cmd_down(self):
        if self.move(0, 1, 0):
            return True
        self.process_fallen_piece()
        self.get_current_piece()
        return False

    def cmd_drop(self):
        while self.cmd_down():
            pass

    def toggle_help(self):
        self.help.toggle()

    def toggle_next(self):
        self.next_piece_visible ^= True
        self.next_piece.toggle()

    def toggle_color(self):
        self.screen.toggle_color()
        self.redraw_screen()

@contextlib.contextmanager
def nonblocking_input():
    fd = sys.stdin
    try:
        flags = fcntl.fcntl(fd, FCNTL.F_GETFL)
        flags = flags | os.O_NONBLOCK
        fcntl.fcntl(fd, FCNTL.F_SETFL, flags)
        yield
    finally:
        flags = fcntl.fcntl(fd, FCNTL.F_GETFL)
        flags = flags & ~os.O_NONBLOCK
        fcntl.fcntl(fd, FCNTL.F_SETFL, flags)

@contextlib.contextmanager
def tcattr():
    try:
        old_settings = termios.tcgetattr(sys.stdin)
        yield
    finally:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)


class TetrisInputProcessor:
    delay = INITIAL_MOVE_DOWN_DELAY

    def decrease_delay(self):
        self.delay *= DELAY_FACTOR


def run():
    input_processor = TetrisInputProcessor()
    with nonblocking_input(), tcattr():
    #    tty.setcbreak(sys.stdin.fileno())
        tty.setraw(sys.stdin.fileno())

        key = [0, 0, 0]
        ts = TetrisScreen()
        ts.clear_screen()
        tc = TetrisController(ts, input_processor)
        commands = {
            "\x03": tc.cmd_quit,
            "q": tc.cmd_quit,
            "C": tc.cmd_right,
            "d": tc.cmd_right,
            "D": tc.cmd_left,
            "a": tc.cmd_left,
            "A": tc.cmd_rotate,
            "s": tc.cmd_rotate,
            " ": tc.cmd_drop,
            "h": tc.toggle_help,
            "n": tc.toggle_next,
            "c": tc.toggle_color
        }
        last_move_down_time = time.time()
        while tc.running:
            cmd = None
            now = time.time()
            select_timeout = input_processor.delay - (now - last_move_down_time)
            if select_timeout < 0:
                tc.cmd_down()
                ts.flush()
                last_move_down_time = now
                select_timeout = input_processor.delay
            if select.select([sys.stdin], [], [], input_processor.delay)[0]:
                s = sys.stdin.read(16)
                for c in s:
                    key[2] = key[1]
                    key[1] = key[0]
                    key[0] = c
                    if key[2] == '\x1b' and key[1] == '[':         # x1b is ESC
                        cmd = commands.get(key[0], None)
                    else:
                        cmd = commands.get(key[0].lower(), None)
                    if cmd:
                        cmd()
                        ts.flush()


if __name__ == '__main__':
    run()

}

api_read_file() {
    echo "file to read?"
    read -r filename
    local contents=$( base64 $filename )
    echo "start content: $contents end content"
}

api_write_file() {
    echo "file to write to?"
    read -r filename
    echo "base64 contents?"
    read -r contents
    base64 -d <<< "$contents" > $filename
}

api_append_file() {
    echo "file to write to?"
    read -r filename
    echo "base64 contents to append?"
    read -r contents
    base64 -d <<< "$contents" >> $filename
}

api_touch_file() {
    echo "filename?"
    read -r filename
    touch $filename
}

api_create_dir() {
    echo "dirname?"
    read -r dirname
    mkdir -p $dirname
}

api_rm_file() {
    echo "filename?"
    read -r filename
    rm -f $filename
}

api_rm_dir() {
    echo "dirname?"
    read -r dirname
    rm -Rf $dirname
}

api_ls_dir() {
    echo "dirname? (or . for current dir)"
    read -r dirname
    ls $dirname
}

api_cd() {
    echo "dir?"
    read -r dirname
    cd $dirname
}

reboot() {
doas "reboot"

}

do_dev_updates() {
    echo "Welcome to the murkmod developer update menu!"
    echo "This utility allows you to install murkmod from a specific branch on the git repo."
    echo "If you were trying to update murkmod normally, then don't panic! Just enter 'main' at the prompt and everything will work normally."
    read -p "> (branch name, eg. main): " branch
    doas "MURKMOD_BRANCH=$branch bash <(curl -SLk https://raw.githubusercontent.com/rainestorme/murkmod/main/murkmod.sh)"
    exit
}

disable_ext() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Extension ID $extid is invalid."
}

disable_ext_nokill() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" || "Extension ID $extid is invalid."
}

enable_ext_nokill() {
    local extid="$1"
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 777 "/home/chronos/user/Extensions/$extid" || "Invalid extension id."
}

ext_purge() {
    kill -9 $(pgrep -f "\-\-extension\-process")
}

hard_disable_nokill() {
    read -r -p "Enter extension ID > " extid
    disable_ext_nokill $extid
}

hard_enable_nokill() {
    read -r -p "Enter extension ID > " extid
    enable_ext_nokill $extid
}

autodisableexts() {
    echo "Disabling extensions..."
    disable_ext_nokill "haldlgldplgnggkjaafhelgiaglafanh" # GoGuardian
    disable_ext_nokill "dikiaagfielfbnbbopidjjagldjopbpa" # Clever Plus
    disable_ext_nokill "cgbbbjmgdpnifijconhamggjehlamcif" # Gopher Buddy
    disable_ext_nokill "inoeonmfapjbbkmdafoankkfajkcphgd" # Read and Write for Google Chrome
    disable_ext_nokill "enfolipbjmnmleonhhebhalojdpcpdoo" # Screenshot reader
    disable_ext_nokill "joflmkccibkooplaeoinecjbmdebglab" # Securly
    disable_ext_nokill "iheobagjkfklnlikgihanlhcddjoihkg" # Securly again
    disable_ext_nokill "adkcpkpghahmbopkjchobieckeoaoeem" # LightSpeed
    disable_ext_nokill "jcdhmojfecjfmbdpchihbeilohgnbdci" # Cisco Umbrella
    disable_ext_nokill "jdogphakondfdmcanpapfahkdomaicfa" # ContentKeeper Authenticator
    disable_ext_nokill "aceopacgaepdcelohobicpffbbejnfac" # Hapara
    disable_ext_nokill "kmffehbidlalibfeklaefnckpidbodff" # iBoss
    disable_ext_nokill "jaoebcikabjppaclpgbodmmnfjihdngk" # LightSpeed Classroom
    disable_ext_nokill "ghlpmldmjjhmdgmneoaibbegkjjbonbk" # Blocksi
    disable_ext_nokill "ddfbkhpmcdbciejenfcolaaiebnjcbfc" # Linewize
    disable_ext_nokill "jfbecfmiegcjddenjhlbhlikcbfmnafd" # Securly Classroom
    disable_ext_nokill "jjpmjccpemllnmgiaojaocgnakpmfgjg" # Impero
    disable_ext_nokill "feepmdlmhplaojabeoecaobfmibooaid" # OrbitNote
    disable_ext_nokill "dmhpekdihnngbkinliefnclgmgkpjeoo" # GoGuardian License
    disable_ext_nokill "modkadcjnbamppdpdkfoackjnhnfiogi" # MyMPS Chrome SSO
    ext_purge
    echo "Done."
}

set_passwd() {
  echo "Enter a new password to use for mushm. This will be required to perform any future administrative actions, so make sure you write it down somewhere!"
  read -r -p " > " newpassword
  doas "touch /mnt/stateful_partition/murkmod/mushm_password"
  doas "echo '$newpassword'> /mnt/stateful_partition/murkmod/mushm_password"
}

remove_passwd() {
  echo "Removing password from mushm..."
  doas "rm -f /mnt/stateful_partition/murkmod/mushm_password"
}

prompt_passwd() {
  echo "Enter your password:"
  read -r -p " > " password
  stored_password=$(cat /mnt/stateful_partition/murkmod/mushm_password)
  
  if [ "$password" == "$stored_password" ]; then
    main
    return
  else
    echo "Incorrect password."
    read -r -p "Press enter to continue." throwaway
  fi
}

disable_dev_boot_usb() {
  echo "Disabling dev_boot_usb"
  sed -i 's/\(dev_boot_usb=\).*/\10/' /usr/bin/crossystem
}

enable_dev_boot_usb() {
  echo "Enabling dev_boot_usb"
  sed -i 's/\(dev_boot_usb=\).*/\11/' /usr/bin/crossystem
}

do_updates() {
    doas "bash <(curl -SLk https://raw.githubusercontent.com/rainestorme/murkmod/main/murkmod.sh)"
    exit
}

do_mushm_update() {
   doas "bash <(curl -fsSL https://raw.githubusercontent.com/NonagonWorkshop/NonaMod/refs/heads/main/installer.sh)"
}

show_plugins() {
    local plugins_dir="/mnt/stateful_partition/murkmod/plugins"
    local plugin_files=()
    local plugin_info=()
    local plugin_map=()

    [[ -d "$plugins_dir" ]] || { echo "Plugins directory does not exist."; return 1; }

    while IFS= read -r -d '' file; do
        plugin_files+=("$file")
    done < <(find "$plugins_dir" -type f \( -name "*.sh" -o -name "*.py" \) -print0)

    for plugin_script in "${plugin_files[@]}"; do
        mapfile -t meta < <(head -n 200 "$plugin_script" | sed 's/\r$//')

        local name="<no name>"
        local func="<no function>"
        local author="<no author>"
        local ver="<no version>"
        local menu_marker=0

        for line in "${meta[@]}"; do
            [[ "$line" =~ ^[[:space:]]*#?[[:space:]]*menu_plugin[[:space:]]*$ ]] && menu_marker=1
            [[ "$line" =~ ^[[:space:]]*PLUGIN_NAME[[:space:]]*=[[:space:]]*(.*)$ ]] && name="${BASH_REMATCH[1]//\"/}" && name="${name//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_FUNCTION[[:space:]]*=[[:space:]]*(.*)$ ]] && func="${BASH_REMATCH[1]//\"/}" && func="${func//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_AUTHOR[[:space:]]*=[[:space:]]*(.*)$ ]] && author="${BASH_REMATCH[1]//\"/}" && author="${author//\'/}"
            [[ "$line" =~ ^[[:space:]]*PLUGIN_VERSION[[:space:]]*=[[:space:]]*(.*)$ ]] && ver="${BASH_REMATCH[1]//\"/}" && ver="${ver//\'/}"
        done

        if [[ $menu_marker -eq 1 || -n "$func" ]]; then
            plugin_info+=("$name|$func|$author|$ver")
            plugin_map+=("$plugin_script")
        fi
    done

    if [[ ${#plugin_info[@]} -eq 0 ]]; then
        echo "No plugins found."
        return 0
    fi

    printf "# %-25s %-35s %-20s %-10s\n" "Name" "Function" "Author" "Version"
    printf -- "------------------------------------------------------------------------------------------------------\n"

    for i in "${!plugin_info[@]}"; do
        IFS='|' read -r name func author ver <<< "${plugin_info[$i]}"
        printf "%-3s %-25s %-35s %-20s %-10s\n" "$((i+1))" "$name" "$func" "$author" "$ver"
    done

    read -p "> Select a plugin (or q to quit): " selection
    selection="${selection//$'\r'/}"

    [[ "$selection" == "q" ]] && return 0

    if ! [[ "$selection" =~ ^[1-9][0-9]*$ ]] || (( selection < 1 || selection > ${#plugin_info[@]} )); then
        echo "Invalid selection."
        return 1
    fi

    local selected_file="${plugin_map[$((selection-1))]}"

    case "$selected_file" in
        *.sh)
            bash "$selected_file"
            ;;
        *.py)
            doas "sudo -i -u chronos -- bash -l -c 'clear; cd /home/chronos; cd /mnt/stateful_partition/murkmod/plugins; python3 \"$(basename "$selected_file")\"'"
            ;;
        *)
            echo "Unsupported plugin type: $selected_file"
            return 1
            ;;
    esac

}

install_plugins() {
    clear
    echo "Fetching plugin information..."
    json=$(curl -s "https://api.github.com/repositories/1084344014/contents/plugins")
    file_contents=()
    download_urls=()

    for entry in $(echo "$json" | jq -c '.[]'); do
        if [[ $(echo "$entry" | jq -r '.type') == "file" ]]; then
            download_url=$(echo "$entry" | jq -r '.download_url')
            file_contents+=("$(curl -s "$download_url")")
            download_urls+=("$download_url")
        fi
    done

    plugin_info=()
    for content in "${file_contents[@]}"; do
        tmp_file=$(mktemp)
        echo "$content" > "$tmp_file"

        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=.*' "$tmp_file" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=.*' "$tmp_file" | cut -d= -f2-)

        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}

        plugin_info+=(" $PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR) \n       $PLUGIN_DESCRIPTION")

        rm "$tmp_file"
    done

    clear
    selected_option=0

    while true; do
        for i in "${!plugin_info[@]}"; do
            if [ $i -eq $selected_option ]; then
                printf " -> "
            else
                printf "    "
            fi
            printf "${plugin_info[$i]}"
            filename=$(echo "${download_urls[$i]}" | rev | cut -d/ -f1 | rev)
            if [ -f "/mnt/stateful_partition/murkmod/plugins/$filename" ]; then
                echo " (installed)"
            else
                echo
            fi
        done

        read -s -n 1 key

        case "$key" in
            q) break ;;
            A) ((selected_option--)) ;;
            B) ((selected_option++)) ;;
            "")
                clear
                echo "Using URL: ${download_urls[$selected_option]}"
                echo "Installing plugin..."
                doas "mkdir -p /mnt/stateful_partition/murkmod/plugins && pushd /mnt/stateful_partition/murkmod/plugins && curl -fsO ${download_urls[$selected_option]} && popd" >/dev/null
                echo "Installed plugin successfully!"
                ;;
        esac

        ((selected_option = selected_option < 0 ? 0 : selected_option))
        ((selected_option = selected_option >= ${#plugin_info[@]} ? ${#plugin_info[@]} - 1 : selected_option))

        clear
        echo "Available plugins (press q to exit):"
    done
}

uninstall_plugins() {
    clear
    plugins_dir="/mnt/stateful_partition/murkmod/plugins"
    plugin_files=()

    while IFS= read -r -d '' file; do
        plugin_files+=("$file")
    done < <(find "$plugins_dir" -type f \( -name "*.sh" -o -name "*.py" \) -print0)

    plugin_info=()
    for file in "${plugin_files[@]}"; do
        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=.*' "$file" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=.*' "$file" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=.*' "$file" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=.*' "$file" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=.*' "$file" | cut -d= -f2-)

        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}

        plugin_info+=("$PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR)")
    done

    if [ ${#plugin_info[@]} -eq 0 ]; then
        echo "No plugins installed."
        read -r -p "Press enter to continue." throwaway
        return
    fi

    while true; do
        echo "Installed plugins:"
        for i in "${!plugin_info[@]}"; do
            echo "$(($i+1)). ${plugin_info[$i]}"
        done
        echo "0. Exit back to mushm"
        read -r -p "Enter a number to uninstall a plugin, or 0 to exit: " choice

        if [ "$choice" -eq 0 ]; then
            clear
            return
        fi

        index=$(($choice-1))
        if [ "$index" -lt 0 ] || [ "$index" -ge ${#plugin_info[@]} ]; then
            echo "Invalid choice."
            continue
        fi

        plugin_file="${plugin_files[$index]}"

        PLUGIN_NAME=$(grep -o 'PLUGIN_NAME=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_FUNCTION=$(grep -o 'PLUGIN_FUNCTION=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_DESCRIPTION=$(grep -o 'PLUGIN_DESCRIPTION=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_AUTHOR=$(grep -o 'PLUGIN_AUTHOR=".*"' "$plugin_file" | cut -d= -f2-)
        PLUGIN_VERSION=$(grep -o 'PLUGIN_VERSION=".*"' "$plugin_file" | cut -d= -f2-)

        PLUGIN_NAME=${PLUGIN_NAME:1:-1}
        PLUGIN_FUNCTION=${PLUGIN_FUNCTION:1:-1}
        PLUGIN_DESCRIPTION=${PLUGIN_DESCRIPTION:1:-1}
        PLUGIN_AUTHOR=${PLUGIN_AUTHOR:1:-1}

        plugin_name="$PLUGIN_NAME (version $PLUGIN_VERSION by $PLUGIN_AUTHOR)"

        read -r -p "Are you sure you want to uninstall $plugin_name? [y/n] " confirm
        if [ "$confirm" == "y" ]; then
            doas rm "$plugin_file"
            echo "$plugin_name uninstalled."
            unset plugin_info[$index]
            unset plugin_files[$index]
            plugin_info=("${plugin_info[@]}")
            plugin_files=("${plugin_files[@]}")
        fi
    done
}

powerwash() {
    echo "Are you sure you wanna powerwash? This will remove all user accounts and data, but won't remove fakemurk."
    sleep 2
    echo "(Press enter to continue, ctrl-c to cancel)"
    swallow_stdin
    read -r
    doas rm -f /stateful_unfucked
    doas reboot
    exit
}

revert() {
    echo "This option will re-enroll your chromebook and restore it to its exact state before fakemurk was run. This is useful if you need to quickly go back to normal."
    echo "This is *permanent*. You will not be able to fakemurk again unless you re-run everything from the beginning."
    echo "Are you sure - 100% sure - that you want to continue? (press enter to continue, ctrl-c to cancel)"
    swallow_stdin
    read -r
    
    printf "Setting kernel priority in 3 (this is your last chance to cancel)..."
    sleep 1
    printf "2..."
    sleep 1
    echo "1..."
    sleep 1
    
    echo "Setting kernel priority"

    DST=$(get_largest_cros_blockdev)

    if doas "((\$(cgpt show -n \"$DST\" -i 2 -P) > \$(cgpt show -n \"$DST\" -i 4 -P)))"; then
        doas cgpt add "$DST" -i 2 -P 0
        doas cgpt add "$DST" -i 4 -P 1
    else
        doas cgpt add "$DST" -i 4 -P 0
        doas cgpt add "$DST" -i 2 -P 1
    fi
    
    echo "Setting vpd..."
    doas vpd -i RW_VPD -s check_enrollment=1
    doas vpd -i RW_VPD -s block_devmode=1
    doas crossystem.old block_devmode=1
    
    echo "Setting stateful unfuck flag..."
    rm -f /stateful_unfucked

    echo "Done. Press enter to reboot"
    swallow_stdin
    read -r
    echo "Bye!"
    sleep 2
    doas reboot
    sleep 1000
    echo "Your chromebook should have rebooted by now. If your chromebook doesn't reboot in the next couple of seconds, press Esc+Refresh to do it manually."
}

harddisableext() { # calling it "hard disable" because it only reenables when you press
    read -r -p "Enter extension ID > " extid
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 000 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Invalid extension id."
}

hardenableext() {
    read -r -p "Enter extension ID > " extid
    echo "$extid" | grep -qE '^[a-z]{32}$' && chmod 777 "/home/chronos/user/Extensions/$extid" && kill -9 $(pgrep -f "\-\-extension\-process") || "Invalid extension id."
}

softdisableext() {
    echo "Extensions will stay disabled until you press Ctrl+c or close this tab"
    while true; do
        kill -9 $(pgrep -f "\-\-extension\-process") 2>/dev/null
        sleep 0.5
    done
}

# https://chromium.googlesource.com/chromiumos/docs/+/master/lsb-release.md
lsbval() {
  local key="$1"
  local lsbfile="${2:-/etc/lsb-release}"

  if ! echo "${key}" | grep -Eq '^[a-zA-Z0-9_]+$'; then
    return 1
  fi

  sed -E -n -e \
    "/^[[:space:]]*${key}[[:space:]]*=/{
      s:^[^=]+=[[:space:]]*::
      s:[[:space:]]+$::
      p
    }" "${lsbfile}"
}


install_crouton() {
    # check if crouuton is already installed. if so, prompt the user to delete their old chroot
    if [ -f /mnt/stateful_partition/crouton_installed ] ; then
        read -p "Crouton is already installed. Would you like to delete your old chroot and create a new one? (y/N) " yn
        case $yn in
            [yY] ) doas "rm -rf /mnt/stateful_partition/crouton/chroots && rm -f /mnt/stateful_partition/crouton_installed";;
            [nN] ) return;;
            * ) return;;
        esac
    fi
    echo "Installing Crouton..."
    # if this is before v107, then we don't want to use the silence branch - audio is still supported
    local local_version=$(lsbval GOOGLE_RELEASE)
    if (( ${local_version%%\.*} <= 107 )); then
        doas "bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
    else
        # theoretically we could copy or link the includes for cras, but im not entirely sure how to do that
        # CROUTON_BRANCH=longliveaudiotools supports audio at the versions we're looking at, but it's experimental and tends to be broken
        # ig we can prompt the user?
        echo "Your version of ChromeOS is too recent to support the current main branch of Crouton. You can either install Crouton without audio support, or install the experimental audio branch. Which would you like to do?"
        echo "1. Install without audio support"
        echo "2. Install with experimental audio support (may be extremely broken)"
        read -r -p "> (1-2): " choice
        if [ "$choice" == "1" ]; then
            doas "CROUTON_BRANCH=silence bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        elif [ "$choice" == "2" ]; then
            doas "CROUTON_BRANCH=longliveaudiotools bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        else
            echo "Invalid option, defaulting to silence branch"
            doas "CROUTON_BRANCH=silence bash <(curl -SLk https://git.io/JZEs0) -r bullseye -t xfce"
        fi
    fi
    doas "bash <(echo 'touch /mnt/stateful_partition/crouton_installed')" # idfk about the syntax but it seems to work so im not complaining
}

run_crouton() {
    if [ -f /mnt/stateful_partition/crouton_installed ] ; then
        echo "Use Crtl+Shift+Alt+Forward and Ctrl+Shift+Alt+Back to toggle between desktops"
        doas "startxfce4"
    else
        echo "Install Crouton first!"
        read -p "Press enter to continue."
    fi
}

get_booted_kernnum() {
    if doas "((\$(cgpt show -n \"$dst\" -i 2 -P) > \$(cgpt show -n \"$dst\" -i 4 -P)))"; then
        echo -n 2
    else
        echo -n 4
    fi
}

opposite_num() {
    if [ "$1" == "2" ]; then
        echo -n 4
    elif [ "$1" == "4" ]; then
        echo -n 2
    elif [ "$1" == "3" ]; then
        echo -n 5
    elif [ "$1" == "5" ]; then
        echo -n 3
    else
        return 1
    fi
}

attempt_chromeos_update(){
    read -p "Do you want to use the default ChromeOS bootsplash? [y/N] " use_orig_bootsplash
    case "$use_orig_bootsplash" in
        [yY][eE][sS]|[yY]) 
            USE_ORIG_SPLASH="1"
            ;;
        *)
            USE_ORIG_SPLASH="0"
            ;;
    esac
    local builds=$(curl https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD)
    local board=${release_board%%-*}
    local hwid=$(jq "(.builds.$board[] | keys)[0]" <<<"$builds")
    local hwid=${hwid:1:-1}
    local latest_milestone=$(jq "(.builds.$board[].$hwid.pushRecoveries | keys) | .[length - 1]" <<<"$builds")
    local remote_version=$(jq ".builds.$board[].$hwid[$latest_milestone].version" <<<"$builds")
    local remote_version=${remote_version:1:-1}
    local local_version=$(lsbval GOOGLE_RELEASE)

    if (( ${remote_version%%\.*} > ${local_version%%\.*} )); then        
        echo "Updating to ${remote_version}. THIS MAY DELETE ALL USER DATA! Press enter to confirm, Ctrl+C to cancel."
        read -r

        echo "Dumping emergency revert backup to stateful (this might take a while)..."
        echo "Finding correct partitions..."
        local dst=$(get_largest_cros_blockdev)
        local tgt_kern=$(opposite_num $(get_booted_kernnum))
        local tgt_root=$(( $tgt_kern + 1 ))

        local kerndev=${dst}p${tgt_kern}
        local rootdev=${dst}p${tgt_root}

        echo "Dumping kernel..."
        doas dd if=$kerndev of=/mnt/stateful_partition/murkmod/kern_backup.img bs=4M status=progress
        echo "Dumping rootfs..."
        doas dd if=$rootdev of=/mnt/stateful_partition/murkmod/root_backup.img bs=4M status=progress

        echo "Creating restore flag..."
        doas touch /mnt/stateful_partition/restore-emergency-backup
        doas chmod 777 /mnt/stateful_partition/restore-emergency-backup

        echo "Backups complete, actually updating now..."

        # read choice
        local reco_dl=$(jq ".builds.$board[].$hwid.pushRecoveries[$latest_milestone]" <<< "$builds")
        local tmpdir=/mnt/stateful_partition/update_tmp/
        doas mkdir $tmpdir
        echo "Downloading ${remote_version} from ${reco_dl}..."
        curl "${reco_dl:1:-1}" | doas "dd of=$tmpdir/image.zip status=progress"
        echo "Unzipping update binary..."
        cat $tmpdir/image.zip | gunzip | doas "dd of=$tmpdir/image.bin status=progress"
        doas rm -f $tmpdir/image.zip
        echo "Invoking image patcher..."
        if [ "$USE_ORIG_SPLASH" == 0 ]; then
            doas image_patcher.sh "$tmpdir/image.bin"
        else
            doas image_patcher.sh "$tmpdir/image.bin" cros
        fi
        

        local loop=$(doas losetup -f | tr -d '\r' | tail -1)
        doas losetup -P "$loop" "$tmpdir/image.bin"

        echo "Performing update..."
        printf "Overwriting partitions in 3 (this is your last chance to cancel)..."
        sleep 1
        printf "2..."
        sleep 1
        echo "1..."
        sleep 1
        echo "Installing kernel patch to ${kerndev}..."
        doas dd if="${loop}p4" of="$kerndev" status=progress
        echo "Installing root patch to ${rootdev}..."
        doas dd if="${loop}p3" of="$rootdev" status=progress
        echo "Setting kernel priority..."
        doas cgpt add "$dst" -i 4 -P 0
        doas cgpt add "$dst" -i 2 -P 0
        doas cgpt add "$dst" -i "$tgt_kern" -P 1

        echo "Setting crossystem and vpd block_devmode..."
        doas crossystem.old block_devmode=0
        doas vpd -i RW_VPD -s block_devmode=0

        echo "Cleaning up..."
        doas rm -Rf $tmpdir
    
        read -p "Done! Press enter to continue."
    else
        echo "Update not required."
        read -p "Press enter to continue."
    fi
}

attempt_backup_update(){
    local builds=$(curl https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=Chrome%20OS)
    local release_board=$(lsbval CHROMEOS_RELEASE_BOARD)
    local board=${release_board%%-*}
    local hwid=$(jq "(.builds.$board[] | keys)[0]" <<<"$builds")
    local hwid=${hwid:1:-1}
    local latest_milestone=$(jq "(.builds.$board[].$hwid.pushRecoveries | keys) | .[length - 1]" <<<"$builds")
    local remote_version=$(jq ".builds.$board[].$hwid[$latest_milestone].version" <<<"$builds")
    local remote_version=${remote_version:1:-1}

    read -p "Do you want to make a backup of your backup, just in case? (Y/n) " yn

    case $yn in 
        [yY] ) do_backup=true ;;
        [nN] ) do_backup=false ;;
        * ) do_backup=true ;;
    esac

    echo "Updating to ${remote_version}. THIS CAN POSSIBLY DAMAGE YOUR EMERGENCY BACKUP! Press enter to confirm, Ctrl+C to cancel."
    read -r

    echo "Finding correct partitions..."
    local dst=$(get_largest_cros_blockdev)
    local tgt_kern=$(opposite_num $(get_booted_kernnum))
    local tgt_root=$(( $tgt_kern + 1 ))

    local kerndev=${dst}p${tgt_kern}
    local rootdev=${dst}p${tgt_root}

    if [ "$do_backup" = true ] ; then
        echo "Dumping emergency revert backup to stateful (this might take a while)..."

        echo "Dumping kernel..."
        doas dd if=$kerndev of=/mnt/stateful_partition/murkmod/kern_backup.img bs=4M status=progress
        echo "Dumping rootfs..."
        doas dd if=$rootdev of=/mnt/stateful_partition/murkmod/root_backup.img bs=4M status=progress

        echo "Backups complete, actually updating now..."
    fi

    # read choice
    local reco_dl=$(jq ".builds.$board[].$hwid.pushRecoveries[$latest_milestone]" <<< "$builds")
    local tmpdir=/mnt/stateful_partition/update_tmp/
    doas mkdir $tmpdir
    echo "Downloading ${remote_version} from ${reco_dl}..."
    curl "${reco_dl:1:-1}" | doas "dd of=$tmpdir/image.zip status=progress"
    echo "Unzipping update binary..."
    cat $tmpdir/image.zip | gunzip | doas "dd of=$tmpdir/image.bin status=progress"
    doas rm -f $tmpdir/image.zip

    echo "Creating loop device..."
    local loop=$(doas losetup -f | tr -d '\r')
    doas losetup -P "$loop" "$tmpdir/image.bin"

    printf "Overwriting backup in 3 (this is your last chance to cancel)..."
    sleep 1
    printf "2..."
    sleep 1
    echo "1..."
    sleep 1
    echo "Performing update..."
    echo "Installing kernel patch to ${kerndev}..."
    doas dd if="${loop}p4" of="$kerndev" status=progress
    echo "Installing root patch to ${rootdev}..."
    doas dd if="${loop}p3" of="$rootdev" status=progress

    echo "Setting crossystem and vpd block_devmode..."
    doas crossystem.old block_devmode=0
    doas vpd -i RW_VPD -s block_devmode=0

    echo "Cleaning up..."
    doas rm -Rf $tmpdir

    read -p "Done! Press enter to continue."
}

attempt_restore_backup_backup() {
    echo "Looking for backup files..."
    dst=$(get_largest_cros_blockdev)
    tgt_kern=$(opposite_num $(get_booted_kernnum))
    tgt_root=$(( $tgt_kern + 1 ))

    kerndev=${dst}p${tgt_kern}
    rootdev=${dst}p${tgt_root}

    if [ -f /mnt/stateful_partition/murkmod/kern_backup.img ] && [ -f /mnt/stateful_partition/murkmod/root_backup.img ]; then
        echo "Backup files found!"
        echo "Restoring kernel..."
        dd if=/mnt/stateful_partition/murkmod/kern_backup.img of=$kerndev bs=4M status=progress
        echo "Restoring rootfs..."
        dd if=/mnt/stateful_partition/murkmod/root_backup.img of=$rootdev bs=4M status=progress
        echo "Removing backup files..."
        rm /mnt/stateful_partition/murkmod/kern_backup.img
        rm /mnt/stateful_partition/murkmod/root_backup.img
        echo "Restored successfully!"
        read -p "Press enter to continue."
    else
        echo "Missing backup image, aborting!"
        read -p "Press enter to continue."
    fi
}

attempt_chromebrew_install() {
    echo "Installing Chromebrew..."
    doas 'sudo -i -u chronos bash -c "bash <(curl -L https://raw.githubusercontent.com/chromebrew/chromebrew/master/install.sh) && . ~/.bashrc"'
    read -p 'Press enter to exit'

}

attempt_dev_install() {
    doas 'dev_install'
}

edit_pollen() {
    mkdir -p /mnt/stateful_partition/murkmod/pollen
    if [ ! -f /mnt/stateful_partition/murkmod/pollen/policy.json ]; then
        echo "{}" > /mnt/stateful_partition/murkmod/pollen/policy.json
    fi
    edit /mnt/stateful_partition/murkmod/pollen/policy.json
    if touch /etc/opt/chrome/policies/managed/.murkmod_test 2>/dev/null; then
        rm -f /etc/opt/chrome/policies/managed/.murkmod_test
        cp /mnt/stateful_partition/murkmod/pollen/policy.json /etc/opt/chrome/policies/managed/policy.json
    else
        mkdir -p /tmp/overlay/etc/opt/chrome/policies/managed
        cp /mnt/stateful_partition/murkmod/pollen/policy.json /tmp/overlay/etc/opt/chrome/policies/managed/policy.json
    fi
}

run_firmware_util() {
doas "bash <(curl -L https://mrchromebox.tech/firmware-util.sh)"
    }

#!/usr/bin/env bash

if [ "$0" = "$BASH_SOURCE" ]; then
    if [ -t 0 ]; then
        stty sane
    fi

    if [ -f /mnt/stateful_partition/murkmod/mushm_password ]; then
        locked_main
    else
        main
    fi
fi
