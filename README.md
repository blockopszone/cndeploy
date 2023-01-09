# CNDeploy

## What is cndeploy

cndeploy is a collection of Ansible roles that provide automated deployments of Cardano staking pools with related community scripts, following the best practices, with the ultimate goal to be integrated with other tools to achieve a secure and highly available setup.

## Disclaimer

This project is in alpha stage, code provided isn't thoroughly tested, and documentation is not complete, so at the moment it is meant to be used only in development and test environments.

## Requirements

A full working installation of Ansible is required in order to run a playbook with the roles provided in this package. At the time of writting the version core 2.12.9 is being used for the development process. Testing is needed for other versions. For more information about Ansible please see :  
- https://docs.ansible.com/

Additionally, a proper set of configuration files, usually grouped into an inventory, are needed to run the roles. Please note that usually the roles provide a safe set of defaults for most parameters, but providing some of the information is always necessary, for example ip addresses and ports of the nodes or some of the stake pool private files (cold.skey, cold.vkey, cold.counter are never copied by the roles because are not needed for day to day bp/relay operations and are better kept safe and away of online servers).

Please note that the registration of the stake pool and its related maintenance like pool's KES keys rotation, must be performed externally to this setup. For more information about this operations please see:  
- https://docs.cardano.org/development-guidelines/operating-a-stake-pool/creating-a-stake-pool/

or, if the use of a script is preferred, cntools from Guild Operators could be used, for more information:  
- https://github.com/cardano-community/guild-operators/blob/alpha/docs/Scripts/cntools.md
- https://cardano-community.github.io/guild-operators/

Be aware that cntools and the other scripts from Guild Operators are installed in the nodes by the roles, but certain operations require the cold.* files and those won't be available in the block producer or relays as mentioned earlier.

Finally, some of the roles expect to have a Cardano node installed on the Ansible master host, in order to copy the stake pool files from it, or even the binaries and/or the blocks database. In the case that this master host is properly protected, it could also be used to hold the cold.* files and perform the rotations.  
  
## Configuration examples 

See below the inventary files comprising a configuration example. As per Ansible's standard functioning, the defined variables have the following precedence (from less to more):  

- hosts inventary file
- <
- all in group_vars
- <
- any in group_vars
- <
- any in host_vars.  

Of course variables can be specified in any of the available locations, but some only make sense for a certain group. Additionally, please note that in the example, Ansible vault is used to protect an api key secret, please refer to Ansible documentation for further explanation on how it works.

- **my_sp_inventory/hosts**
```yaml
bp:
  hosts:
    my_bp_1:
      ansible_host: '1.2.3.4'
      ansible_user: 'ubuntu'
      cndeploy_node_ip: '1.2.3.4'
      cndeploy_node_hostname: 'my_bp_1'
      cndeploy_node_port: '6001'
      cndeploy_node_prio: 1
      cndeploy_node_cores: 4
relay:
  hosts:
    my_relay_1:
      ansible_host: '1.2.3.5'
      ansible_user: 'ubuntu'
      cndeploy_node_ip: '1.2.3.5'
      cndeploy_node_hostname: 'my_relay_1'
      cndeploy_node_port: '3001'
      cndeploy_node_prio: 50
      cndeploy_node_cores: 4
    my_relay_2:
      ansible_host: '1.2.3.6'
      ansible_user: 'ubuntu'
      cndeploy_node_ip: '1.2.3.6'
      cndeploy_node_hostname: 'my_relay_2'
      cndeploy_node_port: '3001'
      cndeploy_node_prio: 50
      cndeploy_node_cores: 4
standby:
  hosts:
    my_standby:
      ansible_host: '1.2.3.7'
      ansible_user: 'ubuntu'
      cndeploy_node_ip: '1.2.3.7'
      cndeploy_node_hostname: 'my_standby'
      cndeploy_node_port: '3001'
      cndeploy_node_prio: 99
      cndeploy_node_cores: 4
my_sp_prod:
  hosts:
    my_bp_1:
    my_relay_1:
    my_relay_2:
    my_standby:
```

- **my_sp_inventory/group_vars/all/vars.yml**  
The variables in the "all" group will be available to every host.
```yaml
cndeploy_node_type: 'default'
cndeploy_node_ticker: 'TICKER'
cndeploy_pkgs_update: true
cndeploy_pkgs_upgrade: true
cndeploy_pkgs_add: true
cndeploy_pkgs_add_list:
  - htop
  - net-tools
cndeploy_node_hostname_change: true
cndeploy_hosts_change: true
cndeploy_hosts: |
  1.2.3.4 mysp.mydomain mysp
  1.2.3.5 myrelay1.mysp.mydomain myrelay1.mysp
  1.2.3.6 myrelay2.mysp.mydomain myrelay2.mysp
cndeploy_add_aliases: true
cndeploy_aliases: |
  alias g='{{ cndeploy_cnode_dir }}/scripts/gLiveView.sh'
  alias nstart='sudo systemctl start cnode.service'
  alias nstop='sudo systemctl stop cnode.service'
  alias nstatus='sudo systemctl status cnode.service'
  alias nlog='sudo journalctl -f -u cnode.service'
  alias nl='sudo journalctl -f -e'
  alias h='htop'
  alias c='clear'
cndeploy_swap_configure: true
cndeploy_swap_enable: true
cndeploy_swap_file_path: '/swapfile'
cndeploy_swap_file_size_mb: 16384
cndeploy_swappiness: 60
cndeploy_disable_ipv6: true
cndeploy_firewall_enabled: true
cndeploy_whitelist_ip:
  - 2.3.4.5
cndeploy_blacklist_ip:
  - 3.4.5.6
cndeploy_allowhostname_enabled: true
cndeploy_allowhostname: my.dynhost.dom
cndeploy_ssh_restrict: true
cndeploy_ssh_pubkeys:
  - ssh-rsa AZAAX3NzaC1yc2EAFAADAQARAAABgQCiRqqAm8U9wyBfNe7rd4TJHBD7dMAdEh3IYjA69kz0gLQHG6QhPOytOWKbn2sc7lwfZBeCcnCaShRKsaW1oHP3oiKJG0E126vTRpZd4hC+TfgjphRFJ/3/k6NiJrrNc5Biv0w0dRxNfdCiAYgUsHQj6wt8HCeZmtn7Tu0mCynnbs8mq4hYa7u4MDAy9Q1i/N/HtwSGBiieSpV0Lw7a9AWu0hVlr/yrN/aqEQHXKNIy76Tl9OQPBiH8DT2aVu9y+0qEun7tNmfBIhGXCOSy7izCkKPZas8LBht15d3Bj6tViNkzf3ShOkPYTVG4X3pUI32mdU5Q24RxvR0xSfbad9Dv5hH1XQXQAtOFVwo+TgOSr8UNCZlKEusSv3ogP9TlPk7L1pg58+LLmLCii3FUmv0lHBaI+kKkTaPllDpXxu6R8A+AS6u5MWnMQ2eA+cfJnusovlPAXqtO6XbFy4T/KJK//AtWabZ9R2xHURyrps4yKA+rMqiIuhpO339scKPjBmc= me@master
cndeploy_cnode_dir_local: '/opt/cardano/cnode'
cndeploy_cnode_dir_local_check_override: false
cndeploy_cnode_bin_archive_url: 'https://update-cardano-mainnet.iohk.io/cardano-node-releases/cardano-node-1.35.4-linux.tar.gz'
cndeploy_cnode_dir: '/opt/cardano/cnode'
```

- **my_sp_inventory/group_vars/bp/vars.yml**  
The variables in the "bp" group will be available only to block producers.
```yaml
cndeploy_node_type: bp
cndeploy_cnode_cncli_install: true
cndeploy_cncli_bin_archive_url: 'https://github.com/cardano-community/cncli/releases/download/v5.2.0/cncli-5.2.0-x86_64-unknown-linux-gnu.tar.gz'
cndeploy_cnode_cncli_ptapikey: '{{ vault_cndeploy_cnode_cncli_ptapikey }}'
cndeploy_cnode_cncli_sync_enabled: true
cndeploy_cnode_cncli_leaderlog_enabled: true
cndeploy_cnode_cncli_validate_enabled: true
cndeploy_cnode_cncli_ptsendtip_enabled: true
cndeploy_cnode_cncli_ptsendslots_enabled: false
cndeploy_cnode_logmonitor_enabled: true
cndeploy_cnode_submitapi_enabled: true
cndeploy_cnode_blockperf_enabled: false
cndeploy_bp_topology_producers_auto: true
```

- **my_sp_inventory/group_vars/relay/vars.yml**  
The variables in the "relay" group will be available to every relay node.
```yaml
cndeploy_node_type: relay
cndeploy_cnode_cncli_install: false
cndeploy_cnode_cncli_sync_enabled: false
cndeploy_cnode_cncli_leaderlog_enabled: false
cndeploy_cnode_cncli_validate_enabled: false
cndeploy_cnode_cncli_ptsendtip_enabled: false
cndeploy_cnode_cncli_ptsendslots_enabled: false
cndeploy_cnode_logmonitor_enabled: false
cndeploy_cnode_submitapi_enabled: false
cndeploy_cnode_blockperf_enabled: false
cndeploy_relay_custom_peers_auto: true
cndeploy_relay_custom_peers_auto_iptables: true
```

- **my_sp_inventory/group_vars/standby/vars.yml**  
The variables in the "standby" group will be available to every standby host (a host that runs the Cardano node without any configuration in order to be in sync and to be available when needed to be used as failover/test/build/etc).
```yaml
cndeploy_node_type: standby
cndeploy_cnode_cncli_install: false
cndeploy_cnode_cncli_sync_enabled: false
cndeploy_cnode_cncli_leaderlog_enabled: false
cndeploy_cnode_cncli_validate_enabled: false
cndeploy_cnode_cncli_ptsendtip_enabled: false
cndeploy_cnode_cncli_ptsendslots_enabled: false
cndeploy_cnode_logmonitor_enabled: false
cndeploy_cnode_submitapi_enabled: false
cndeploy_cnode_blockperf_enabled: false
```

- **my_sp_inventory/host_vars/my_relay_1/vars.yml**  
As host_vars have higher precedence than group_vars we can setup an exception for one host , in this case packages won't get automatically upgraded for my_relay_1.
```yaml
cndeploy_pkgs_update: false
cndeploy_pkgs_upgrade: false
```

## Deploying the nodes example

In the main directory of the cndeploy project there are many playbook examples available to use, from the ones executing only one role, to another that sets up an entire stake pool. Edit the desired one to customise it accordingly, and proceed to execute it as below (please note that we keep using Ansible's vault in the example, so we provide a key file):
```
ansible-playbook --vault-password-file=my_sp_inventory/.vault_pass cndeploy/setup_stake_pool.yml -i my_sp_inventory/hosts -l my_sp_prod
```

## Configuration variables reference

### Host setup 

<table>
  <tr>
    <th align="left">Variable</th>
    <th align="left">Type</th>
    <th align="left">Default</th>
    <th align="left">Required</th>
    <th align="left">Roles</th>
    <th align="left">Description</th>
  </tr>
  <tr>
    <td>cndeploy_node_hostname_change</td>
    <td>Bool</td>
    <td>False</td>
    <td>No</td>
    <td>cndeploy_os_tweaks</td>
    <td>Set to true to change hostname</td>
  </tr>
  <tr>
    <td>cndeploy_node_hostname</td>
    <td>String</td>
    <td>None</td>
    <td>No</td>
    <td>cndeploy_os_tweaks</td>
    <td>Set to the desired hostname</td>
  </tr>
  <tr>
    <td>cndeploy_hosts_change</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_hosts</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_pkgs_update</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_pkgs_upgrade</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_pkgs_add</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_pkgs_add_list</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_add_aliases</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_aliases</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_swap_configure</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_swap_enable</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_swap_file_path</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_swap_file_size_mb</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_swappiness</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_disable_ipv6</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>  
</table>

### Access and Firewall

<table>
  <tr>
    <th align="left">Variable</th>
    <th align="left">Type</th>
    <th align="left">Default</th>
    <th align="left">Required</th>
    <th align="left">Roles</th>
    <th align="left">Description</th>
  </tr>
  <tr>
    <td>cndeploy_firewall_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_whitelist_ip</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_blacklist_ip</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_allowhostname_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_allowhostname</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_ssh_restrict</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_ssh_pubkeys</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>  
</table>

### Cardano node 

<table>
  <tr>
    <th align="left">Variable</th>
    <th align="left">Type</th>
    <th align="left">Default</th>
    <th align="left">Required</th>
    <th align="left">Roles</th>
    <th align="left">Description</th>
  </tr>
  <tr>
    <td>cndeploy_node_type</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_dir</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_dir_local</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_dir_local_check_override</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_bin_archive_url</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_logmonitor_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_submitapi_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_blockperf_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_bp_topology_producers_auto</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_relay_custom_peers_auto</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_relay_custom_peers_auto_iptables</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>  
</table>

### Cncli 

<table>
  <tr>
    <th align="left">Variable</th>
    <th align="left">Type</th>
    <th align="left">Default</th>
    <th align="left">Required</th>
    <th align="left">Roles</th>
    <th align="left">Description</th>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_install</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cncli_bin_archive_url</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_ptapikey</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_sync_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_leaderlog_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_validate_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_ptsendtip_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>cndeploy_cnode_cncli_ptsendslots_enabled</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>

## TODO

- Finish documentation
- Further testing  
- Mythril integration
- Publish on Galaxy

## Contribute

This software is developed on my free time and is provided under a GPLv3 license. I use it to manage my stake pool BZONE, feel free to use it and to contribute in any way. If you find it useful please consider to support the development by staking with me or by donating some ADA.  

- https://www.blockops.zone/contribute/  
