# ssh-agent: make pushes to github.com "just work" without a manual `ssh-add`.
#
# SSH_AUTH_SOCK is also exported in config.fish, but conf.d loads *before* config.fish,
# so we set it here too — it must be present before we touch the agent below.
# ~/.ssh/github has no passphrase, so the add is silent; the persistent systemd
# ssh-agent then keeps it for every later shell, so this effectively runs once per boot.
# No-ops safely on machines without the agent socket or the key. Managed by chezmoi.
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

if status is-interactive; and test -S "$SSH_AUTH_SOCK"; and test -r "$HOME/.ssh/github"
    if not ssh-add -l 2>/dev/null | string match -q "*.ssh/github *"
        ssh-add "$HOME/.ssh/github" 2>/dev/null
    end
end
