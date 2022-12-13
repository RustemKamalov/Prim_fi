#   I= eszkoz IP cime
#   t= timeout 100msec-ban
#   n= PLC ModBus cime
#   f= elso olvasando regiszter cime 400000 nelkul
#   r= olvasando regiszterek szama

# KP18 (TCP/MB+ brigde)
/Dmon/bin/dmmbtcp -T "I=10.48.3.79 t=1 n=222 f=830 r=10"

# clock
#/Dmon/bin/dmmbtcp -T "I=192.168.42.81 t=1 n=0 f=2808 r=125"

# eventhandling MDP1
#/Dmon/bin/dmmbtcp -T "I=10.48.3.1 t=1 n=0 f=6229 r=10"

# eventhandling MDP1
#/Dmon/bin/dmmbtcp -T "I=10.48.3.1 t=1 n=0 f=6670 r=10"

# P2_ora 
#/Dmon/bin/dmmbtcp -T "I=10.48.3.1 t=1 n=0 f=2825 r=20"

# P2_Regard
#/Dmon/bin/dmmbtcp -T "I=10.48.3.1 t=1 n=0 f=7145 r=20"

# P2_ora MBP_TCP bridge-en keresztul
#Dmon/bin/dmmbtcp -T "I=10.48.3.79 t=1 n=12 f=2825 r=20"

# Fi_ mdp2 chain2 init,ack
#/Dmon/bin/dmmbtcp -T "I=10.48.3.5 t=1 n=0 f=6673 r=2"

# Fi_ mdp2 chain2 queue
#/Dmon/bin/dmmbtcp -T "I=10.48.3.5 t=1 n=0 f=6102 r=10"
