#!/bin/bash
. ./conf.sh

_FUSE_SDL=fuse-sdl
_FUSE_GTK=fuse-gtk
_OPT_ARCH='--machine 48'
_OPT_SOUND='--sound --speaker-type Beeper'
_OPT_VIDEO='--graphics-filter paltv3x'
_OPT_VIDEO_WINDOW='--no-full-screen'
_OPT_VIDEO_FULLSCREEN_SDL='--sdl-fullscreen-mode 1 --full-screen'
_OPT_SPEED_FAST='--accelerate-loader --fastload --detect-loader --no-loading-sound --slt --traps'
_OPT_SPEED_SLOW='--no-accelerate-loader --no-fastload --no-detect-loader --loading-sound --no-slt --no-traps'
_OPT_TAPE="--auto-load --tape $srcdir/test.tap"

declare -A CmdLine
declare -A CmdDesc

# $1=tag $2=command $3=description
add_cmd() {
	CmdLine[$1]="$2"
	CmdDesc[$1]="$3"
}

add_cmd SDL_FS_FAST \
	"$_FUSE_SDL $_OPT_ARCH $_OPT_SOUND $_OPT_VIDEO $_OPT_VIDEO_FULLSCREEN_SDL $_OPT_SPEED_FAST" \
	'Fast, fullscreen (mode 1), PAL TV x3 (SDL)'
add_cmd SDL_FS_SLOW \
	"$_FUSE_SDL $_OPT_ARCH $_OPT_SOUND $_OPT_VIDEO $_OPT_VIDEO_FULLSCREEN_SDL $_OPT_SPEED_SLOW" \
	'Slow, fullscreen (mode 1), PAL TV x3 (SDL)'
add_cmd GTK_W_FAST \
	"$_FUSE_GTK $_OPT_ARCH $_OPT_SOUND $_OPT_VIDEO $_OPT_VIDEO_WINDOW $_OPT_SPEED_FAST" \
	'Fast, window, PAL TV x3 (GTK)'
add_cmd GTK_W_SLOW \
	"$_FUSE_GTK $_OPT_ARCH $_OPT_SOUND $_OPT_VIDEO $_OPT_VIDEO_WINDOW $_OPT_SPEED_SLOW" \
	'Slow, window, PAL TV x3 (GTK)'

declare DIALOG

DIALOG="`which dialog`" || true
if [[ x"$DIALOG" == x ]]; then
    DIALOG=`which whiptail` || true
fi
if [[ x"$DIALOG" == x ]]; then
    echo 'Error: no "dialog" nor "whiptail" found.' >&2
    exit 1
fi

tmp="`mktemp`"

$DIALOG --notags --separate-output --radiolist \
'Select options to run FUSE with:' \
15 70 4 \
SDL_FS_FAST "${CmdDesc[SDL_FS_FAST]}" - \
SDL_FS_SLOW "${CmdDesc[SDL_FS_SLOW]}" - \
GTK_W_FAST "${CmdDesc[GTK_W_FAST]}" - \
GTK_W_SLOW "${CmdDesc[GTK_W_SLOW]}" on 2> "$tmp" || { echo 'Cancelled.' >&2; rm -f -- "$tmp"; exit 1; }

read _tag <"$tmp"
rm -f "$tmp"
${CmdLine[$_tag]} $_OPT_TAPE
