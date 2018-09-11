# HERO Software Developement Kit

## About
The HERO SDK contains the following packages:
* PULP HERO GCC Toolchain with RISC-V offloading support through OpenMP 4.5.
* PULP HERO Linux driver and `libpulp` runtime library for offloading support.
* Host Linux kernel and Buildroot root file system.
* PULP SDK ([link](https://github.com/pulp-platform/pulp-sdk));
* HERO Examples using OpenMP Heterogeneous Accelerator Execution Model.

### Prerequisites (on Ubuntu 16.04)
Starting from a fresh Ubuntu 16.04 distribution, here are the commands to be executed to get all required dependencies:
```
sudo apt install build-essential bison flex git python3-pip gawk texinfo libgmp-dev libmpfr-dev libmpc-dev swig3.0 libjpeg-dev lsb-core doxygen python-sphinx sox graphicsmagick-libmagick-dev-compat libsdl2-dev libswitch-perl libftdi1-dev u-boot-tools fakeroot
sudo pip3 install artifactory twisted prettytable sqlalchemy pyelftools openpyxl xlsxwriter pyyaml numpy
```
### Checkout the HERO SDK sources
The HERO SDK uses GIT submodule. To checkout properly the sources you have to execute the following command:
```
git clone --recursive git@github.com:pulp-platform/hero-sdk.git
```
or if you use HTTPS
```
git clone --recursive https://github.com/pulp-platform/hero-sdk.git
```

## Build the HERO SDK
### Build all or TL;TR;
The build is automatically managed by various scripts. The main builder script is `hero-z-7045-builder`.
You can build everything just launching the following command:
```
./hero-z-7045-builder -A
```
The first build takes at least 1 hour (depending on your internet connection). The whole HERO SDK requires roughly 25 GiB of disk space. If you want to build a single module only, you can do so by triggering the correspodning build step separately. Execute

```
./hero-z-7045-builder -h
```
to list the available build commands. Note that some modules have dependencies and require to be built in order. The above command displays the various modules in the correct build order.

##  Setup of the HERO platform
Once you have built the host Linux system, you can set up operation of the HERO platform.

### Format SD card

To properly format your SD card, insert it to your computer and type `dmesg` to find out the device number of the SD card.
In the following, it is referred to as `/dev/sdX`.

**NOTE**: Executing the following commands on a wrong device number will corrupt the data on your workstation. You need root priviledges to format the SD card.

First of all, type
```
sudo dd if=/dev/zero of=/dev/sdX bs=1024 count=1
```
to erase the partition table of the SD card.

Next, start `fdisk` usign
```
sudo fdisk /dev/sdX
```
and then type `n` followed by `p` and `1` to create a new primary partition.
Type `1` followed by `1G` to define the first and last cyclinder, respectively.
Then, type `n` followed by `p` and `2` to create a second primary partition.
Select the first and last cyclinder of this partition to use the rest of the SD card.
Type `p` to list the newly created partitions and to get their device nodes, e.g., `/dev/sdX1`.
To write the partition table to the SD card and exit `fdisk`, type `w`.

Next, execute
```
sudo mkfs -t vfat -n ZYNQ_BOOT /dev/sdX1
sudo mkfs -t vfat -n STORAGE   /dev/sdX2
```
to create a new FAT filesystem on both partitions.

### Load boot images to SD card

To install the generated images, copy the contents of the directory
```
zynqlinux/sd_image
```
to the first partition of the prepared SD card.
You can do so by executing
```
./copy_to_sd_card.sh
```
**NOTE**: By default, this script expects the SD card partition to be mounted at `/run/media/${USER}/ZYNQ_BOOT` but you can specify a custom SD card mount point by setting up the env variable `SD_BOOT_PARTITION`. 

Insert the SD card into the board and make sure the board boots from the SD card.
To this end, the [boot mode switch](http://www.wiki.xilinx.com/Prepare%20Boot%20Medium) of the Zynq must be set to `00110`.
Connect the board to your network.
Boot the board.

### Install support files

Once you have setup the board you can define the following environmental variables (e.g. in `scripts/hero-z-7045-env.sh`)
```
export HERO_TARGET_HOST=<user_id>@<hero-target-ip>
export HERO_TARGET_PATH=<installation_dir>
```
to enable the HERO builder to install the driver, support applications and libraries using a network connection. Then, execute
```
./hero-z-7045-builder -i
```
to install the files on the board.

By default, the root filesystem comes with pre-generated SSH keys in `/etc/ssh/ssh_host*`. The default root password is
```
hero
```
and is set at startup by the script `/etc/init.d/S45password`.

**NOTE**: We absolutely recommend to modify the root filestystem to set a custom root password and include your own SSH keys. How this can be done is explained on our [HOWTO webpage](https://iis-people.ee.ethz.ch/~vogelpi/hero/software/host/zynqlinux/). We are not responsible for any vulnerabilities and harm resulting from using the provided unsafe password and SSH keys.

## Execute the OpenMP examples
### Prerequisites
The HERO SDK contains also some OpenMP 4.5 example applications. Before running an example application, you must have built the HERO SDK, set up the HERO platform and installed the driver, support applications and libraries.

Setup the build enviroment by executing
```
source scripts/hero-z-7045-env.sh
```

Connect to the board and load the PULP driver:
```
cd ${HERO_TARGET_PATH_DRIVER}
insmod pulp.ko
```

To print any UART output generated by PULP, connect to the HERO target board via SSH and start the PULP UART reader:
```
cd ${HERO_TARGET_PATH_APPS}
./uart
```

### Application Execution
To compile and execute an application, navigate to the application folder execute the make:
```
cd hero-openmp-examples/helloworld
make clean all run
```

Alternatively, you can also directly connect to the board via SSH, and execute the binary on the board once it has been built:
```
cd ${HERO_TARGET_PATH_APPS}
export LD_LIBRARY_PATH=${HERO_TARGET_PATH_LIB}
./app.exe
```

## Additional information
For additional information on how to build the host Linux system, customize the Buildroot root filesystem (e.g. installing your SSH keys) etc. visit the corresponding [HOWTO webpage](https://iis-people.ee.ethz.ch/~vogelpi/hero/software/host/zynqlinux/).

## Issues and throubleshooting
If you find problems or issues during the build process, you can take a look at the troubleshooting [page](FAQ.md) or you can directly open an [issue](https://github.com/pulp-platform/hero-sdk/issues) in case your problem is not a common one.
