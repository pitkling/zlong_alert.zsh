# zlong_alert.zsh

`zlong_alert.zsh` will send a notification and optionally sound a
[bell](https://en.wikipedia.org/wiki/Bell_character) to alert you when a
command that has taken a long time (default: 15 seconds) has completed.

By default, notifications are sent using [Apprise](https://github.com/caronc/apprise).
To use other notification mechanisms or change the message format, define the
shell function `zlong_alert_func` (see [Configuration](#Configuration)).

---

## Installation

### Pre-requisite

Ensure that you have installed [Apprise](https://github.com/caronc/apprise) or
configure `zlong_alert_func` to use a different notification mechanism.

### zplug

```bash
zplug "kevinywlui/zlong_alert.zsh"
```

### Oh My Zsh

1. Download the plugin

    a. Clone into `$ZSH_CUSTOM/plugins/zlong_alert`.

    or

    b. if on archlinux you can use this [aur](https://aur.archlinux.org/packages/zlong-alert-git) package

2. Add `zlong_alert` to `plugins` in `.zshrc`.

### Zim

Add in your `~/.zimrc`:
```bash
zmodule "kevinywlui/zlong_alert.zsh" --name zlong_alert
```

### Manual 

This script just needs to be sourced so add this to your `.zshrc`:
```bash
source /path/to/zlong_alert.zsh
```

---

## Configuration

There are 7 variables you can set that will alter the behavior this script.

- `zlong_duration` (default: `15`): number of seconds that is considered a long duration.
- `zlong_ignore_cmdpfxs` (default: see source): command prefixes that prevent alerts.
- `zlong_strip_pfxs` (default: `"sudo time"`): prefixes to strip from commands (not considered part of actual command).
- `zlong_send_notifications` (default: `true`): whether to send notifications.
- `zlong_terminal_bell` (default: `true`): whether to enable the terminal bell.
- `zlong_ignorespace` (default: `false`): whether to ignore commands with a leading space
- `zlong_alert_func` (default: see source): shell function that sends notifications.

For example, adding the following anywhere in your `.zshrc`
```bash
zlong_send_notifications=false
zlong_duration=2
zlong_ignore_cmdpfxs=(vim ssh pacman yay)
```
will alert you, without sending a notification, if a command has lasted for more
than 2 seconds, provided that the command does not start with any of `vim ssh
pacman yay`.

### zlong_alert_func

`zlong_alert_func` takes three string arguments: the command that caused the
notification (argument `$1`), the duration of the command in seconds (argument
`$2`), and the exit status of the command (argument `$3`). The default function
`zlong_alert_func_default` uses [Apprise](https://github.com/caronc/apprise)
to send notifications (via the `zlong_alert` Apprise tag).

## Changelog

See [CHANGELOG](./CHANGELOG.md)

## Credit

This script is the result of me trying to understand and emulate this gist:
<https://gist.github.com/jpouellet/5278239> My version fixes some things
(possibly bugs?) that I did not like about the original version.
