# Decentralized Airbnb on Ethereum Blockchain

This project is a decentralized implementation of the Airbnb platform, built on the Ethereum blockchain using Solidity smart contracts. It allows users to list their rental properties, book stays, and pay in cryptocurrency.

## Features

- **Rental Listing**: Property owners can list their rentals by providing details such as name, city, location coordinates, description, image URL, maximum number of guests, and price per day.
- **Booking Rentals**: Users can book rentals for specific date ranges and pay the corresponding amount in cryptocurrency.
- **Secure Payments**: Payments for booking rentals are securely handled through the smart contract, ensuring transparent and trustless transactions.
- **Price Conversion**: The contract utilizes a price feed to convert rental prices from USD to the blockchain's native currency.
-  **Cross-token**:  Implemented cross-token payment functionality to improve accessibility.
- **Admin Controls**: An admin account has the ability to change the listing fee and withdraw the contract's balance.
- **Event Logging**: Important events, such as new rental listings and bookings, are logged for transparency and auditing purposes.

## Prerequisites

To run this project locally, you'll need to have the following installed:

- [Node.js](https://nodejs.org/en/) (v12 or later)
- [Truffle](https://trufflesuite.com/) (a development environment for Ethereum)
- [Ganache](https://trufflesuite.com/ganache/) (a local Ethereum blockchain for testing)
- [MetaMask](https://metamask.io/) (a cryptocurrency wallet)

## Installation

Just use  Remix IDE on browser

## Usage

Keep atleast 3 accounts on MetaMask, admin, owner, tenant

Check commments on every code, start with `b.sol`

then move over to `airbnb.sol`

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
