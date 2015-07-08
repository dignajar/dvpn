# dVPN

Juniper Network Connect client for GNU/Linux.

### Installation

1. Download ```install_dvpn.sh``` (```wget https://raw.githubusercontent.com/dignajar/dvpn/master/install_dvpn.sh```)
2. Set execute permissions. ```chmod 755 install_dvpn.sh```
3. Install ```./install_dvpn.sh {url} {realm}```

Note:
- The installer needs unzip and wget commands.
- Juniper Network Connect software is 32bit, you must have 32bit C runtime support libraries installed on your system.

### Installation on Ubuntu 14.04 LTS / 15.04

1. ```$ sudo apt-get install -y wget unzip lib32z1 lib32ncurses5 lib32bz2-1.0```
2. ```$ cd /tmp/```
3. ```$ wget https://raw.githubusercontent.com/dignajar/dvpn/master/install_dvpn.sh```
4. ```$ chmod 755 install_dvpn.sh```
5. ```$ ./install_dvpn.sh {url} {realm}```

*Note: Ubuntu 15.04 by default comes with Kernel 3.19.0, this version of kernel doesn't work with Juniper Network Connect, you need to upgrade the kernel to v4.x (http://ubuntuhandbook.org/index.php/2015/04/upgrade-to-linux-kernel-4-0-in-ubuntu/).*

### Usage

Connect
`dvpn`

Disconnect
`dvpn --disconnect`

Information about dVPN
`dvpn --help`

Regenerate certificate
`dvpn --certificate`
