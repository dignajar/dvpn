#!/bin/bash

NAME="dvpn"
VERSION="1.2"
PATH_NETWORK="/opt/network_connect"
OWNER=$(whoami)
NCLINUX="https://github.com/dignajar/dvpn/raw/master/ncLinuxApp.jar"
MD5SUM="d334c1e062a2af291faef2676a1554f7"
TMPFILE="/tmp/ncLinuxApp.jar"

VPN_URL="$1"
REALM="$2"

# Check arguments {vpn url} {vpn realm}
if [[ -z "$1" || -z "$2" ]]
then
	echo "dVPN v$VERSION

Usage: ./install_dvpn.sh {url} {realm}
Example: ./install_dvpn.sh vpn.domain.com Users"

	exit 0
fi

# Download NcLinux
type wget > /dev/null
if [ $? -eq 0 ]
then
	wget "$NCLINUX" -O "$TMPFILE"
else
	curl "$NCLINUX" -o "$TMPFILE"
fi

# Checksum MD5
MD5TMP=$(md5sum "$TMPFILE" | awk '{print $1}')
if [ "$MD5TMP" != "$MD5SUM" ]
then
	echo "MD5 Failed."
	exit 1
fi

# Installation
sudo mkdir -p "$PATH_NETWORK"
sudo chown -R $OWNER:$OWNER "$PATH_NETWORK"
unzip -o "$TMPFILE" -d "$PATH_NETWORK/"
sudo chown root:root "$PATH_NETWORK/ncsvc"
sudo chmod 6711 "$PATH_NETWORK/ncsvc"
chmod 744 "$PATH_NETWORK/ncdiag"
chmod 755 "$PATH_NETWORK/getx509certificate.sh"

# Certificate
bash "$PATH_NETWORK/getx509certificate.sh" "$VPN_URL" "$PATH_NETWORK/certificate.ssl"

# Permissions
sudo touch /bin/"$NAME"
sudo chown $OWNER:$OWNER /bin/"$NAME"
chmod 755 /bin/"$NAME"

# Connection script
echo '#!/bin/bash

VERSION="'"$VERSION"'"
PATH_NETWORK="'"$PATH_NETWORK"'"
VPN_URL="'"$VPN_URL"'"
REALM="'"$REALM"'"
CERT_FILE=/opt/network_connect/certificate.ssl
KERNEL=$(uname -ar)

# Check kernel version
uname -r | grep -e "3.19.2\|3.19.1\|3.19.0\|3.13.0-59"
if [ $? -eq 0 ]
then
  echo "This version of Linux Kernel is not compatible with Juniper Network client."
  echo "To fix it, upgrade/downgrade your Linux Kernel."
  exit 1
fi

# --help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]
then
	echo "Version: $VERSION"
	echo "Kernel: $KERNEL"
	exit 0
fi

# --certificate argument, this regenerate the certificate
if [[ "$1" == "--certificate" || "$1" == "-c" ]]
then
	bash "$PATH_NETWORK/getx509certificate.sh" "$VPN_URL" "$PATH_NETWORK/certificate.ssl"
	exit 0
fi

# --disconnect argument
if [[ "$1" == "--disconnect" || "$1" == "-d" ]]
then
	echo "Disconnecting..."
	/opt/network_connect/ncsvc -K
	exit 0
fi

echo "dVPN v$VERSION"
read -p "Username: " USERNAME; echo
stty -echo
read -p "Passcode: " PIN; echo
stty echo

/opt/network_connect/ncsvc -K

/opt/network_connect/ncsvc -h $VPN_URL -u $USERNAME -p $PIN -r $REALM -f $CERT_FILE -L 3&

pid=$!
notConnected=true
while [ -e /proc/$pid -a $notConnected = true ]; do
  ip link show | grep tun0 > /dev/null
  if [ $? -eq 0 ]
  then
    echo "Connection successful."
    pgrep ncsvc
    notConnected=false
  fi
  sleep 1
done

if [ $notConnected = true ]
then
  echo "Connection failed."
	echo "- Try to login in WebVPN portal. Example: browse https://$VPN_URL/$REALM"
	echo "- Check your credentials."
	echo "- Check your internet connection and DNS."
	echo "- Try to regenerate your certificate. Command: dvpn --certificate"
  echo ""
  echo "Note: Juniper Network Connect needs 32bits Libraries."
fi
' > /bin/"$NAME"
