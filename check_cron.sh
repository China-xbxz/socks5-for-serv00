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

# Telegram 通知函数
send_telegram_message() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TG_CHAT_ID}" \
    -d text="$message" >/dev/null
}

# 检查并添加 crontab 任务
echo "检查并添加 crontab 任务..."

# 检查 s5 相关文件是否存在
if [ -e "${S5_DIR}/s5" ] && [ -e "${S5_DIR}/config.json" ]; then
  echo "检查 socks5 的 crontab 任务..."
  
  if (crontab -l | grep -F "$CRON_S5_REBOOT" >/dev/null); then
    send_telegram_message "任务已存在: socks5 重启任务，用户: $USER"
  else
    (crontab -l; echo "$CRON_S5_REBOOT") | crontab -
    send_telegram_message "成功添加 socks5 重启任务，用户: $USER"
  fi

  if (crontab -l | grep -F "$CRON_S5_KEEPALIVE" >/dev/null); then
    send_telegram_message "任务已存在: socks5 保活任务，用户: $USER"
  else
    (crontab -l; echo "$CRON_S5_KEEPALIVE") | crontab -
    send_telegram_message "成功添加 socks5 保活任务，用户: $USER"
  fi
fi

# 检查 keepalive.sh 是否存在
if [ -e "${KEEPALIVE_SCRIPT}" ]; then
  echo "检查 keepalive.sh 的 crontab 任务..."

  if (crontab -l | grep -F "$CRON_KEEPALIVE_REBOOT" >/dev/null); then
    send_telegram_message "任务已存在: keepalive.sh 重启任务，用户: $USER"
  else
    (crontab -l; echo "$CRON_KEEPALIVE_REBOOT") | crontab -
    send_telegram_message "成功添加 keepalive.sh 重启任务，用户: $USER"
  fi

  if (crontab -l | grep -F "$CRON_KEEPALIVE_PERIODIC" >/dev/null); then
    send_telegram_message "任务已存在: keepalive.sh 定期任务，用户: $USER"
  else
    (crontab -l; echo "$CRON_KEEPALIVE_PERIODIC") | crontab -
    send_telegram_message "成功添加 keepalive.sh 定期任务，用户: $USER"
  fi
fi

# 输出完成信息
echo "socks5 和 keepalive.sh 的任务已检查并添加完成。可以通过 crontab -l 查看当前任务列表。"
