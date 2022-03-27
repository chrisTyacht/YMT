// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/Uniswap.sol";
import "../interfaces/IPinkAntiBot.sol";
 
contract YachtMasterToken is ERC20, ERC20Snapshot, Ownable {
    
    //Integration with PinkSaleAntibot interface     
    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;
    
    // Mapping to exclude some contracts from fees. Transfers are excluded from fees if address in this mapping is recipient or sender.
    mapping (address => bool) public excludedFromFees;

    // Yacht funds wallet address that will be used for DAO treasury and buy Yachts.
    address payable public yachtMasterWalletAddress;
    
    // Marketing wallet address used for funding marketing.
    address payable public marketingWalletAddress;
    
    // Developer wallet address used for funding the team.
    address payable public developerWalletAddress;
    
    // Liquidity wallet address used to hold the 35% of YMT tokens for the liquidity pool.
    // After these coins are moved to the DEX, this address will no longer be used.
    address public liquidityWalletAddress;
    
    // Address of the wallet that will keep YMT tokens for burn.
    address payable public tobeburntWalletAddress;
    
    // Address of the contract responsible for the air dropping.
    address public airDropWalletAddress;
    
    // The PancakeSwap router address for swapping YMT tokens for WBNB.
    address public uniswapRouterAddress;
    
    // The initial block timestamp of the token contract.
    uint256 public initialTimeStamp;

    // Yacht transaction fee - deployed at 3%.
    uint256 public yachtTransactionFeePercent = 3;

    // Developer team transaction fee - deployed at 1%.
    uint256 public developerFeePercent = 1;

    // Marketing transaction fee - deployed at 1%.
    uint256 public marketingFeePercent = 1;

    // Marketing transaction fee - deployed at 1%.
    uint256 public burnFeePercent = 1;
    
    // PancakeSwap router interface.
    IUniswapV2Router02 private uniswapRouter;

    // Address of the WBNB to YMT token pair on PancakeSwap.
    address public uniswapPair;

                
     // Initial token distribution:
    // 20% - Air drop contract (will be locked and vested periodically outside of contract)
    // 35% - Liquidity pool (1 year lockup period after vesting presale - outside of contract)
    // 30% - Burn
    // 10% - Developer coins (6 month lockup period)
    // 5% - Marketing
    constructor(
        uint256 initialSupply, 
        address payable _yachtMasterWalletAddress,
        address payable _marketingWalletAddress,
        address payable _developerWalletAddress,
        address _liquidityWalletAddress,
        address payable _tobeburntWalletAddress,
        address _airDropWalletAddress,
        address _uniswapRouterAddress,
        address pinkAntiBot_) ERC20("YachtMasterToken", "YMT") {
            initialTimeStamp = block.timestamp;
            yachtMasterWalletAddress = _yachtMasterWalletAddress;
            marketingWalletAddress = _marketingWalletAddress;
            developerWalletAddress = _developerWalletAddress;
            liquidityWalletAddress = _liquidityWalletAddress;
            tobeburntWalletAddress = _tobeburntWalletAddress;
            airDropWalletAddress = _airDropWalletAddress;
            uniswapRouterAddress = _uniswapRouterAddress;

            // Create an instance of the PinkAntiBot variable from the provided address
            pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
            // Register the deployer to be the token owner with PinkAntiBot. You can
            // later change the token owner in the PinkAntiBot contract
            pinkAntiBot.setTokenOwner(msg.sender);
            antiBotEnabled = true;
                        
            excludedFromFees[yachtMasterWalletAddress] = true;
            excludedFromFees[marketingWalletAddress] = true;
            excludedFromFees[developerWalletAddress] = true;
            excludedFromFees[liquidityWalletAddress] = true;
            excludedFromFees[tobeburntWalletAddress] = true;
            excludedFromFees[airDropWalletAddress] = true;
                       
            _mint(marketingWalletAddress, (initialSupply) * 5 / 100);
            _mint(developerWalletAddress, (initialSupply) * 10 / 100);
            _mint(liquidityWalletAddress, (initialSupply) * 35 / 100);
            _mint(tobeburntWalletAddress, (initialSupply) * 30 / 100);
            _mint(airDropWalletAddress, (initialSupply) * 20 / 100);

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
            uniswapRouter = _uniswapV2Router;
            _approve(address(this), address(uniswapRouter), initialSupply);
            uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            IERC20(uniswapPair).approve(address(uniswapRouter), type(uint256).max);
    
        }   
    /**
     * Returns the contract address
     * Return contract address
     */
    function getContractAddress() public view returns (address){
        return address(this);
    }

    /**
    * @dev Adds a user to be excluded from fees.
    * @param user address of the user to be excluded from fees.
     */
    function excludeUserFromFees(address user) public onlyOwner {
        excludedFromFees[user] = true;
    }

    /**
    * @dev Gets the current timestamp, used for testing + verification
    * @return the the timestamp of the current block
     */
    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /**
    * @dev Removes a user from the fee exclusion.
    * @param user address of the user than will now have to pay transaction fees.
     */
    function includeUsersInFees(address user) public onlyOwner {
        excludedFromFees[user] = false;
    }

    // Use this function to control whether to use PinkAntiBot or not instead
    // of managing this in the PinkAntiBot contract
    function setEnableAntiBot(bool _enable) external onlyOwner {
        antiBotEnabled = _enable;
    }
 
    // Internal Transfer function override to collect taxes only on Swap.   
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        
        //when to collect taxes      
        if((sender == uniswapPair || recipient == uniswapPair) && !excludedFromFees[sender] && !excludedFromFees[recipient]) {
                        
            //Investor cannot have more than 2% of total supply
            if(sender == uniswapPair && !excludedFromFees[sender] && !excludedFromFees[recipient]) {
                require((balanceOf(recipient) + amount) < (totalSupply() / 76), "You can't have more than 2% of the total supply.");                                
            }

            // Yacht transaction fee.
            uint256 yachtFee = (amount * yachtTransactionFeePercent) / 100;
            // Marketing team transaction fee.
            uint256 marketingFee = (amount * marketingFeePercent) / 100;
            // Developer team transaction fee.
            uint256 developerFee = (amount * developerFeePercent) / 100;
            // Burn fee
            uint256 burnFee = (amount * burnFeePercent) / 100;

            // The total fee to send to the contract address.
            uint256 totalFee = yachtFee + marketingFee + developerFee + burnFee;
    
            // Sends the transaction fees to the contract address
            super._transfer(sender, address(this), totalFee);
            
            // Prepares amount afterfees
            amount -= totalFee;
        }

        super._transfer(sender, recipient, amount);
    }
    
    /**
     * @dev Swaps YMT tokens from transaction fees to BNB.
     * @param amount the amount of YMT tokens to swap
     */
    function swapYMTForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), amount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
     /**
     * @dev Sends BNB to transaction fee wallets after YMT swaps.
     * @param amount the amount to be transfered
     */
    function sendFeesToWallets(uint256 amount) private {
        uint256 totalFee = yachtTransactionFeePercent + marketingFeePercent + developerFeePercent + burnFeePercent;
        yachtMasterWalletAddress.transfer((amount * yachtTransactionFeePercent) / totalFee);
        marketingWalletAddress.transfer((amount * marketingFeePercent) / totalFee);
        developerWalletAddress.transfer((amount * developerFeePercent) / totalFee);
        tobeburntWalletAddress.transfer((amount * burnFeePercent) / totalFee);
    }

     /**
     * @dev Swaps YMT to BNB.
     */
    function swapFeesManually() public onlyOwner {
        uint256 contractYMTBalance = balanceOf(address(this));        
        if (contractYMTBalance > 0) {
            swapYMTForBNB(contractYMTBalance);                        
        }          
    }
    
    /**
     * @dev Sends BNB to transaction
     */
    function disperseFeesManually() public onlyOwner {
        uint256 contractBNBBalance = address(this).balance;
        sendFeesToWallets(contractBNBBalance);
    }
    
    receive() external payable {}
           
    function snapshot() public onlyOwner {
        _snapshot();
    }

    // The following functions are overrides required by Solidity.
    // Enabling antibot from Pinksale
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        // Only use PinkAntiBot if this state is true
        if (antiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }
        
        super._beforeTokenTransfer(from, to, amount);
    }
}