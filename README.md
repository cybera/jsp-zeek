# JSP Zeek
This project was created for the JSP project to run Zeek in a Docker container

## Tested on
* Dell R440
* Ubuntu 18.04 Host

## Pre-prerequisites

Install Ubuntu 18.04 with LVM volumes

### Interfaces
- eno2 for OS management (SSH, etc.)
- the other NICs (eno1 and fibre ports) will be setup in a bridge for Zeek to consume

If this needs to be changed, the `host/60-zeek-bridge.yaml` and `host/ethtool.sh` files can be modified to suit your needs.

### Storage (optional, but highly recommended)
The remaining SSD storage can be used for Docker containers, images, and volumes. Keeping Docker storage on their own partition
means Docker can't starve the host operating system's root partition of storage.

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
* Enable firewall to only permit 22/tcp inbound (SSH)
* Disable NIC offloading features
* install Docker
* build Zeek Docker container
* run Zeek Docker container


# Zeek (Docker)
## Limitations
* `AF_PACKET` is the only packet capturing method supported at this time. It makes installation simpler since it's built into the kernel, meaning there's no need to maintain a kernel module such as `PF_RING`.

## Build
```bash
./docker_build.sh
```

## Run
```bash
./docker_run.sh
```

## Logging JSON
Add the following line to `docker/files/local.zeek.append` and rebuild container
```
redef LogAscii::use_json = T;
```

**Note**: Logging JSON breaks the ability to use the zeek command line tools such as `zeek-cut`. `jq` is the recommended
tool when JSON is enabled.

## Adding additional Root CA(s)
Zeek uses its own root CA store based on [Mozilla's](https://docs.zeek.org/en/stable/scripts/base/protocols/ssl/mozilla-ca-list.zeek.html).
This list can be appended to with your own root CAs. You might want to do this if you have your own internal CA, and want Zeek to properly validate certificates signed by it.

First, get the subject of the cert then convert to hex format:
```bash
# Get subject
$ openssl x509 -in new-ca.crt -subject -noout

# Convert to hex
$ openssl x509 -in new-ca.crt -inform pem -outform der | hexdump -v -e '1/1 "\\\x"' -e '1/1 "%02X"'
```

Append the following to `docker/files/local.zeek.append` (replace `%SUBJECT%` and `%HEXCERT%`):

```
redef SSL::root_certs += {
        ["%SUBJECT%"] = "%HEXCERT%",
};
```

You can do this with as many certificates as you need:
```
redef SSL::root_certs += {
        ["%SUBJECT1%"] = "%HEXCERT1%",
        ["%SUBJECT2%"] = "%HEXCERT2%",
        ["%SUBJECT3%"] = "%HEXCERT3%",
};
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

# Syslog Shipper (Optional) (Docker)
We use rsyslog to ship our logs. We base the configuration on [this](https://blog.zeek.org/2015/09/analyzing-bro-logs-with-sagan.html) Zeek blog post.

The run script will automatically map the Zeek log directories (Docker volumes) to ship them to the syslog collector.

**Note** It's recommended to use the Zeek JSON log format with this feature

## Build
```bash
cd docker-syslog
./docker_build.sh
```

## Run
```bash
cd docker-syslog
./docker_run.sh <ip or hostname of syslog server>
```
