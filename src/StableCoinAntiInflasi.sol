// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StableCoinAntiInflasi is ERC20 {
    uint256 public priceInIDR = 15000; // Initial price of 1 USDe in IDR
    address public owner;
    address public USDeToken; // Address of USDe ERC20 token

    uint256 constant public LTV = 90; // Loan-to-Value ratio in percentage

    struct Deposit {
        uint256 amountUSDe;
        uint256 amountIDR;
    }

    event Borrow(address indexed user, uint256 amountIDR);
    event Withdraw(address indexed user, uint256 amountUSDe);
    event Repay(address indexed user, uint256 amountIDR);

    mapping(address => Deposit) public deposits;

    constructor(address _USDeToken) ERC20("IDR Stablecoin", "IDR") {
        owner = msg.sender;
        USDeToken = _USDeToken;
    }

    function setPriceInIDR(uint256 newPriceInIDR) external onlyOwner {
        require(newPriceInIDR > 0, "Price must be greater than 0");
        priceInIDR = newPriceInIDR;
    }

    function mint(uint256 amountUSDe, uint256 borrowIdr) external {
        ERC20(USDeToken).transferFrom(msg.sender, address(this), amountUSDe);

        deposits[msg.sender].amountUSDe += amountUSDe;
        deposits[msg.sender].amountIDR += borrowIdr;

        _mint(msg.sender, borrowIdr);

        isHealthy(msg.sender);
    }

    function borrow(uint256 amountIDR) external {
        deposits[msg.sender].amountIDR += amountIDR;

        _mint(msg.sender, amountIDR);

        emit Borrow(msg.sender, amountIDR);
        isHealthy(msg.sender);
    }

    function repay(uint256 amountIDR) external {
        require(balanceOf(msg.sender) >= amountIDR, "Not enough IDR balance to repay");

        _burn(msg.sender, amountIDR);

        deposits[msg.sender].amountIDR -= amountIDR;

        emit Repay(msg.sender, amountIDR);

        isHealthy(msg.sender);
    }

    function withdraw(uint256 amountUSDe) external {
        require(deposits[msg.sender].amountUSDe >= amountUSDe, "Not enough collateral to withdraw");

        uint256 newCollateralValue = (deposits[msg.sender].amountUSDe - amountUSDe) * priceInIDR * LTV / 100;
        require(newCollateralValue >= deposits[msg.sender].amountIDR, "Loan will not be healthy after withdrawal");

        deposits[msg.sender].amountUSDe -= amountUSDe;

        ERC20(USDeToken).transfer(msg.sender, amountUSDe);

        emit Withdraw(msg.sender, amountUSDe);

        isHealthy(msg.sender);
    }

    function isHealthy(address user) public {
        uint256 collateralValue = deposits[user].amountUSDe * priceInIDR * LTV / 100;
        uint256 debt = deposits[user].amountIDR;

        require(collateralValue >= debt, "Loan is not healthy");
    }

    function liquidate(address user) external {
    uint256 collateralValue = deposits[user].amountUSDe * priceInIDR * LTV / 100;
    uint256 debt = deposits[user].amountIDR;

    require(collateralValue < debt, "Loan is still healthy, cannot liquidate");

    uint256 remainingCollateral = debt * 100 / (priceInIDR * LTV);
    deposits[user].amountUSDe = remainingCollateral;
    deposits[user].amountIDR = 0;

    _burn(user, debt);

    emit Liquidate(user);
    
}
event Liquidate(address indexed user);


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
}
