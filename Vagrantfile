##################################################
# Vagrant Configuration
##################################################

Vagrant.require_version ">= 1.8.4"

ENV['PYTHONIOENCODING'] = "utf-8"

Vagrant.configure("2") do |config|

    config.vm.provider :virtualbox do |v|
        v.name = "xenial-php7.vb"
        v.customize [
            "modifyvm", :id,
            "--name", "xenial-php7.vb",
            "--memory", 2048,
            "--natdnshostresolver1", "on",
            "--cpus", 1,
        ]
    end

    config.vm.hostname = "xenial-php7.vb"
    config.vm.box = "bento/ubuntu-16.04"

    config.vm.network :private_network, ip: "10.10.10.10"
    config.ssh.forward_agent = true
    config.ssh.pty = true
    config.ssh.insert_key = false

    #############################################################
    # Ansible initial provisioning
    #############################################################

    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/playbook.yml"
        ansible.inventory_path = "ansible/inventories/dev"
        ansible.limit = 'all'
        ansible.extra_vars = {
            private_interface: "10.10.10.10",
            hostname: "xenial-php7.vb"
        }
    end
end
