#!/bin/bash

# 当前用户和目录定义
USER=$(whoami)
S5_DIR="/home/${USER}/.s5"
KEEPALIVE_SCRIPT="/home/${USER}/serv00-play/keepalive.sh"

# 定时任务命令定义
CRON_S5_REBOOT="@reboot nohup ${S5_DIR}/s5 -c ${S5_DIR}/config.json >/dev/null 2>&1 &"
CRON_S5_KEEPALIVE="*/28 * * * * pgrep -x 's5' > /dev/null || nohup ${S5_DIR}/s5 -c ${S5_DIR}/config.json >/dev/null 2>&1 &"
CRON_KEEPALIVE_REBOOT="@reboot bash ${KEEPALIVE_SCRIPT} > /dev/null 2>&1"
CRON_KEEPALIVE_PERIODIC="*/30 * * * * bash ${KEEPALIVE_SCRIPT} > /dev/null 2>&1"

# 检查并添加 crontab 任务
echo "检查并添加 crontab 任务..."

# 检查 s5 相关文件是否存在
if [ -e "${S5_DIR}/s5" ] && [ -e "${S5_DIR}/config.json" ]; then
  echo "添加 socks5 的 crontab 重启任务"
  (crontab -l | grep -F "$CRON_S5_REBOOT") || (crontab -l; echo "$CRON_S5_REBOOT") | crontab -
  (crontab -l | grep -F "$CRON_S5_KEEPALIVE") || (crontab -l; echo "$CRON_S5_KEEPALIVE") | crontab -
fi

# 检查 keepalive.sh 是否存在
if [ -e "${KEEPALIVE_SCRIPT}" ]; then
  echo "添加 keepalive.sh 的 crontab 重启和定期任务"
  (crontab -l | grep -F "$CRON_KEEPALIVE_REBOOT") || (crontab -l; echo "$CRON_KEEPALIVE_REBOOT") | crontab -
  (crontab -l | grep -F "$CRON_KEEPALIVE_PERIODIC") || (crontab -l; echo "$CRON_KEEPALIVE_PERIODIC") | crontab -
fi

# 输出完成信息
echo "socks5 和 keepalive.sh 的任务已检查并添加完成。可以通过 crontab -l 查看当前任务列表。"
