// SPDX-License-Identifier: GPL-3.0


//choose an admin acc
//b.sol compile, then go to deploy
// choose environment as 'injected provider - metamask'
// click to deploy


pragma solidity >=0.8.2 <0.9.0;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
/**
 * @title PriceConverter
 * @dev Set & change PriceConverter
 */
contract PriceConverter {
    address public priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306 ;          //from chainlink datafeed //have to put this as input while deploying airbnb

    function getPrice() public view returns (uint256, uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface( priceFeedAddress );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = priceFeed.decimals();
        return (uint256(price), decimals);
    }

    function convertFromUSD(uint256 amountInUSD) public view returns (uint256) {
        (uint256 price, uint256 decimals) = getPrice();
        uint256 convertedPrice = (amountInUSD * 10**decimals) / price;
        return convertedPrice;
    }
}