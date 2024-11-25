// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StableCoinAntiInflasi.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StableCoinAntiInflasiTest is Test {
    StableCoinAntiInflasi public stableCoin;
    address susde = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/edkZ0hex4FXMIX8y9gjX2GGCLUybFwDJ");
        stableCoin = new StableCoinAntiInflasi(address(susde));
        deal(susde, address(this), 10000e18);
    }

    function testMint() public {
        IERC20(susde).approve(address(stableCoin), 1000e18);
        stableCoin.mint(100, 500000);

        uint256 userBalance = stableCoin.balanceOf(address(this));
        assertEq(userBalance, 500000);
    }

    function testBorrow() public {
        IERC20(susde).approve(address(stableCoin), 1000e18);
        stableCoin.mint(200, 100000);

        uint256 userBalance = stableCoin.balanceOf(address(this));
        assertEq(userBalance, 100000);
    }

    function testRepay() public {
        IERC20(susde).approve(address(stableCoin), 1000e18);
        stableCoin.mint(200, 100000);

        stableCoin.repay(50000);

        (uint256 amountUSDe, uint256 amountIDR) = stableCoin.deposits(address(this));
        assertEq(amountIDR, 50000);
    }

    function testWithdraw() public {
        IERC20(susde).approve(address(stableCoin), 1000e18);
        stableCoin.mint(200, 100000);

        stableCoin.withdraw(100);

        (uint256 amountUSDe, uint256 amountIDR) = stableCoin.deposits(address(this));
        assertEq(amountUSDe, 100);
    }

//     function testLiquidate() public {
//     IERC20(susde).approve(address(stableCoin), 1000e18);
//     stableCoin.mint(200, 100000);

//     stableCoin.setPriceInIDR(10000); // Decrease price to trigger liquidation
//     stableCoin.liquidate(address(this));

//     (uint256 amountUSDe, uint256 amountIDR) = stableCoin.deposits(address(this));
//     assertEq(amountUSDe, 100); // Remaining collateral
//     assertEq(amountIDR, 0);    // Debt cleared
// }

}
