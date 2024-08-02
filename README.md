# MoneyBox Smart Contract

This repository contains the MoneyBox smart contract, a Solidity implementation for a decentralized funding platform.

## Overview

The MoneyBox contract allows users to contribute funds towards a specific goal amount. It uses Chainlink price feeds to ensure a minimum USD value for contributions and includes features like fund withdrawal once the goal is achieved.

## Features

- Minimum contribution of $5 USD
- Goal-based funding
- Owner-only withdrawal
- Chainlink price feed integration
- Fallback and receive functions for direct transfers

## Requirements

- Solidity ^0.8.18
- Foundry (for development and testing)
- Chainlink Contracts

## Key Functions

- `fund()`: Allows users to contribute ETH
- `withdraw()`: Enables the owner to withdraw funds once the goal is achieved
- `getAddressToAmountFunded()`: Retrieves the amount funded by a specific address
- `getFunder()`: Gets the address of a funder by index
- `getOwner()`: Returns the contract owner's address
- `getGoalAmount()`: Retrieves the funding goal amount

## Setup and Deployment

1. Clone this repository
2. Install dependencies: `forge install`
3. Compile the contract: `forge build`
4. Run tests: `forge test`
5. Deploy the contract, providing the Chainlink price feed address and goal amount as constructor parameters

## License

This project is licensed under the MIT License.