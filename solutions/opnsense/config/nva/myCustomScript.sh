# Two-Nics scenarios only

# $1 = OPNScriptURI
# $2 = Primary/Secondary/SingNic/TwoNics
# $3 = Trusted Nic subnet prefix - used to get the gw
# $4 = Windows-VM-Subnet subnet prefix - used to route/nat allow internet access from Windows Management VM
# $5 = ELB VIP Address
# $6 = Private IP Secondary Server

# Prepare config.xml (OPNsense)
fetch $1config-twonics.xml
fetch $1get_nic_gw.py
gwip=$(python get_nic_gw.py $3)
sed -i "" "s/yyy.yyy.yyy.yyy/$gwip/" config-twonics.xml
sed -i "" "s_zzz.zzz.zzz.zzz_$4_" config-twonics.xml
cp config-twonics.xml /usr/local/etc/config.xml

# Install CA root certificate and bash
env IGNORE_OSVERSION=yes
pkg bootstrap -f; pkg update -f
env ASSUME_ALWAYS_YES=YES pkg install ca_root_nss && pkg install -y bash

# Install OPNsense (bootstrap)
fetch $1opnsense-bootstrap.sh.in
sed -i "" 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i "" "s/reboot/shutdown -r +1/g" opnsense-bootstrap.sh.in
sh ./opnsense-bootstrap.sh.in -y -r "22.7"

# Install Azure waagent
fetch https://github.com/Azure/WALinuxAgent/archive/refs/tags/v2.8.0.11.tar.gz
tar -xvzf v2.8.0.11.tar.gz
cd WALinuxAgent-2.8.0.11/
python3 setup.py install --register-service --lnx-distro=freebsd --force
cd ..
ln -s /usr/local/bin/python3.9 /usr/local/bin/python
sed -i "" 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/' /etc/waagent.conf
fetch $1actions_waagent.conf
cp actions_waagent.conf /usr/local/opnsense/service/conf/actions.d

# Remove wrong route at initialization
cat > /usr/local/etc/rc.syshook.d/start/22-remoteroute <<EOL
#!/bin/sh
route delete 168.63.129.16
EOL
chmod +x /usr/local/etc/rc.syshook.d/start/22-remoteroute

#Adds support to LB probe from IP 168.63.129.16
# Add Azure VIP on Arp table
echo # Add Azure Internal VIP >> /etc/rc.conf
echo static_arp_pairs=\"azvip\" >>  /etc/rc.conf
echo static_arp_azvip=\"168.63.129.16 12:34:56:78:9a:bc\" >> /etc/rc.conf
# Makes arp effective
service static_arp start
# To survive boots adding to OPNsense Autorun/Bootup:
echo service static_arp start >> /usr/local/etc/rc.syshook.d/start/20-freebsd