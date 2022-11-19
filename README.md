# Building your CyberArk Conjur Enterprise and Openshift CRC LAB
Created by <huy.do@cyberark.com>
### Video on step by step setting up this LAB is at https://youtu.be/...

# PART I: SETING UP ENVIRONMENT
# 1. LAB Prerequisites
- ESXI server or VMWorkstation to create standalone lab VMs as below:
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
  - CyberArk software and related tools can be downloaded at https://cyberark-customers.force.com/mplace/s/#software
    
