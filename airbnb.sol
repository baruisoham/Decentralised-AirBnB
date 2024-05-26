// SPDX-License-Identifier: GPL-3.0

// every account should have 1 ETH atleast

//admin acc
// while deploying airbnb contract click on drop down menu
// we had to give pricefeedaddress from b.sol code and listing fees of the platform (in USD)  (30  USD)
// deploy airbnb and b from admin acc (first acc)
// once done, see the deployed contract of airbnb

//owner - listing
// then choose the owner's account (2nd account)
//  the 'value' entered should be = listing fees (in Wei), this listing fees will go to the smart contract, admin can then click on withdraw balance to get that  amount
// addRentals - in contract drop down menu
// give the variables whatever 
// in price per day, mention USD value of one whole ETH atleast (3300)

// click on getAllRentals to see all rentals in console

//rental
//choose 3rd acc
// the 'value' entered should be = 0 , renter will not pay any fee
// go to bookDates drop down menu in the deployed contract
// we clicked getAllRentals, so there in console it shows the id of the properties, take id of the property that you want, put in id field
// timeStamp has to be given in unix format
// https://www.epochconverter.com/ use this
// use it to get current timestamp(from date)
//use it to get future timestamp (to date)
// choose the timestamp such that atleast 1 ETH value is to be used.
//then remove the listing fees mentined in 'value' section, as renter doesnt have to give listing fees






pragma solidity >=0.8.2 <0.9.0;

import "./b.sol";

  /**
   * @title DecentralAirbnb
   * @dev set and change DecentralAirbnb
   */
contract DecentralAirbnb is PriceConverter {
    //--------------------------------------------------------------------
    // VARIABLES

    address public admin;

    uint256 public listingFee;
    uint256 private _rentalIds;

    struct RentalInfo {
        uint256 id;
        address owner;
        string name;
        string city;
        string latitude;
        string longitude;
        string description;
        string imgUrl;
        uint256 maxNumberOfGuests;
        uint256 pricePerDay;
    }

    struct Booking {
        address renter;
        uint256 fromTimestamp;
        uint256 toTimestamp;
    }

    RentalInfo[] public rentals;

    function getAllRentals() public view returns (RentalInfo[] memory) {
    return rentals;
}

    mapping(uint256 => Booking[]) rentalBookings;

    //--------------------------------------------------------------------
    // EVENTS

    event NewRentalCreated(
        uint256 id,
        address owner,
        string name,
        string city,
        string latitude,
        string longitude,
        string description,
        string imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        uint256 timestamp
    );

    event NewBookAdded(
        uint256 rentalId,
        address renter,
        uint256 bookDateStart,
        uint256 bookDateEnd,
        uint256 timestamp
    );

    //--------------------------------------------------------------------
    // ERRORS

    error DecentralAirbnb__OnlyAdmin();
    error DecentralAirbnb__InvalidFee();
    error DecentralAirbnb__InvalidRentalId();
    error DecentralAirbnb__InvalidBookingPeriod();
    error DecentralAirbnb__AlreadyBooked();
    error DecentralAirbnb__InsufficientAmount();
    error DecentralAirbnb__TransferFailed();

    //--------------------------------------------------------------------
    // MODIFIERS


    //if msg.sender who is trying to execute the contract is not admin, then revert the contract back
    modifier onlyAdmin() {
        if(msg.sender != admin) revert DecentralAirbnb__OnlyAdmin();            
        _;
    }

    modifier isRental(uint _id) {
        if(_id >= _rentalIds) revert DecentralAirbnb__InvalidRentalId();
        _;
    }

    //--------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(uint256 _listingFee, address _priceFeedAddress) {
        admin = msg.sender;
        listingFee = _listingFee;
        priceFeedAddress = _priceFeedAddress;
    }

    //--------------------------------------------------------------------
    // FUNCTIONS

    function addRental(
        string memory _name,
        string memory _city,
        string memory _latitude,
        string memory _longitude,
        string memory _description,
        string memory _imgUrl,
        uint256 _maxGuests,
        uint256 _pricePerDay
    ) external payable {
        if(msg.value != listingFee) revert DecentralAirbnb__InvalidFee();
        uint256 _rentalId = _rentalIds;

        RentalInfo memory _rental = RentalInfo(
            _rentalId,
            msg.sender,
            _name,
            _city,
            _latitude,
            _longitude,
            _description,
            _imgUrl,
            _maxGuests,
            _pricePerDay
        );

        rentals.push(_rental);
        _rentalIds++;

        emit NewRentalCreated(
            _rentalId,
            msg.sender,
            _name,
            _city,
            _latitude,
            _longitude,
            _description,
            _imgUrl,
            _maxGuests,
            _pricePerDay,
            block.timestamp
        );
    }

    function bookDates(
        uint256 _id,
        uint256 _fromDateTimestamp,
        uint256 _toDateTimestamp
    ) external payable isRental(_id) {              //function can be called from outside and is payable

        RentalInfo memory _rental = rentals[_id];

        uint256 bookingPeriod = (_toDateTimestamp - _fromDateTimestamp) /
            1 days;
        // can't book less than 1 day
        if(bookingPeriod < 1) revert DecentralAirbnb__InvalidBookingPeriod();
        
        uint256 _amount = convertFromUSD(_rental.pricePerDay) * bookingPeriod;

        if(msg.value != _amount) revert DecentralAirbnb__InsufficientAmount();
        if(checkIfBooked(_id, _fromDateTimestamp, _toDateTimestamp)) revert DecentralAirbnb__AlreadyBooked();

        rentalBookings[_id].push(                                           // seperate maps were made for each property, when new booking for a property is added, it is added to that property's map with from and to dates
            Booking(msg.sender, _fromDateTimestamp, _toDateTimestamp)
        );

        (bool success,) = payable(_rental.owner).call{value: msg.value}("");        // transfer money if success
        if (!success) revert DecentralAirbnb__TransferFailed();

        emit NewBookAdded(
            _id,
            msg.sender,
            _fromDateTimestamp,
            _toDateTimestamp,
            block.timestamp
        );
    }

    function checkIfBooked(             // was called when we were adding rental
        uint256 _id,
        uint256 _fromDateTimestamp,
        uint256 _toDateTimestamp
    ) internal view returns (bool) {

        Booking[] memory _rentalBookings = rentalBookings[_id];         // list of all the bookings for the property id

        // Make sure the rental is available for the booking dates
        for (uint256 i = 0; i < _rentalBookings.length;) {
            if (                                                                //this condition checks if any overlap with previous bookings, if yes, then return true
                ((_fromDateTimestamp >= _rentalBookings[i].fromTimestamp) &&
                    (_fromDateTimestamp <= _rentalBookings[i].toTimestamp)) ||
                ((_toDateTimestamp >= _rentalBookings[i].fromTimestamp) &&
                    (_toDateTimestamp <= _rentalBookings[i].toTimestamp))
            ) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;           // no overlap
    }

    function getRentals() external view returns (RentalInfo[] memory) {
        return rentals;
    }

    // Return the list of booking for a given rental
    function getRentalBookings(uint256 _id)
        external
        view
        isRental(_id)
        returns (Booking[] memory)              // it ensures that the return type is a booking struct from the memory  
    {
        return rentalBookings[_id];             // each element in rentalbooking array holds a struct called Booking
    }

    function getRentalInfo(uint256 _id)             // returns the rental property info from the rentals array
        external                                    // each element in rentals array holds a struct called RentalInfo that holds values like location, name, description for that specific property
        view
        isRental(_id)
        returns (RentalInfo memory)
    {
        return rentals[_id];                        // return a specific element from rentals array, this element is a struct of RentalInfo
    }

    // ADMIN FUNCTIONS

    function changeListingFee(uint256 _newFee) external onlyAdmin {
        listingFee = _newFee;
    }

    function withdrawBalance() external onlyAdmin {
        (bool success,) = payable(admin).call{value: address(this).balance}("");            // payable to admin, call and pay from contract's address, pay the balance entirely
        if (!success) revert DecentralAirbnb__TransferFailed();
    }
}
