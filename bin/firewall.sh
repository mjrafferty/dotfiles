#!/bin/bash

IPTABLES="/usr/bin/iptables"
IPTABLESSAVE="/usr/bin/iptables-save"
IPTABLESRESTORE="/usr/bin/iptables-restore"

DNS1="192.168.1.102"
DNS2="1.1.1.1"

#inside
IINTERFACE="eth0"
#outside
OINTERFACE="wlp4s0"

_rules() {

	_stop;

	echo "Setting internal rules"

	#echo "Setting default rule to drop"
	#$IPTABLES -P FORWARD DROP
	#$IPTABLES -P INPUT   DROP
	#$IPTABLES -P OUTPUT  DROP

	#default rule
	echo "Creating states chain"
	$IPTABLES -N allowed-connection
	$IPTABLES -F allowed-connection
	$IPTABLES -A allowed-connection -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A allowed-connection -i $IINTERFACE -m limit -j LOG --log-prefix "Bad packet from ${IINTERFACE}:"
	$IPTABLES -A allowed-connection -j DROP

	#ICMP traffic
	echo "Creating icmp chain"
	$IPTABLES -N icmp_allowed
	$IPTABLES -F icmp_allowed
	$IPTABLES -A icmp_allowed -m state --state NEW -p icmp --icmp-type time-exceeded -j ACCEPT
	$IPTABLES -A icmp_allowed -m state --state NEW -p icmp --icmp-type destination-unreachable -j ACCEPT
	$IPTABLES -A icmp_allowed -p icmp -j LOG --log-prefix "Bad ICMP traffic:"
	$IPTABLES -A icmp_allowed -p icmp -j DROP

	#Incoming traffic
	echo "Creating incoming ssh traffic chain"
	$IPTABLES -N allow-ssh-traffic-in
	$IPTABLES -F allow-ssh-traffic-in
	#Flood protection
	$IPTABLES -A allow-ssh-traffic-in -m limit --limit 1/second -p tcp --tcp-flags ALL RST --dport ssh -j ACCEPT
	$IPTABLES -A allow-ssh-traffic-in -m limit --limit 1/second -p tcp --tcp-flags ALL FIN --dport ssh -j ACCEPT
	$IPTABLES -A allow-ssh-traffic-in -m limit --limit 1/second -p tcp --tcp-flags ALL SYN --dport ssh -j ACCEPT
	$IPTABLES -A allow-ssh-traffic-in -m state --state RELATED,ESTABLISHED -p tcp --dport ssh -j ACCEPT

	#outgoing traffic
	echo "Creating outgoing ssh traffic chain"
	$IPTABLES -N allow-ssh-traffic-out
	$IPTABLES -F allow-ssh-traffic-out
	$IPTABLES -A allow-ssh-traffic-out -p tcp --dport ssh -j ACCEPT

	echo "Creating outgoing dns traffic chain"
	$IPTABLES -N allow-dns-traffic-out
	$IPTABLES -F allow-dns-traffic-out
	$IPTABLES -A allow-dns-traffic-out -p udp -d $DNS1 --dport domain -j ACCEPT
	$IPTABLES -A allow-dns-traffic-out -p udp -d $DNS2 --dport domain -j ACCEPT

	echo "Creating outgoing http/https traffic chain"
	$IPTABLES -N allow-www-traffic-out
	$IPTABLES -F allow-www-traffic-out
	$IPTABLES -A allow-www-traffic-out -p tcp --dport www -j ACCEPT
	$IPTABLES -A allow-www-traffic-out -p tcp --dport https -j ACCEPT

	#Catch portscanners
	echo "Creating portscan detection chain"
	$IPTABLES -N check-flags
	$IPTABLES -F check-flags
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL FIN,URG,PSH -m limit --limit 5/minute -j LOG --log-level alert --log-prefix "NMAP-XMAS:"
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL ALL -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "XMAS:"
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL ALL -j DROP
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "XMAS-PSH:"
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL NONE -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "NULL_SCAN:"
	$IPTABLES -A check-flags -p tcp --tcp-flags ALL NONE -j DROP
	$IPTABLES -A check-flags -p tcp --tcp-flags SYN,RST SYN,RST -m limit --limit 5/minute -j LOG --log-level 5 --log-prefix "SYN/RST:"
	$IPTABLES -A check-flags -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	$IPTABLES -A check-flags -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/minute -j LOG --log-level 5 --log-prefix "SYN/FIN:"
	$IPTABLES -A check-flags -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

	# Apply and add invalid states to the chains
	echo "Applying chains to INPUT"
	$IPTABLES -A INPUT -m state --state INVALID -j DROP
	$IPTABLES -A INPUT -p icmp -j icmp_allowed
	$IPTABLES -A INPUT -j check-flags
	$IPTABLES -A INPUT -i lo -j ACCEPT
	$IPTABLES -A INPUT -j allow-ssh-traffic-in
	$IPTABLES -A INPUT -j allowed-connection
	$IPTABLES -t filter -A INPUT -j REJECT


	echo "Applying chains to FORWARD"
	$IPTABLES -A FORWARD -m state --state INVALID -j DROP
	$IPTABLES -A FORWARD -p icmp -j icmp_allowed
	$IPTABLES -A FORWARD -j check-flags
	$IPTABLES -A FORWARD -o lo -j ACCEPT
	$IPTABLES -A FORWARD -j allow-ssh-traffic-in
	$IPTABLES -A FORWARD -j allow-www-traffic-out
	$IPTABLES -A FORWARD -j allowed-connection
	$IPTABLES -t filter -A FORWARD -j REJECT

	echo "Applying chains to OUTPUT"
	$IPTABLES -A OUTPUT -m state --state INVALID -j DROP
	$IPTABLES -A OUTPUT -p icmp -j icmp_allowed
	$IPTABLES -A OUTPUT -j check-flags
	$IPTABLES -A OUTPUT -o lo -j ACCEPT
	$IPTABLES -A OUTPUT -j allow-ssh-traffic-out
	$IPTABLES -A OUTPUT -j allow-dns-traffic-out
	$IPTABLES -A OUTPUT -j allow-www-traffic-out
	$IPTABLES -A OUTPUT -j allowed-connection

	$IPTABLES -A OUTPUT -p TCP --dport 22005 -j ACCEPT             # For work login server
	$IPTABLES -A OUTPUT -p UDP --dport 53 -j ACCEPT                # DNS
	$IPTABLES -A OUTPUT -p UDP --dport 5353 -j ACCEPT              # Avahi maybe? I'll check at some point
	$IPTABLES -A OUTPUT -p TCP --dport 465 -j ACCEPT               # Google SMTP
	$IPTABLES -A OUTPUT -p TCP --dport 993 -j ACCEPT               # Google IMAP
	$IPTABLES -t filter -A OUTPUT -j REJECT

	#Allow client to route through via NAT (Network Address Translation)
	$IPTABLES -t nat -A POSTROUTING -o $OINTERFACE -j MASQUERADE

}

_start() {

	echo "Starting firewall"

	if [ -e "${FIREWALL}" ]; then

		_restore;

	else

		echo "${FIREWALL} does not exists. Using default rules."
		_rules;

	fi

}

_stop() {

	echo "Stopping firewall"
	$IPTABLES -F
	$IPTABLES -t nat -F
	$IPTABLES -X
	$IPTABLES -P FORWARD ACCEPT
	$IPTABLES -P INPUT   ACCEPT
	$IPTABLES -P OUTPUT  ACCEPT

}

_showstatus() {

	echo "Status"
	$IPTABLES -L -n -v --line-numbers

	echo "NAT status"
	$IPTABLES -L -n -v --line-numbers -t nat

}

_panic() {

	echo "Setting panic rules"
	$IPTABLES -F
	$IPTABLES -X
	$IPTABLES -t nat -F
	$IPTABLES -P FORWARD DROP
	$IPTABLES -P INPUT   DROP
	$IPTABLES -P OUTPUT  DROP
	$IPTABLES -A INPUT -i lo -j ACCEPT
	$IPTABLES -A OUTPUT -o lo -j ACCEPT

}

_save() {

	echo "Saving Firewall rules"
	$IPTABLESSAVE > "$FIREWALL"

}

_restore() {

	echo "Restoring Firewall rules"
	$IPTABLESRESTORE < "$FIREWALL"

}

_restart() {

	_stop;
	_start;

}

_showoptions() {

	cat <<- EOF

	Usage: ./firewall.sh {start|save|restore|panic|stop|restart|showstatus}

		start)      will restore setting if exists else force rules
		stop)       delete all rules and set all to accept
		rules)      force settings of new rules
		save)       will store settings in
		restore)    will restore settings from
		showstatus) Shows the status

EOF
}
