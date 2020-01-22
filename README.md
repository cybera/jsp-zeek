# JSP Zeek
This project was created for the JSP project to run Zeek in a Docker container

## Tested on
* Dell R440
* Ubuntu 18.04 Host

## Pre-prerequisites

Install Ubuntu 18.04 with LVM volumes

### Interfaces
- eno2 for OS management (SSH, etc.)
- the other NICs will be setup in a bridge for Zeek to consume

### Storage (optional)
The remaining SSD storage is used for Docker containers and images.
To create an LVM partition for docker :

```bash
lvcreate -l 100%FREE -n docker ubuntu-vg
mkfs.ext4 -L docker  /dev/ubuntu-vg/docker
echo 'LABEL=docker /var/lib/docker ext4 defaults 0 0' >> /etc/fstab
systemctl stop docker
mount /dev/ubuntu-vg/docker /mnt
rsync -av /var/lib/docker/ /mnt/
umount /mnt
rm -rf /var/lib/docker/*
mount -a
systemctl start docker
```

#### Zeek logs
The 4 1TB drives (in RAID10) are used for storing zeek logs.
This array is mounted under `/var/lib/docker/volumes`

```bash
mkfs.ext4 /dev/sdb1
echo '/dev/sdb1 /var/lib/docker/volumes ext4 defaults 0 0' >> /etc/fstab
mount -a
```

## Setup Host

Once the Ubuntu host has been setup, the following script can be used to deploy the remaining steps:

```bash
./setup.sh
```

This will:
* enable automatic security updates
* install Docker
* build Zeek Docker container
* run Zeek Docker container


# Docker
## Limitations
* `AF_PACKET` is the only packet capturing method supported at this time. It makes installation simpler since it's built into the kernel, meaning there's no need to maintain a kernel module such as `PF_RING`.

## Build
```bash
./docker_build.sh
```

## Run
Ensure the `INTERFACE` variable in `docker_run.sh` is changed to the interface being analyzed

```bash
./docker_run.sh
```

## Debug
If you need to get shell access within the Zeek container, use the following:
```bash
docker exec -it zeek /bin/bash
```

## Log Storage
Docker volumes are used to store all archived and spooled Zeek logs. They can be viewed under these directories on the host:
* `/var/lib/docker/volumes/zeek-logs`
* `/var/lib/docker/volumes/zeek-spool`
