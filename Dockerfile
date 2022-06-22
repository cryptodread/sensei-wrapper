FROM --platform=linux/arm64/v8 node:12-buster-slim AS builder

WORKDIR /build
COPY . .
RUN apt-get update
RUN apt-get install -y git python3 curl build-essential
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN npm install && npm run build

FROM --platform=linux/arm64/v8 node:16-buster-slim
RUN apt-get update && apt-get install wget build-essential -y && wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_arm.tar.gz -O - |\
        tar xz && mv yq_linux_arm /usr/bin/yq
COPY . .
WORKDIR /sensei/web-admin
COPY --from=builder /build .
COPY --from=builder $HOME/.cargo $HOME/.cargo

WORKDIR /sensei/
# Import Entrypoint and give permissions
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD assets/utils/check-web.sh /usr/local/bin/check-web.sh
RUN chmod +x /usr/local/bin/check-web.sh

EXPOSE 80 5401

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
