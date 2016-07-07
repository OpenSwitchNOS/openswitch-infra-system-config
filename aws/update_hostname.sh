#!/usr/bin/bash
# change hostname
# Takes one paramter . newhostname 
# usage : update_hostname <newhostname>
echo "Current hostname is `hostname`"
echo "Updating hostname to $1"
old_hostname=`hostname`
new_hostname=$1
echo "Hostname has been updated to `hostname`"
echo "Updating /etc/hostname file configuration"
echo $new_hostname > /etc/hostname 

echo "udpated /etc/hostname file is "
cat /etc/hostname


echo "Proceeding to update /etc/hosts file with the new hostname entry"
nfqdn=`echo $new_hostname | cut -d'.' -f1`
elastic_ip=`nslookup $old_hostname | cut -d' ' -f2 | grep ^[0-9]`
hosts_entry="$elastic_ip $new_hostname $nfqdn"

echo $hosts_entry >> /etc/hosts

echo "updated /etc/hosts file is "
cat /etc/hosts
hostname "$new_hostname"

#update and install
#apt-get update
#apt-get upgrade -y
#apt-get install -y python-pip
#apt-get install puppet

#edit config file
sed -i "8iserver=puppetmaster.openswitch.net" /etc/puppet/puppet.conf
sed -i "9icertname=$new_hostname" /etc/puppet/puppet.conf
puppet agent -t


