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

# Set commands to ignore (do not notify) if needed
(( ${+zlong_ignore_cmds} )) || zlong_ignore_cmds='bat emacs htop info less mail man meld most mutt nano nvim screen ssh tail tmux top vi vim watch'

# Set prefixes to ignore (consider command in argument) if needed
(( ${+zlong_ignore_pfxs} )) || zlong_ignore_pfxs='sudo time'

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
    if [[ "$zlong_send_notifications" == false ]]; then
        return;
    fi

    local duration=$(($EPOCHSECONDS - ${zlong_timestamp-$EPOCHSECONDS}))
    local lasted_long=$(($duration - $zlong_duration))
    local cmd_head

    # Ignore leading spaces (-L) and command prefixes (like time and sudo)
    typeset -L last_cmd_no_pfx="$zlong_last_cmd"
    local no_pfx
    while [[ -n "$last_cmd_no_pfx" && -z "$no_pfx" ]]; do
        cmd_head="${last_cmd_no_pfx%% *}"
        if [[ "$zlong_ignore_pfxs" =~ "(^|[[:space:]])${(q)cmd_head}([[:space:]]|$)" ]]; then
            last_cmd_no_pfx="${last_cmd_no_pfx#* }"
        else
            no_pfx=true
        fi
    done

    # Notify only if delay > $zlong_duration and command not ignored
    if [[ $lasted_long -gt 0 && ! -z $last_cmd_no_pfx && ! "$zlong_ignore_cmds" =~ "(^|[[:space:]])${(q)cmd_head}([[:space:]]|$)" ]]; then
        [[ $(declare -f zlong_alert_func) ]] &&
            zlong_alert_func         "$zlong_last_cmd" "$duration" "$exit_status" ||
            zlong_alert_func_default "$zlong_last_cmd" "$duration" "$exit_status"

        # Sound bell if configured
        if [[ "$zlong_terminal_bell" == 'true' ]]; then
            echo -n "\a"
        fi
    fi

    zlong_last_cmd=''
}

add-zsh-hook preexec zlong_alert_pre
add-zsh-hook precmd zlong_alert_post
