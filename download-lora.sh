#!/bin/bash

CIVITAI_TOKEN="REMOVED-CIVITAI-TOKEN"
LORA_DIR="/home/eric/kuan/sd-docker/stable-diffusion-webui/models/Lora"

if [ -z "$1" ]; then
    echo "用法: $0 <civitai 下載連結>"
    echo "範例: $0 https://civitai.com/api/download/models/12345"
    exit 1
fi

URL="$1"

# 如果 URL 沒有 token，自動加上
if [[ "$URL" != *"token="* ]]; then
    if [[ "$URL" == *"?"* ]]; then
        URL="${URL}&token=${CIVITAI_TOKEN}"
    else
        URL="${URL}?token=${CIVITAI_TOKEN}"
    fi
fi

echo "下載到: $LORA_DIR"

# 記錄下載前的檔案列表
before=$(ls "$LORA_DIR")

wget --content-disposition -P "$LORA_DIR" "$URL"

if [ $? -ne 0 ]; then
    echo "下載失敗"
    exit 1
fi

# 找出新下載的檔案
new_file=$(comm -13 <(echo "$before" | sort) <(ls "$LORA_DIR" | sort) | head -1)

if [ -z "$new_file" ]; then
    echo "找不到新下載的檔案"
    exit 1
fi

# 如果副檔名不是 .safetensors，自動補上
if [[ "$new_file" != *.safetensors ]]; then
    mv "$LORA_DIR/$new_file" "$LORA_DIR/${new_file}.safetensors"
    echo "重新命名: $new_file -> ${new_file}.safetensors"
fi
