FROM ghcr.io/ggml-org/llama.cpp:server-cuda13-b10680

ENV HF_HOME=/root/.cache/huggingface

COPY preset.ini ui-config.json /app/

EXPOSE 9931

CMD ["--host", "0.0.0.0", \
     "--port", "9931", \
     "--cors-origins", "http://localhost:9931,http://127.0.0.1:9931", \
     "--models-max", "1", \
     "--models-preset", "/app/preset.ini", \
     "--ui-config-file", "/app/ui-config.json", \
     "--ui-mcp-proxy"]
