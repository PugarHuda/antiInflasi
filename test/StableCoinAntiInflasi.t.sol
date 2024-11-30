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
// function testYieldCalculation() public {
//     // Setup awal: transfer USDe ke kontrak dan mint stablecoin
//     IERC20(susde).approve(address(stableCoin), 1000e18);
//     stableCoin.mint(1000e18, 500000e18); // Mint dengan deposit awal

//     // Simulasi waktu berjalan 1 hari (86400 detik)
//     uint256 initialBalance = stableCoin.balanceOf(address(this));
//     uint256 initialTime = block.timestamp;
//     vm.warp(initialTime + 1 days);

//     // Hitung yield yang diharapkan
//     uint256 expectedYield = (initialBalance * stableCoin.annualYieldRate() * 1 days) / (365 days * 100);
//     uint256 calculatedYield = stableCoin.calculateYield(address(this));

//     // Pastikan perhitungan yield benar
//     assertEq(calculatedYield, expectedYield, "Yield calculation mismatch");
// }

// function testClaimYield() public {
//     // Setup awal: transfer USDe ke kontrak dan mint stablecoin
//     IERC20(susde).approve(address(stableCoin), 1000e18);
//     stableCoin.mint(1000e18, 500000e18); // Mint dengan deposit awal

//     // Simulasi waktu berjalan 1 hari (86400 detik)
//     uint256 initialBalance = stableCoin.balanceOf(address(this));
//     uint256 initialTime = block.timestamp;
//     vm.warp(initialTime + 1 days);

//     // Klaim yield
//     stableCoin.claimYield();

//     // Hitung saldo setelah klaim
//     uint256 newBalance = stableCoin.balanceOf(address(this));
//     uint256 expectedYield = (initialBalance * stableCoin.annualYieldRate() * 1 days) / (365 days * 100);

//     // Pastikan saldo bertambah dengan jumlah yield yang benar
//     assertEq(newBalance, initialBalance + expectedYield, "Yield claim incorrect");

//     // Pastikan waktu klaim diperbarui
//     assertEq(stableCoin.lastClaimed(address(this)), block.timestamp, "Last claimed time not updated");
// }

// function testYieldMultipleClaims() public {
//     // Setup awal: transfer USDe ke kontrak dan mint stablecoin
//     IERC20(susde).approve(address(stableCoin), 1000e18);
//     stableCoin.mint(1000e18, 500000e18); // Mint dengan deposit awal

//     // Simulasi waktu berjalan 1 hari, klaim yield, lalu tunggu lagi
//     uint256 initialBalance = stableCoin.balanceOf(address(this));
//     vm.warp(block.timestamp + 1 days);
//     stableCoin.claimYield();

//     uint256 balanceAfterFirstClaim = stableCoin.balanceOf(address(this));
//     vm.warp(block.timestamp + 1 days); // Simulasi waktu berjalan 1 hari lagi
//     stableCoin.claimYield();

//     uint256 balanceAfterSecondClaim = stableCoin.balanceOf(address(this));
//     uint256 expectedYieldPerDay = (initialBalance * stableCoin.annualYieldRate() * 1 days) / (365 days * 100);

//     // Pastikan yield ditambahkan setiap kali klaim
//     assertEq(balanceAfterFirstClaim, initialBalance + expectedYieldPerDay, "First claim yield incorrect");
//     assertEq(balanceAfterSecondClaim, balanceAfterFirstClaim + expectedYieldPerDay, "Second claim yield incorrect");
// }

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