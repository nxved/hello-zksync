// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EGG is ERC20, Ownable {
    constructor() ERC20("EGG", "EGG") Ownable() {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    //*******************MINT********************************
    //anyone can mint to test feeding of dinosaur
    function mintForTEST(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
