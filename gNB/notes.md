# docker image
docker pull rohankharade/ueransim
docker image tag rohankharade/ueransim:latest ueransim:latest

# troubleshooting network configuration 
il FAUT avoir une src dans les routes "ip route"
bien penser à ajouter une route vers le subnet demo-oai dans le gNB

# troubleshooting

on essaye de set up le simulateur gnB de UERANSIM
il faut bien configurer le mcc, le mc ET le tac correctement pour que le gNB se co

le tac peut-être trouvé dans la configuration du nrf, à l'endroit du plmn, et vaut par défaut 0xa000 dans OAI basic deployment

on peut afficher les logs avec `docker logs oai-amf`


---
the following error : 

```
[IA0] cannot be accepted as the UE does not have an emergency
[2024-06-19 08:48:58.881] [nas] [error] Rejecting Security Mode Command with cause [SEC_MODE_REJECTED_UNSPECIFIED]
```

can be solved by disabling the IA0 algorithm in the CN : for OAI, edit the `oai-cn5g-fed/docker-compose/conf/basic_nrf_config.yaml` file and change the `supported_integrity_algorithms` field

---

the following is probably due to a bad slice configuration in the UE side
edit fields sessions.type, sessions.apn, sessions.slice.sst and sessions.slice.sd accordingly with the ones defines in `oai-cn5g-fed/docker-compose/conf/basic_nrf_config.yaml` 

```
[error] PDU Session Establishment Reject received [MISSING_OR_UNKNOWN_DNN]
```

---

you can now ping from dn-container (192.168.è0.135) and perform iperf3 bandwith tests !!!! 


il faut être sur d'avoir le forwarding d'activé sur toutes les machines (hote CN ET OS hôte en cas de VM)

