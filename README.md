# Building standalone CyberArk Conjur Enterprise and K8s LAB
This project will help you to quickly build up the standalone, single VM lab environment to test conjur and k8s application integration including:
- conjur follower in kubernetes 
- k8s jwt authentication
- conjur push to k8s file
- conjur push to kubernetes secret
- and other

All setup, installing and configuration steps are all put in sequence of scripts to make the setup process quicker and easier

Comments and question, please send to <huy.do@cyberark.com>

### Video on step by step setting up this LAB is at https://youtu.be/qiXBtv5R1z4

# PART I: SETING UP ENVIRONMENT
# 1.1. LAB Prerequisites
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
    
# 1.2. VMs Preparation
## **Step1.2.1: Preparing CentOS Stream 9**
CentOS Stream 9 can be downloaded at https://www.centos.org/download/

![centos-download](./images/01.centos-download.png?align=center)

Creating VM and installing with minimal install option

![policy](./images/02.minimal-install.png)

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
git clone https://github.com/huydd79/conjur-k8s-lab
```
Installation folder contains 3 sub folders for diffirent setup
- 1.k8s-setup: scripts to setup k8s standalone cluster environment
- 2.conjur-setp: scripts to install podman, mysql, conjur master containers and deploying conjur follower in k8s
- 3.cityapp-setup: scripts to deploys different types of cityapp application

Each folder will have ```00.config.sh``` which contains some parameters. Review file content, change all related parameters to actual value and set ```READY=true``` before doing further steps.

# PART II: SETING UP CONJUR - K8S LAB
# 2.1. Setting up K8s standalone cluster
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
## **Step2.1.2: Installing kubelet kubeadm and kubectl**
Login to VM as root, running below command to install kubelet and tools
```
cd /opt/lab/conjur-k8s-lab/1.k8s-setup
./02.installing-k8s-and-tools.sh
```
## **Step2.1.3: Setting up cluster and networking**
Login to VM as root, running below command to create stand alone cluster and configure networking
```
cd /opt/lab/conjur-k8s-lab/1.k8s-setup
./03.creating-k8s-cluster.sh 
```
Make sure that cni0 interface is getting correct IP (in 10.244) before doing futher steps
```
ip address show dev cni0 | grep 10.244
```
Checking for the kubelet service status and cluster info
```
service kubelet status
kubectl get all
```
## **Step2.1.4: Setting up kubernetes dashboard**
Login to VM as root, running below command to install kubernetes dashboard web GUI
```
cd /opt/lab/conjur-k8s-lab/1.k8s-setup
./04.installing-k8s-dashboard.sh
```
Copy the value of service account token to notepad for later usage. Checking status of k8s dashboard deployment
```
kubectl -n kubernetes-dashboard get pods -o wide
```
Open browser and login to k8s dashboard using previous copied token
```
https://<VMIP>:30443
```
# 2.2. Setting up podman and conjur environment
## **Step2.2.1: Reviewing 00.config.sh**
Login to VM as root, edit the 00.config.sh
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
vi 00.config.sh
```
Changed all related parameters such as IP, domain, password... and set ```READY=true``` to continue
## **Step2.2.2: Installing podman**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./01.installing-podman.sh
```
Using ```podman image ls``` to check current podman images
## **Step2.2.3: Setting up mysql container and database**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./02.running-mysql-db.sh
```
Using command ```podman container ls``` to make sure mysql container is up and running.
Using command ```ping mysql.demo.local``` to make sure host entry has been added correctly
## **Step2.2.4: Installing conjur master**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./03.loading-conjur-images.sh
./04.starting-conjur-container.sh
./05.configuring-conjur-master.sh
```
Using command ```podman image ls``` to make sure that image is loaded correctly
Using command ```podman container ls``` to make sure that conjur1 container is up and running
Using command ```curl -k https://conjur-master.demo.local/info``` to check conjur master status
Using browser and put in conjur master URL ```https://<VMIP>```, login using user admin and password is set in ```00.config.sh``` file
## **Step2.2.5: Installing conjur CLI**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./06.installing-conjur-cli.sh
```
Providing admin password for conjur cli configuration. Using command ```conjur whoami``` to doublecheck.
## **Step2.2.6: Loading demo data and enable conjur-k8s-jwt authentication**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./07.loading-demo-data.sh
./08.enable-k8s-jwt-authenticator.sh
./09.loading-conjur-jwt-data.sh 
```
Using ```curl -k https://conjur-master.demo.local/info``` to see the authenticaion options that are allowed.
Using browser, login to conjur GUI to review the demo data and content
## **Step2.2.7: Deploying conjur follower on k8s**
Login to VM as root and running below commands
```
cd /opt/lab/conjur-k8s-lab/2.conjur-setup
./10.loading-k8s-follower-configmap.sh 
11.deploying-follower-k8s.sh 
```
Login to k8s dashboard, select namespace conjur and checking for follower deployment and pod status
Login to conjur GUI, go to ```seting>Conjur Cluster``` to check for follower status
Open browser and go to ```https://<VM-IP>:30444/info``` to check for follower detai info

# PART III: TESTING CITYAPP OPTIONS
# 3.1. Building cityapp image
## **Step3.1.1: Reviewing 00.config.sh**
Login to VM as root, edit the 00.config.sh
```
cd /opt/lab/conjur-k8s-lab/3.cityapp-setup
vi 00.config.sh
```
Changed all related parameters such as IP, domain... and set ```READY=true``` to continue
## **Step3.1.2: Building image**
Login to VM as root, review the cityapp image detail on /opt/lab/conjur-k8s-lab/3.cityapp-setup/build
- Dockerfile: contain building info
- index.php: detail code of cityapp web application
Running below command to build cityapp image
```
cd /opt/lab/conjur-k8s-lab/3.cityapp-setup
./01.building-cityapp-image.sh
```
Using command ```podman image ls``` to make sure cityapp image has been build and put at localhost/cityapp
# 3.2. Running cityapp-hardcode
Login to VM as root, running below command to deploy cityapp-hardcode
```
cd /opt/lab/conjur-k8s-lab/3.cityapp-setup
./02.running-cityapp-hardcode.sh
```
# 3.3. Running cityapp-conjurtok8sfile
Login to VM as root, running below command to deploy conjurtok8sfile
```
cd /opt/lab/conjur-k8s-lab/3.cityapp-setup
./03.running-cityapp-conjurtok8sfile.sh
```
# 3.4. Running cityapp-conjurtok8ssecret
Login to VM as root, running below command to deploy conjurtok8ssecret
```
cd /opt/lab/conjur-k8s-lab/3.cityapp-setup
./04.running-cityapp-conjurtok8ssecret.sh
```
# PART IV: FINAL TESTING
Login to conjur GUI, change the value of secret ```test/host1/user```, ``` test/host1/pass``` and wait for 30 seconds. Refeshing the cityapp webpages to see if the credential values can be changed
# --- LAB END ---
