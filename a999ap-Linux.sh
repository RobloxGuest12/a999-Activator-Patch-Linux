

#!/usr/bin/env bash

# a999 Activator Patch
# Linux-compatible edition
# Original patch values preserved.

SCRIPTPATH="$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")"
SCRIPTPATHMAIN="$(dirname "$SCRIPTPATH")"

dir=""
folderpath=""
A999_FILE=""
BACKUP_FILE=""

# ------------------------------------------
# Terminal colors
# ------------------------------------------

LIGHTMODE()
{
    APP=$'\033[38;5;23m'
    TITLE=$'\033[38;5;24m'
    BODY=$'\033[38;5;23m'
    PROMPTSTYLE=$'\033[38;5;66m'
    OSFOUND=$'\033[38;5;67m'
    WARNING=$'\033[38;5;160m'
    ERROR=$'\033[38;5;9m'
    CANCEL=$'\033[38;5;31m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
}

DARKMODE()
{
    APP=$'\033[38;5;158m'
    TITLE=$'\033[38;5;153m'
    BODY=$'\033[38;5;158m'
    PROMPTSTYLE=$'\033[38;5;152m'
    OSFOUND=$'\033[38;5;111m'
    WARNING=$'\033[38;5;160m'
    ERROR=$'\033[38;5;196m'
    CANCEL=$'\033[38;5;38m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
}

UIColors()
{
    # Override using A999_THEME=light or A999_THEME=dark.
    case "${A999_THEME:-}" in
        light)
            LIGHTMODE
            ;;
        dark)
            DARKMODE
            ;;
        *)
            # COLORFGBG is supported by some Linux terminals.
            if [[ "${COLORFGBG:-}" =~ '^([0-9]+);([0-9]+)$' ]]; then
                if (( BASH_REMATCH[2] >= 8 )); then
                    LIGHTMODE
                else
                    DARKMODE
                fi
            else
                DARKMODE
            fi
            ;;
    esac
}

UIColors

# ------------------------------------------
# Window interface
# ------------------------------------------

WINDOWBAR()
{
    clear
    printf '%s%s                           a999 Activator Patch %sV1.0.0%s\n' \
        "$APP" "$BOLD" "$APP" "$RESET"

    printf '%s\n' \
        "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
}

WINDOWBAREND()
{
    printf '\n%s%s                                Script Canceled\n' "$CANCEL" "$BOLD"
    printf '%s%s\n' "$APP" "$BOLD"
    printf '%s\n' \
        "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
    printf '%s\n' "$RESET"
    exit 0
}

WINDOWERROR()
{
    printf '\n%s%s\n' "$ERROR" "$BOLD"
    printf '%s\n' \
        "       Command not recognized, please report the following code to GitHub:" \
        "                                     384508"

    printf '%s%s\n' "$APP" "$BOLD"
    printf '%s\n' \
        "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
    printf '%s\n' "$RESET"
    exit 1
}

# ------------------------------------------
# Menu selector
# ------------------------------------------

MENU_SELECTOR()
{
    local options=("$@")
    local selected=0
    local key rest
    local num_options=${#options[@]}
    local i

    if (( num_options == 0 )); then
        return 111
    fi

    printf '\n'

    for i in "${!options[@]}"; do
        if (( i == selected )); then
            printf '%s%s                >-%s%s\n' \
                "$PROMPTSTYLE" "$BOLD" "${options[$i]}" "$RESET"
        else
            printf '                  %s%s%s\n' \
                "$TITLE" "${options[$i]}" "$RESET"
        fi
    done

    while true; do

        # Move cursor back to the beginning of the menu.
        tput cuu "$num_options" 2>/dev/null || true

        for i in "${!options[@]}"; do
            if (( i == selected )); then
                printf '%s%s                >-%s-<%s\n' \
                    "$PROMPTSTYLE" "$BOLD" "${options[$i]}" "$RESET"
            else
                printf '                  %s%s  %s\n' \
                    "$TITLE" "${options[$i]}" "$RESET"
            fi
        done

        IFS= read -r -s -n 1 key || return 111

        case "$key" in

            $'\x1b')
                IFS= read -r -s -n 2 -t 1 rest || continue

                case "$rest" in
                    '[A')
                        ((selected--))
                        (( selected < 0 )) && selected=$((num_options - 1))
                        ;;
                    '[B')
                        ((selected++))
                        (( selected >= num_options )) && selected=0
                        ;;
                esac
                ;;

            "")
                return "$selected"
                ;;

            [Qq])
                return 111
                ;;

            [Cc])
                return 110
                ;;

        esac
    done
}

# ------------------------------------------
# Main menu
# ------------------------------------------

MAINMENU()
{
    WINDOWBAR

    printf '%s%s                   Select the a999 executable to get started%s\n' \
        "$TITLE" "$BOLD" "$RESET"

    printf '%s                  Use %s↑ ↓%s to navigate. Press %sReturn%s to select\n' \
        "$BODY" "$BOLD" "$BODY" "$BOLD" "$RESET"

    printf '\n%s%s                            Please choose an option:\n' \
        "$TITLE" "$BOLD"

    menuoptions=(
        "-----------Select a999 executable-----------"
        "--------------------Exit--------------------"
    )

    MENU_SELECTOR "${menuoptions[@]}"
    selection=$?

    case "$selection" in
        0) A999FOLDER ;;
        1) WINDOWBAREND ;;
        110|111) WINDOWBAREND ;;
        *) WINDOWERROR ;;
    esac
}

# ------------------------------------------
# Linux file picker
# ------------------------------------------

A999FOLDER()
{
    WINDOWBAR

    printf '%s%s                         Select the a999 executable%s\n' \
        "$TITLE" "$BOLD" "$RESET"

    if command -v zenity >/dev/null 2>&1; then

        folderpath=$(zenity --file-selection \
            --title="Select the a999 executable" \
            --file-filter="a999 executable | a999" \
            2>/dev/null)

    elif command -v kdialog >/dev/null 2>&1; then

        folderpath=$(kdialog --getopenfilename \
            "$HOME" \
            "a999|a999 executable" \
            --title "Select the a999 executable" \
            2>/dev/null)

    else

        printf '\n%sNo graphical file picker found.%s\n' "$WARNING" "$RESET"
        printf 'Enter the full path to a999: '

        IFS= read -r folderpath

    fi

    if [[ -z "$folderpath" ]]; then
        WINDOWBAREND
    fi

    FOLDERVERIFY
}

# ------------------------------------------
# Verify executable folder
# ------------------------------------------

FOLDERVERIFY()
{
    dir=$(dirname "$folderpath")
    A999_FILE="$folderpath"
    BACKUP_FILE="$A999_FILE.a999-original"

    local required_files=(
        "changelog.md"
        "license.md"
        "readme.md"
    )

    local required_folders=(
        "bin"
        "payload"
    )

    local file
    local folder

    for file in "${required_files[@]}"; do
        if [[ ! -f "$dir/$file" ]]; then
            FOLDERERROR
            return 1
        fi
    done

    for folder in "${required_folders[@]}"; do
        if [[ ! -d "$dir/$folder" ]]; then
            FOLDERERROR
            return 1
        fi
    done

    if [[ ! -f "$A999_FILE" ]]; then
        FOLDERERROR
        return 1
    fi

    if [[ -f "$dir/.patched" ]]; then
        FOLDERPASSPATCHED
        return 0
    fi

    FOLDERPASS
    return 0
}

# ------------------------------------------
# Folder verification failed
# ------------------------------------------

FOLDERERROR()
{
    printf '\n%s        This folder has been corrupted. Please redownload and try again.\n' "$ERROR"

    printf '%s%s\n' "$APP" "$BOLD"
    printf '%s\n' \
        "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
    printf '%s\n' "$RESET"

    exit 1
}

# ------------------------------------------
# Folder passed
# ------------------------------------------

FOLDERPASS()
{
    WINDOWBAR

    printf '%s%s                              a999 executable found!%s\n' \
        "$TITLE" "$BOLD" "$RESET"

    printf '%s                  Use %s↑ ↓%s to navigate. Press %sReturn%s to select\n' \
        "$BODY" "$BOLD" "$BODY" "$BOLD" "$RESET"

    printf '\n%s%s                            Please choose an option:\n' \
        "$TITLE" "$BOLD"

    menuoptions=(
        "-------------* Start Patching *-------------"
        "-----------Select a999 executable-----------"
        "--------------------Exit--------------------"
    )

    MENU_SELECTOR "${menuoptions[@]}"
    selection=$?

    case "$selection" in
        0) A999PATCH ;;
        1) A999FOLDER ;;
        2) WINDOWBAREND ;;
        110|111) WINDOWBAREND ;;
        *) WINDOWERROR ;;
    esac
}

# ------------------------------------------
# Already patched
# ------------------------------------------

FOLDERPASSPATCHED()
{
    WINDOWBAR

    printf '%s%s                          a999 has already been patched%s\n' \
        "$TITLE" "$BOLD" "$RESET"

    printf '%s                  Use %s↑ ↓%s to navigate. Press %sReturn%s to select\n' \
        "$BODY" "$BOLD" "$BODY" "$BOLD" "$RESET"

    printf '\n%s%s                            Please choose an option:\n' \
        "$TITLE" "$BOLD"

    menuoptions=(
        "-------------* Revert Patches *-------------"
        "-----------Select a999 executable-----------"
        "--------------------Exit--------------------"
    )

    MENU_SELECTOR "${menuoptions[@]}"
    selection=$?

    case "$selection" in
        0) A999PATCHREVERT ;;
        1) A999FOLDER ;;
        2) WINDOWBAREND ;;
        110|111) WINDOWBAREND ;;
        *) WINDOWERROR ;;
    esac
}

# ------------------------------------------
# Apply patches
# ------------------------------------------

A999PATCH()
{
    WINDOWBAR

    printf '%s%s                               Applying patches...\n' \
        "$TITLE" "$BOLD"

    printf '%s\n' "$BODY"

    # Check that the executable is writable.
    if [[ ! -w "$A999_FILE" ]]; then
        printf '%sERROR: a999 is not writable.%s\n' "$ERROR" "$RESET"
        exit 1
    fi

    # Create a backup before modifying the executable.
    if [[ ! -f "$BACKUP_FILE" ]]; then
        if ! cp -p "$A999_FILE" "$BACKUP_FILE"; then
            printf '%sERROR: Could not create backup.%s\n' "$ERROR" "$RESET"
            exit 1
        fi
    fi

    # GNU/Linux sed syntax.
    sed -i \
        -e '17s/047-95293/122-77536/' \
        -e '17s/18A0749D-A68D-430C-8E31-1920612F3229/9EE30DC1-EC4B-47CE-A002-24CD6B18947D/' \
        -e '17s/15.8.7_19H411/15.8.8_19H422/' \
        -e '19s/047-95429/122-77510/' \
        -e '19s/C8FE847C-FE0E-49B1-9C7E-F56894B6E2BF/5D4563BF-445C-4D8D-AF56-0BAC336265F3/' \
        -e '19s/15.8.7_19H411/15.8.8_19H422/' \
        -e '26s/15.8.7/15.8.8/' \
        -e '140s/15.8.7/15.8.8/' \
        -e '142s/15.8.7/15.8.8/' \
        -e '143s/15.8.7/15.8.8/' \
        -e '145s/15.8.7/15.8.8/' \
        -e '175s/15.8.7/15.8.8/' \
        "$A999_FILE"

    if [[ $? -ne 0 ]]; then
        cp -p "$BACKUP_FILE" "$A999_FILE"
        printf '%sERROR: Patching failed. Original restored.%s\n' "$ERROR" "$RESET"
        exit 1
    fi

    touch "$dir/.patched"

    printf '%s%s                                   All Done!%s\n' \
        "$BODY" "$BOLD" "$RESET"

    printf '\n%s%s                            Please choose an option:\n' \
        "$TITLE" "$BOLD"

    menuoptions=(
        "-----------------Start a999-----------------"
        "--------------------Exit--------------------"
    )

    MENU_SELECTOR "${menuoptions[@]}"
    selection=$?

    case "$selection" in

        0)
            printf '%s\n' "$RESET"
            cd "$dir" || exit 1

            if [[ -x "./$(basename "$A999_FILE")" ]]; then
                "./$(basename "$A999_FILE")"
                exit $?
            else
                printf '%sERROR: a999 is not executable.%s\n' "$ERROR" "$RESET"
                exit 1
            fi
            ;;

        1)
            WINDOWBAREND
            ;;

        110|111)
            WINDOWBAREND
            ;;

        *)
            WINDOWERROR
            ;;

    esac
}

# ------------------------------------------
# Revert patches
# ------------------------------------------

A999PATCHREVERT()
{
    WINDOWBAR

    printf '%s%s                               Removing patches...\n' \
        "$TITLE" "$BOLD"

    printf '%s\n' "$BODY"

    if [[ -f "$BACKUP_FILE" ]]; then

        # Restore the exact original file.
        cp -p "$BACKUP_FILE" "$A999_FILE" || {
            printf '%sERROR: Backup restoration failed.%s\n' "$ERROR" "$RESET"
            exit 1
        }

        rm -f "$BACKUP_FILE"

    else

        # Fallback for files patched without this Linux version.
        sed -i \
            -e '17s/122-77536/047-95293/' \
            -e '17s/9EE30DC1-EC4B-47CE-A002-24CD6B18947D/18A0749D-A68D-430C-8E31-1920612F3229/' \
            -e '17s/15.8.8_19H422/15.8.7_19H411/' \
            -e '19s/122-77510/047-95429/' \
            -e '19s/5D4563BF-445C-4D8D-AF56-0BAC336265F3/C8FE847C-FE0E-49B1-9C7E-F56894B6E2BF/' \
            -e '19s/15.8.8_19H422/15.8.7_19H411/' \
            -e '26s/15.8.8/15.8.7/' \
            -e '140s/15.8.8/15.8.7/' \
            -e '142s/15.8.8/15.8.7/' \
            -e '143s/15.8.8/15.8.7/' \
            -e '145s/15.8.8/15.8.7/' \
            -e '175s/15.8.8/15.8.7/' \
            "$A999_FILE" || exit 1

    fi

    rm -f "$dir/.patched"

    printf '%s%s                                   All Done!%s\n' \
        "$BODY" "$BOLD" "$RESET"

    printf '%s%s\n' "$APP" "$BOLD"

    printf '%s\n' \
        "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"

    printf '%s\n' "$RESET"
    exit 0
}

# ------------------------------------------
# Start
# ------------------------------------------

if [[ ! -t 0 ]]; then
    echo "This script requires an interactive terminal."
    exit 1
fi

MAINMENU
