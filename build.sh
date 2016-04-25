#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Usage: <box> <version> <token>"
    exit 1
fi

case $1 in

    xenial-php7)
         grep -q $1 Vagrantfile
         if [ $? -eq 1 ]; then
           echo "Looks like you are in the wrong branch. Your Vagrantfile does not contain $1"
           exit
         fi
        ;;

    trusty-php7)
         grep -q $1 Vagrantfile
         if [ $? -eq 1 ]; then
           echo "Looks like you are in the wrong branch. Your Vagrantfile does not contain $1"
           exit
         fi
        ;;

    *)
        echo $"Usage: $0 {xenial-php7|trusty-php7}"
        exit 1
esac

exit 1

# cleanup previous builds
vagrant destroy -f
rm package.box

# build the box
vagrant box update
vagrant up
vagrant ssh -c 'sudo pecl uninstall xdebug' # hack needed due to issues with the xdebug install
vagrant up --provision
vagrant package --base "$1".vb

curl https://atlas.hashicorp.com/api/v1/box/peterrehm/"$1"/versions \
        -X POST \
        -d version[version]="$2" \
        -d access_token="$3"

# add a new provider
curl https://atlas.hashicorp.com/api/v1/box/peterrehm/"$1"/version/"$2"/providers \
-X POST \
-d provider[name]='virtualbox' \
-d access_token="$3"

# 2-step upload process
curl -X PUT --upload-file package.box $(curl -sS https://atlas.hashicorp.com/api/v1/box/peterrehm/"$1"/version/"$2"/provider/virtualbox/upload?access_token="$3" | grep -Po '(?<="upload_path":")[^"]*')

# release the version
curl https://atlas.hashicorp.com/api/v1/box/peterrehm/"$1"/version/"$2"/release \
        -X PUT \
        -d access_token="$3"
