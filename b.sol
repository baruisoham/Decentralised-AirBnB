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



    //finds the current price of one crypto in USD   (conversion rate)
    function getPrice() public view returns (uint256, uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface( priceFeedAddress );
        (, int256 price, , , ) = priceFeed.latestRoundData();                           /// it returns a lot of daya, but we only store the price as price variable
        uint256 decimals = priceFeed.decimals();                                        // no. of decimals used in the price feed's return value
        return (uint256(price), decimals);                                              // return no. of decimals and price
    }


    //convert given amount of USD to native cryptocurrency

    function convertFromUSD(uint256 amountInUSD) public view returns (uint256) {
        (uint256 price, uint256 decimals) = getPrice();                                 // calls the previous function
        uint256 convertedPrice = (amountInUSD * 10**decimals) / price;              // power of decimals to accomodate for change and then divide by price to get number of coins
        return convertedPrice;
    }
}
