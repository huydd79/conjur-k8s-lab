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
## **Step1.1: Preparing CentOS Stream 9**
- CentOS Stream 9 can be downloaded at https://www.centos.org/download/
- Creating VM and installing with minimal install option
- Checking for IP, DNS and Internet connection
## **Step1.2: Copying files for setting up**
Login to VM as root, creating folder for setup_files
```
mkdir -p /opt/lab/setup_files
chmod 777 /opt/lab/setup_files
```
Copy conjur appliance image file to setup_files folder
- Conjur docker image: conjur-appliance-Rls-12.7.tar.gz
