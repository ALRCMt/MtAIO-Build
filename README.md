# MtHMR 系统搭建指南

# 整体介绍

MtHMR 系统是一套整合了多种开源组件的系统集合，本质上是跑在Proxmox VE虚拟化平台上的若干个虚拟机以及其中应用的服务器，其源于两年前欲求文件存储与共享的突发奇想，归功于<del>强大的行动力</del>（大嘘）
，在使用了各家网盘、小主机T620&Alist 均不尽人意后，搭建了这套系统

作为一个完全的小白，这套系统的搭建帮助我了解学习计算机知识及linux系统，配置网络环境，以及成为一位合格的垃圾佬，可以说，我完全是一下一下摸索着搭建这套系统的，因此我认为如果你有兴趣搭建这么一套系统，不论有没有技术基础，也一定可以成功，所以在这里，我会把MtHMR系统搭建过程中的大小问题及解决方法记录下来，希望可以帮到你

感谢这些对我有帮助的人：

[@生火人firemaker](https://space.bilibili.com/304756911?spm_id_from=333.1387.favlist.content.click)

[@Intro_iu](https://space.bilibili.com/204773750/?spm_id_from=333.788.upinfo.head.click)

[@康文昌](https://space.bilibili.com/34786453?spm_id_from=333.1387.favlist.content.click)

[@技术爬爬虾](https://space.bilibili.com/316183842?spm_id_from=333.1387.favlist.content.click) 

[@科技宅小明](https://space.bilibili.com/5626102?spm_id_from=333.1387.favlist.content.click)


如果你有疑问，请联系我

[![QQ](https://img.shields.io/badge/QQ-ALRCMt-white.svg)](https://qm.qq.com/q/4uVkK9nRPW?personal_qrcode_source=3)
[![邮箱](https://img.shields.io/badge/邮箱-b122330417@163.com-blue.svg)](mailto:b122330417@163.com)

## 核心功能

- Proxmox VE虚拟化多系统
- 预装TrueNas并配置多种共享服务（NFS、SMB、WebDAV）
- 预装多种Docker服务（DPanel_docker可视化、Syncthing_文件备份...）
- 蒲公英异地组网多平台随时使用
- 额外一套独立windows10系统冗余
- <del>装一波逼</del>

## 需求与使用场景 [引用自@生火人firemaker](https://github.com/firemakergk/aquar-build-helper?tab=readme-ov-file#%E9%9C%80%E6%B1%82%E4%B8%8E%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF)

从零纯手工搭建系统的过程很长，因为这是长期沉淀下来的，有很多细节蕴含在其中。然而我更想强调的是，当你走完所有这些路途以后，你和这套系统磨合才真正开始。**一套软件系统是生长在使用者的需求上的，合理且充分的需求就像土壤，是软件系统存活乃至成长的必要条件。**

所以搭建系统前你需要问自己一些问题：

- 你希望使用这套系统解决什么问题？
- 这些问题是否有其他更便利的解决方式？
- 这套系统的特性是否适合你长期使用？

如果这些问题的答案都支持你搭建这套系统，那么请阅读接下来的内容，祝你好运

<br />

# 硬件配置





v我50













<br />

# 系统配置 

**参考[@生火人firemaker](https://github.com/firemakergk/aquar-build-helper?tab=readme-ov-file#%E7%B3%BB%E7%BB%9F%E5%AE%89%E8%A3%85)**
**主要是以下系统的安装与配置**

 - [Proxmox Virtual Environment](/README.md#%E5%AE%89%E8%A3%85pveproxmox-virtual-environment)
 - [TrueNAS scale](/README.md#%E5%AE%89%E8%A3%85truenas-scale)
 - [Ubuntu Server](/README.md#%E5%AE%89%E8%A3%85-ubuntuubuntu-server)
> 特殊安装：Windows10
> 因为我的笔记本坏了一段时间，又没有别的电脑，刚好有一块多的m.2硬盘  
> 于是我上安装了一套额外的win10

<br />

## 安装 PVE([Proxmox Virtual Environment](https://www.proxmox.com/en/downloads/category/proxmox-virtual-environment))

**1.下载镜像**

pve的镜像官网下载页面：https://www.proxmox.com/en/downloads/category/iso-images-pve

直接下载最新版本即可

**2.制作启动盘**

推荐使用Etcher制作启动盘，你要用Rufus也随便

Etcher下载地址：[https://pve.proxmox.com/pve-docs/pve-admin-guide.html#installation\_prepare\_media](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#installation_prepare_media)

**3.安装PVE**

将启动盘插入物理机，重启进入BIOS（进bios哪个键自己网上搜对应主板去），选择从启动盘启动，然后进入安装流程

安装过程中pve会让你设置一个域名，并不关键，按默认即可

安装流程的官方文档：https://pve.proxmox.com/pve-docs/pve-admin-guide.html#installation_installer

安装过程中卡死？解决方法：[PVE安装时卡死](/README.md#00pve%E5%AE%89%E8%A3%85%E6%97%B6%E5%8D%A1%E6%AD%BB)

**4.验证安装**

PVE安装完成后，首先在你的物理机屏幕上会显示出服务的IP地址（大概类似[https://192.168.X.XXX:8006/](https://youripaddress:8006/))，注意是https协议，在局域网下打开这个地址，你就可以看到PVE的WEB控制台了

![](./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20110507.png)

默认用户是root，密码是你安装时设置的，语言设置为中文

 <br />
 
## 安装 TrueNAS([TrueNAS scale](https://www.truenas.com/download-truenas-community-edition/))

TrueNAS scale相较于可以直接搭载Docker服务，虽然使用PVE这种虚拟化平台作为底层系统，但是TrueNAS scale能提供更多选择（其实就是我根本没看是core还是scale

**1.下载镜像**

TrueNAS SCALE的下载页面： https://www.truenas.com/download-truenas-community-edition

刚进入时会提示你注册，点击右下角的No Thanks即可看到下载链接了。推荐直接下载最新版本即可。

**2.上传镜像到PVE**

在左侧的树状图中选择pve节点的local存储，在右侧选择ISO镜像，然后点上传，上传你的在上一步下载的TrueNAS scale ISO文件。你可以提前下载后面两节需要用到的镜像，然后集中上传，这可以节省很多时间。


**3.创建虚拟机**

在pve的web页面的右上角点击创建虚拟机，为TrueNAS创建一个虚拟机。

通用信息配置中勾选右下角的Advanced，并把这个虚拟机设置为开机自启动，然后设置启动顺序为1，等待时间60(秒)，需要注意的是这里的等待时间指的是这台虚拟机开机后等待下一台虚拟机开机的时间，而不是他与上一台虚拟机开机的等待时间。**设置合理的启动顺序和等待时间非常重要**，否则会影响上层服务的存储池挂载

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030601.png" alt="" width="700px"/>

操作系统配置页面选择你上传的TrueNAS IOS镜像，并设置操作系统类型为Other

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030634.png" alt="" width="700px"/>

系统配置页面我的配置如下：

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030653.png" alt="" width="700px"/>

系统磁盘空间我分配了32G，其他配置项没有需要修改的地方

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030701.png" alt="" width="700px"/>

CPU分配了2核，另外CPU类型选择了host，在单机情况下这样设置可以获得最小性能损耗

> *在8.x版本的系统中，如果使用的是混合架构的CPU如12代i7，可以直接在界面的CPU Affinity设置中指定绑定的CPU序号*  
> *查看CPU多核类别的方法是使用`lscpu -e`命令，可以看到E核的MAXMHZ会低于P核*  
> *（这里我并没有这么配置，所以我不太清楚具体配置）*

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030809.png" alt="" width="700px"/>

内存方面由于TrueNAS推荐使用16G以上内存空间，但是我总共只有16G内存，所以分配了8G，可以正常使用

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030759.png" alt="" width="700px"/>

网络方面我暂时修改默认配置，未来应该可以将网络类型换成VirtlIO以提升性能

进入到确认页面后点击创建就可以了

<img src="./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030836.png" alt="" width="700px"/>

虚拟机创建成功后，打开他的console应该就可以看到安装提示了。

**4.安装TrueNAS core**

推荐教程 https://post.smzdm.com/p/a6d8m6vg/

官方文档：https://www.truenas.com/docs/scale/25.04/gettingstarted/install/

由于在一些USB设备连接不稳定的情况下，TrueNAS虚拟机会收到USB热插拔的影响而死机，所以安装完成以后打开虚拟机的Options（选项）页，双击Hotplug（热拔插）设置项，把USB选项的勾选去掉。


**5.验证安装**

TrueNAS安装成功后在局域网中使用浏览器打开提示中的地址应该就可以看到TrueNAS的Web页面了

![](./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20030930.png)

默认用户名是truenas_admin，密码是在安装时设置


<br />

## 安装 ubuntu([Ubuntu Server](https://cn.ubuntu.com/download/server/step1))

**1.下载镜像**

由于我们使用ubuntu的作用主要是承载各种服务而非直接与之交互，所以选择没有GUI的Ubuntu Server版本。

Ubuntu Server下载页面：https://cn.ubuntu.com/download/server/step1

选择最新的LTS版本即可

**2.上传镜像**

与TrueNAS章节的上传操作一致，不再重复

**3.创建虚拟机**

与TrueNAS章节的创建操作类似，内存我分配了4GB


**4.安装Ubuntu Server**

推荐教程：https://blog.csdn.net/FungLeo/article/details/148370828

Ubuntu Server官方文档的安装指引：https://ubuntu.com/server/docs/install/step-by-step

安装时有几点需要注意：

1.  Mirror设置时，Ubuntu现在默认为国内源地址，如果不是的话请更换成你所在的地区最稳定的地址
2.  SSH设置时勾选Install SSH Server
3.  Snaps页面不要选择任何软件进行安装
4.  在Ubuntu安装开始执行一段时间后（大概几分钟），会开始拉取软件源信息，没必要等待，直接选择"跳过并重启"即可

**5.验证安装**

在PVE中找到Ubuntu的虚拟机，并进入Console界面，多按动几次回车键，如果看到类似的提示，则输入你安装时设置的用户名和密码。如果登录成功则说明系统正常运行了

![](./photo/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202025-08-09%20122037.png)





# 注意事项
以下为我实际搭建过程中的一些“小问题”（并不）和小巧思
<br />

## 00.PVE安装时卡死
如果你有一张独立显卡，那么在安装PVE时可能会卡在Loading Driver...，这是因为缺少显卡驱动导致的


解决方法：
- 启动Proxmox VE安装程序
启动计算机并进入Proxmox VE的引导程序菜单
- 选择安装选项：
在引导菜单中，使用箭头键选择“Install Proxmox VE (Terminal UI)”选项
- 编辑引导参数：
按下键盘上的 e 键进入编辑模式
- 修改Linux引导行：
使用箭头键导航到以 linux 开头的那一行。
将光标移动到该行的末尾
- 添加nomodeset参数：
在该行的末尾，确保与最后一个参数之间有一个空格，然后输入 nomodeset。
启动安装程序：
完成编辑后，按下 Ctrl + X 或 F10 键（具体取决于系统提示）以启动安装程序


将通过禁用图形化模块解决该问题


## 01.docker安装的网络问题

由于国内网络问题，docker使用阿里云镜像源安装
在ubuntu控制台输入以下命令


``` shell
# 一、准备工作
# 在开始之前，请确保您的系统是 Ubuntu 版本 22.04。可以使用以下命令来更新系统：
 
sudo apt update
sudo apt upgrade -y
 
# 二、检查系统版本
# 为了确认您的 Ubuntu 版本，您可以运行以下命令：
 
lsb_release -a
 
# 三、安装 Docker
# 1. 安装必要的依赖
# 在安装 Docker 之前，我们需要安装一些必要的依赖包。运行以下命令：
 
sudo apt install apt-transport-https ca-certificates curl software-properties-common
 
# 备份并移除可能已损坏的密钥文件
sudo mv /usr/share/keyrings/docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg.bak 2>/dev/null
 
# 使用阿里云镜像源下载 GPG 密钥
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
 
# 检查密钥是否正确导入
if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    echo "GPG 密钥已成功导入"
else
    echo "GPG 密钥导入失败，请检查网络连接"
    exit 1
fi
 
# 设置 Docker 阿里云镜像源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
# 更新 apt 包索引并安装 Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
 
# 验证 Docker 安装
sudo docker run hello-world
```


## 02.PVE网卡莫名其妙掉线问题

网上看到的原因基本是intel的网卡所致，怀疑是驱动兼容性问题
打开PVE控制台


``` shell
# 先安装工具
apt -y install ethtool
ethtool -K eno1 tso off gso off
# 修改vi /etc/network/interfaces ，在iface eno1 inet manual下新增post-up ethtool -K eno1 tso off gso off
auto lo
iface lo inet loopback

iface eno1 inet manual
        post-up ethtool -K eno1 tso off gso off   #  新增这句

auto vmbr0
iface vmbr0 inet static
        address 192.168.1.33/24
        gateway 192.168.0.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0

source /etc/network/interfaces.d/*
```

## 03.ssh功能开启问题

因为ubuntu虚拟机的控制台与本机粘贴板不互通，又不想安装其它插件，于是打算用windows的cmd远程ssh，但是ubuntu的ssh功能死活打不开，最终发现他妈的命令中是`ssh`而不是`sshd`


``` shell
# 首先，打开ubuntu控制台，并输入以下命令以启动SSH服务
systemctl start ssh
# 确认SSH服务已启动，输入以下命令查看SSH服务状态
systemctl status ssh
```

## 04.PVE8 概要面板显示CPU温度


通过shell脚本自动配置，省时省力省心
运行这段指令：

``` shell
(curl -Lf -o /tmp/temp.sh https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh || curl -Lf -o /tmp/temp.sh https://mirror.ghproxy.com/https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh) && chmod +x /tmp/temp.sh && /tmp/temp.sh remod
```
然后刷新页面就可以了

安装CPU温度检测软件sensors
``` shell
apt install lm-sensors -y
```
传感器探测
``` shell 
sensors-detect
```
全部选择yes即可，可能其中一个地方提示 ENTER ，按 回车键 即可

ISA adapter：CPU温度信息

acpitz-acpi-0：主板温度信息

nvme-pci-0200：nvme固态硬盘温度（如果有安装的话）普通的sata固态硬盘不会显示

最气人的是不知道为什么我这里死活不显示CPU核心温度和主板温度，所以其他我也懒得配置了，平时使用
``` shell
sensors
```
看一下基本温度就行了
