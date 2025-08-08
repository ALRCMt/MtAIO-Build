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







## 核心功能

- Proxmox VE虚拟化多系统

- 预装TrueNas并配置好多种共享服务（NFS、SMB、WebDAV）

- 预装多种Docker服务（DPanel_docker可视化、Syncthing_文件备份...）

- 蒲公英异地组网多平台随时使用

- <del>装一波逼</del>

## 需求与使用场景（[引用自@生火人firemaker](https://github.com/firemakergk/aquar-build-helper?tab=readme-ov-file#%E9%9C%80%E6%B1%82%E4%B8%8E%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF)）

从零纯手工搭建系统的过程很长，因为这是长期沉淀下来的，有很多细节蕴含在其中。然而我更想强调的是，当你走完所有这些路途以后，你和这套系统磨合才真正开始。**一套软件系统是生长在使用者的需求上的，合理且充分的需求就像土壤，是软件系统存活乃至成长的必要条件。**

所以搭建系统前你需要问自己一些问题：

- 你希望使用这套系统解决什么问题？
- 这些问题是否有其他更便利的解决方式？
- 这套系统的特性是否适合你长期使用？

如果这些问题的答案都支持你搭建这套系统，那么请阅读接下来的内容，祝你好运。

# 硬件配置





















# 系统配置
















# 注意事项
以下为我实际搭建过程中的一些“小问题”和小巧思


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
在PVE控制台输入以下命令


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
