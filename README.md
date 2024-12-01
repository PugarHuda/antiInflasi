
# StableCoinAntiInflasi Smart Contract

This Solidity smart contract provides a stablecoin solution for Indonesian Rupiah (IDR) pegged to the US Dollar (USD) through a Loan-to-Value (LTV) mechanism. It integrates borrowing, repayment, and yield functionality to maintain anti-inflationary properties.

---

## Features

### **Core Functionality**
1. **Minting and Borrowing:**
   - Users can mint IDR stablecoins by depositing USDe tokens as collateral.
   - Borrowed amounts are subject to the Loan-to-Value (LTV) ratio.

2. **Repayment and Withdrawal:**
   - Users can repay their borrowed IDR amounts and withdraw their USDe collateral.

3. **Price Management:**
   - The owner can adjust the price of 1 USDe in IDR dynamically.

4. **Healthy Loan Check:**
   - Ensures collateral value covers the borrowed debt based on the LTV ratio.

### **Yield Mechanism**
- Annual yield (default: 10%) is distributed based on the user’s IDR balance.
- Yield is calculated and claimable periodically.

### **Liquidation**
- Loans below the healthy collateral threshold can be liquidated to recover the debt.

---

## Deployment

The contract must be deployed with the address of an existing USDe ERC20 token.

```solidity
constructor(address _USDeToken) ERC20("IDR Stablecoin", "IDR") {
    owner = msg.sender;
    USDeToken = _USDeToken;
}
```

---

## Events

1. **Borrow**  
   `event Borrow(address indexed user, uint256 amountIDR);`  
   Triggered when a user borrows IDR stablecoins.

2. **Withdraw**  
   `event Withdraw(address indexed user, uint256 amountUSDe);`  
   Triggered when collateral is withdrawn.

3. **Repay**  
   `event Repay(address indexed user, uint256 amountIDR);`  
   Triggered when a user repays their borrowed IDR.

4. **YieldClaimed**  
   `event YieldClaimed(address indexed user, uint256 amount);`  
   Triggered when a user claims their yield.

5. **Liquidate**  
   `event Liquidate(address indexed user);`  
   Triggered when a user’s loan is liquidated.

---

## Modifiers

- **onlyOwner:** Ensures only the contract owner can execute specific functions.

---

## Usage

### Borrow IDR
```solidity
mint(uint256 amountUSDe, uint256 borrowIdr)
```
Users deposit USDe tokens as collateral to mint IDR stablecoins.

### Repay Loan
```solidity
repay(uint256 amountIDR)
```
Repay borrowed IDR to reduce debt.

### Withdraw Collateral
```solidity
withdraw(uint256 amountUSDe)
```
Withdraw collateral once the loan remains healthy.

### Claim Yield
```solidity
claimYield()
```
Claim accumulated yield based on the user’s IDR balance.

---

## Security Considerations

1. **Healthy Loan Check:**
   Ensures loans maintain a healthy collateral-to-debt ratio.
2. **Yield Rate Validation:**
   Yield rates are capped between 0% and 100% to prevent abuse.
3. **Owner-only Functions:**
   Critical operations such as price adjustment and yield rate updates are restricted to the contract owner.

---

## License

This project is licensed under the MIT License.
