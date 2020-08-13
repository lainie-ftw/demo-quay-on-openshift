#!/usr/bin/env bash 

# author: Laine Vyvyan @lainie-ftw laine.vyvyan@gmail.com

#Set up some variables
pullsecretfile="quay-secret-config.json"
quayconfigfile="quay-ecosystem.yaml"

clusterrooturl="cluster-lan-fe6a.lan-fe6a.example.opentlc.com"
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

read -p "${blue}Login to the cluster.${reset}"
oc login ${clusterapiurl}

read -p "${green}*** We'll start by installing and setting up Quay itself via the Quay operator. ***${reset}"

read -p "${blue}Enter a project name to create for Quay to run in: " project
echo "${reset}"
oc new-project ${project}
quayurl="quayecosystem-quay-${project}.apps.${clusterrooturl}"

#delete the limitrange on the project - proceed with caution!
oc delete limitrange ${project}-core-resource-limits

read -p "${blue}Apply the image pull secret to the ${project} project.${reset}"
oc create secret generic redhat-pull-secret --from-file=".dockerconfigjson=${pullsecretfile}" --type='kubernetes.io/dockerconfigjson'

read -p "${green}Apply the operator to the ${project} project in the UI.${reset}"

read -p "${blue}Show off the super cool Quay config file.${reset}"
cat ${quayconfigfile}

read -p "${blue}Apply the super cool Quay config file. ${reset}"
oc create -f ${quayconfigfile}

read -p "${green}Watch the pods spin up and answer any questions, and then log in to Quay.${reset}"

read -p "${blue}Use skopeo to copy an image from Quay.io into the new Quay.${reset}"
echo -e "skopeo copy docker://quay.io/lainieftw/python-27-rhel7 docker://${quayurl}/quay/python-27-rhel7 --dest-creds=u:p --dest-tls-verify=false\n"
sudo podman login quay.io
skopeo copy docker://quay.io/lainieftw/python-27-rhel7 docker://${quayurl}/quay/python-27-rhel7-laine --dest-creds=admin:password --dest-tls-verify=false

echo "${green}*** Set up and show off Quay mirroring! ***${reset}"

echo "${green}*** Install the cluster security operator to show Quay and Clair integration on the main OpenShift admin view dashboard. ***${reset}"
















