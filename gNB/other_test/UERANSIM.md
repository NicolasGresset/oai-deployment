# Testing OAI Core Network with UERANSIM

This tutorial will lead you into the testing of OAI Core Network with the state of the art UE and RAN simulator UERANSIM. More explanation and troubleshooting can be found [here](https://github.com/aligungr/UERANSIM/wiki).

## Assumptions

The reader is assumed to have basic knowledge in

- Linux terminal
- Network manipulation

### Software requirements

| Software      | Version       | Official website |
|:---------------|:---------------| :----------- |
| Host OS | >= Ubuntu 16.04     | <https://releases.ubuntu.com/xenial/> |
| Cmake | >= 3.17          |  <https://cmake.org/> |
| gcc | >= 9.0.0          | <https://gcc.gnu.org/> |
| g++ | >= 9.0.0 | <https://gcc.gnu.org/> |
| Wireshark (for debugging purposes) | any | <https://www.wireshark.org/>|

## Installation

### Clone repository

```bash
cd ~
git clone https://github.com/aligungr/UERANSIM
```

### Install dependencies

For ubuntu users :

```bash
sudo apt update
sudo apt upgrade
sudo apt install make
sudo apt install gcc
sudo apt install g++
sudo apt install libsctp-dev lksctp-tools
sudo apt install iproute2
sudo snap install cmake --classic
```

### Build

```bash
cd ~/UERANSIM
make
```

You have now access to 2 executables in `~/UERANSIM/build` :

- nr-gnb : executable for 5G gNB
- nr-ue : execurable for 5G UE

## Configuration

Both executables take a config.yaml file as input argument.
More informations for customization can be found [there](https://github.com/aligungr/UERANSIM/wiki/Configuration)

### gNB

#### YAML configuration

An example configuration is given below

```yaml
mcc: '208'          # Mobile Country Code value
mnc: '95'           # Mobile Network Code value (2 or 3 digits)

nci: '0x000000010'  # NR Cell Identity (36-bit)
idLength: 32        # NR gNB ID length in bits [22...32]
tac: 0xa000            # Tracking Area Code IMPORTANT

linkIp: 192.168.200.5  # gNB's local IP address for Radio Link Simulation (Usually same with local IP)
ngapIp: 192.168.200.5  # gNB's local IP address for N2 Interface (Usually same with local IP)
gtpIp: 192.168.200.5 # gNB's local IP address for N3 Interface (Usually same with local IP)

# List of AMF address information
amfConfigs:
  - address: 192.168.70.132 # must match the IP address of the AMF service in CN
    port: 38412 # default port for sctp

slices:
  - sst: 222
    sd: 123

# Indicates whether or not SCTP stream number errors should be ignored.
ignoreStreamIds: true
```

Make sure that `mcc`, `mnc` and `tac` match the values set in nrf configuration. If you perform basic deployment with OAI, the configuration file must be [this](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docker-compose/conf/basic_nrf_config.yaml?ref_type=heads) one.

The corresponding fields (in nrf configuration) are :

```yaml
  plmn_support_list:
    - mcc: 208
      mnc: 95
      tac: 0xa000
```

Make sure that `sst` and `sd` match one of the SNSSAIs defined in the [same](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docker-compose/conf/basic_nrf_config.yaml?ref_type=heads) configuration file.

#### Add a static route to demo-oai subnet

Assuming gNB host physical interface connected to the CN host is `NIC1` and its IP address is `IP_ADDR_NIC1`, add a static route to reach the CN host from the gNB host

```bash
gNG-host $: sudo ip route add route 192.168.70.128/26 \
                       via IP_ADDR_NIC1\
                       dev NIC1_NAME
```

### UE

An example configuration is given below

```yaml
# IMSI number of the UE. IMSI = [MCC|MNC|MSISDN] (In total 15 digits)
supi: 'imsi-208950000000031'
# Mobile Country Code value of HPLMN
mcc: '208'
# Mobile Network Code value of HPLMN (2 or 3 digits)
mnc: '95'
# SUCI Protection Scheme : 0 for Null-scheme, 1 for Profile A and 2 for Profile B
protectionScheme: 0
# Home Network Public Key for protecting with SUCI Profile A
homeNetworkPublicKey: '5a8d38864820197c3394b92613b20b91633cbd897119273bf8e4a6f4eec0a650'
# Home Network Public Key ID for protecting with SUCI Profile A
homeNetworkPublicKeyId: 1
# Routing Indicator
routingIndicator: '0000'

# Permanent subscription key
key: '0C0A34601D4F07677303652C0462535B'
# Operator code (OP or OPC) of the UE
op: '63bfa50ee6523365ff14c1f45f88737d'
# This value specifies the OP type and it can be either 'OP' or 'OPC'
opType: 'OPC'
# Authentication Management Field (AMF) value
amf: '8000'
# IMEI number of the device. It is used if no SUPI is provided
imei: '356938035643803'
# IMEISV number of the device. It is used if no SUPI and IMEI is provided
imeiSv: '4370816125816151'

# List of gNB IP addresses for Radio Link Simulation
gnbSearchList:
  - 192.168.200.5

# UAC Access Identities Configuration
uacAic:
  mps: false
  mcs: false

# UAC Access Control Class
uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false

# Initial PDU sessions to be established
sessions:
  - type: 'IPv4'
    apn: 'default'
    slice:
      sst: 222
      sd: 123

# Configured NSSAI for this UE by HPLMN
configured-nssai:
  - sst: 222
    sd: 123

# Default Configured NSSAI for this UE
default-nssai:
  - sst: 222
    sd: 123

# Supported integrity algorithms by this UE
integrity:
  IA1: true
  IA2: true
  IA3: true

# Supported encryption algorithms by this UE
ciphering:
  EA1: true
  EA2: true
  EA3: true

# Integrity protection maximum data rate for user plane
integrityMaxRate:
  uplink: 'full'
  downlink: 'full'
```

Make sure that `SUPI`, `key` and `opc` match one of the entry in the sql database used for deployment.

Make sure that `sst` and `sd` match one of the SNSSAIs defined in the [configuration file](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docker-compose/conf/basic_nrf_config.yaml?ref_type=heads).

### CN

Beware that for now, UERANSIM do NOT support integraty and ciphering algorithm NIA0, NEA0 repectively.
Therefore, you should remove them in the configuration file of CN :

```yaml
  supported_integrity_algorithms:
     # - "NIA0" comment this line
    - "NIA1"
    - "NIA2"
  supported_encryption_algorithms:
    # - "NEA0" comment this line
    - "NEA1"
    - "NEA2"
```

## Usage

### gNB

You can simply run

```bash
~/UERANSIM/build/nr-gnb -c path/to/your/gnb/config/file
```

Expected output :

```bash
UERANSIM v3.2.6
[2024-06-20 07:50:00.904] [sctp] [info] Trying to establish SCTP connection... (192.168.70.132:38412)
[2024-06-20 07:50:00.928] [sctp] [info] SCTP connection established (192.168.70.132:38412)
[2024-06-20 07:50:00.928] [sctp] [debug] SCTP association setup ascId[3]
[2024-06-20 07:50:00.929] [ngap] [debug] Sending NG Setup Request
[2024-06-20 07:50:00.936] [ngap] [debug] NG Setup Response received
[2024-06-20 07:50:00.936] [ngap] [info] NG Setup procedure is successful
```

Run

```bash
CN-host $: docker logs oai-amf
```

You should now see that gNB has been succesfully registered.

**Troubleshooting** : if the procedure is stuck at the establishment of SCTP connection step, it probably means you don't have a route to reach the AMF. Try to ping the address and check if forwarding is enabled on the CN-host (report to OAI-CN-deployment tutorial). If you are running the CN-host inside of a VM, forwarding must also be enabled in the host OS.

### UE

You can simply run

```bash
sudo ~/UERANSIM/build/nr-ue -c path/to/your/ue/config/file
```

(command must be run as root to be allowed to create TUN interface).

Expected output :

```bash
UERANSIM v3.2.6
[2024-06-20 08:03:27.364] [rrc] [debug] New signal detected for cell[1], total [1] cells in coverage
[2024-06-20 08:03:27.364] [nas] [info] UE switches to state [MM-DEREGISTERED/PLMN-SEARCH]
[2024-06-20 08:03:29.565] [nas] [error] PLMN selection failure, no cells in coverage
[2024-06-20 08:03:29.932] [nas] [info] Selected plmn[208/95]
[2024-06-20 08:03:32.365] [rrc] [info] Selected cell plmn[208/95] tac[40960] category[SUITABLE]
[2024-06-20 08:03:32.365] [nas] [info] UE switches to state [MM-DEREGISTERED/PS]
[2024-06-20 08:03:32.366] [nas] [info] UE switches to state [MM-DEREGISTERED/NORMAL-SERVICE]
[2024-06-20 08:03:32.366] [nas] [debug] Initial registration required due to [MM-DEREG-NORMAL-SERVICE]
[2024-06-20 08:03:32.368] [nas] [debug] UAC access attempt is allowed for identity[0], category[MO_sig]
[2024-06-20 08:03:32.368] [nas] [debug] Sending Initial Registration
[2024-06-20 08:03:32.369] [rrc] [debug] Sending RRC Setup Request
[2024-06-20 08:03:32.371] [rrc] [info] RRC connection established
[2024-06-20 08:03:32.373] [rrc] [info] UE switches to state [RRC-CONNECTED]
[2024-06-20 08:03:32.374] [nas] [info] UE switches to state [MM-REGISTER-INITIATED]
[2024-06-20 08:03:32.374] [nas] [info] UE switches to state [CM-CONNECTED]
[2024-06-20 08:03:32.430] [nas] [debug] Authentication Request received
[2024-06-20 08:03:32.430] [nas] [debug] Received SQN [000000000080]
[2024-06-20 08:03:32.430] [nas] [debug] SQN-MS [000000000000]
[2024-06-20 08:03:32.481] [nas] [debug] Security Mode Command received
[2024-06-20 08:03:32.482] [nas] [debug] Selected integrity[1] ciphering[0]
[2024-06-20 08:03:32.491] [nas] [debug] Registration accept received
[2024-06-20 08:03:32.491] [nas] [info] UE switches to state [MM-REGISTERED/NORMAL-SERVICE]
[2024-06-20 08:03:32.491] [nas] [debug] Sending Registration Complete
[2024-06-20 08:03:32.492] [nas] [info] Initial Registration is successful
[2024-06-20 08:03:32.492] [nas] [debug] Sending PDU Session Establishment Request
[2024-06-20 08:03:32.492] [nas] [debug] UAC access attempt is allowed for identity[0], category[MO_sig]
[2024-06-20 08:03:32.709] [nas] [debug] PDU Session Establishment Accept received
[2024-06-20 08:03:32.727] [nas] [info] PDU Session establishment is successful PSI[1]
[2024-06-20 08:03:32.772] [app] [info] Connection setup for PDU session[1] is successful, TUN interface[uesimtun0, 12.1.1.3] is up.
```

UE must now be registered by AMF and a new interface has been created.

**Troubleshooting**
- The following means that you probably forgot [this](#cn) part. 

```bash
[IA0] cannot be accepted as the UE does not have an emergency
[2024-06-19 08:48:58.881] [nas] [error] Rejecting Security Mode Command with cause [SEC_MODE_REJECTED_UNSPECIFIED]
```

- The following means that UE's APN, SST or SD configuration do not match any of the ones configured in CN.

```bash
[error] PDU Session Establishment Reject received [MISSING_OR_UNKNOWN_DNN]
```

- If no interface was created, you may have not run the command as root.
