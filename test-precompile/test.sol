// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Contract {
    struct Ciphertext {
        bytes cipher;
        string req_id;
    }
    event SatisfiedConditions(string[] conditions);
    Ciphertext public ciphertext;
    bytes public plaintext;
    function storeCipher(bytes memory _cipher, string memory req_id) external {
        ciphertext.cipher = _cipher;
        ciphertext.req_id = req_id;
    }

    // This function simulates checking conditions and returns some condition strings
    function checkCondition() external returns (string[] memory) {
        if (
            keccak256(abi.encode(ciphertext.req_id)) !=
            keccak256(abi.encode(""))
        ) {
            string[] memory reqId_done = new string[](100);

            reqId_done[0] = string(abi.encodePacked(ciphertext.req_id)); // This should be a real condition that has been satisfied based on some checks. For instance, after a sprcific timestamp.

            emit SatisfiedConditions(reqId_done);
            ciphertext.req_id = "";
            return reqId_done;
        }
        return new string[](0);
    }

    // This function accepts a key and a condition and decrypts the ciphertexts
    function keySubmission(
        bytes calldata key,
        string calldata condition
    ) external returns (bytes memory) {
        address precompileAddress = address(
            0x0000000000000000000000000000000000000094
        );
        bytes memory c = bytes(condition);

        uint32 cipherLength=uint32(ciphertext.cipher.length);

        bytes memory length1 = new bytes(4);
        length1[0] = bytes1(uint8(cipherLength >> 24));
        length1[1] = bytes1(uint8(cipherLength >> 16));
        length1[2] = bytes1(uint8(cipherLength >> 8));
        length1[3] = bytes1(uint8(cipherLength));

        uint32 idLength=uint32(c.length);
        
        bytes memory length2 = new bytes(4);
        length2[0] = bytes1(uint8(idLength >> 24));
        length2[1] = bytes1(uint8(idLength >> 16));
        length2[2] = bytes1(uint8(idLength >> 8));
        length2[3] = bytes1(uint8(idLength));
        
         (bool success, bytes memory decryptedData) = precompileAddress.call(
               abi.encodePacked(uint8(3),key, length1, length2, ciphertext.cipher, c)
            );
       
      
        plaintext = decryptedData;
        return decryptedData;
    }
}
