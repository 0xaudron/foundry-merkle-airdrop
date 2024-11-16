// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    bytes32 public ROOT =
        0x7c87e00359d4761ac276e1141b46a73796510ead0a6a440761c2aebb1ce386a9;
    address public user;
    address public gasPayer;
    uint256 public userPrivKey;
    uint256 AMOUNT = 25 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT * 5;
    bytes32 PROOF_ONE =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 PROOF_TWO =
        0xe1c4aac40cc4f9cf6b13e431bf3707048fddfa15bbeee6d1b58e224f736c846b;
    bytes32[] PROOF = [PROOF_ONE, PROOF_TWO];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        assertEq(startingBalance, 0);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance : ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
