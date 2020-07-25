FROM nimlang/nim:1.2.4 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    curl

RUN nimble install https://github.com/MerosCrypto/mc_randomx && \
    nimble install https://github.com/MerosCrypto/mc_bls && \
    nimble install https://github.com/MerosCrypto/Nim-Meros-RPC && \
    nimble install stint -y

COPY . ./
RUN nim c src/main.nim

FROM ubuntu:devel
COPY --from=builder ./build/Mineros .
ENTRYPOINT ["./Mineros"]
