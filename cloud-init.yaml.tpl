#cloud-config

repo_update: true
repo_upgrade: all
disable_root: 0

# https://tailscale.com/kb/1293/cloud-init
runcmd:
  - ['echo Hi > test.md']
  - ['sh', '-c', 'curl -fsSL https://tailscale.com/install.sh | sh']
  - ['sh', '-c', "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && sudo sysctl -p /etc/sysctl.d/99-tailscale.conf" ]
  # Generate an auth key from your Admin console
  # https://login.tailscale.com/admin/settings/keys
  - ['tailscale', 'up', '--authkey=${tailscale_authkey}']
  - ['tailscale', 'set', '--ssh']
  - ['tailscale', 'set', '--advertise-exit-node']
