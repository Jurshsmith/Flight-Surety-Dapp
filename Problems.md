WORKING WITH THE ASYNC PARADIGM:

Problems that can be potentially solved later should listed here:

- Figure out how to make testing seamless, things like watching the test files and restarting on file change. [FIXED]

- `bytes32` as flight key in Flight struct type throws an error even after using this snippet to compute the bytes32 data from the client side:

```
  const encoded = contract.web3.eth.abi.encodeParameters(['string', 'string'], [flightName, salt]);
  const hash = contract.web3.utils.sha3(encoded, { encoding: 'hex' });
  console.log({ hash });
```

Short term solution: use `string` instead.

- The issue was actually related to gas limit and spec in web3 vs ganache-cli

```
 this error appears when you don't add the "gas" parameter to "send" method. Too bad that it is not documented anywhere...

So the correct method call should be: contract.methods.mymethod.send({from: account, gas: })
```
