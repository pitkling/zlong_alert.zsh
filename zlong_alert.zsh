# Use zsh/datetime for $EPOCHSECONDS
zmodload zsh/datetime || return

# Be sure we can actually set hooks
autoload -Uz add-zsh-hook || return

# Set as false to disable notifications
(( ${+zlong_send_notifications} )) || zlong_send_notifications='true'

# Set as true to enable terminal bell (beep)
(( ${+zlong_terminal_bell} )) || zlong_terminal_bell='true'

# Define a long duration if needed
(( ${+zlong_duration} )) || zlong_duration=15

# Set command prefixes that prevent alerts (e.g., because the indicate interactive commands like `vi`)
(( ${+zlong_ignore_cmdpfxs} )) ||
    zlong_ignore_cmdpfxs=(
        'bat'
        'emacs'
        'git diff'
        'git log'
        'htop'
        'info'
        'less'
        'mail'
        'man'
        'meld'
        'most'
        'mutt'
        'nano'
        'nvim'
        'screen'
        'ssh'
        'tail'
        'tmux'
        'top'
        'vi'
        'vim'
        'watch'
    )

# Set prefixes to strip from commands (not considered part of actual command)
(( ${+zlong_strip_pfxs} )) || zlong_strip_pfxs=(sudo time)

# Set as true to ignore commands starting with a space
(( ${+zlong_ignorespace} )) || zlong_ignorespace='false'

# Define the default alerting function
zlong_alert_func_default() {
    if [[ "$zlong_internal_alert_func_default_disabled" == true ]]; then
        return;
    fi

    local cmd="$1"
    local secs="$2"
    local exit_status="$3"

    if ! command -v apprise &> /dev/null; then
        >&2 echo "zlong_alert.zsh: Could not find 'apprise', disabling default 'zlong_alert_func'. Install 'apprise' () or set custom 'zlong_alert_func'."
        zlong_internal_alert_func_default_disabled='true'
    else
        local ftime="$(printf '%dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60)))"
        [[ $exit_status == "0" ]] && exit_status="✅ command succeeded" || exit_status="❌ command failed"
        apprise --tag zlong_alert -t "$exit_status in $ftime" -b "$cmd"
    fi
}

zlong_alert_pre() {
    zlong_last_cmd="$1"

    if [[ "$zlong_ignorespace" == 'true' && "${zlong_last_cmd:0:1}" == [[:space:]] ]]; then
        # set internal variables to nothing ignoring this command
        zlong_last_cmd=''
        zlong_timestamp=0
    else
        zlong_timestamp=$EPOCHSECONDS
    fi
}

zlong_alert_post() {
    local -i exit_status=$?

    # Do nothing if explicitly disabled
    [[ "$zlong_send_notifications" == false ]] && return

    # Reset global last command after storing in local variable for further use
    local last_cmd=$zlong_last_cmd
    zlong_last_cmd=''

    # Do not alert if duration does not exceed $zlong_duration
    local duration=$(($EPOCHSECONDS - ${zlong_timestamp-$EPOCHSECONDS}))
    [[ $duration -le $zlong_duration ]] && return

    # Strip leading spaces (-L) and prefixes from $zlong_strip_pfxs
    typeset -L last_cmd_no_pfx="$last_cmd"
    local cmd_head
    local no_pfx
    while [[ -n "$last_cmd_no_pfx" && -z "$no_pfx" ]]; do
        cmd_head="${last_cmd_no_pfx%% *}"
        if [[ "${zlong_strip_pfxs[@]}" =~ "(^|[[:space:]])${(q)cmd_head}([[:space:]]|$)" ]]; then
            last_cmd_no_pfx="${last_cmd_no_pfx#* }"
        else
            no_pfx=true
        fi
    done
    [[ -z $last_cmd_no_pfx ]] && return

    # Do not alert for commands starting with an ignored command prefix
    for cmdpfx in $zlong_ignore_cmdpfxs; do
        [[ $last_cmd_no_pfx = $cmdpfx* ]] && return
    done

    [[ $(declare -f zlong_alert_func) ]] &&
        zlong_alert_func         "$last_cmd" "$duration" "$exit_status" ||
        zlong_alert_func_default "$last_cmd" "$duration" "$exit_status"

    # Sound bell if configured
    if [[ "$zlong_terminal_bell" == 'true' ]]; then
        echo -n "\a"
    fi
}

add-zsh-hook preexec zlong_alert_pre
add-zsh-hook precmd zlong_alert_post
