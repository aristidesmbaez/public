#! /bin/bash
USER=$(id -u -n)
echo "Checking for Docker subgid Requirements"
if grep -q "$USER:100000:65536" "/etc/subgid"; then
  echo "Requirements already in subgid"
else
  echo "subgid missing requirements, adding"
  echo "$USER:100000:65536" >> /etc/subgid
fi
echo "Checking for Docker subuid Requirements"
if grep -q "$USER:100000:65536" "/etc/subuid"; then
  echo "Requirements already in subuid"
else
  echo "subuid missing requirements, adding"
  echo "$USER:100000:65536" >> /etc/subuid
fi
echo "Installing Docker rootless"    
/bin/bash /usr/bin/dockerd-rootless-setuptool.sh "install"
if [[ -f "$HOME/.minikube/certs/ZscalerRootCertificate.pem" ]]; then
  echo "Minikube already has zscaler certificate"
else
  echo "Minikube does not have the zscaler certificate, adding"
  mkdir -p $HOME/.minikube/certs/
  ln -s /usr/local/.ca-certs/ZscalerRootCertificate.pem $HOME/.minikube/certs/
fi
exit 0
