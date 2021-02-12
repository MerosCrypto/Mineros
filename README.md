# Mineros

The original Meros miner, which was never optimized nor threaded. It is not maintained and should not be used.

### Compilation

```
git clone https://github.com/MerosCrypto/Mineros
cd Mineros
nimble install https://github.com/MerosCrypto/mc_randomx https://github.com/MerosCrypto/mc_bls https://github.com/MerosCrypto/Nim-Meros-RPC stint
nim c src/main.nim
```

### Usage

Mineros requires an active Meros node to work. While it is possible to mine blocks without one, it isn't possible to earn Meros without a node. Mining earns Merit, which is used to verify transactions. Only by verifying transactions do Merit Holders earn Meros. Without any verifications, Meros won't mint Meros.

```
./build/Mineros 127.0.0.1 5133
```

Where `127.0.0.1` is the Meros node's IP and `5133` is the RPC port.
