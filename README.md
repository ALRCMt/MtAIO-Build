
## 因为在`README.md`写全部教程太不方便了，所以接下来完整教程请在我的个人网站查看https://ht.tyyz2415.top

<br />

**这里只放开头介绍**


MtAIO 系统是一套整合了多种开源组件的系统集合，本质上是跑在 Proxmox VE 虚拟化平台上的若干个虚拟机以及其中应用的个人服务器，其源于两年前欲求文件存储与共享的突发奇想，归功于<del>强大的行动力</del>（大嘘）
，在使用了各家云服务器均不尽人意后，搭建了这套系统

本指南作为我自己摸索学习的记录，借鉴了[https://github.com/firemakergk/aquar-build-helper](https://github.com/firemakergk/aquar-build-helper) 的内容

作为一个完全的小白，这套系统的搭建帮助我了解学习计算机知识及 linux 系统，配置网络环境，以及成为一位合格的垃圾佬，可以说，我完全是一下一下摸索着搭建这套系统的，因此我认为如果你有兴趣搭建这么一套系统，不论有没有技术基础，也一定可以成功，所以在这里，我会把 MtAIO 系统搭建过程中的大小问题及解决方法记录下来，希望可以帮到你

感谢这些对我有帮助的人：

[@生火人 firemaker](https://space.bilibili.com/304756911?spm_id_from=333.1387.favlist.content.click)

[@Intro_iu](https://space.bilibili.com/204773750/?spm_id_from=333.788.upinfo.head.click)

[@康文昌](https://space.bilibili.com/34786453?spm_id_from=333.1387.favlist.content.click)

[@技术爬爬虾](https://space.bilibili.com/316183842?spm_id_from=333.1387.favlist.content.click)

[@科技宅小明](https://space.bilibili.com/5626102?spm_id_from=333.1387.favlist.content.click)

如果你有疑问，或者发现了我的错误，请联系我

[![QQ](https://img.shields.io/badge/QQ-ALRCMt-white.svg?style=flat-square)](https://qm.qq.com/q/4uVkK9nRPW?personal_qrcode_source=3)
[![邮箱](https://img.shields.io/badge/邮箱-b122330417@163.com-blue.svg?style=flat-square)](mailto:b122330417@163.com)


## 核心功能

- Proxmox VE 虚拟化多系统
- 预装 TrueNas 并配置多种共享服务（NFS、SMB、WebDAV）
- 预装多种 Docker 服务（*Resilio Sync*文件备份、*immich*影像管理、*Aria2*离线下载...）
- 蒲公英异地组网多平台随时使用
- 一套独立的 windows10 系统冗余
- <del>装逼</del>

## 需求与使用场景 [引用自@生火人 firemaker](https://github.com/firemakergk/aquar-build-helper?tab=readme-ov-file#%E9%9C%80%E6%B1%82%E4%B8%8E%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF)

从零纯手工搭建系统的过程很长，因为这是长期沉淀下来的，有很多细节蕴含在其中。然而我更想强调的是，当你走完所有这些路途以后，你和这套系统磨合才真正开始。**一套软件系统是生长在使用者的需求上的，合理且充分的需求就像土壤，是软件系统存活乃至成长的必要条件。**

所以搭建系统前你需要问自己一些问题：

- 你希望使用这套系统解决什么问题？
- 这些问题是否有其他更便利的解决方式？
- 这套系统的特性是否适合你长期使用？

如果这些问题的答案都支持你搭建这套系统，那么请阅读接下来的内容，祝你好运
