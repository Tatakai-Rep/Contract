# Tatakai Smart Contracts

This repository contains the smart contracts for the Tatakai project, which includes a token contract and a sign-in system.

## Overview

The project consists of one main smart contracts:
 
1. **SignInSystem (SIS)**: A sign-in system that allows users to sign in with a fee

## Smart Contracts
 

### SignInSystem (SIS)

The SignInSystem is a contract that manages user sign-ins with the following features:
- Configurable sign-in fee
- Time gap between sign-ins (default: 23 hours)
- Tracking of sign-in statistics
- Owner-only fund management
- Event emission for sign-in activities

### Deployment
- Deployed Network: OpBNB Mainnet
- Contract Address: 0x8fc0178e07310bf081897c7d9625b8180e7c5cef
- Block Explorer: opbnbscan.com

## Development

### Prerequisites
- Node.js
- Hardhat
- Solidity ^0.8.20

### Installation
```bash
npm install
```

### Compilation
```bash
npx hardhat compile
```

### Testing
```bash
npx hardhat test
```

## License

This project is licensed under the MIT License.
