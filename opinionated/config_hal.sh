# OpsMx 
# Hal Configuration Script
# Please note that this script should be run ONLY ONCE
#######################################################################################################
# Update this information based on your environment and uncomment the appropriate lines
# Instructions for creating guthub-token can be found at https://github.com/settings/tokens
# and https://www.spinnaker.io/setup/artifacts/github
#######################################################################################################
#BASEURL=http://<jenkins host>:8181/jenkins
#USERNAME=<Jenkins Username>
#PASSWORD=<Jenkins password
#TOKEN_FILE=<github-token>
#######################################################################################################
#######################################################################################################

export KUBECONFIG=/home/vagrant/.kube/config

# Get nodePort numbers
DECKNP=$(kubectl get svc spin-deck-ui -n oes -o jsonpath='{...nodePort}')
GATENP=$(kubectl get svc spin-gate-np -n oes -o jsonpath='{...nodePort}')

#Creat a script to be run inside HAL Pod
cd /vagrant
rm -f /tmp/tmp-hal-config.sh 2>&1 > /dev/null
cat <<EOF >> /tmp/tmp-hal-config.sh
#!/bin/sh
hal config security ui edit --override-base-url http://10.168.3.10:$DECKNP
hal config security api edit --override-base-url http://10.168.3.10:$GATENP
#hal config provider kubernetes account add OpsMx-k8s --provider-version v2 --kubeconfig-file=/home/spinnaker/.kube/config --only-spinnaker-managed true
#hal config provider kubernetes enable

# OPTIONAL ADDITIONAL CONFIGURATION
#hal config artifact github account add OpsMx-k8s-Github --token-file /home/spinnaker/$TOKEN_FILE
#hal config artifact github enable

#hal config ci jenkins master add OpsMx-k8s-Jenkins --address $BASEURL --username $USERNAME --password $PASSWORD
#hal config ci jenkins enable
 
#hal config security authn ldap edit --user-dn-pattern="cn={0}" --url=ldap://oes-openldap:389/dc=example,dc=org
#hal config security authn ldap enable

hal deploy apply
EOF

chmod +x /tmp/tmp-hal-config.sh
#Copy the script and required files into the HAD POD
#kubectl cp /home/vagrant/.kube/config oes-spinnaker-halyard-0:/home/spinnaker/.kube  -n oes

# OPTIONAL ADDITIONAL CONFIGURATION
#kubectl cp $TOKEN_FILE oes-spinnaker-halyard-0:/home/spinnaker/ -n oes

kubectl cp /tmp/tmp-hal-config.sh oes-spinnaker-halyard-0:/home/spinnaker/tmp.sh  -n oes

#Execute the script
kubectl exec oes-spinnaker-halyard-0 -n oes -- /home/spinnaker/tmp.sh
sleep 600
#echo "==========================================================================="
#echo "==========================================================================="
#echo 
#echo "Installation of Spinnaker is now complete. Login to the URL below using admin/OpsMx@123"
#echo 
#kubectl get svc spin-deck-ui -n oes -o jsonpath='{"http://10.168.3.10:"}{...nodePort}{"\n"}'
#echo 
#echo "==========================================================================="
#echo "==========================================================================="
