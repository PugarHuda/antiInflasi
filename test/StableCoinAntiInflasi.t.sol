// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StableCoinAntiInflasi.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MOCK") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}

contract StableCoinAntiInflasiTest is Test {
    StableCoinAntiInflasi public stableCoin;
    MockERC20 public mockToken;

    function setUp() public {
        mockToken = new MockERC20();
        stableCoin = new StableCoinAntiInflasi(address(mockToken));
    }

    function testMint() public {
        mockToken.approve(address(stableCoin), 1000 * 10 ** mockToken.decimals());
        stableCoin.mint(100, 500000);

        uint256 userBalance = stableCoin.balanceOf(address(this));
        assertEq(userBalance, 500000);
    }

    function testUpdatePrice() public {
        stableCoin.updatePrice(20000);
        assertEq(stableCoin.priceInIDR(), 20000);
    }
}
