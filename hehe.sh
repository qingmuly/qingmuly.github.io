#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# wget http://yxl.kfj.cc/openvpn.sh && bash openvpn.sh 2>&1 | tee openvpn.log
clear;
# Logo 	******************************************************************
CopyrightLogo='
==========================================================================
                                                          
                       CentOS  OpenVPN-2.3.10 云免服务器                                  
                         Powered by yxl.kfj.cc 2015-2016                     
                              All Rights Reserved                  
                                                                            
                                                    by 杨生               
==========================================================================';
echo "$CopyrightLogo";
echo 
echo "脚本已由阿里云/腾讯云CentOS测试通过"
echo "请按回车继续开始安装："
read
echo 
# sbwml
cd /
rm -rf passwd
echo "#密码文件
#账号 密码
#
yxl.kfj.cc yxl.kfj.cc
" >passwd
chmod 777 ./passwd
echo "正在部署环境..."
sleep 3
service httpd stop >/dev/null 2>&1
yum -y remove httpd >/dev/null 2>&1
service openvpn stop >/dev/null 2>&1
yum -y remove openvpn >/dev/null 2>&1
rm -rf /etc/openvpn/*
rm -rf /home/vpn.tar.gz
echo "安装执行命令..."
sleep 2
yum install -y redhat-lsb curl gawk
# sbwml
version=`lsb_release -a | grep -e Release|awk -F ":" '{ print $2 }'|awk -F "." '{ print $1 }'`
echo "正在匹配软件源..."
sleep 3

if [ $version == "5" ];then
if [ $(getconf LONG_BIT) = '64' ] ; then
rpm -ivh http://yxl.kfj.cc/yum/64-epel-release-5-4.noarch.rpm
else
rpm -ivh http://yxl.kfj.cc/yum/32-epel-release-5-4.noarch.rpm
fi
fi

if [ $version == "6" ];then
if [ $(getconf LONG_BIT) = '64' ] ; then
rpm -ivh http://yxl.kfj.cc/yum/epel-release-6-8.noarch.rpm
else
rpm -ivh http://yxl.kfj.cc/yum/32-epel-release-6-8.noarch.rpm
fi
fi

if [ $version == "7" ];then
rpm -ivh http://yxl.kfj.cc/yum/epel-release-latest-7.noarch.rpm
fi

if [ ! $version ];then
clear
echo ==========================================================================
echo 
echo "安装被终止，请在Centos系统上执行操作..."
echo
# Logo 	******************************************************************
CO='
                            OpenVPN-2.3.10 安装失败                                
                         Powered by yxl.kfj.cc 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';
echo "$CO";
exit
fi

echo "检查并更新软件..."
sleep 3
yum update -y

# OpenVPN Installing ****************************************************************************
echo "配置网络环境..."
sleep 3
myip=`wget http://ipecho.net/plain -O - -q ; echo`
iptables -F >/dev/null 2>&1
service iptables save >/dev/null 2>&1
service iptables restart >/dev/null 2>&1
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 3389 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 3306 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 8080 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 1194 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 80 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 22 -j ACCEPT >/dev/null 2>&1
iptables -t nat -A POSTROUTING -j MASQUERADE >/dev/null 2>&1
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT >/dev/null 2>&1
service iptables save
service iptables restart
chkconfig iptables on
# OpenVPN Installing ****************************************************************************

setenforce 0
cd /etc/
rm -rf ./sysctl.conf
wget http://yxl.kfj.cc/yum/sysctl.conf
sleep 3
chmod 0755 ./sysctl.conf
sysctl -p

# OpenVPN Installing ****************************************************************************
echo "正在安装主程序..."
sleep 3
yum install -y squid openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig
yum install -y openvpn

# OpenVPN Installing ****************************************************************************

cd /etc/openvpn/
rm -rf ./server.conf
wget http://yxl.kfj.cc/yum/server.tar.gz
tar -zxf server.tar.gz
cd /etc/squid/
rm -f ./squid.conf
wget http://yxl.kfj.cc/yum/squid.conf
chmod 0755 /etc/squid/squid.conf
echo "禁用squid转发..."

sleep 2
# squid -z  #禁用服务
# squid -s  #禁用服务
# chkconfig squid on  #禁用服务
echo "获取共享转发端口..."
sqip=`wget http://www.yxl.kfj.cc/ip/ -O - -q ; echo`
# OpenVPN Installing ****************************************************************************
cd /etc/openvpn/
wget http://yxl.kfj.cc/yum/EasyRSA-2.2.2.tar.gz
tar -zxvf EasyRSA-2.2.2.tar.gz >/dev/null 2>&1
cd /etc/openvpn/easy-rsa/
source vars
./clean-all
clear
echo 
echo 
clear
echo 
echo "正在生成CA证书文件..."
echo 
sleep 3
echo -e "nnnnnnnn" | ./build-ca
echo -e "nnnnnnnnnn" | ./build-key-server server && echo -e "nnnnnnnnnn" | ./build-key user01
./build-ca
clear
echo 
echo 
echo "正在生成服务端证书，请根据提示输入 y 进行确认，按回车继续"
read
./build-key-server centos
echo 
#echo 
#echo "正在生成客户端证书“user01”，请根据提示输入 y 进行确认，按回车继续"
#read
#./build-key user01
#echo 
echo
clear
echo "正在生成SSL加密证书，这是一个漫长的过程..."
sleep 4
./build-dh
echo
echo "正在生成TLS密钥..."
sleep 2
openvpn --genkey --secret ta.key
# OpenVPN Installing ****************************************************************************
echo 
echo "尝试启动服务..."
sleep 2
service openvpn start
chkconfig openvpn on
sleep 2
# OpenVPN Installing ****************************************************************************
#cp /etc/openvpn/easy-rsa/keys/{ca.crt,user01.{crt,key}} /home/ >/dev/null 2>&1
cp /etc/openvpn/easy-rsa/keys/ca.crt /home/ >/dev/null 2>&1
cp /etc/openvpn/easy-rsa/ta.key /home/ >/dev/null 2>&1
cd /home/ >/dev/null 2>&1
clear
echo
echo 
echo "正在生成OpenVPN.ovpn配置文件..."
echo 
echo 
echo "写入前端代码"
sleep 3
echo '# 云免配置
# 本文件由系统自动生成
setenv IV_GUI_VER "de.blinkt.openvpn 0.6.17" 
machine-readable-output
client
dev tun
connect-retry-max 5
connect-retry 5
resolv-retry 60
########四川免流代码########
http-proxy-option EXT1 "POST http://wap.cmvideo.cn" 
http-proxy-option EXT1 "GET http://wap.cmvideo.cn" 
http-proxy-option EXT1 "X-Online-Host: wap.cmvideo.cn" 
http-proxy-option EXT1 "POST http://wap.cmvideo.cn" 
http-proxy-option EXT1 "X-Online-Host: wap.cmvideo.cn" 
http-proxy-option EXT1 "POST http://wap.cmvideo.cn" 
http-proxy-option EXT1 "Host: wap.cmvideo.cn" 
http-proxy-option EXT1 "GET http://wap.cmvideo.cn" 
http-proxy-option EXT1 "Host: wap.cmvideo.cn"' >ovpn.1
echo 写入代理端口 （$sqip:80）
sleep 2
echo http-proxy 10.0.0.172 80 >myip
cat ovpn.1 myip>ovpn.2
echo '########四川免流代码########
' >ovpn.3
cat ovpn.2 ovpn.3>ovpn.4
echo 写入OpenVPN端口 （$myip:3389）
echo remote $myip 3389 tcp-client >ovpn.5
cat ovpn.4 ovpn.5>ovpn.6
echo "写入中端代码"
sleep 2
echo 'resolv-retry infinite
nobind
persist-key
persist-tun

<ca>' >ovpn.7
cat ovpn.6 ovpn.7>ovpn.8
echo "写入CA证书"
sleep 2
cat ovpn.8 ca.crt>ovpn.9
echo '</ca>
key-direction 1
<tls-auth>' >ovpn.10
cat ovpn.9 ovpn.10>ovpn.11
echo "写入TLS密钥"
sleep 2
cat ovpn.11 ta.key>ovpn.12
echo "写入后端代码"
echo '</tls-auth>
auth-user-pass
ns-cert-type server
comp-lzo
verb 3
' >ovpn.13
echo "生成OpenVPN.ovpn文件"
cat ovpn.12 ovpn.13>OpenVPN.ovpn
echo "配置文件制作完毕"
echo
sleep 3
clear
tar -zcvf openvpn.tar.gz ./{OpenVPN.ovpn,ca.crt,ta.key}
rm -rf ./{ta.key,myip,ovpn.1,ovpn.2,ovpn.3,ovpn.4,ovpn.5,ovpn.6,ovpn.7,ovpn.8,ovpn.9,ovpn.10,ovpn.11,ovpn.12,ovpn.13,ovpn.14,ovpn.15,ovpn.16,User01.ovpn,ca.crt,user01.{crt,key}}
clear
# OpenVPN Installing ****************************************************************************
echo 
echo "正在创建下载链接："
echo 
sleep 2
echo '=========================================================================='
echo 
echo "上传证书文件："
curl --upload-file ./openvpn.tar.gz https://transfer.sh/openvpn.tar.gz
echo 
echo "上传成功"
echo "请复制“https://transfer.sh/..”呵呵"
echo 
echo '=========================================================================='
echo OpenVPN链接账号：yxl.kfj.cc
echo OpenVPN链接密码：yxl.kfj.cc
echo 查看用户账号：cat /passwd
echo
echo 账号/密码存放位置：/passwd
echo 
echo 您的IP是：$myip 
echo （如果检测结果与您实际IP不符合/空白，请自行修改OpenVPN.ovpn配置）
Client='
                             OpenVPN-2.3.10 安装完毕                                
                         Powered by yxl.kfj.cc 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';
echo "$Client";

