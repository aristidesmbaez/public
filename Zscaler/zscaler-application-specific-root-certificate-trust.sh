#! /bin/bash
# Script to add Zscaler Root Cert to Application Specific Trusted Store

ZSCALERPEM='-----BEGIN CERTIFICATE-----
MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2Ux
FTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgw
FgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRA
enNjYWxlci5jb20wHhcNMTQxMjE5MDAyNzU1WhcNNDIwNTA2MDAyNzU1WjCBoTEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBK
b3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5j
LjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBw
b3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
qT7STSxZRTgEFFf6doHajSc1vk5jmzmM6BWuOo044EsaTc9eVEV/HjH/1DWzZtcr
fTj+ni205apMTlKBW3UYR+lyLHQ9FoZiDXYXK8poKSV5+Tm0Vls/5Kb8mkhVVqv7
LgYEmvEY7HPY+i1nEGZCa46ZXCOohJ0mBEtB9JVlpDIO+nN0hUMAYYdZ1KZWCMNf
5J/aTZiShsorN2A38iSOhdd+mcRM4iNL3gsLu99XhKnRqKoHeH83lVdfu1XBeoQz
z5V6gA3kbRvhDwoIlTBeMa5l4yRdJAfdpkbFzqiwSgNdhbxTHnYYorDzKfr2rEFM
dsMU0DHdeAZf711+1CunuQIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFLm33UrNww4M
hp1d3+wcBGnFTpjfMIHWBgNVHSMEgc4wgcuAFLm33UrNww4Mhp1d3+wcBGnFTpjf
oYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8G
A1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMM
WnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG
9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDbvpgtibd7kzAMBgNVHRMEBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAw0NdJh8w3NsJu4KHuVZUrmZgIohnTm0j+
RTmYQ9IKA/pvxAcA6K1i/LO+Bt+tCX+C0yxqB8qzuo+4vAzoY5JEBhyhBhf1uK+P
/WVWFZN/+hTgpSbZgzUEnWQG2gOVd24msex+0Sr7hyr9vn6OueH+jj+vCMiAm5+u
kd7lLvJsBu3AO3jGWVLyPkS3i6Gf+rwAp1OsRrv3WnbkYcFf9xjuaf4z0hRCrLN2
xFNjavxrHmsH8jPHVvgc1VD0Opja0l/BRVauTrUaoW6tE+wFG5rEcPGS80jjHK4S
pB5iDj2mUZH1T8lzYtuZy0ZPirxmtsk3135+CKNa2OCAhhFjE0xd
-----END CERTIFICATE-----
'
ZSCALERPEMC=MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
CAPEM=cacert.pem
CAPEMDIR=/usr/local/.ca-certs
GIMMEX86=/usr/local/Cellar/gimme-aws-creds
GIMMEM1=/opt/homebrew/Cellar/gimme-aws-creds
CERTIFICERT=$(python3 -m certifi)
pythonbins=()
gimmex86array=()
gimmexm1array=()
keystore_pass=changeit
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
USERHOME=(/Users/"$loggedInUser")
#Make ca-certs directory
mkdir -p -m 777 $CAPEMDIR

#Download Mozilla CA Certs to user home folder
/usr/bin/su -l "$loggedInUser" -c "curl -k https://curl.se/ca/cacert.pem -o $CAPEMDIR/$CAPEM"

#Add Zscaler Root Cert to Mozilla Bundle
/usr/bin/su -l "$loggedInUser" -c "echo '$ZSCALERPEM' >> $CAPEMDIR/$CAPEM"

#Create Zscaler Root CA PEM file
echo "$ZSCALERPEM" > $CAPEMDIR/ZscalerRootCertificate.pem

#Curl
echo "Checking for Zscaler Root Cert in Curl"
if grep -q "cacert=$CAPEMDIR/$CAPEM" "$USERHOME/.curlrc"; then
  echo "Zscaler Cert Already in Curl"
else
  echo "Zscaler Cert not in Curl, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'cacert=$CAPEM' >> $USERHOME/.curlrc"
fi


#wget
echo "Checking for Zscaler Root Cert in wget"
if grep -q "ca_certificate=$CAPEMDIR/$CAPEM" "$USERHOME/.wgetrc"; then
  echo "Zscaler Cert Already in wget"
else
  echo "Zscaler Cert not in wget, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'ca_certificate=$CAPEMDIR/$CAPEM' >> $USERHOME/.wgetrc"
fi

#AWS CLI CA Bundles
echo "Checking for Zscaler Root Cert in AWS CLI Bash"
if grep -q "AWS_CA_BUNDLE=$CAPEMDIR/$CAPEM" "$USERHOME/.bash_profile"; then
  echo "Zscaler Cert Already in AWS CLI Bash"
else
  echo "Zscaler Cert not in AWS CLI Bash, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'export AWS_CA_BUNDLE=$CAPEMDIR/$CAPEM' >> $USERHOME/.bash_profile"
fi
echo "Checking for Zscaler Root Cert in AWS CLI ZSH"
if grep -q "AWS_CA_BUNDLE=$CAPEMDIR/$CAPEM" "$USERHOME/.zshenv"; then
  echo "Zscaler Cert Already in AWS CLI ZSH"
else
  echo "Zscaler Cert not in AWS CLI ZSH, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'export AWS_CA_BUNDLE=$CAPEMDIR/$CAPEM' >> $USERHOME/.zshenv"
fi

#NPM
echo "Checking for Zscaler Root Cert in NPM Bash"
if grep -q "NODE_EXTRA_CA_CERTS=$CAPEMDIR/$CAPEM" "$USERHOME/.bash_profile"; then
  echo "Zscaler Cert Already in NPM Bash"
else
  echo "Zscaler Cert not in NPM Bash, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'export NODE_EXTRA_CA_CERTS=$CAPEMDIR/$CAPEM' >> $USERHOME/.bash_profile"
fi
echo "Checking for Zscaler Root Cert in NPM ZSH"
if grep -q "NODE_EXTRA_CA_CERTS=$CAPEMDIR/$CAPEM" "$USERHOME/.zshenv"; then
  echo "Zscaler Cert Already in NPM ZSH"
else
  echo "Zscaler Cert not in NPM ZSH, adding"
  /usr/bin/su -l "$loggedInUser" -c "echo 'export NODE_EXTRA_CA_CERTS=$CAPEMDIR/$CAPEM' >> $USERHOME/.zshenv"
fi

echo "Checking if Git is Installed"
if [[ "$(git --version)" =~ "git version" ]];then
echo "Git is installed"
echo "Adding Zscaler Root Cert to GIT"
/usr/bin/su -l "$loggedInUser" -c "git config --global http.sslcainfo $CAPEMDIR/$CAPEM"
else
echo "Git not Installed"
fi

#Java
echo "Create Zscaler Root Cert PEM and Convert to DER for Java"
/usr/bin/su -l "$loggedInUser" -c "openssl x509 -in $CAPEMDIR/ZscalerRootCertificate.pem -inform pem -out $CAPEMDIR/ZscalerRootCertificate.der -outform der"
keytool  -import  -trustcacerts -alias zscalerrootca -file $CAPEMDIR/ZscalerRootCertificate.der -keystore $(/usr/libexec/java_home)/lib/security/cacerts -storepass $keystore_pass -noprompt

#Add Zsclaer CA to Python
echo "Checking for Zscaler Root Cert in Certifi"
if grep -q "$ZSCALERPEMC" "$CERTIFICERT"; then
  echo "Zscaler Cert Already in Certifi"
else
  echo "Zscaler Cert not in Certifi"
  pip3 install certifi
  pip3 install --upgrade certifi
  echo "$ZSCALERPEM" >> "$(python3 -m certifi)"
fi
 echo "Finding Additional Python Bins"
while IFS=  read -r -d $'\0'; do
   pythonbins+=("$REPLY")
done < <(find -L /usr/local/lib/python*/. /opt/homebrew/bin/python*/. /opt/homebrew/Cellar/python*/. /usr/local/Cellar/python*/. -name 'cacert.pem' -print0)
for ELEMENT in ${pythonbins[@]}
do
if grep -q "$ZSCALERPEMC" "$ELEMENT"; then
  echo "Zscaler Cert already in $ELEMENT"
else
  echo "Adding Zscaler Cert to $ELEMENT"
  echo "$ZSCALERPEM" >> "$ELEMENT"
fi
done

#Account for Gimme-AWS-Creds installed from brew
echo "Checking if Gimme-AWS-Creds is installed from Brew"
if [[ -d "$GIMMEX86" ]];then
 echo "Gimme directory found adding Zscaler cert to Bundles"
while IFS=  read -r -d $'\0'; do
   gimmex86array+=("$REPLY")
done < <(find -L "$GIMMEX86/." -name 'cacert.pem' -print0)
for ELEMENT in ${gimmex86array[@]}
do
if grep -q "$ZSCALERPEMC" "$ELEMENT"; then
  echo "Zscaler Cert already in $ELEMENT"
else
  echo "Adding Zscaler Cert to $ELEMENT"
  echo "$ZSCALERPEM" >> "$ELEMENT"
fi
done
elif [[ -d "$GIMMEM1" ]];then
 echo "Gimme directory found adding Zscaler cert to Bundles"
while IFS=  read -r -d $'\0'; do
   gimmexm1array+=("$REPLY")
done < <(find -L "$GIMMEM1/." -name 'cacert.pem' -print0)
for ELEMENT in ${gimmexm1array[@]}
do
if grep -q "$ZSCALERPEMC" "$ELEMENT"; then
  echo "Zscaler Cert already in $ELEMENT"
else
  echo "Adding Zscaler Cert to $ELEMENT"
  echo "$ZSCALERPEM" >> "$ELEMENT"
fi
done
else
  echo "Gimme from brew not found"
fi

exit 0