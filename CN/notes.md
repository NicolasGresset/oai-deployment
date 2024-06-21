let's try to automage the deployment of the VM with valgrant AND ansible


installed vagrant and vagrant-libvirt (had to use `VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-libvirt` for some dependencies issues)

OKKKKKKKKKKKKKKk
ca marche plutôt très très bien !!! 

je peux déployer une vm avec tout d'installé comme il faut <33
pour l'utilisateur, il n'y a plus qu'à avoir vagrant, qemu / kvm et libvirt et ajouter une route statique
c'est très très beau, ca marche super

le core est set up en genre 5 minutes (et on peut encore speed up le process en trouvant un miroir apt plus proche)



## deployment with gnb

on essaye de set up le simulateur gnB de UERANSIM
il faut bien configurer le mcc, le mc ET le tac correctement pour que le gNB se co

on arrive aussi à co l'UE mais on a un pb de protocole de communication en cas d'urgence
on tente un fix de débile : https://github.com/aligungr/UERANSIM/issues/417

maybe a smarter fix : https://github.com/aligungr/UERANSIM/issues/417