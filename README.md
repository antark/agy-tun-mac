# agy-tun-mac
mac上安装agy-tun之后就可以支持agy(antigravity)的正常登陆

# 在新 Mac 上部署 agy-tun (零依赖, 不需要访问 GitHub)
前提: 把 agy-tun-bundle.tar.gz 和 agy-tun-deploy.sh 放到同一目录

# 用法:
bash agy-tun-deploy.sh --port 1080     # 使用1080 socks5 的代理端口，默认 13659

# 执行后的输出
% bash agy-tun-deploy.sh --port 10808
[+] extracted to ~/.local/agy-tun
[+] 使用架构: arm64
[+] tun.yaml 端口已改为 10808

================================================================
部署完成

每次使用:
  sudo agy-tun-up      # 启 TUN (一次密码)
  agy                  # 不要任何 proxy env var
  sudo agy-tun-down    # 用完清理 (可选, reboot 也会清)

前提:
  - 本机 SOCKS5 代理监听 127.0.0.1:10808
  - agy 二进制本身已安装 (Antigravity 官方安装器)
================================================================
