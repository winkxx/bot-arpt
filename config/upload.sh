#!/usr/bin/env bash
#
# Copyright (c) 2018-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/aria2.conf
# File name：upload.sh
# Description: Use Rclone to upload files after Aria2 download is complete
# Version: 2.2
#

## 基础设置 ##

# Aria2 下载目录
DOWNLOAD_PATH='/root/Download'

# Rclone 配置时填写的网盘名
DRIVE_NAME=$Remote

# 网盘目录。即上传目标路径，留空为网盘根目录，末尾不要有斜杠。
DRIVE_PATH=$Upload

# 日志保存路径。注释或留空为不保存。
#LOG_PATH='/root/.aria2/upload.log'

## 文件过滤 ##

# 限制最低上传大小，仅 BT 多文件下载时有效，用于过滤无用文件。低于此大小的文件将被删除，不会上传。
#MIN_SIZE=10m

# 保留文件类型，仅 BT 多文件下载时有效，用于过滤无用文件。其它文件将被删除，不会上传。
#INCLUDE_FILE='mp4,mkv,rmvb,mov'

# 排除文件类型，仅 BT 多文件下载时有效，用于过滤无用文件。排除的文件将被删除，不会上传。
#EXCLUDE_FILE='html,url,lnk,txt,jpg,png'

## 高级设置 ##

# RCLONE 配置文件路径
#export RCLONE_CONFIG=$HOME/.config/rclone/rclone.conf

# RCLONE 配置文件密码
#export RCLONE_CONFIG_PASS=password

# RCLONE 并行上传文件数，仅对单个任务有效。
#export RCLONE_TRANSFERS=4

# RCLONE 块的大小，默认5M，理论上是越大上传速度越快，同时占用内存也越多。如果设置得太大，可能会导致进程中断。
#export RCLONE_CACHE_CHUNK_SIZE=5M

# RCLONE 块可以在本地磁盘上占用的总大小，默认10G。
#export RCLONE_CACHE_CHUNK_TOTAL_SIZE=10G

# RCLONE 上传失败重试次数，默认 3
#export RCLONE_RETRIES=3

# RCLONE 上传失败重试等待时间，默认禁用，单位 s, m, h
export RCLONE_RETRIES_SLEEP=10s

# RCLONE 异常退出重试次数
RETRY_NUM=2

#============================================================

FILE_PATH=$3                                   # Aria2传递给脚本的文件路径。BT下载有多个文件时该值为文件夹内第一个文件，如/root/Download/a/b/1.mp4
RELATIVE_PATH=${FILE_PATH#${DOWNLOAD_PATH}/}   # 路径转换，去掉开头的下载路径。
TOP_PATH=${DOWNLOAD_PATH}/${RELATIVE_PATH%%/*} # 路径转换，BT下载文件夹时为顶层文件夹路径，普通单文件下载时与文件路径相同。
RED_FONT_PREFIX="\033[31m"
LIGHT_GREEN_FONT_PREFIX="\033[1;32m"
YELLOW_FONT_PREFIX="\033[1;33m"
LIGHT_PURPLE_FONT_PREFIX="\033[1;35m"
FONT_COLOR_SUFFIX="\033[0m"
INFO="[${LIGHT_GREEN_FONT_PREFIX}INFO${FONT_COLOR_SUFFIX}]"
ERROR="[${RED_FONT_PREFIX}ERROR${FONT_COLOR_SUFFIX}]"
WARRING="[${YELLOW_FONT_PREFIX}WARRING${FONT_COLOR_SUFFIX}]"

TASK_INFO() {
    echo -e "
-------------------------- [${YELLOW_FONT_PREFIX}TASK INFO${FONT_COLOR_SUFFIX}] --------------------------
${LIGHT_PURPLE_FONT_PREFIX}Download path:${FONT_COLOR_SUFFIX} ${DOWNLOAD_PATH}
${LIGHT_PURPLE_FONT_PREFIX}File path:${FONT_COLOR_SUFFIX} ${FILE_PATH}
${LIGHT_PURPLE_FONT_PREFIX}Upload path:${FONT_COLOR_SUFFIX} ${UPLOAD_PATH}
${LIGHT_PURPLE_FONT_PREFIX}Remote path:${FONT_COLOR_SUFFIX} ${REMOTE_PATH}
-------------------------- [${YELLOW_FONT_PREFIX}TASK INFO${FONT_COLOR_SUFFIX}] --------------------------
"
}

CLEAN_UP() {
    [[ -n ${MIN_SIZE} || -n ${INCLUDE_FILE} || -n ${EXCLUDE_FILE} ]] && echo -e "${INFO} Clean up excluded files ..."
    [[ -n ${MIN_SIZE} ]] && rclone delete -v "${UPLOAD_PATH}" --max-size ${MIN_SIZE}
    [[ -n ${INCLUDE_FILE} ]] && rclone delete -v "${UPLOAD_PATH}" --exclude "*.{${INCLUDE_FILE}}"
    [[ -n ${EXCLUDE_FILE} ]] && rclone delete -v "${UPLOAD_PATH}" --include "*.{${EXCLUDE_FILE}}"
}

UPLOAD_FILE() {
    RETRY=0
    RETRY_NUM=2
    TASK_INFO
    while [ ${RETRY} -le ${RETRY_NUM} ]; do
        [ ${RETRY} != 0 ] && (
            echo
            echo -e "$(date +"%m/%d %H:%M:%S") ${ERROR} Upload failed! Retry ${RETRY}/${RETRY_NUM} ..."
            echo -e "$(date +"%m/%d %H:%M:%S") ${ERROR} 上传失败，重新尝试 Retry ${RETRY}/${RETRY_NUM} ..."
            echo
        )
        rclone move -P -v "${UPLOAD_PATH}" "${REMOTE_PATH}"#更换为copy模式
        echo && echo -e "rclone 开始上传"
        RCLONE_EXIT_CODE=$?
        if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
            [ -e "${DOT_ARIA2_FILE}" ] && rm -vf "${DOT_ARIA2_FILE}"
            rclone rmdirs -v "${DOWNLOAD_PATH}" --leave-root
            echo -e "$(date +"%m/%d %H:%M:%S") ${INFO} Upload done: ${UPLOAD_PATH} -> ${REMOTE_PATH}"
            [ $LOG_PATH ] && echo -e "$(date +"%m/%d %H:%M:%S") [INFO] Upload done: ${UPLOAD_PATH} -> ${REMOTE_PATH}" >>${LOG_PATH}
            echo -e "$(date +"%m/%d %H:%M:%S") [INFO] 上传完成: ${UPLOAD_PATH} -> ${REMOTE_PATH}" >>${LOG_PATH}
            break
        else
            RETRY=$((${RETRY} + 1))
            [ ${RETRY} -gt ${RETRY_NUM} ] && (
                echo
                echo -e "$(date +"%m/%d %H:%M:%S") ${ERROR} Upload failed: ${UPLOAD_PATH}"
                echo -e "$(date +"%m/%d %H:%M:%S") ${ERROR} 上传失败: ${UPLOAD_PATH}"
                [ $LOG_PATH ] && echo -e "$(date +"%m/%d %H:%M:%S") [ERROR] Upload failed: ${UPLOAD_PATH}" >>${LOG_PATH}
                echo
            )
            sleep 3
        fi
       
    done
}

UPLOAD() {
    echo -e "$(date +"%m/%d %H:%M:%S") ${INFO} Start upload..."
    echo && echo -e "开始上传"
    TASK_INFO
    UPLOAD_FILE
}



if [ -e "${FILE_PATH}.aria2" ]; then
    DOT_ARIA2_FILE="${FILE_PATH}.aria2"
elif [ -e "${TOP_PATH}.aria2" ]; then
    DOT_ARIA2_FILE="${TOP_PATH}.aria2"
fi
UPLOAD

/bot/drc push "${FILE_PATH}" "${RELATIVE_PATH}"
echo -e "${ERROR} Unknown error."
TASK_INFO
exit 1
