#!/bin/bash
# 在新 Mac 上部署 agy-tun (零依赖, 不需要访问 GitHub)
#
# 前提: 把 agy-tun-bundle.tar.gz 和本脚本放到同一目录
# 用法:
#   bash agy-tun-deploy.sh                 # 用默认 SOCKS5 端口 13659
#   bash agy-tun-deploy.sh --port 1080     # 改端口
set -e

BUNDLE="$(cd "$(dirname "$0")" && pwd)/agy-tun-bundle.tar.gz"
PORT=13659

while [ $# -gt 0 ]; do
  case "$1" in
    --port) PORT="$2"; shift 2;;
    -h|--help) sed -n '2,10p' "$0"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

[ -f "$BUNDLE" ] || { echo "[!] 找不到 $BUNDLE"; exit 1; }

# 1. 解压
mkdir -p "$HOME/.local"
tar -xzf "$BUNDLE" -C "$HOME/.local/"
DIR="$HOME/.local/agy-tun"
echo "[+] extracted to $DIR"

# 2. 按架构挑对应二进制
ARCH=$(uname -m)
case "$ARCH" in
  arm64)  SRC=hev-socks5-tunnel-arm64;;
  x86_64) SRC=hev-socks5-tunnel-x86_64;;
  *) echo "[!] 不支持的架构: $ARCH"; exit 1;;
esac
if [ ! -f "$DIR/$SRC" ]; then
  echo "[!] bundle 里没有 $SRC"; exit 1
fi
cp "$DIR/$SRC" "$DIR/hev-socks5-tunnel"
chmod +x "$DIR/hev-socks5-tunnel"
xattr -c "$DIR/hev-socks5-tunnel" 2>/dev/null || true
rm -f "$DIR/hev-socks5-tunnel-arm64" "$DIR/hev-socks5-tunnel-x86_64"
echo "[+] 使用架构: $ARCH"

# 3. 改端口
if [ "$PORT" != "13659" ]; then
  sed -i '' "s/port: 13659/port: $PORT/" "$DIR/tun.yaml"
  echo "[+] tun.yaml 端口已改为 $PORT"
fi

# 4. 创建用户级软链
mkdir -p "$HOME/.local/bin"
ln -sf "$DIR/up.sh"   "$HOME/.local/bin/agy-tun-up"
ln -sf "$DIR/down.sh" "$HOME/.local/bin/agy-tun-down"
ln -sf "$DIR/hev-socks5-tunnel" "$HOME/.local/bin/hev-socks5-tunnel"

# 5. PATH 提示
case ":$PATH:" in
  *":$HOME/.local/bin:"*) PATH_OK=yes;;
  *) PATH_OK=no;;
esac

cat <<MSG

================================================================
部署完成

每次使用:
  sudo agy-tun-up      # 启 TUN (一次密码)
  agy                  # 不要任何 proxy env var
  sudo agy-tun-down    # 用完清理 (可选, reboot 也会清)

MSG

[ "$PATH_OK" = "no" ] && cat <<MSG2
注意: \$HOME/.local/bin 不在 PATH 里, 要么:
  - 加到 ~/.zshrc:  export PATH="\$HOME/.local/bin:\$PATH"
  - 或用全路径:  sudo \$HOME/.local/bin/agy-tun-up

MSG2

cat <<MSG3
前提:
  - 本机 SOCKS5 代理监听 127.0.0.1:$PORT
  - agy 二进制本身已安装 (Antigravity 官方安装器)
================================================================
MSG3
