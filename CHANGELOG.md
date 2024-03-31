# Changelog

## [0.2.2] - 2024-03-30
### Changed
- Removed check for deprecated `zlong_use_notify_send` variable
- Removed `zlong_message` and instead make `zlong_alert_func` customizable
- Default `zlong_alert_func` uses [`apprise`](https://github.com/caronc/apprise)
  instead of `notify-send` and `alerter`
- Added support for exit status to `zlong_alert_func`
- Added `nvim` and `vi` to default `zlong_ignore_cmds`

## [0.2.1] - 2019-09-26
### Changed
- CHANGELOG renamed to CHANGELOG.md

## [0.2.0] - 2019-09-26
### Added
- A pointer to this file from the README

### Changed
- No longer warn you when `notify-send` is not available.
- Will only use `notify-send` if it exists and has not been explicitly disabled: https://github.com/kevinywlui/zlong_alert.zsh/issues/1#issuecomment-535543780

## [0.1.0] - 2019-09-25
### Added
- Added a VERSION and CHANGELOG file
