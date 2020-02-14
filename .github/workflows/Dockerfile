FROM nimlang/nim:1.0.4 AS builder
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    curl
RUN cd Mineros && \
    nimble install https://github.com/MerosCrypto/mc_randomx && \
    nimble install https://github.com/MerosCrypto/mc_bls && \
    nimble install https://github.com/MerosCrypto/Nim-Meros-RPC && \
    nim c src/main.nim

FROM ubuntu:devel
COPY --from=builder ./Mineros/build/Mineros .
ENTRYPOINT ["./Mineros"]