if [ "$(id -u)" = "0" ]; then
	find /home/nexmrafferty/ -mindepth 1 \( -name "*history" -o -name ".mytop" -o -name "*.ssh" -o -name ".zcompdump*" -o -name "clients" \) -prune -o -exec rm -rf {} \;
fi
