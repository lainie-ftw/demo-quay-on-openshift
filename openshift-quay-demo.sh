#!/usr/bin/env bash 

# author: Laine Vyvyan @lainie-ftw laine.vyvyan@gmail.com

#Set up some variables
pullsecretfile="quay-secret-config.json"
quayconfigfile="quay-ecosystem.yaml"

clusterrooturl="cluster-quay-6f8a.quay-6f8a.example.opentlc.com"
clusterapiurl="https://api.${clusterrooturl}:6443/"

#Setting up some colors for helping read the demo output
#Using ${green}GREEN${reset} for UI pauses
#Using ${blue}BLUE${reset} for script steps

green=$(tput setaf 2)
blue=$(tput setaf 4)
purple=$(tput setaf 125)
reset=$(tput sgr0)

#Let's do this thing...
read -p "${green}Welcome to the Quay on OpenShift demo! Press enter to proceed. ${reset}"

read -p "${blue}1. Login to the cluster.${reset}"
oc login ${clusterapiurl}

read -p "${blue}2. Enter a project name to create: " project
echo "${reset}"
oc new-project ${project}
quayurl="example-quayecosystem-quay-${project}.apps.${clusterrooturl}"


read -p "${blue}3. Delete project limitrange? [y/n] " deletelimit 
echo "${reset}"
if [ $deletelimit == "y" ]
then
	oc delete limitrange ${project}-core-resource-limits
fi

read -p "${blue}4. Apply the secret to the project.${reset}"
oc create secret generic redhat-pull-secret --from-file=".dockerconfigjson=${pullsecretfile}" --type='kubernetes.io/dockerconfigjson'

read -p "${green}5. Pause the script to apply the operator to ${project} in the UI.${reset}"

read -p "${blue}6. Show off the super cool Quay config file.${reset}"
cat ${quayconfigfile}

read -p "${blue}7. Apply the super cool Quay config file. ${reset}"
oc create -f ${quayconfigfile}

read -p "${green}8. Pause to watch the pods spin up and answer any questions, and then log in to Quay.${reset}"

read -p "${blue}9. Use skopeo to copy an image from Quay.io into the new Quay.${reset}"
echo -e "skopeo copy docker://quay.io/lainieftw/python-27-rhel7 docker://${quayurl}/quay/python-27-rhel7 --dest-creds=u:p --dest-tls-verify=false\n"
skopeo copy docker://quay.io/lainieftw/python-27-rhel7 docker://${quayurl}/quay/python-27-rhel7 --dest-creds=quay:password --dest-tls-verify=false

echo "${green}10. Show off mirroring in the UI! ${reset}"

read -p "${blue}11. Show what happens when you delete the super cool Quay config file from the project? [y/n] " deleteconfigfile
if [ $deleteconfigfile == "y" ]
then
	oc delete -f ${quayconfigfile}
fi
















