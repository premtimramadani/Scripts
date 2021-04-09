#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'


case $1 in
	-help)
		echo -e "${YELLOW}Usage of the program"
		echo "====================="
		echo "option: -add (to add a new publisher to the database)"
		echo "brandprotection -add <apk file name> <additional information without spaces>"
		echo "==============================================================================="
		echo "option: -checkcert (to check if the unverified app is published by someone trusted)"
		echo "brandprotection -checkCert <apk file name>"
		echo "==============================================================================="
		echo "option: -printcert (to print the certificate of an application)"
		echo "brandprotection -printCert <apk file name>"
		echo "==============================================================================="
                echo "option: -checkHash (to check if the hash of the application matches)"
                echo "brandprotection -checkHash <apk file name>"
		echo -e "===============================================================================${NC}"
		;;
	-checkCert)
		if [ ! -d "$2" ]
		then
			sha256=$(unzip -p $2 META-INF/*.RSA | keytool -printcert  | grep SHA256 | sed -n 1p | cut -d " " -f 3)

	        	infile=$(grep "$sha256" ~/BrandProtection/database.txt | cut -d "=" -f 3)

        		if [ -z "$infile" ]
	        	then
        	        	echo -e "${RED}[-]Not in our database"
	                	echo -e "======================${NC}"
		        else
        		        echo -e "${GREEN}[+]In our database:"
                		echo "======================"
		                echo $infile | tr " " "\n"
        		        echo -e "======================${NC}"
			fi
		else
			ls $2 > content.txt
			input="~/BrandProtection/content.txt"
			while IFS= read -r line
			do
				sha256=$(unzip -p "$2/$line" META-INF/*.RSA | keytool -printcert  | grep SHA256 | sed -n 1p | cut -d " " -f 3)
				infile=$(grep "$sha256" ~/BrandProtection/database.txt | cut -d "=" -f 3)
				if [ -z "$infile" ]
	                        then
        	                        echo -e "${RED}[-]$line-------Not in our database"
                	                echo -e "===================================================================================${NC}"
                        	else
                                	echo -e "${GREEN}[+]$line--------In our database:"
	                                echo "==================================================================================="
        	                        echo $infile | tr " " "\n"
                	                echo -e "===================================================================================${NC}"
				fi
			done < "content.txt"
		fi
		;;
	-add)
		sha256=$(unzip -p $2 META-INF/*.RSA | keytool -printcert  | grep SHA256 | sed -n 1p | cut -d " " -f 3)
		echo "$sha256==$3" >> ~/BrandProtection/database.txt
		;;
	-printCert)
                cert=$(unzip -p $2 META-INF/*.RSA | keytool -printcert)
		echo -e "${GREEN}$cert${NC}"
		;;
	-checkHash)
		sha256=$(sha256sum $2 | cut -d " " -f 1)
		infile=$(grep "$sha256" ~/BrandProtection/database.txt | cut -d "=" -f 5)
		if [ -z "$infile" ]
		then
			echo -e "${RED}[-]Hash is not in our database"
			echo -e "===================================================================================${NC}"
		else
			echo -e "${GREEN}[+]Hash matches with our database"
			echo -e "===================================================================================${NC}"
		fi
		;;
	*)
		echo -e "${YELLOW}[?]For help type: brandprotection -help${NC}"
		;;
esac
