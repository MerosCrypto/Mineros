# Mineros

[Meros](https://github.com/MerosCrypto/Meros)'s Official Miner.

### Compilation

```
git clone https://github.com/MerosCrypto/Mineros
cd Mineros
nimble install https://github.com/MerosCrypto/BN https://github.com/MerosCrypto/Argon2 https://github.com/MerosCrypto/mc_bls https://github.com/MerosCrypto/Nim-Meros-RPC finals nimcrypto
```

After installing `mc_bls`, you do need to set it up. Instructions on how to can be found [here](https://github.com/MerosCrypto/mc_bls).

```
nim c src/main.nim
```
