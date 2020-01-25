# Mineros

[Meros](https://github.com/MerosCrypto/Meros)'s Official Miner.

### Compilation

```
git clone https://github.com/MerosCrypto/Mineros
cd Mineros
nimble install https://github.com/MerosCrypto/mc_randomx https://github.com/MerosCrypto/mc_bls https://github.com/MerosCrypto/Nim-Meros-RPC
nim c src/main.nim
```

### Usage

Mineros requires an active Meros node to work. While it is possible to mine blocks without one, it isn't possible to earn Meros without a node. Mining earns Merit, which is used to verify transactions. Only by verifying transactions do Merit Holders earn Meros. Without any verifications, Meros won't mint Meros.

The first step is acquiring your miner key. This can done via the `ClientRPCSample`, located under `Meros/samples/`. Building and running it via `nim c -r samples/ClientRPCSample`, from within `Meros/`, will allow you to call the `personal` module's `getMiner` method, which takes 0 arguments. The output will be a JSON object whose `result` value will be a string starting with 32 0s.

Then, to run Mineros, execute `./build/Mineros 00000000000000000000000000000000...`. Mineros will automatically start mining.
