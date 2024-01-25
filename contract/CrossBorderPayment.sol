  // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.0;

   import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
   import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
   import "@openzeppelin/contracts/access/Ownable.sol";
   import "@openzeppelin/contracts/utils/math/SafeMath.sol";

   contract CrossBorderPayment is Ownable {
       using SafeMath for uint256;

       IERC20 public token; // The ERC-20 token contract
       AggregatorV3Interface public priceFeed; // Chainlink Aggregator contract for exchange rates

       event PaymentInitiated(address indexed sender, address indexed recipient, uint256 amount, string currency);
       event PaymentCompleted(address indexed sender, address indexed recipient, uint256 amount, string currency);

       constructor(address _tokenAddress, address _priceFeedAddress) Ownable (_priceFeedAddress) {
           token = IERC20(_tokenAddress);
           priceFeed = AggregatorV3Interface(_priceFeedAddress);
       }

       function initiatePayment(address _recipient, uint256 _amount, string memory _currency) external onlyOwner {
           require(_recipient != address(0), "Invalid recipient address");
           require(_amount > 0, "Invalid amount");

           // Get the current exchange rate from the Chainlink Oracle
           uint256 exchangeRate = getExchangeRate(_currency);

           // Calculate the equivalent amount in the token's native currency
           uint256 equivalentAmount = _amount.mul(exchangeRate).div(1e8); // Assuming Chainlink uses 8 decimals

           // Ensure the contract has enough balance in the native currency
           require(token.balanceOf(address(this)) >= equivalentAmount, "Insufficient balance in the contract");

           // Emit PaymentInitiated event
           emit PaymentInitiated(msg.sender, _recipient, _amount, _currency);
       }

       function completePayment(address _payer, address _recipient, uint256 _amount, string memory _currency) external onlyOwner {
           require(_payer != address(0), "Invalid payer address");
           require(_recipient != address(0), "Invalid recipient address");
           require(_amount > 0, "Invalid amount");

           // Get the current exchange rate from the Chainlink Oracle
           uint256 exchangeRate = getExchangeRate(_currency);

           // Calculate the equivalent amount in the token's native currency
           uint256 equivalentAmount = _amount.mul(exchangeRate).div(1e8); // Assuming Chainlink uses 8 decimals

           // Ensure the contract has enough balance in the native currency
           require(token.balanceOf(address(this)) >= equivalentAmount, "Insufficient balance in the contract");

           // Transfer funds from the payer to the recipient in the native currency
           token.transferFrom(_payer, _recipient, equivalentAmount);

           // Emit PaymentCompleted event
           emit PaymentCompleted(_payer, _recipient, _amount, _currency);
       }

       function getContractBalance() external view returns (uint256) {
           return token.balanceOf(address(this));
       }

       function getExchangeRate(string memory _currency) public view returns (uint256) {
           (, int256 price, , ,) = priceFeed.latestRoundData();
           require(price > 0, "Invalid exchange rate");
           return uint256(price);
       }
   }
