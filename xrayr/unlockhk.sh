wget -O /etc/XrayR/custom_outbound.json https://raw.githubusercontent.com/Lairdkin/cdn/main/xrayr/custom_outbound.json
wget -O /etc/XrayR/route.json https://raw.githubusercontent.com/Lairdkin/cdn/main/xrayr/route.json
sed -i 's/RouteConfigPath:\s#/RouteConfigPath:/' /etc/XrayR/config.yml
sed -i 's/OutboundConfigPath:\s#/OutboundConfigPath:/' /etc/XrayR/config.yml
/usr/bin/XrayR restart
echo -e "\033[32mHK区域解锁完成 \033[0m" 
