#!/bin/bash

###########################################################################
#
# Created by
# Lukas Satin <luke.satin@gmail.com>
#
# Auto Installer for MainNet EOS Network
# Home: github.com/cyberluke
###########################################################################




install_tools(){
	if [[ $OS == "ubuntu" ]] || [[ $OS == "debian" ]]
	then
		sudo apt -y update; sudo apt -y install jq; sudo apt -y install git wget curl
	elif [[ $OS == "centos" ]]
	then
		yum -y update && yum -y install git wget sudo curl epel-release; yum -y install jq
	elif [[ $OS == "fedora" ]]
	then
		dnf -y install git wget sudo dnf-yum curl jq tar
	fi
}




GLOBAL_PATH=$(pwd)
OS=$(cat /etc/os-release | grep '^ID=' | cut -d '=' -f2 | tr -d '"')
OS_VER=$(cat /etc/os-release | grep -i version_id | cut -d '=' -f2 | tr -d '"')
GET_COMM="wget"
OS_SOURCE_DIR=""
MAINNET="Main"
MAINNET_BIN_DIR="$GLOBAL_PATH/bin"
DATE=$(date +%Y-%m-%d)
EOS_SOURCE_DIR=""
ACCOUNT_NAME=""

if [[ -f $(find /usr -type f -name curl) ]] && [[ -f $(find /usr -type f -name jq) ]]
then
	TAG=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ver' | tr -d '"')
	EOS_VER=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ver' | tr -d '"' | grep -o '[0-9]\.[0-9]\.[0-9]')
    EOSIO_DEB16=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ubuntu16_bin' | tr -d '"')
	EOSIO_DEB18=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ubuntu18_bin' | tr -d '"')
	EOSIO_FEDORA27=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.fedora27_bin' | tr -d '"')
	EOSIO_CENTOS7=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.centos7_bin' | tr -d '"')
else
	clear
	if [[ $OS == "centos" || $OS == "fedora" || $OS == "ubuntu" ]]
	then
		printf "These packages are requierd to prepare a NODE for MainNet:\n"
		if [[ $OS == "centos" ]]
		then
			for i in "git" "wget" "sudo" "curl" "epel-release" "jq";do
				printf "%s\t" "$i"
			done
		elif [[ $OS == "fedora" ]]
		then
			for i in "git" "wget" "sudo" "curl" "tar" "dnf-yum" "jq";do
				printf "%s\t" "$i"
			done
		elif [[ $OS == "ubuntu" ]]
		then
			for i in "git" "wget"  "curl" "jq";do
				printf "%s\t" "$i"
			done
		fi
	else
		printf "\033[0;31mYour will try to install eosio on unsuported system %s %s\033[m\n" "$OS" "$OS_VER"
		exit -1
	fi
	printf "\n"
	printf "Install/update them now?\n"
	select answer in "YES" "NO"; do
		case $answer in 
			"YES")
				install_tools
				break
				;;
			"NO")
				exit -1
				;;
		esac
	done

	TAG=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ver' | tr -d '"')
	EOS_VER=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ver' | tr -d '"' | grep -o '[0-9]\.[0-9]\.[0-9]')
    EOSIO_DEB16=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ubuntu16_bin' | tr -d '"')
	EOSIO_DEB18=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ubuntu18_bin' | tr -d '"')
	EOSIO_FEDORA27=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.fedora27_bin' | tr -d '"')
	EOSIO_CENTOS7=$(curl -sS https://monitor.jungletestnet.io/version.json | jq '.centos7_bin' | tr -d '"')
fi

################################################################
#
#CONFIG SECTION VAIRABLES
#
################################################################
logo(){
echo -n $'\E[0;32m'
	cat << "EOF"
    __________  _____    __  ___      _       _   __     __
   / ____/ __ \/ ___/   /  |/  /___ _(_)___  / | / /__  / /_
  / __/ / / / /\__ \   / /|_/ / __ `/ / __ \/  |/ / _ \/ __/
 / /___/ /_/ /___/ /  / /  / / /_/ / / / / / /|  /  __/ /_
/_____/\____//____/  /_/  /_/\__,_/_/_/ /_/_/ |_/\___/\__/
EOF
printf "\033[m"
}

# NODE_MONITOR_JSON='{
#     "bp_name": "{{bp_name}}",
#     "organisation": "{{organisation}}",
#     "location": "{{location}}",
#     "node_addr": "{{node_addr}}",
#     "port_http": "{{port_http}}",
#     "port_ssl": "{{port_ssl}}",
#     "port_p2p": "{{port_p2p}}",
#     "pub_key": "{{pub_key}}",
#     "bp": {{bp}},
#     "enabled": {{enabled}},
#     "comment": "{{comment}}",
#     "telegram": "{{telegram}}"
#     "url": "url"
# }'

GENESIS='{
  "initial_timestamp": "2018-06-08T08:08:08.888",
  "initial_key": "EOS7EarnUhcyYqmdnPon8rm7mBCTnBoot6o7fE2WzjvEX2TdggbL3",
  "initial_configuration": {
    "max_block_net_usage": 1048576,
    "target_block_net_usage_pct": 1000,
    "max_transaction_net_usage": 524288,
    "base_per_transaction_net_usage": 12,
    "net_usage_leeway": 500,
    "context_free_discount_net_usage_num": 20,
    "context_free_discount_net_usage_den": 100,
    "max_block_cpu_usage": 200000,
    "target_block_cpu_usage_pct": 1000,
    "max_transaction_cpu_usage": 150000,
    "min_transaction_cpu_usage": 100,
    "max_transaction_lifetime": 3600,
    "deferred_trx_expiration_window": 600,
    "max_transaction_delay": 3888000,
    "max_inline_action_size": 4096,
    "max_inline_action_depth": 4,
    "max_authority_depth": 6
  }
}'

#PRODUCER_PRIV_KEY_DEF="!! INSERT HERE PRIVATE KEY TO THIS PUBLIC ADDRESS !!";

################################################################
#
#END CONFIG SECTION VAIRABLES
#
################################################################

#####################################################
#CONFIG SECTION
#####################################################

config_func(){
			#printf "Enter Main Net Account NAME (Exchange filtering): "
			#read name
			#until [[ $name =~ [a-z1-5]{12} ]]
			#do
			#	printf "Account name should have length 12, lowercase a-z, number 1-5\n"
			#	printf "Enter account NAME: "
			#	read name
			#done
			#ACCOUNT_NAME=$name
	####
	#VARIABLES SECTION
	#
	printf "Do you configure EOSIO NODE for BP?\n"
select answer in "Yes" "No" "Exit"; do
	case $answer in
		"Yes")
			select answer in "Yes" "No"; do
				case $answer in
					"Yes")
						break
						;;
					"No")
						exit -1
						;;
					esac
				done
			printf "\n"
			printf "Enter NODE HTTP SERVER address and port in the format for example (0.0.0.0:8888) or leave blank for the default value: "
			read ans
			if [[ -n $ans ]]
			then
				NODE_HTTP_SRV_ADDR=$ans
			else
				NODE_HTTP_SRV_ADDR="0.0.0.0:8888"
			fi
			printf "Enter NODE P2P listen endpoint address and port in the format for example (0.0.0.0:9876) or leave blank for the default value: "
			read ans
			if [[ -n $ans ]]
			then
				NODE_P2P_LST_ENDP=$ans
			else
				NODE_P2P_LST_ENDP="0.0.0.0:9876"
			fi
			printf "Enter NODE P2P server address and port in the format for example (0.0.0.0:9876) or leave blank for the default value: "
			read ans
			if [[ -n $ans ]]
			then
				NODE_P2P_SRV_ADDR=$ans
			else
				NODE_P2P_SRV_ADDR="0.0.0.0:9876"
			fi
			printf "Will you use ssl?\n"
			select answer in "Yes" "No"; do
			case $answer in
				"Yes")
					printf "Enter NODE HTTPS server address in the format for example (0.0.0.0:443): "
					read ans
					if [[ -n $ans ]]
					then
						NODE_HTTPS_SERVER_ADDR=$ans
						NODE_SSL_PORT=$(echo $NODE_HTTPS_SERVER_ADDR | cut -d ":" -f2)
					else
						NODE_HTTPS_SERVER_ADDR=""
						NODE_SSL_PORT=""
					fi
					printf "\033[0;31mIf you use ssl port, please your certificate info into config.ini after installation.\033[0m\n"
					break
					;;
				"No")
					NODE_HTTPS_SERVER_ADDR=""
					NODE_SSL_PORT=""
					break
					;;
				esac
			done

			NODE_HOST=$(echo $NODE_HTTP_SRV_ADDR | cut -d ":" -f1)
			NODE_API_PORT=$(echo $NODE_HTTP_SRV_ADDR | cut -d ":" -f2)
			#NODE_SSL_PORT=$(echo $NODE_HTTPS_SERVER_ADDR | cut -d ":" -f2)

			printf "Enter Producer Public Key: "
			read key
			RODUCER_PUB_KEY=$key
			RODUCER_PRIV_KEY="";

			printf "Enter Producer NAME: "
			read name
			until [[ $name =~ [a-z1-5]{12} ]]
			do
				printf "Account name should have length 12, lowercase a-z, number 1-5\n"
				printf "Enter Producer NAME: "
				read name
			done
			PRODUSER_NAME=$name
			PRODUCER_AGENT_NAME=$name

			MAINNET="$MAINNET-$PRODUSER_NAME"
			WALLET_HOST="127.0.0.1"
			WALLET_PORT="5553"

			PEER_LIST='p2p-peer-address = 185.253.188.1:19876
p2p-peer-address = 807534da.eosnodeone.io:19872
p2p-peer-address = api-full1.eoseoul.io:9876
p2p-peer-address = api-full2.eoseoul.io:9876
p2p-peer-address = api.eosuk.io:12000
p2p-peer-address = boot.eostitan.com:9876
p2p-peer-address = bp.antpool.com:443
p2p-peer-address = bp.cryptolions.io:9876
p2p-peer-address = bp.eosbeijing.one:8080
p2p-peer-address = bp.libertyblock.io:9800
p2p-peer-address = br.eosrio.io:9876
p2p-peer-address = eos-seed-de.privex.io:9876
p2p-peer-address = eos.nodepacific.com:9876
p2p-peer-address = eos.staked.us:9870
p2p-peer-address = eu-west-nl.eosamsterdam.net:9876
p2p-peer-address = eu1.eosdac.io:49876
p2p-peer-address = fn001.eossv.org:443
p2p-peer-address = fullnode.eoslaomao.com:443
p2p-peer-address = mainnet.eosarabia.org:3571
p2p-peer-address = mainnet.eoscalgary.io:5222
p2p-peer-address = mainnet.eospay.host:19876
p2p-peer-address = mars.fnp2p.eosbixin.com:443
p2p-peer-address = node.eosflare.io:1883
p2p-peer-address = node1.eosnewyork.io:6987
p2p-peer-address = node2.eosnewyork.io:6987
p2p-peer-address = p.jeda.one:3322
p2p-peer-address = p2p.eos.bitspace.no:9876
p2p-peer-address = p2p.eosio.cr:1976
p2p-peer-address = p2p.genereos.io:9876
p2p-peer-address = p2p.meet.one:9876
p2p-peer-address = p2p.one.eosdublin.io:9876
p2p-peer-address = p2p.two.eosdublin.io:9876
p2p-peer-address = p2p.unlimitedeos.com:15555
p2p-peer-address = peer.eosn.io:9876
p2p-peer-address = peer1.mainnet.helloeos.com.cn:80
p2p-peer-address = peer2.mainnet.helloeos.com.cn:80
p2p-peer-address = peering.mainnet.eoscanada.com:9876
p2p-peer-address = peering2.mainnet.eosasia.one:80
p2p-peer-address = pub0.eosys.io:6637
p2p-peer-address = pub1.eosys.io:6637
p2p-peer-address = publicnode.cypherglass.com:9876
p2p-peer-address = seed1.greymass.com:9876
p2p-peer-address = seed2.greymass.com:9876
			 '

			ISBP=true
			PRODUCER_URL=""
			PRODUCER_PRIV_KEY_DEF="!! INSERT HERE PRIVATE KEY TO THIS PUBLIC ADDRESS !!";
			break
			;;
		"No")
			
			NODE_HTTP_SRV_ADDR="0.0.0.0:8888"
			NODE_P2P_LST_ENDP="0.0.0.0:9876"
			NODE_P2P_SRV_ADDR="0.0.0.0:9876"
			NODE_HTTPS_SERVER_ADDR=""


			NODE_HOST="0.0.0.0" 
			NODE_API_PORT="8888"
			NODE_SSL_PORT=""



			PRODUCER_PUB_KEY=""
			PRODUCER_PRIV_KEY="";

			PRODUSER_NAME="NoNBP_NODE"
			PRODUCER_AGENT_NAME=""

			MAINNET="$MAINNET-NODE"

			WALLET_HOST="127.0.0.1"
			WALLET_PORT="5553"

			PEER_LIST='p2p-peer-address = 185.253.188.1:19876
p2p-peer-address = 807534da.eosnodeone.io:19872
p2p-peer-address = api-full1.eoseoul.io:9876
p2p-peer-address = api-full2.eoseoul.io:9876
p2p-peer-address = api.eosuk.io:12000
p2p-peer-address = boot.eostitan.com:9876
p2p-peer-address = bp.antpool.com:443
p2p-peer-address = bp.cryptolions.io:9876
p2p-peer-address = bp.eosbeijing.one:8080
p2p-peer-address = bp.libertyblock.io:9800
p2p-peer-address = br.eosrio.io:9876
p2p-peer-address = eos-seed-de.privex.io:9876
p2p-peer-address = eos.nodepacific.com:9876
p2p-peer-address = eos.staked.us:9870
p2p-peer-address = eu-west-nl.eosamsterdam.net:9876
p2p-peer-address = eu1.eosdac.io:49876
p2p-peer-address = fn001.eossv.org:443
p2p-peer-address = fullnode.eoslaomao.com:443
p2p-peer-address = mainnet.eosarabia.org:3571
p2p-peer-address = mainnet.eoscalgary.io:5222
p2p-peer-address = mainnet.eospay.host:19876
p2p-peer-address = mars.fnp2p.eosbixin.com:443
p2p-peer-address = node.eosflare.io:1883
p2p-peer-address = node1.eosnewyork.io:6987
p2p-peer-address = node2.eosnewyork.io:6987
p2p-peer-address = p.jeda.one:3322
p2p-peer-address = p2p.eos.bitspace.no:9876
p2p-peer-address = p2p.eosio.cr:1976
p2p-peer-address = p2p.genereos.io:9876
p2p-peer-address = p2p.meet.one:9876
p2p-peer-address = p2p.one.eosdublin.io:9876
p2p-peer-address = p2p.two.eosdublin.io:9876
p2p-peer-address = p2p.unlimitedeos.com:15555
p2p-peer-address = peer.eosn.io:9876
p2p-peer-address = peer1.mainnet.helloeos.com.cn:80
p2p-peer-address = peer2.mainnet.helloeos.com.cn:80
p2p-peer-address = peering.mainnet.eoscanada.com:9876
p2p-peer-address = peering2.mainnet.eosasia.one:80
p2p-peer-address = pub0.eosys.io:6637
p2p-peer-address = pub1.eosys.io:6637
p2p-peer-address = publicnode.cypherglass.com:9876
p2p-peer-address = seed1.greymass.com:9876
p2p-peer-address = seed2.greymass.com:9876'

			ISBP=false
			PRODUCER_URL=""
			PRODUCER_PRIV_KEY_DEF="";
			break
			;;
		"Exit")
			exit -1
			;;
		esac
	done
	MAINNET_DIR="$GLOBAL_PATH/$MAINNET"
	WALLET_DIR="$GLOBAL_PATH/wallet"
	SNAPSHOT_DIR="$GLOBAL_PATH/snapshot"
	###################################################################
	if [[ ! -d $WALLET_DIR ]]; then
    echo "..:: Creating Wallet Dir: $WALLET_DIR ::..";
    mkdir $WALLET_DIR

    echo "..:: Creating Wallet start.sh ::..";
    # Creating start.sh for wallet
    echo "#!/bin/bash" > $WALLET_DIR/start.sh
    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $WALLET_DIR/start.sh
    echo "DATADIR=$WALLET_DIR" >> $WALLET_DIR/start.sh
    echo "\$DATADIR/stop.sh" >> $WALLET_DIR/start.sh
    echo "$MAINNET_BIN_DIR/keosd --wallet-dir \$DATADIR --data-dir \$DATADIR --http-server-address $WALLET_HOST:$WALLET_PORT \"\$@\" > $WALLET_DIR/stdout.txt 2> $WALLET_DIR/stderr.txt  & echo \$! > \$DATADIR/wallet.pid" >> $WALLET_DIR/start.sh
    echo "echo \"Wallet started\"" >> $WALLET_DIR/start.sh
    chmod u+x $WALLET_DIR/start.sh


    # Creating stop.sh for wallet
    echo "#!/bin/bash" > $WALLET_DIR/stop.sh
    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $WALLET_DIR/stop.sh
    echo "DIR=$WALLET_DIR" >> $WALLET_DIR/stop.sh
    echo '
    if [ -f $DIR"/wallet.pid" ]; then
        pid=$(cat $DIR"/wallet.pid")
        echo $pid
        kill $pid
        rm -r $DIR"/wallet.pid"

        echo -ne "Stoping Wallet"

        while true; do
            [ ! -d "/proc/$pid/fd" ] && break
            echo -ne "."
            sleep 1
        done
        echo -ne "\rWallet stopped. \n"

    fi
    ' >>  $WALLET_DIR/stop.sh
    chmod u+x $WALLET_DIR/stop.sh

	fi

	#start Wallet
	echo "..:: Satrt Wallet ::.."
	if [[ ! -f $WALLET_DIR/wallet.pid ]]; then
	    $WALLET_DIR/start.sh
	fi

	#################### MAINNET #################################

	# Creating MainNet Folder and files
	if [[ ! -d $MAINNET_DIR ]]; then
	    echo "..:: Creating MainNet Dir: $MAINNET ::..";

	    mkdir $MAINNET_DIR
	    
	else
		printf "\033[0;31m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\033[0;31m       MainNet folder already exists %s, please rename or move this folder.\033[0m\n" "$MAINNET_DIR"
		printf "\033[0;31m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		exit -1
		
	fi
	    # Creating node start.sh 
	    echo "..:: Creating start.sh ::..";
	    echo "#!/bin/bash" > $MAINNET_DIR/start.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/start.sh
	    echo "NODEOS=$MAINNET_BIN_DIR/nodeos" >> $MAINNET_DIR/start.sh
	    echo "DATADIR=$MAINNET_DIR" >> $MAINNET_DIR/start.sh
	    echo -ne "\n";
	    echo "\$DATADIR/stop.sh" >> $MAINNET_DIR/start.sh
	    echo -ne "\n";
	    echo "ulimit -s 64000";
	    echo -ne "\n";
	    echo "\$NODEOS --data-dir \$DATADIR --config-dir \$DATADIR \"\$@\" > \$DATADIR/stdout.txt 2> \$DATADIR/stderr.txt &  echo \$! > \$DATADIR/nodeos.pid" >> $MAINNET_DIR/start.sh
	    chmod u+x $MAINNET_DIR/start.sh


	    # Creating node stop.sh 
	    echo "..:: Creating stop.sh ::..";
	    echo "#!/bin/bash" > $MAINNET_DIR/stop.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/stop.sh
	    echo "DIR=$MAINNET_DIR" >> $MAINNET_DIR/stop.sh
	    echo -ne "\n";
	    echo '
	    if [ -f $DIR"/nodeos.pid" ]; then
	        pid=$(cat $DIR"/nodeos.pid")
	        echo $pid
	        kill $pid

	        echo -ne "Stoping Nodeos"

	        while true; do
	            [ ! -d "/proc/$pid/fd" ] && break
	            echo -ne "."
	            sleep 1
	        done
	        rm -r $DIR"/nodeos.pid"

	        DATE=$(date -d "now" +'%Y_%m_%d-%H_%M')
	        if [ ! -d $DIR/logs ]; then
	            mkdir $DIR/logs
	        fi
	        tar -pcvzf $DIR/logs/stderr-$DATE.txt.tar.gz stderr.txt stdout.txt


	        echo -ne "\rNodeos stopped. \n"

	    fi
	    ' >>  $MAINNET_DIR/stop.sh
	    chmod u+x $MAINNET_DIR/stop.sh


	    # Creating cleos.sh 
	    echo "..:: Creating cleos.sh ::..";
	    echo "#!/bin/bash" > $MAINNET_DIR/cleos.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/cleos.sh
	    echo "CLEOS=$MAINNET_BIN_DIR/cleos" >> $MAINNET_DIR/cleos.sh
	    echo -ne "\n"
	    if [[ $NODE_SSL_PORT != "" ]]; then
		echo "\$CLEOS -u https://127.0.0.1:$NODE_SSL_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $MAINNET_DIR/cleos.sh
		echo "#\$CLEOS -u http://127.0.0.1:$NODE_API_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $MAINNET_DIR/cleos.sh
	    else
		echo "\$CLEOS -u http://127.0.0.1:$NODE_API_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $MAINNET_DIR/cleos.sh
		echo "#\$CLEOS -u https://127.0.0.1:$NODE_SSL_PORT --wallet-url http://127.0.0.1:$WALLET_PORT \"\$@\"" >> $MAINNET_DIR/cleos.sh


	    fi
	    # if [[ -x $MAINNET/cleos.sh ]]
	    # then
	    # 	echo "try to chmod cleos sh"
	    # else
	    # 	echo "in else block"
	    chmod u+x $MAINNET_DIR/cleos.sh
	    # fi


	    # genesis.json

	    echo -ne "$GENESIS" > $MAINNET_DIR/genesis.json


	# config.ini 
	    echo -ne "\n\n..:: Creating config.ini ::..\n\n";
	    if [[ $ISBP == true ]]
	    then
		    if [[ $PRODUCER_PRIV_KEY -eq "" ]]; then 
			echo -n $'\E[0;33m'
			echo "!!! PRIV KEY SECTION !!! You can enter your private key here and it will be imported in wallet and inserted in config.ini. I can skip this step (Enter) and do it manually before start"
			echo -ne "PRIV KEY (Enter skip):"
			read PRODUCER_PRIV_KEY
			echo -n $'\E[0;37m'
		    fi
		fi


	    if [[ $PRODUCER_PRIV_KEY == "" ]]; then 
		PRODUCER_PRIV_KEY=$PRODUCER_PRIV_KEY_DEF
	    else 
		if [[ ! -f $WALLET_DIR/default.wallet ]]; then

	    	    WALLET_LOG=$( $MAINNET_DIR/cleos.sh wallet create --to-console)


	    	    WALLET_PASS=$(echo $WALLET_LOG | awk -F\" '{ print $2 }')


	    	    # walletUnlock
	    	    FILENAME="$MAINNET_DIR/unlock.sh"
	    	    echo '..:: Creating WalletUnlock.sh ::..'

	    	    echo "#!/bin/bash" > $FILENAME
	    	    echo "./cleos.sh wallet unlock --password $WALLET_PASS" >> $FILENAME
	    	    chmod u+x $FILENAME

		    echo "$WALLET_LOG" > $WALLET_DIR/wallet_pass.txt


		fi

		# $MAINNET_DIR/cleos.sh wallet import --private-key $PRODUCER_PRIV_KEY	
	    fi


	    echo "#EOS MainNet Config file. Autogenerated by human task." > $MAINNET_DIR/config.ini
	    echo '
	    #genesis-json = "'$MAINNET_DIR'/genesis.json"
	    blocks-dir = "'$MAINNET_DIR'/blocks"

	    http-server-address = '$NODE_HTTP_SRV_ADDR'
	    p2p-listen-endpoint = '$NODE_P2P_LST_ENDP'
	    p2p-server-address = '$NODE_P2P_SRV_ADDR'
	    access-control-allow-origin = *

	    http-validate-host = false
	    verbose-http-errors = true
	    abi-serializer-max-time-ms = 2000
	    wasm-runtime = wabt

	  ' >> $MAINNET_DIR/config.ini

	    if [[ $NODE_HTTPS_SERVER_ADDR != "" ]]; then
	    echo '
	    # SSL
	    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
	    https-server-address = '$NODE_HTTPS_SERVER_ADDR'
	    # Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
	    https-certificate-chain-file = /path/to/certificate-chain
	    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
	    https-private-key-file = /path/to/certificate-key

	    ' >> $MAINNET_DIR/config.ini
	    else
	    echo '
	    # SSL
	    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
	    # https-server-address =
	    # Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
	    # https-certificate-chain-file =
	    # Filename with https private key in PEM format. Required for https (eosio::http_plugin)
	    # https-private-key-file =

	    ' >> $MAINNET_DIR/config.ini

	    fi


	    echo '
	    allowed-connection = any

	    p2p-max-nodes-per-host = 150

	    max-clients = 120
	    connection-cleanup-period = 30
	    network-version-match = 0
	    sync-fetch-span = 2000
	    enable-stale-production = false

	    chain-state-db-size-mb = 16384
		#chain-state-db-size-mb = 65536
	    reversible-blocks-db-size-mb = 1048
		#reversible-blocks-db-size-mb = 2048
	    contracts-console = false
	    
    	chain-state-db-guard-size-mb = 128 
    	reversible-blocks-db-guard-size-mb = 2

		#ver > 1.5.0
		chain-threads = 4

	    mongodb-queue-size = 256
	    # mongodb-uri =

	    # peer-key =
	    # peer-private-key =

        #actor-whitelist = '$ACCOUNT_NAME'
        #filter-on = '$ACCOUNT_NAME':transfer:

	    plugin = eosio::producer_plugin
	    plugin = eosio::chain_api_plugin
	    plugin = eosio::history_plugin
	    plugin = eosio::history_api_plugin
	    plugin = eosio::chain_plugin

	    #plugin = net_plugin
	    #plugin = net_api_plugin

	    agent-name = '$PRODUCER_AGENT_NAME'

	    ' >> $MAINNET_DIR/config.ini

	    if [[ $ISBP == true ]]; then
	    echo '
	    plugin = eosio::producer_plugin

	    signature-provider = '$PRODUCER_PUB_KEY'=KEY:'$PRODUCER_PRIV_KEY'
	    producer-name = '$PRODUSER_NAME'
	    ' >> $MAINNET_DIR/config.ini
	    else 
	    echo '
	    #plugin = eosio::producer_plugin
	    #private-key = ["'$PRODUCER_PUB_KEY'","'$PRODUCER_PRIV_KEY'"]
	    #producer-name = '$PRODUSER_NAME'
	    ' >> $MAINNET_DIR/config.ini

	    fi

	    echo "$PEER_LIST" >> $MAINNET_DIR/config.ini

		echo '
actor-blacklist = blacklistmee

#https://eoscorearbitration.io/wp-content/uploads/2018/07/ECAF_Arbitrator_Order_2018-06-19-AO-001.pdf
actor-blacklist = ge2dmmrqgene
actor-blacklist = gu2timbsguge
actor-blacklist = ge4tsmzvgege
actor-blacklist = gezdonzygage
actor-blacklist = ha4tkobrgqge
actor-blacklist = ha4tamjtguge
actor-blacklist = gq4dkmzzhege

#https://eoscorearbitration.io/wp-content/uploads/2018/07/ECAF_Arbitrator_Order_2018-06-22-AO-002.pdf
actor-blacklist = gu2teobyg4ge
actor-blacklist = gq4demryhage
actor-blacklist = q4dfv32fxfkx
actor-blacklist = ktl2qk5h4bor
actor-blacklist = haydqnbtgene
actor-blacklist = g44dsojygyge
actor-blacklist = guzdonzugmge
actor-blacklist = ha4doojzgyge
actor-blacklist = gu4damztgyge
actor-blacklist = haytanjtgige
actor-blacklist = exchangegdax
actor-blacklist = cmod44jlp14k
actor-blacklist = 2fxfvlvkil4e
actor-blacklist = yxbdknr3hcxt
actor-blacklist = yqjltendhyjp
actor-blacklist = pm241porzybu
actor-blacklist = xkc2gnxfiswe
actor-blacklist = ic433gs42nky
actor-blacklist = fueaji11lhzg
actor-blacklist = w1ewnn4xufob
actor-blacklist = ugunxsrux2a3
actor-blacklist = gz3q24tq3r21
actor-blacklist = u5rlltjtjoeo
actor-blacklist = k5thoceysinj
actor-blacklist = ebhck31fnxbi
actor-blacklist = pvxbvdkces1x
actor-blacklist = oucjrjjvkrom

#https://eoscorearbitration.io/wp-content/uploads/2018/07/ECAF-Temporary-Freeze-Order-2018-07-13-AO-003.pdf
actor-blacklist = neverlandwal
actor-blacklist = tseol5n52kmo
actor-blacklist = potus1111111

#https://eoscorearbitration.io/wp-content/uploads/2018/07/ECAF-Order-of-Emergency-Protection-2018-07-19-AO-004.pdf
actor-blacklist = craigspys211

#https://eoscorearbitration.io/wp-content/uploads/2018/08/ECAF-Order-of-Emergency-Protection-2018-08-07-AO-005.pdf
actor-blacklist = eosfomoplay1

#https://eoscorearbitration.io/wp-content/uploads/2018/08/ECAF-Order-of-Emergency-Protection-2018-08-28-AO-006.pdf
actor-blacklist = wangfuhuahua

#https://eoscorearbitration.io/wp-content/uploads/2018/09/ECAF-Order-of-Emergency-Protection-2018-09-07-AO-008.pdf
#https://eoscorearbitration.io/wp-content/uploads/2018/09/ECAF-Order-of-Emergency-Protection-2018-09-24-AO-010.pdf
#actor-blacklist = ha4timrzguge
actor-blacklist = guytqmbuhege

#https://eoscorearbitration.io/wp-content/uploads/2018/09/ECAF-Order-of-Emergency-Protection-2018-09-09-AO-009.pdf
actor-blacklist = huobldeposit

#https://eoscorearbitration.io/wp-content/uploads/2018/09/ECAF-Order-of-Emergency-Protection-2018-09-25-AO-011.pdf
actor-blacklist = gm3dcnqgenes
actor-blacklist = gm34qnqrepqt
actor-blacklist = gt3ftnqrrpqp
actor-blacklist = gtwvtqptrpqp
actor-blacklist = gm31qndrspqr
actor-blacklist = lxl2atucpyos

#https://eoscorearbitration.io/wp-content/uploads/2018/10/ECAF-Order-of-Emergency-Protection-2018-10-05-AO-012.pdf
actor-blacklist = g4ytenbxgqge
actor-blacklist = jinwen121212
actor-blacklist = ha4tomztgage
actor-blacklist = my1steosobag
actor-blacklist = iloveyouplay
actor-blacklist = eoschinaeos2
actor-blacklist = eosholderkev
actor-blacklist = dreams12true
actor-blacklist = imarichman55

#https://eoscorearbitration.io/wp-content/uploads/2018/10/ECAF-Order-of-Emergency-Protection-2018-10-05-AO-013.pdf
actor-blacklist = gizdcnjyg4ge

#https://eoscorearbitration.io/wp-content/uploads/2018/10/ECAF-Order-of-Emergency-Protection-2018-10-12-AO-014.pdf
actor-blacklist = gyzdmmjsgige

#https://eoscorearbitration.io/wp-content/uploads/2018/10/ECAF-Order-of-Emergency-Protection-2018-10-13-AO-015.pdf
actor-blacklist = guzdanrugene
actor-blacklist = earthsop1sys

#https://eoscorearbitration.io/wp-content/uploads/2018/10/ECAF-Order-of-Emergency-Protection-2018-10-31-AO-017.pdf
actor-blacklist = refundwallet
actor-blacklist = jhonnywalker
actor-blacklist = alibabaioeos
actor-blacklist = whitegroupes
actor-blacklist = 24cryptoshop
actor-blacklist = minedtradeos

' >> $MAINNET_DIR/config.ini


	

	###############################
	# Register Producer

	    echo '..:: Creating your registerProducer.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp01_registerProducer.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp01_registerProducer.sh
	    echo "./cleos.sh system regproducer $PRODUSER_NAME $PRODUCER_PUB_KEY \"$PRODUCER_URL\" -p $PRODUSER_NAME" >> $MAINNET_DIR/bp01_registerProducer.sh
	    chmod u+x $MAINNET_DIR/bp01_registerProducer.sh

	# UnRegister Producer

	    echo '..:: Creating your unRegisterProducer.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp06_unRegisterProducer.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp06_unRegisterProducer.sh
	    echo "./cleos.sh system unregprod $PRODUSER_NAME -p $PRODUSER_NAME" >> $MAINNET_DIR/bp06_unRegisterProducer.sh
	    chmod u+x $MAINNET_DIR/bp06_unRegisterProducer.sh


	# Stake Coins
	    echo '..:: Creating Stake script  stakeTokens.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp02_stakeTokens.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp02_stakeTokens.sh
	    echo "./cleos.sh system delegatebw $PRODUSER_NAME $PRODUSER_NAME \"40.0000 EOS\" \"40.0000 EOS\" -p $PRODUSER_NAME" >> $MAINNET_DIR/bp02_stakeTokens.sh
	    echo "#./cleos.sh push action eosio delegatebw '{\"from\":\"$PRODUSER_NAME\", \"receiver\":\"$PRODUSER_NAME\", \"stake_net_quantity\": \"1000.0000 EOS\", \"stake_cpu_quantity\": \"1000.0000 EOS\", \"transfer\": true}' -p $PRODUSER_NAME" >> $MAINNET_DIR/bp02_stakeTokens.sh
	    
	    chmod u+x $MAINNET_DIR/bp02_stakeTokens.sh

	# Unstake Coins
	    echo '..:: Creating UnStake script  unStakeTokens.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp05_unStakeTokens.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp05_unStakeTokens.sh
	    echo "./cleos.sh system undelegatebw $PRODUSER_NAME $PRODUSER_NAME \"40.0000 EOS\" \"40.0000 EOS\" -p $PRODUSER_NAME" >> $MAINNET_DIR/bp05_unStakeTokens.sh
	    chmod u+x $MAINNET_DIR/bp05_unStakeTokens.sh


	# Vote Producer
	    echo '..:: Creating Vote script  voteProducer.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp03_voteProducer.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp03_voteProducer.sh
	    echo "./cleos.sh system voteproducer prods $PRODUSER_NAME $PRODUSER_NAME -p $PRODUSER_NAME" >> $MAINNET_DIR/bp03_voteProducer.sh
	    echo "#./cleos.sh system voteproducer prods $PRODUSER_NAME $PRODUSER_NAME tiger lion -p $PRODUSER_NAME" >> $MAINNET_DIR/bp03_voteProducer.sh
	    chmod u+x $MAINNET_DIR/bp03_voteProducer.sh

	# Claim rewrds
	    echo '..:: Creating ClaimReward script claimReward.sh ::..'

	    echo "#!/bin/bash" > $MAINNET_DIR/bp04_claimReward.sh
	    echo -ne "################################################################################\n#\n# Script Created by http://github.com/cyberluke\n# For EOS MainNet\n#\n# ################################################################################\n\n" >> $MAINNET_DIR/bp04_claimReward.sh
	    echo "./cleos.sh system claimrewards $PRODUSER_NAME -p $PRODUSER_NAME" >> $MAINNET_DIR/bp04_claimReward.sh
	    chmod u+x $MAINNET_DIR/bp04_claimReward.sh


	# FINISH
##ASCI
	    FINISHTEXT="\n.=================================================================================.\n"
	    FINISHTEXT+="|=================================================================================|\n"
	    FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙...::: INSTALLATION COMPLETED :::...˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
	    FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
	    FINISHTEXT+="|˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙˙|\n"
	    FINISHTEXT+="\_-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-_/\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+="Wallet key was stroed in file wallet_pass.txt. Please use it to unlock you wallet:\n"
	    FINISHTEXT+="./cleos.sh wallet unlock\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+="All scripts to manage you node are located in $MAINNET_DIR folder:\n"
	    FINISHTEXT+="  start.sh - start your node. If you inserted your private key, then everything is ready and the install script will start nodeos and keosd for you automatically, then, please wait until it's synced.\n"
	    FINISHTEXT+="  stop.sh - stop your node\n"
	    FINISHTEXT+="  bp01_registerProducer.sh - register producer. Use it to register in the system contract.\n"
	    FINISHTEXT+="  bp02_stakeTokens.sh - stake tokens. Use it to stake tokens before voting.\n"
	    FINISHTEXT+="  bp03_voteProducer.sh - vote example. Vote only for you. You can add producer manually in script or using monitor interface. \n"
	    FINISHTEXT+="  bp05_unStakeTokens.sh - unstake tokens.\n"
	    FINISHTEXT+="  bp06_unRegisterProducer.sh - unregister producer.\n"
	    FINISHTEXT+="  stderr.txt - node logs file\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+="To stop/start wallet use start/stop.sh scripts in wallet folder. This installation script starts wallet by default.\n"
	    FINISHTEXT+="\n"
	    # FINISHTEXT+="Installation Script disabled. To run again please chmod:\n"
	    # FINISHTEXT+="chmod u+x $0\n"
	    FINISHTEXT+="\n"
	    FINISHTEXT+=". - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
	    FINISHTEXT+="| https://github.com/cyberluke\n"

	    echo -n $'\E[0;32m'
	    echo -ne $FINISHTEXT
	    echo -ne $FINISHTEXT >> $GLOBAL_PATH/Main.txt

	    echo ""
	    echo "This info was saved to Main.txt file"
	    echo ""
	    printf "\n"
	    read -n 1 -s -r -p "Press any key to continue"
	    echo -n $'\E[0;33m'

    #chmod 644 $0

    echo ""
    read -n 1 -s -r -p "Press any key to continue"
    printf "\n"

}
######################################################
#END CONFIG SECTION
######################################################

######################################################
##Source Section
######################################################
create_symlink_path(){
	if [[ -d "/usr/local/eosio/bin" ]]
	then
		if [[ ! -L "$MAINNET_BIN_DIR" ]]
		then
			ln -s /usr/local/eosio/bin $GLOBAL_PATH/bin
			
		elif [[ -L "$MAINNET_BIN_DIR" ]] 
			then
				unlink $MAINNET_BIN_DIR
				ln -s /usr/local/eosio/bin $GLOBAL_PATH/bin
		fi
	elif [[ -d "/usr/opt/eosio" ]]
	then
		if [[ ! -L "$MAINNET_BIN_DIR" ]]
		then
			ln -s /usr/opt/eosio/$EOS_VER/bin $GLOBAL_PATH/bin
			
		elif [[ -L "$MAINNET_BIN_DIR" ]] 
			then
				unlink $MAINNET_BIN_DIR
				ln -s /usr/opt/eosio/$EOS_VER/bin $GLOBAL_PATH/bin

		fi
	fi

}

install_from_source(){
	printf "Installing\n"
	if [[ $EOS_SOURCE_DIR == "" ]]
	then
		EOS_SOURCE_DIR="$GLOBAL_PATH/eos-source"
	fi

	if [[ ! -d $EOS_SOURCE_DIR ]]
	then
    	echo "..:: Downloading EOS Sources ::..";     
    	mkdir $EOS_SOURCE_DIR
    	cd $EOS_SOURCE_DIR
    
    	git clone https://github.com/EOS-Mainnet/eos --recursive .
  		git checkout $TAG
    	git submodule update --init --recursive
    	./eosio_build.sh -s EOS
    	./eosio_install.sh

    else
    	cd $EOS_SOURCE_DIR
    
    	git clone https://github.com/EOS-Mainnet/eos --recursive .
		git checkout $TAG
    	git submodule update --init --recursive
    	./eosio_build.sh -s EOS
    	./eosio_install.sh
    fi
    if [[ -d "/usr/local/eosio" ]]
    then
    	create_symlink_path
    	config_func
    else
    	printf "033[0;31EOSIO not installed\033[m\n"
    	exit -1
    fi
	
}

update_from_source(){
	if [[ $EOS_SOURCE_DIR == "" ]]
	then
		EOS_SOURCE_DIR="$GLOBAL_PATH/eos-source"
	fi
	if [[ ! -d $EOS_SOURCE_DIR ]]
	then
		printf "Enter full path to EOSIO dir Sources\n"
		read EOS_SOURCE_DIR
	fi
	cd $EOS_SOURCE_DIR
	git checkout -f
	git branch -f
	git pull
	git checkout $TAG
	git submodule update --init --recursive
	./eosio_build.sh -s EOS
	./eosio_install.sh
	create_symlink_path
	printf "DONE\n"
}

##################################################################
#BINARY SECTION
##################################################################

remove_eosio(){
	echo "Star removing"
	if [[ $OS == "ubuntu" ]]
	then
		if [[ -n $(apt-cache search eosio) ]]
		then
			apt -y remove eosio
			if [[ -d "/usr/opt/eosio" ]]
			then
				find /usr/opt -type d -name eosio -exec rm -rf {} \;
			fi
			printf "\n"
		fi
	elif [[ $OS == "centos" ]] || [[ $OS == "fedora" ]]
	then
		yum -y remove eosio
		if [[ -d "/usr/opt/eosio" ]]
		then
			find /usr/opt -type d -name eosio -exec rm -rf {} \;
		fi
		printf "\n"
	fi
	printf "removed, status %s\n " "$?"
}

remove_locall_install_eosio(){
	#############################
	#CODE FROM EOSIO Uninstall script
	###############################
	binaries=(cleos
          eosio-abigen
          eosio-launcher
        	  eosio-s2wasm
          eosio-wast2wasm
          eosiocpp
          keosd
          nodeos)
	if [ "$(id -u)" -ne 0 ]; then
		printf "\n\tThis requires sudo, please run ./eosio_uninstall.sh with sudo\n\n"
		exit -1
	fi
	pushd /usr/local &> /dev/null
	rm -rf eosio
	pushd bin &> /dev/null
	for binary in ${binaries[@]}; do
		rm ${binary}
	done
	# Handle cleanup of directories created from installation
	if [ "$1" == "--full" ]; then
	    if [ -d ~/Library/Application\ Support/eosio ]; then rm -rf ~/Library/Application\ Support/eosio; fi # Mac OS
	    if [ -d ~/.local/share/eosio ]; then rm -rf ~/.local/share/eosio; fi # Linux
	fi
	popd &> /dev/null

}

update_eosio(){
	if [[ $OS == "ubuntu" ]]
	then
		if [[ $OS_VER == "16.04" ]]
		then
			$GET_COMM $EOSIO_DEB16
		    dpkg -i ./eosio*${EOS_VER}*.deb
			rm eosio*${EOS_VER}*.deb
		elif [[ $OS_VER == "18.04" ]]
		then
			$GET_COMM $EOSIO_DEB18
		    dpkg -i ./eosio*${EOS_VER}*.deb
			rm eosio*${EOS_VER}*.deb
			#statements
		fi
	elif [[ $OS == "centos" ]] 
	then
		$GET_COMM $EOSIO_CENTOS7
		#rpm -Uvh ./eosio*${EOS_VER}*.rpm --nodeps
		yum -y update ./eosio*${EOS_VER}*.rpm
		rm ./eosio*${EOS_VER}*.rpm
	elif [[ $OS == "fedora" ]]
	then
		$GET_COMM $EOSIO_FEDORA27
		#rpm -Uvh ./eosio*${EOS_VER}*.rpm --nodeps
		yum -y update ./eosio*${EOS_VER}*.rpm
		rm ./eosio*${EOS_VER}*.rpm
	fi
	
	if [ $? -gt 0 ]
	then
		printf "\033[0;31mUpdate unsuccessfully\n\033[m"
		exit -1
	else
		create_symlink_path
		printf "\033[0;32mUpdated successfully\n\033[m"
	fi

}

install_deb(){

if [[ $OS_VER == "16.04" ]]
then
	$GET_COMM $EOSIO_DEB16 
	apt -y update && dpkg -i ./eosio*${EOS_VER}*.deb 2>/dev/null
	apt -y install -f 	
	if [[ -n $(apt-cache search eosio) ]]
	then
		printf "\033[0;32m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "Installed EOSIO %s\n" "$(apt-cache show eosio | grep -i "version")"
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		rm ./eosio*${EOS_VER}*.deb
		create_symlink_path
		config_func
	else
		printf "\033[0;31m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "EOSIO not installed\n"
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		exit -1
	fi  
	
elif [[ $OS_VER == "18.04" ]]
then
	$GET_COMM $EOSIO_DEB18
	apt -y update && dpkg -i ./eosio*${EOS_VER}*.deb 2>/dev/null
	apt -y install -f 
	if [[ -n $(apt-cache search eosio) ]]
	then
		printf "\033[0;32m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "Installed EOSIO %s\n" "$(apt-cache show eosio | grep -i "version")"
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		rm ./eosio*${EOS_VER}*.deb &>/dev/null
		create_symlink_path
		config_func
	else
		printf "\033[0;31m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "EOSIO not installed\n"
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		exit -1
	fi
fi


}

install_rpm(){
	if [[ $OS == "centos" ]]
	then
		$GET_COMM $EOSIO_CENTOS7
		#rpm -ivh ./eosio*${EOS_VER}*.rpm --nodeps
		yum -y install ./eosio*${EOS_VER}*.rpm
	elif [[ $OS == "fedora" ]]
	then
		$GET_COMM $EOSIO_FEDORA27
		#rpm -ivh ./eosio*${EOS_VER}*.rpm --nodeps
		yum -y install ./eosio*${EOS_VER}*.rpm
	fi

	if [[ -n $(rpm -qa | grep eosio) ]]
	then
		clear
		printf "\033[0;32m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "Installed EOSIO  %s\n" "$(yum info eosio | grep -i "version")"
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		rm eosio*${EOS_VER}*.rpm &>/dev/null
		create_symlink_path
		config_func
	else
		printf "\033[0;31m:::::::::::::::::::::::::::::::::::::::::::::::\n"
		printf "\n"
		printf "EOSIO not installed\n" 
		printf ":::::::::::::::::::::::::::::::::::::::::::::::\033[0m\n"
		printf "\n"
		exit -1
	fi

}

search_previous_version(){
	printf "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n"
	printf "\n"
	######################################################################################################################################################
	#echo -n $'\E[0;32m'

######################################################################################################################################################
	logo
	printf "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n"
	if [[ -d "/usr/opt/eosio" ]]
	then
		printf  "\033[0mEOSIO binary installation\t\t  [\033[0;32m Found \033[m]\n"
		if [[ $OS == "ubuntu" ]]
		then
			if [[ $(apt-cache show eosio | grep -i "version" | grep -o '[0-9]\.[0-9]\.[0-9]') != $EOS_VER ]]
			then
				printf  "Installed EOSIO\t\t\t\t  [\033[0;32m %s  \033[m]\t[\033[0;31m  New update %s  \033[m]\n" "$(apt-cache show eosio | grep -i "version")" "$TAG"
			else
				printf  "Installed EOSIO\t\t\t\t  [\033[0;32m %s  \033[m]\t[\033[0;32m  Latest \033[m]\n" "$(apt-cache show eosio | grep -i "version")"
			fi
		elif [[ $OS == "centos" ]] || [[ $OS == "fedora" ]]
		then
			if [[ $(yum info eosio | grep -i "version" | grep -o '[0-9]\.[0-9]\.[0-9]') != $EOS_VER ]]
			then
				printf "Installed EOSIO\t\t\t\t  [\033[0;32m %s  \033[m]\t[\033[0;31m New update %s  \033[m]\n" "$(yum info eosio | grep -i "version")" "$TAG"
			else
				printf "Installed EOSIO\t\t\t\t  [\033[0;32m %s  \033[m]\t[\033[0;32m Latest \033[m]\n" "$(yum info eosio | grep -i "version")"
			fi
		fi
		printf "\n"
		# if [[ -n $(curl -sS https://monitor.jungletestnet.io/version.json | jq '.ubuntu18_bin' | tr -d '"') ]]
		# then 
		# 	printf "Unfortunately, there are no binary files yet. Upgrade possible only from source code.\n"
		# 	printf "But in your case you have binary installation, please try run update later\n"
		# 	exit 1
		# fi
		select answer in "Update EOSIO" "Install MainNet Node" "Uninstall EOSIO" "Exit" ; do
		case $answer in
			"Update EOSIO")
				update_eosio
				printf "\n"
				main
				;;
			"Install MainNet Node")
				create_symlink_path
				config_func
				break
				;;
			"Uninstall EOSIO")
				remove_eosio
				main
				break
				;;
			"Exit")
				exit 1
				;;
			esac
		done
	elif [[ -d "/usr/local/eosio" ]]
	then
		echo -e  "\033[mEOSIO source installation  \t\t  [\033[0;32m Found \033[m]"
		if [[ $(/usr/local/eosio/bin/nodeos -v) != $TAG ]]
		then
			printf "Installed EOSIO\t\t\t\t  [\033[0;32m Version: %s  \033[m]\t[\033[0;31m New update %s  \033[m]\n" "$(/usr/local/eosio/bin/nodeos -v)" "$TAG"
		else
			printf "Installed EOSIO\t\t\t\t  [\033[0;32m Version: %s  \033[m]\t[\033[0;32m Latest \033[m]\n" "$(/usr/local/eosio/bin/nodeos -v)"
		fi
		####################################
		#part from eosio uninstaller script 
		# https://github.com/EOSIO/eos/blob/master/eosio_uninstall.sh
		####################################
		if [ -d "/usr/local/eosio" ]; then
			   printf "\n"
			   select yn in "Update EOSIO" "Install MainNet Node" "Uninstall EOSIO" "Exit"; do
			      case $yn in
			         "Update EOSIO" )
						 remove_locall_install_eosio
						 update_from_source
						 #create_symlink_path
						 ;;
					 "Install MainNet Node")
						create_symlink_path
						config_func
						break
						;;
			         "Uninstall EOSIO" )
			            remove_locall_install_eosio
			            main
			            ;;
			         [Exit]* )
			            exit 1
			            ;;
			      esac
			   done
			fi
		else
			echo -e  "\033[0mEOSIO installation  \t\t  [\033[0;31m Not Found \033[m]"
				printf "Please choose instalation type of EOSIO \n"
				printf "\n"
				select answer in "Binary EOSIO" "Source EOSIO" "Exit"; do
				case $answer in
					"Binary EOSIO")
							if [[ $OS == "ubuntu" ]]
							then
								install_deb
								
							elif [[ $OS == "centos" ]] || [[ $OS == "fedora" ]]
							then
								#printf "there are no binaries file, you needinstall from source"
								install_rpm
							fi
							break
							;;
					"Source EOSIO")
							#install_tools
							install_from_source
							break
							;;
						"Exit")
							exit 1
							;;
				esac
			done
		
	fi
}

sync_method(){
	printf "\n"
	printf "Please choose a way to sync your node with Main Net :\n"
	printf "HINT: Rerun this script using screen -S command!\n"
	select choose in "Classic syncronisation" "Using EOS Node Tools (by BlockMatrix) snapshot (Ubuntu/Centos/Debian only)" "Exit"; do
	case $choose in
		"Classic syncronisation")
			cd $MAINNET_DIR
			./start.sh --delete-all-blocks --genesis-json genesis.json
			printf "Go to $MAINNET and check file stderr.txt if everything ok\n"
			printf "Check block status with: cleos get info\n"
			break
			;;
		"Using EOS Node Tools (by BlockMatrix) snapshot (Ubuntu/Centos/Debian only)")
			printf "\n"
            
			if [[ ! -d $SNAPSHOT_DIR ]]
			then
				mkdir $SNAPSHOT_DIR
			fi
			
			if [[ $OS == "centos" || $OS == "fedora" || $OS == "ubuntu" ]]
			then
				cd $MAINNET_DIR
				sudo rm -rf blocks state
				cd $SNAPSHOT_DIR
				wget $(wget --quiet "https://eosnode.tools/api/blocks?limit=1" -O- | jq -r '.data[0].s3') -O blocks_backup.tar.gz
				tar xvzf blocks_backup.tar.gz -C $MAINNET_DIR/
				cd $MAINNET_DIR
				./start.sh --hard-replay --wasm-runtime wabt
				printf "Go to $MAINNET and check file stderr.txt is synchronization started?\n"
			else
				printf "We do not support snapshot for your OS %s" "$OS"
				sync_method
			fi
			break
			;;
		"Exit" )
			printf "Exit\n"
			exit 1
			;;
		esac
	done 
}

#######################################################

#####################################################
#MAIN 
#####################################################
main(){
if [[ $OS == "ubuntu" ]]
then
	clear
	search_previous_version
	
elif [[ $OS == "centos" ]] || [[ $OS == "fedora" ]]
then
	clear
	search_previous_version
fi
 
}
#####################################################
#END MAIN 
#####################################################


main

sync_method
