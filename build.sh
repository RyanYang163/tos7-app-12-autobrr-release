#!/bin/bash
# Build script — TOS 7 Docker application package
set -e
APPID="tos7-app-12-autobrr"
OUT="build/output"
rm -rf build "$OUT"; mkdir -p "$OUT"

# 图标在 images/icons/ 下(或 Assets/Icons,视 D2 违规而定),文件名不一定等于 <appid>
ICON=$(ls images/icons/*.svg images/icons/*.png \
         Assets/Icons/*.svg Assets/Icons/*.png 2>/dev/null | head -1)
if [ -z "$ICON" ]; then
    echo "ERROR: no icon found under images/icons/" >&2
    exit 1
fi
EXT=$(printf '%s' "${ICON##*.}")

# 暂存区:把包内该有的文件按平台要求摊到根
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
cp config.ini "${APPID}.lang" docker-compose.yml "$STAGE/"
cp "$ICON" "$STAGE/${APPID}.${EXT}"
for x in init.d DEBIAN prebuilt Scripts scripts; do
    [ -e "$x" ] && cp -r "$x" "$STAGE/" 2>/dev/null || true
done

tar -czf "$OUT/${APPID}.tar.gz" -C "$STAGE" .
# 显式写成 POSIX 的「<hash>  <name>」两空格格式:
# Git Bash 的 sha256sum 默认输出二进制模式,会带一个 '*' 前缀,平台解析不了
( cd "$OUT" && printf '%s  %s\n' \
    "$(sha256sum "${APPID}.tar.gz" | cut -d' ' -f1)" \
    "${APPID}.tar.gz" > "${APPID}.tar.gz.sha256" )
echo "=== Built: $OUT/${APPID}.tar.gz ==="
tar -tzf "$OUT/${APPID}.tar.gz" | sed 's/^/    /'
