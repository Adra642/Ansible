# Ansible — Single Machine Configuration

Automates the full setup of a Fedora workstation: system packages, repositories,
dotfiles, GNOME desktop, themes, Docker, and Git/SSH keys.

---

## Project Structure

```
ansible.cfg               # Ansible settings (inventory, vault, privilege escalation)
site.yml                  # Master playbook — runs the full non-interactive setup
.vault_pass               # Vault decryption key (gitignored, never committed)
group_vars/
  all/
    vars.yml              # User variables (email, name)
    vault.yml             # Encrypted vault (sudo password)
playbooks/
  system_base.yml         # RPM Fusion repos, dnf tuning, base packages, full upgrade
  packages.yml            # DNF packages, Flatpak apps, package groups, bloat removal
  extra_repos.yml         # Visual Studio Code (Microsoft repo) + COPR tools (eza, wezterm, zellij)
  dotfiles.yml            # Clone .dotfiles repo, create symlinks, download zellij plugins
  gnome.yml               # GNOME settings, keybindings, and shell extensions
  theme.yml               # IosevkaTerm font, Vimix cursors, Orchis theme, Papirus icons
  docker.yml              # Docker CE install, user group, service start, image pull
  git.yml                 # Global Git config and ed25519 SSH key generation
  tasks/
    font_install.yml      # Included by theme.yml — downloads and installs font
    cursor_install.yml    # Included by theme.yml — clones and installs cursor theme
    theme_install.yml     # Included by theme.yml — clones and installs GTK theme
    icons_install.yml     # Included by theme.yml — installs Papirus folder colours
```

---

## User Variables (Required Before First Run)

Edit `group_vars/all/vars.yml` with your details:

```yaml
---
git_email: "your@email.com"
git_name: "Your Name"
docker_user: "user"
```

This file is committed to git. Do not put sensitive data in it — use the vault for secrets.

---

## Vault Setup (Required Before First Run)

Playbooks that use `become: true` rely on an **Ansible Vault** to supply the sudo
password. The vault file is committed in encrypted form; the key lives only on your machine.

### 1. Create the vault password file

```bash
echo "your_vault_encryption_password" > .vault_pass
chmod 600 .vault_pass
```

> `.vault_pass` is listed in `.gitignore` and will never be committed.

### 2. Edit the unencrypted vault file

```bash
ansible-vault decrypt group_vars/all/vault.yml
```

Set your actual sudo password:

```yaml
---
ansible_become_password: "your_sudo_password"
```

### 3. Re-encrypt the vault file

```bash
ansible-vault encrypt group_vars/all/vault.yml
```

The file will be replaced with an encrypted version (starts with `$ANSIBLE_VAULT;…`).
This encrypted file is safe to commit.

### Editing the vault later

```bash
ansible-vault view group_vars/all/vault.yml   # view
ansible-vault edit group_vars/all/vault.yml   # edit in $EDITOR
ansible-vault rekey group_vars/all/vault.yml  # change encryption password
```

---

## Running the Playbooks

`ansible.cfg` sets the inventory (`localhost`), the vault password file (`.vault_pass`),
and privilege escalation, so no extra flags are needed.

### Full setup (non-interactive)

```bash
ansible-playbook site.yml
```

### Individual playbooks

```bash
ansible-playbook playbooks/system_base.yml
ansible-playbook playbooks/packages.yml
ansible-playbook playbooks/extra_repos.yml
ansible-playbook playbooks/git.yml
ansible-playbook playbooks/dotfiles.yml
ansible-playbook playbooks/docker.yml
ansible-playbook playbooks/gnome.yml
ansible-playbook playbooks/theme.yml
```


---

## Security Notes

| File | Committed to git | Contains |
|---|---|---|
| `group_vars/all/vault.yml` | Yes (encrypted) | Sudo password (ciphertext) |
| `.vault_pass` | **No** (gitignored) | Vault encryption key |

Keep `.vault_pass` backed up securely (password manager, encrypted drive, etc.) —
losing it means you cannot decrypt the vault.
