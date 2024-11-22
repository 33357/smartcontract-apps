# MT3000 配置教学

## 路由器配置
连接路由器网络
![](./4.jpg)

访问 http://192.168.8.1 设置语言和管理员密码
![](./5.jpg)
![](./6.jpg)

之后可以进入管理员界面
![](./7.jpg)

给路由器的 WAN 口插入网线之后先同步时间
![](./8.jpg)

配置 WIFI
![](./9.jpg)

系统升级
![](./10.jpg)

## 科学网络配置
打开高级设置，点击链接
![](./11.jpg)

输入管理员密码
![](./12.jpg)

进入 openwrt 界面
![](./13.jpg)

这个原生界面用起来不是很方便，建议安装 istore 界面 https://cafe.cpolar.cn/wkdaily/gl-inet-onescript

输入 ip 地址和账户密码
![](./14.jpg)

进入命令界面
![](./15.jpg)

输入命令进入脚本界面
``` bash
wget -O gl-inet.sh https://cafe.cpolar.cn/wkdaily/gl-inet-onescript/raw/branch/master/gl-inet.sh && chmod +x gl-inet.sh && ./gl-inet.sh
```
![](./16.jpg)

输入 1，等待执行完成
![](./17.jpg)

刷新网页，界面更新
![](./18.jpg)

重启路由器
![](./19.jpg)

刷新页面，界面更新完整
![](./20.jpg)

下载 passwall 安装包 https://github.com/AUK9527/Are-u-ok/blob/main/apps/README.md 推荐第二个

在 `iStore` `手动安装`界面上传安装文件
![](./21.jpg)

等待安装结束
![](./22.jpg)

刷新界面打开 `服务`，点击 `Pass Wall`，看到 PassWall 管理界面
![](./23.jpg)

打开 `Node List`，点击 `添加`
![](./24.jpg)

导入分享 URL 或者填写节点信息，点击 `保存并使用`
![](./25.jpg)

成功添加节点
![](./26.jpg)

打开 `主开关`，选择 `TCP节点` 和 `UDP节点` ，点击 `保存并使用`
![](./27.jpg)

测试网络链接
![](./28.jpg)

点击 `App Update`，更新软件
![](./29.jpg)

点击 `Rule Manage`，配置规则
![](./30.jpg)

## 网络测试

测试 ip
![](./31.jpg)

测 google
![](./32.jpg)