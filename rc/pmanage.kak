declare-option str-list pmanage_process_list

define-command -docstring "pstart <command>: start process in background, and create FIFO buffer named after process PID." \
pstart -params 1 %{ nop %sh{
    cmd="${1%&*}"
    fifo=$(mktemp -u "${TMPDIR:-/tmp}/pmanage-process.XXXXXXXXXX") || exit "can't create FIFO for $cmd"
    mkfifo "$fifo"
    ( $cmd >$fifo <$fifo ) >/dev/null 2>&1 </dev/null &
    process=$!
    printf "%s\n" "set-option -add global pmanage_process_list $process
                   edit -fifo $fifo $process
                   hook -once -always global BufClose $process %{ nop %sh{ rm -rf $fifo; kill $process } }
                   hook -once -always global KakEnd .* %{ nop %sh{ rm -rf $fifo; kill $process } }
                   hook -once -always global BufCloseFifo $fifo %{ nop %sh{ rm -rf $fifo } }" | kak -p $kak_session
}}

define-command -docstring "pstop <PID>: delete process buffer and send SIGTERM signal to process." \
-shell-script-candidates %{
    eval "set $kak_opt_pmanage_process_list"
    while [ $# -ne 0 ]; do
        printf "%s\n" "$1"
        shift
    done
} pstop -params 1 %{ try %{
    remove-process-from-list %arg{1}
    delete-buffer %arg{1}
}}

define-command -docstring "pkill <PID>: delete process buffer and send SIGKILL signal to process." \
-shell-script-candidates %{
    eval "set $kak_opt_pmanage_process_list"
    while [ $# -ne 0 ]; do
        printf "%s\n" "$1"
        shift
    done
} pkill -params 1 %{ try %{
    remove-process-from-list %arg{1}
    delete-buffer %arg{1}
    nop %sh{ kill -9 $1 }
}}

define-command -hidden remove-process-from-list -params 1 %{ evaluate-commands %sh{
    process="$1"
    eval "set $kak_opt_pmanage_process_list"
    printf "%s\n" "set-option global pmanage_process_list"
    options=
    while [ $# -ne 0 ]; do
        [ $process = $1 ] || options="'$1' $options"
        shift
    done
    printf "%s\n" "set-option global pmanage_process_list $options"
}}
