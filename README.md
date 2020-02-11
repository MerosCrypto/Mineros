# Mineros

[Meros](https://github.com/MerosCrypto/Meros)' Official Miner.

### Compilation

```
git clone https://github.com/MerosCrypto/Mineros
cd Mineros
nimble install https://github.com/MerosCrypto/mc_randomx https://github.com/MerosCrypto/mc_bls https://github.com/MerosCrypto/Nim-Meros-RPC
nim c src/main.nim
```

### Usage

Mineros requires an active Meros node to work. While it is possible to mine blocks without one, it isn't possible to earn
Meros without a node. Mining earns Merit, which is used to verify transactions. Only by verifying transactions do Merit
Holders earn Meros. Without any verifications, Meros won't mint Meros.

```shell script
./build/Mineros localhost 5133
```

Where `localhost` is the Meros node and `5133` is the RPC port.
