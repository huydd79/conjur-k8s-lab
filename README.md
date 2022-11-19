# Building your CyberArk Conjur Enterprise and Openshift CRC LAB
Created by <huy.do@cyberark.com>
### Video on step by step setting up this LAB is at https://youtu.be/...

# PART I: SETING UP ENVIRONMENT
# 1. LAB Prerequisites
- ESXI server or VMWorkstation to create standalone lab VM as below:
  - 8GB RAM (minimum), recommended 16GB
  - 2 vCore CPU
  - 60GB HDD
  - CentOS Stream 9 base OS (Minimal Install)
    - Hostname: k8s.demo.local
    - LAN IP (eg 172.16.100.109/24)
    - Internet connection to do yum updating and packages installation
- Conjur appliance images & utilities:
  - Contact CyberArk local representative for following images and tools
    - conjur-appliance-Rls-12.7.tar.gz
    - conjur-cli-rhel-8.tzr.gz
  - CyberArk softwares and related tools can be downloaded at https://cyberark-customers.force.com/mplace/s/#software
 *The IP addresses in this document are using from current lab environment. Please replace the **172.16.100.109** by your actual **VM IP**’s
    
# 2. VMs Preparation
## **Step1.2.1: Preparing CentOS Stream 9**
- CentOS Stream 9 can be downloaded at https://www.centos.org/download/
- Creating VM and installing with minimal install option
- Checking for IP, DNS and Internet connection
- Installing git tool
```
yum -y install git
```
## **Step1.2.2: Copying files for setting up**
Login to VM as root, creating folder for setup_files
```
mkdir -p /opt/lab/setup_files
chmod 777 /opt/lab/setup_files
```
Copy conjur appliance image file to setup_files folder
- Conjur docker image: conjur-appliance-Rls-12.7.tar.gz
## **Step1.2.3: Cloning git hub repo**
Login to VM as root and running below command
```
cd /opt/lab
git clone git clone https://github.com/huydd79/conjur-k8s-lab
```
Installation folder contains 3 sub folders for diffirent setup
- 1.k8s-setup: scripts to setup k8s standalone cluster environment
- 2.conjur-setp: scripts to install podman, mysql, conjur master containers and deploying conjur follower in k8s
- 3.cityapp-setup: scripts to deploys different types of cityapp application

Each folder will have ```00.config.sh``` which contains some parameters. Review file content, change all related parameters to actual value and set ```READY=true``` before doing further steps.

# PART II: SETING UP CONJUR - K8S LAB
# 1. Setting up K8s standalone cluster
## **Step2.1.1: Installing cri-o**
Login to VM as root, running below command to install cri-o
```
cd /opt/lab/conjur-k8s-lab/1.k8s-setup
./01.installing-cri-o.sh
```
Checking crio service after done to make sure crio is up and run
```
service crio status
```
