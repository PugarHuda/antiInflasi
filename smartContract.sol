// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StableCoinAntiInflasi {
    uint256 public priceInIDR = 15000; // Initial price of 1 USDe in IDR
    address public owner;
    uint256 public yieldRate = 5; // Yield rate as a percentage (5%)
    uint256 public platformFee = 20; // Platform fee as a percentage (20%)
    
    struct Deposit {
        uint256 amountUSDe;
        uint256 amountIDR;
        uint256 claimableYield;
        uint256 lastUpdatedPrice; // Records the price at the last yield calculation
    }
    
    mapping(address => Deposit) public deposits;
    address[] public userAddresses; // Array to track addresses that have deposited

    constructor() {
        owner = msg.sender;
    }

    // Deposit USDe and convert it to IDR with current price
    function deposit(uint256 amountUSDe) external {
        uint256 amountIDR = amountUSDe * priceInIDR;

        Deposit storage userDeposit = deposits[msg.sender];
        
        // Update yield based on any price change
        if (userDeposit.amountUSDe > 0) {
            userDeposit.claimableYield += calculateYield(userDeposit.amountIDR, userDeposit.lastUpdatedPrice);
        } else {
            userAddresses.push(msg.sender); // Add new user address if this is the first deposit
        }

        // Record the deposit with current price details
        userDeposit.amountUSDe += amountUSDe;
        userDeposit.amountIDR += amountIDR;
        userDeposit.lastUpdatedPrice = priceInIDR;
    }

    // Calculate yield based on the amount in IDR and last updated price
    function calculateYield(uint256 amountIDR, uint256 priceAtLastUpdate) internal view returns (uint256) {
        uint256 yield = (amountIDR * yieldRate) / 100;
        uint256 adjustedYield = (yield * (100 - platformFee)) / 100;

        // Adjust the yield based on the latest price relative to the last updated price
        return (adjustedYield * priceInIDR) / priceAtLastUpdate;
    }

    // Claim the accumulated yield
    function claimYield() external {
        Deposit storage userDeposit = deposits[msg.sender];
        
        // Calculate any additional yield since the last claim
        userDeposit.claimableYield += calculateYield(userDeposit.amountIDR, userDeposit.lastUpdatedPrice);
        
        uint256 claimable = userDeposit.claimableYield;
        require(claimable > 0, "No claimable yield available");

        // Reset claimable yield and record the updated price
        userDeposit.claimableYield = 0;
        userDeposit.lastUpdatedPrice = priceInIDR;

        // Implement transfer logic for yield (e.g., in stable IDR token)
    }

    // Update the mock price via a mock oracle, recalculates claimable yield
    function updatePrice(uint256 newPriceInIDR) external onlyOwner {
        require(newPriceInIDR > 0, "Price must be greater than zero");

        // Update claimable yield for each user based on the new price
        for (uint256 i = 0; i < userAddresses.length; i++) {
            address userAddr = userAddresses[i];
            Deposit storage userDeposit = deposits[userAddr];
            userDeposit.claimableYield += calculateYield(userDeposit.amountIDR, userDeposit.lastUpdatedPrice);
            userDeposit.lastUpdatedPrice = newPriceInIDR;
        }
        
        priceInIDR = newPriceInIDR;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
}
