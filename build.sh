#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Usage: <box> <version> <token>"
    exit 1
fi

case $1 in

    bionic-php74)
         grep -q $1 Vagrantfile
         if [ $? -eq 1 ]; then
           echo "Looks like you are in the wrong branch. Your Vagrantfile does not contain $1"
           exit
         fi
        ;;

    *)
        echo $"Usage: $0 {bionic-php74}"
        exit 1
esac

# cleanup previous builds
vagrant destroy -f
rm package.box

# build the box
vagrant box update

vagrant up
if [ $? -ne 0 ]; then
    exit 1
fi

vagrant package --base bionic-php7.vb
if [ $? -ne 0 ]; then
    exit 1
fi

# create a new version
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $3" \
  https://app.vagrantup.com/api/v1/box/peterrehm/"$1"/versions \
  --data "{ \"version\": { \"version\": \"$2\" } }"

# add a new provider
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $3" \
  https://app.vagrantup.com/api/v1/box/peterrehm/"$1"/version/"$2"/providers \
  --data '{ "provider": { "name": "virtualbox" } }'

# 2-step upload process
curl --request PUT --upload-file package.box $(curl -sS --header "Authorization: Bearer $3" https://app.vagrantup.com/api/v1/box/peterrehm/"$1"/version/"$2"/provider/virtualbox/upload | grep -Po '(?<="upload_path":")[^"]*')

# release the version
curl \
  --header "Authorization: Bearer $3" \
  https://app.vagrantup.com/api/v1/box/peterrehm/"$1"/version/"$2"/release \
  --request PUT
