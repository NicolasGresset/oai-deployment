# OAI-CN installation

This tutorial will lead you into OAI's 5G Core Network installation.
The reference tutorial can be found [here](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_HOME.md), it provides more information to help you customize the deployment to your needs.

The deployment should not take longer than 30 minutes.

## Assumptions

The reader is supposed to have basic knowledge in

- linux terminal
- docker / docker-compose
- linux firewall manipulation with iptables

### Hardware requirements

- 4 core CPU
- 16 GiB RAM
- At least 2 GiB storage for docker images

### Software requirements

| Software      | Version       | Official website |
|:---------------|:---------------| :-----------|
| docker engine | >= 19.03.9          |  <https://www.docker.com/>|
| docker-compose | >= 1.27.4          | <https://www.docker.com/>|
| Host OS | Ubuntu 20.04 LTS          | <https://releases.ubuntu.com/focal/>|
| Wireshark (for debugging purposes) | >= 3.4.4 | <https://www.wireshark.org/>|

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Reconnect to make changes take effect
su - $USER
```

## Scenario

This deployment is applicable to 2 scenarios :

- Scenario I:  AMF, SMF, UPF (SPGWU), <u>NRF</u>, UDM, UDR, AUSF, MYSQL
- Scenario II:  AMF, SMF, UPF (SPGWU), UDM, UDR, AUSF, MYSQL

## Network manipulations

Every 5G Core function is assigned a IP address in the subnet demo-oai as defined in the [docker-compose file](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docker-compose/docker-compose-basic-nrf.yaml) :

```yaml
networks:
    public_net:
        driver: bridge
        name: demo-oai-public-net
        ipam:
            config:
                - subnet: 192.168.70.128/26
        driver_opts:
            com.docker.network.bridge.name: "demo-oai"
```

Therefore, you can edit the assigned ip address of every Core function by editing this docker-compose file, e.g

```yaml
oai-nrf:
        container_name: "oai-nrf"
        image: oaisoftwarealliance/oai-nrf:v2.0.1
        expose:
            - 80/tcp
            - 8080/tcp
        volumes:
            - ./conf/basic_nrf_config.yaml:/openair-nrf/etc/config.yaml
        environment:
            - TZ=Europe/Paris
        networks:
            public_net:
                ipv4_address: 192.168.70.130 # edit this line to change the ip address of nrf service
```

### On the CN host

Allow packet forwarding

```bash
CN-host $: sudo sysctl net.ipv4.conf.all.forwarding=1
CN-host $: sudo iptables -P FORWARD ACCEPT
```

Beware that last rule is not persistent and should be applied again after each reboot.

### On the gNB host

Assuming gNB host physical interface connected to the CN host is `NIC1` and its IP address is `IP_ADDR_NIC1`, add a static route to reach the CN host from the gNB host

```bash
gNG-host $: sudo ip route add route 192.168.70.128/26 \
                       via IP_ADDR_NIC1\
                       dev NIC1_NAME
```

## Download source code

```bash
# Clone directly on the latest release tag
git clone --branch v2.0.1 https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git
cd oai-cn5g-fed
# If you forgot to clone directly to the latest release tag
git checkout -f v2.0.1

# Synchronize all git submodules
./scripts/syncComponents.sh
```

It may take some time (~ 2 minutes).
Expected output :

```sh
---------------------------------------------------------
OAI-NRF     component branch : master
OAI-AMF     component branch : master
OAI-SMF     component branch : master
OAI-UPF     component branch : master
OAI-AUSF    component branch : master
OAI-UDM     component branch : master
OAI-UDR     component branch : master
OAI-UPF-VPP component branch : master
OAI-NSSF    component branch : master
OAI-NEF     component branch : master
OAI-PCF     component branch : master
---------------------------------------------------------
git submodule deinit --force .
git submodule update --init --recursive
wd/oai-cn5g-fed/component/oai-nrf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-amf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-smf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-upf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-ausf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-udm wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-udr wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-upf-vpp wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-nssf wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-nef wd/oai-cn5g-fed
wd/oai-cn5g-fed
wd/oai-cn5g-fed/component/oai-pcf wd/oai-cn5g-fed
wd/oai-cn5g-fed
```

## Registering a UE

You can register a UE before running the CN by adding an entry into the [database file](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docker-compose/database/oai_db2.sql) :
Add this line anywhere after the `AuthentificationSubscription` table definition :

```mysql
INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('208950000000031', '5G_AKA', '0C0A34601D4F07677303652C0462535B', '0C0A34601D4F07677303652C0462535B', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '63bfa50ee6523365ff14c1f45f88737d', NULL, NULL, NULL, NULL, '208950000000031'),
```

Make sure to edit the IMSI, opc and key according to the settings of your user device.

You can also add an UE after the core started by entering the mysql container

```bash
CN-host $: docker exec -it mysql /bin/bash
mysql-container$: mysql -uroot -plinux
mysql-container$: use oai_db;
mysql-container$: INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('208950000000031', '5G_AKA', '0C0A34601D4F07677303652C0462535B', '0C0A34601D4F07677303652C0462535B', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '63bfa50ee6523365ff14c1f45f88737d', NULL, NULL, NULL, NULL, '208950000000031'),
```

## Python script

The deployment uses a python script which is a wrapper around docker-compose and parses some argument.

```bash
CN-host $: pwd
/home/<CN-host>/oai/oai-cn-fed/docker-compose
CN-host $: python3 core-network.py --help

usage: core-network.py [-h] --type {start-mini,start-basic,start-basic-vpp,stop-mini,stop-basic,stop-basic-vpp} [--scenario {1,2}] [--capture CAPTURE]

OAI 5G CORE NETWORK DEPLOY

optional arguments:
  -h, --help            show this help message and exit
  --type {start-mini,start-basic,start-basic-vpp,stop-mini,stop-basic,stop-basic-vpp}, -t {start-mini,start-basic,start-basic-vpp,stop-mini,stop-basic,stop-basic-vpp}
                        Functional type of 5g core network ("start-mini"|"start-basic"|"start-basic-vpp"|"stop-mini"|"stop-basic"|"stop-basic-vpp")
  --scenario {1,2}, -s {1,2}
                        Scenario with NRF ("1") and without NRF ("2")
  --capture CAPTURE, -c CAPTURE
                        Add an automatic PCAP capture on docker networks to CAPTURE file

example:
        python3 core-network.py --type start-basic
        python3 core-network.py --type start-basic-vpp
        python3 core-network.py --type start-mini --scenario 2
        python3 core-network.py --type stop-mini --scenario 2
        python3 core-network.py --type start-basic --scenario 1
```

## Deploying the Core Network

```bash
CN-host $: python3 core-network.py --type start-basic --scenario 1
```

Expected output :

```bash
[2022-06-29 16:13:16,657] root:DEBUG:  Starting 5gcn components... Please wait....
[2022-06-29 16:13:16,657] root:DEBUG: docker-compose -f docker-compose-basic-nrf.yaml up -d
Creating network "demo-oai-public-net" with driver "bridge"
Creating mysql   ... done
Creating oai-nrf ... done
Creating oai-udr ... done
Creating oai-udm ... done
Creating oai-ausf ... done
Creating oai-amf  ... done
Creating oai-smf  ... done
Creating oai-spgwu ... done
Creating oai-ext-dn ... done

[2022-06-29 16:14:02,294] root:DEBUG:  OAI 5G Core network started, checking the health status of the containers... takes few secs....
[2022-06-29 16:14:02,294] root:DEBUG: docker-compose -f docker-compose-basic-nrf.yaml ps -a
[2022-06-29 16:15:00,842] root:DEBUG:  All components are healthy, please see below for more details....
Name                    Command                  State                  Ports
----------------------------------------------------------------------------------------------
mysql             docker-entrypoint.sh mysqld      Up (healthy)   3306/tcp, 33060/tcp
oai-amf           /bin/bash /openair-amf/bin ...   Up (healthy)   38412/sctp, 80/tcp, 9090/tcp
oai-ausf          /bin/bash /openair-ausf/bi ...   Up (healthy)   80/tcp
oai-nrf           /bin/bash /openair-nrf/bin ...   Up (healthy)   80/tcp, 9090/tcp
oai-smf           /bin/bash /openair-smf/bin ...   Up (healthy)   80/tcp, 8080/tcp, 8805/udp
oai-spgwu         /bin/bash /openair-spgwu-t ...   Up (healthy)   2152/udp, 8805/udp
oai-ext-dn   /bin/bash -c  ip route add ...   Up
oai-udm           /bin/bash /openair-udm/bin ...   Up (healthy)   80/tcp
oai-udr           /bin/bash /openair-udr/bin ...   Up (healthy)   80/tcp
[2022-06-29 16:15:00,843] root:DEBUG:  Checking if the containers are configured....
[2022-06-29 16:15:00,843] root:DEBUG:  Checking if AMF, SMF and UPF registered with nrf core network....
[2022-06-29 16:15:00,843] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="AMF" | grep -o "192.168.70.132"
192.168.70.132
[2022-06-29 16:15:01,113] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="SMF" | grep -o "192.168.70.133"
192.168.70.133
[2022-06-29 16:15:01,146] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="UPF" | grep -o "192.168.70.134"
192.168.70.134
[2022-06-29 16:15:01,174] root:DEBUG:  Checking if AUSF, UDM and UDR registered with nrf core network....
[2022-06-29 16:15:01,175] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="AUSF" | grep -o "192.168.70.138"
192.168.70.138
[2022-06-29 16:15:01,187] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="UDM" | grep -o "192.168.70.137"
192.168.70.137
[2022-06-29 16:15:01,197] root:DEBUG: curl -s -X GET http://192.168.70.130/nnrf-nfm/v1/nf-instances?nf-type="UDR" | grep -o "192.168.70.136"
192.168.70.136
[2022-06-29 16:15:01,207] root:DEBUG:  AUSF, UDM, UDR, AMF, SMF and UPF are registered to NRF....
[2022-06-29 16:15:01,207] root:DEBUG:  Checking if SMF is able to connect with UPF....
[2022-06-29 16:15:01,271] root:DEBUG:  UPF did answer to N4 Association request from SMF....
[2022-06-29 16:15:01,304] root:DEBUG:  SMF receiving heathbeats from UPF....
[2022-06-29 16:15:01,304] root:DEBUG:  OAI 5G Core network is configured and healthy....
```

## Stopping the CN

```bash
CN-host $: python3 core-network.py --type stop-basic --scenario 1
```
