FROM --platform=linux/arm64/v8 node:16 as build-web-admin

WORKDIR /build

COPY sensei/ .

WORKDIR /build/web-admin
RUN npm install
RUN npm run build

FROM --platform=linux/arm64/v8 rust:1.56 as build-sensei

WORKDIR /build

# copy your source tree
COPY sensei/ .

COPY --from=build-web-admin /build/web-admin/build/ /build/web-admin/build/

RUN rustup component add rustfmt

RUN cargo build --verbose --release

# our final base
FROM --platform=linux/arm64/v8 rust:1.56

# copy the build artifact from the build stage
COPY --from=build-sensei /build/target/release/senseid .

RUN apt-get update && apt-get install wget -y && wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_arm.tar.gz -O - |\
        tar xz && mv yq_linux_arm /usr/bin/yq

# Import Entrypoint and give permissions
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD assets/utils/check-web.sh /usr/local/bin/check-web.sh
RUN chmod +x /usr/local/bin/check-web.sh

EXPOSE 80 5401 3001

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
