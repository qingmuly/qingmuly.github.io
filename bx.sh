#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# wget http://yxl.kfj.cc/openvpn.sh && bash openvpn.sh 2>&1 | tee openvpn.log
clear;
# Logo 	******************************************************************
CopyrightLogo='
==========================================================================
                                                          
                       CentOS  OpenVPN-2.3.10                                   
                                             
                                            
                                                                            
                                                    自动脚本测试               
==========================================================================';
echo "$CopyrightLogo";
echo 
echo "脚本已由阿里云/腾讯云CentOS测试通过"
echo "请按回车继续开始安装："
read
echo 
# sbwml
#cd /
#rm -rf passwd
#echo "#密码文件
#账号 密码
#
#1 1
#" >passwd
#chmod 777 ./passwd
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
read -p "请设置数据库密码："  mysqlpass
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
rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
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

myip=`wget http://www.icanhazip.com -O - -q ; echo`
iptables -F >/dev/null 2>&1
service iptables save >/dev/null 2>&1
service iptables restart >/dev/null 2>&1
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 3389 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 3306 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 8080 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 1194 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 443 -j ACCEPT >/dev/null 2>&1
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
wget http://qingmuly.github.io/sysctl.conf
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
rm -rf ./login.sh
rm -rf ./disconnect.sh
rm -rf ./connect.sh
wget http://qingmuly.github.io/server.tar.gz
tar -zxf server.tar.gz
cd /etc/squid/
rm -f ./squid.conf
wget http://qingmuly.github.io/squid.conf
chmod 0755 /etc/squid/squid.conf
echo "禁用squid转发..."


cd /bin/
wget http://qingmuly.github.io/proxy
chmod 777 proxy
./proxy -l 8080 -d >/dev/null 2>&1
echo "启动proxy"





yum install httpd -y
sleep 3
yum install mysql mysql-server -y
sleep 1
yum install php -y
sleep 2
yum install php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php- mcrypt php-bcmath php-mhash libmcrypt -y
yum  install  php-mcrypt  libmcrypt  libmcrypt-devel -y

cd  /etc/httpd/conf/
rm -f httpd.conf
wget http://qingmuly.github.io/httpd.conf


sleep 3

/etc/init.d/mysqld start
/etc/init.d/httpd restart
chkconfig mysqld on
chkconfig httpd on



cd /var/www/html/
wget http://qingmuly.github.io/WEB.zip
unzip WEB.zip
mysqladmin -u root password $mysqlpass
sleep 2
cd /root/
wget http://qingmuly.github.io/q.sql
sleep 2
mysql -uroot -pqqq123 -e "source /root/q.sql"  
sleep 5
echo "数据库导入完成......"

sleep 2
# squid -z  #禁用服务
# squid -s  #禁用服务
# chkconfig squid on  #禁用服务
echo "获取共享转发端口..."
sqip=`wget http://www.icanhazip.com/ -O - -q ; echo`
# OpenVPN Installing ****************************************************************************
cd /etc/openvpn/
wget http://qingmuly.github.io/EasyRSA-2.2.2.tar.gz
tar -zxvf EasyRSA-2.2.2.tar.gz >/dev/null 2>&1
cd /etc/openvpn/easy-rsa/
#开始配置证书
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
echo '# 半夏测试免流配置
# 本文件由系统自动生成
# 常规模式
client
dev tun
proto tcp
########免流代码########
remote wap.10086.cn 80
http-proxy-option EXT1 POST http://wap.10086.cn
http-proxy-option EXT1 VPN
http-proxy-option EXT1 Host: wap.10086.cn / HTTP/1.1"' >ovpn.1
echo 写入代理端口 （$sqip:8080）
sleep 2
echo http-proxy $sqip 8080 >myip
cat ovpn.1 myip>ovpn.2
echo '########免流代码########
' >ovpn.3
cat ovpn.2 ovpn.3>ovpn.4
echo 写入OpenVPN端口 （$myip:443）
echo '#remote $myip 443 tcp-client' >ovpn.5
cat ovpn.4 ovpn.5>ovpn.6
echo "写入中端代码"
sleep 2
echo 'resolv-retry infinite
nobind
persist-key
persist-tun
push route 114.114.114.114 114.114.115.115
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
#echo "上传证书文件："
echo 
sleep 2
clear
echo '=========================================================================='
echo 
cp openvpn.tar.gz /var/www/html
sed -i "s/MySQLPass/$mysqlpass/g" /var/www/html/php/conn.php
sed -i "s/www.52ml.org/$myip/g" /var/www/html/php/conn.php
echo "正在创建下载链接："
#curl --upload-file ./openvpn.tar.gz https://transfer.sh/openvpn.tar.gz
#echo 
#$echo "请复制并下载： "
#$curl -# --upload-file ./openvpn.tar.gz https://transfer.sh/openvpn.tar.gz
#$echo 
echo '=========================================================================='
echo "配置文件下载地址为：http://$sqip/openvpn.tar.gz"
echo "请下载后删除源文件"
echo
echo 
echo 您的IP是：$myip 
echo （如果检测结果与您实际IP不符合/空白，请自行修改OpenVPN.ovpn配置）
Client='
                             OpenVPN-2.3.10 安装完毕                                
                         Powered by yxl.kfj.cc 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';
echo "$Client";

