## Merkle Airdrop
A Merkle Airdrop is a cryptographic method for efficiently distributing tokens to a large group of people while minimizing the amount of data stored on the blockchain.

Basically this is the file strucutre of the contracts : 

```plaintext
src/
├── MerkleAirdrop.sol      
└── BagelToken.sol

script/
├── DeployMerkleAirdrop.s.sol      
├── GenerateInput.s.sol
├── target/
├── MakeMerkle.s.sol
└── Interact.s.sol

test/
├── Crypto.t.sol      
└── MerkleAirdrop.s.sol
```
### Structure

```plaintext
1. List of Eligible Users and Token Amounts
+---------------------------------------------------------------+
|   Address 1    ->  Amount 1                                    |
|   Address 2    ->  Amount 2                                    |
|   Address 3    ->  Amount 3                                    |
|   Address 4    ->  Amount 4                                    |
|   ...                                                    |
+---------------------------------------------------------------+

2. Hashing Each Address and Amount into Leaf Nodes
+-------------------------+      +-------------------------+ 
| Hash(Address 1, Amount 1) |      | Hash(Address 2, Amount 2) | 
+-------------------------+      +-------------------------+ 
            |                              |
            v                              v
+-------------------------+      +-------------------------+ 
| Hash(Address 3, Amount 3) |      | Hash(Address 4, Amount 4) | 
+-------------------------+      +-------------------------+

3. Building the Merkle Tree (Parent Nodes)
+---------------------------------------+       +---------------------------------------+
| Hash( Hash(Address 1, Amount 1),     |       | Hash( Hash(Address 3, Amount 3),     |
|      Hash(Address 2, Amount 2) )     |       |      Hash(Address 4, Amount 4) )     |
+---------------------------------------+       +---------------------------------------+

4. Final Merkle Root (Stored on-chain)
+---------------------------------------------------------------+
| Merkle Root (Single Hash)                                      |
| (Represents the entire structure)                              |
+---------------------------------------------------------------+

5. User Claim Process
- User submits their Merkle Proof, consisting of hashes required
  to verify their inclusion in the Merkle tree.
  
- The Merkle Proof is validated against the stored Merkle Root.
- If valid, the user is eligible to claim their tokens.
```

## MerkleAirdrop.sol

### Overview

`MerkleAirdrop.sol` is a smart contract designed to facilitate a token airdrop using a Merkle tree structure. It enables a trusted party to distribute tokens to a list of eligible addresses in a secure and verifiable manner. Users can claim their tokens by proving they are part of the Merkle tree, which is a cryptographic proof that validates their eligibility. Additionally, the contract implements signature-based verification to ensure the authenticity of claims.

### Key Features

- **Merkle Proof Validation**: Users can claim tokens only if their address and amount are included in the Merkle tree, validated through Merkle proof.
- **Single Claim Per Address**: Each address can only claim once, preventing double claims.
- **Signature Verification**: Claims are signed by a designated signer, and the contract verifies the signature to ensure authenticity.

### Key Variables

- `i_merkleRoot`: The Merkle root used to verify the validity of claims.
- `i_airdropToken`: The ERC20 token to be distributed during the airdrop.
- `s_hasClaimed`: A mapping that tracks whether an address has already claimed tokens.
- `MESSAGE_TYPEHASH`: A constant used in the EIP712 hashing process for claim messages.

### Key Functions

- **claim**: Allows an eligible address to claim their tokens by providing their Merkle proof, signature, and claim details.
- **getMessageHash**: Generates an EIP712 hash of the claim data, used to verify signatures.
- **_isValidSignature**: Verifies the signature of the claim to ensure it matches the expected signer.

### Events

- `Claim`: Emitted when a user successfully claims their tokens.

---

## BagelToken.sol

### Overview

`BagelToken.sol` is a basic ERC20 token contract that allows the contract owner to mint new tokens. It is designed to be used in conjunction with the `MerkleAirdrop.sol` contract as the airdrop token. The token follows the standard ERC20 implementation from OpenZeppelin, with the addition of minting functionality, making it suitable for use in token distribution schemes like airdrops.

### Key Features

- **ERC20 Token Implementation**: The contract follows the standard ERC20 token interface, allowing it to be used in various decentralized applications.
- **Minting**: Only the owner of the contract can mint new tokens, enabling controlled token issuance for purposes like airdrops.

### Key Functions

- **mint**: Allows the contract owner to mint new tokens and send them to a specified address.

---

## Conclusion

Together, these two contracts facilitate a secure and efficient way to conduct airdrops, ensuring that only eligible users receive tokens and that the claims are both verified and secure.
