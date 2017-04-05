dd bs=1 count=13 if=/dev/c0d0 of=/tmp/bootusername skip=1024
var=$( cat /tmp/bootusername )
useradd -m $var
usermod -g users $var
su - $var
