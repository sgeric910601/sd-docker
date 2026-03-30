FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    git wget curl libgl1 libglib2.0-0 \
    libgoogle-perftools4 libtcmalloc-minimal4 \
    fonts-dejavu-core bc \
    && rm -rf /var/lib/apt/lists/*

# 建立與 host eric (uid=1002) 相同 uid 的使用者
RUN useradd -m -u 1002 sduser && chown sduser:sduser /opt/conda

# 安裝 SD 需要的額外套件
COPY requirements_versions.txt /tmp/requirements_versions.txt
RUN pip install --no-cache-dir openai-clip && \
    pip install --no-cache-dir -r /tmp/requirements_versions.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER sduser
WORKDIR /sd

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--listen", "--port", "7860", "--skip-torch-cuda-test", "--no-half-vae", "--medvram", "--unload-gfpgan"]
