// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface DepositableERC20 is IERC20 {
    function deposit() external payable;
}
/// @title A sample bank contract
/// @author Will Papper and Syndicate Inc.
/// @notice The Bank contract keeps track of the deposits and withdrawals for a
/// single user. The bank takes a 0.3% fee on every withdrawal. The bank contract
/// supports deposits and withdrawals for any ERC-20, but only one ERC-20 token
/// can be used per bank contract.
/// @dev Security for the Bank contract is paramount :) You can assume that the
/// owner of the Bank contract is the first account in Ganache (accounts[0]
/// within Bank.js), and that the user of the bank is not the owner of the Bank
/// contract (e.g. the user of the bank is accounts[1] within Bank.js, not
/// accounts[0]).
contract Bank {
    using SafeERC20 for IERC20;
    using SafeERC20 for DepositableERC20;
    
    address public owner;
    // The contract address for DAI
    address private  DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
       
    // The contract address for USDC
    address private  USDC_ADDRESS =  0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    IERC20 daiToken = IERC20(DAI_ADDRESS);
    IERC20 usdcToken = IERC20(USDC_ADDRESS);
    
    
    
       
    // The address where bank fees should be sent
    address private BANK_FEE_ADDRESS = 0xcD0Bf0039d0F09CF93f9a05fB57C2328F6D525A3;
    
    uint256 public Balance = 0;
    
   
    
    
        

    

    // The bank should take a fee of 0.3% on every withdrawal. For example, if a
    // user is withdrawing 1000 DAI, the bank should receive 3 DAI. If a user is
    // withdrawing 100 DAI, the bank should receive .3 DAI. The same should hold
    // true for USDC as well.
    // The bankFee is set using setBankFee();
    uint256 private bankFee = 0;
    
    mapping(address => uint) balances;
    
    constructor()  {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // You should change this value to USDC_ADDRESS if you want to set the bank
    // to use USDC.
    

   
    function depositDai(uint256 amount) public payable {
        uint256 DaiOfContractBeforeTransfer = daiToken.balanceOf(address(this));
         
        // Initialize the ERC20 for USDC or DAI
       
        // Transfer funds from the user to the bank
        daiToken.transferFrom(msg.sender, address(this), amount);
        uint256 DaiOfContractAfterTransfer = daiToken.balanceOf(address(this));
        uint256 daiOfUser = DaiOfContractAfterTransfer - DaiOfContractBeforeTransfer; 
        balances[msg.sender] = daiOfUser;

        // Increase the balance by the deposit amount and return the balance
        
        
    }
    
    function depositUsdc(uint256 amount) public payable {
        uint256 UsdcContractBeforeTransfer = usdcToken.balanceOf(address(this));
        usdcToken.transferFrom(msg.sender, address(this), amount);
        uint256 UsdcContractAfterTransfer = usdcToken.balanceOf(address(this));
        uint256 usdcOFUser = UsdcContractAfterTransfer - UsdcContractBeforeTransfer;
        balances[msg.sender] = usdcOFUser;
        
        
    }
    
    function depositErc20(address _erc20Address, uint256 amount) public payable{
        DepositableERC20 erc20 = DepositableERC20(_erc20Address);
        uint256 Erc20ContractBeforeTransfer = erc20.balanceOf(address(this));
        erc20.transferFrom(msg.sender, address(this), amount);
        uint256 Erc20ContractAfterTransfer = erc20.balanceOf(address(this));
        uint256 erc20OfUser = Erc20ContractAfterTransfer - Erc20ContractBeforeTransfer;
        balances[msg.sender] = erc20OfUser;
     
        
    }
    
    

    
    function withdrawDai(uint256 amount) public onlyOwner()  {
        // Initialize the ERC20 for USDC or DAI
        

        // Calculate the fee that is owed to the bank
        (uint256 amountToUser, uint256 amountToBank) = calculateBankFee(amount);

        daiToken.transfer(msg.sender, amountToUser);
        // Decrease the balance by the amount sent to the user
        balances[msg.sender] -= amountToUser;

        daiToken.transfer(BANK_FEE_ADDRESS, amountToBank);
        // Decrease the balance by the amount sent to the bank
        balances[msg.sender] -= amountToBank;

        
    }
    
    function withdrawUsdc(uint256 amount) public onlyOwner() {
        (uint256 amountToUser, uint256 amountToBank) = calculateBankFee(amount);
        usdcToken.transfer(msg.sender, amountToUser);
        balances[msg.sender] -= amountToUser;
        usdcToken.transfer(BANK_FEE_ADDRESS, amountToBank);
        balances[msg.sender] -= amountToBank;
        
        
    }
    
     function withDrawErc20(address _erc20Address, uint256 amount) public onlyOwner() {
         DepositableERC20 erc20 = DepositableERC20(_erc20Address);
         (uint256 amountToUser, uint256 amountToBank) = calculateBankFee(amount);
         erc20.transfer(msg.sender, amountToUser);
         balances[msg.sender] -= amountToUser;
         erc20.transfer(BANK_FEE_ADDRESS, amountToBank);
         balances[msg.sender] -= amountToBank;
         
     }

  
    function calculateBankFee(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        // TODO: Implement the 0.3% fee to the bank here
        uint256 amountToBank = amount * bankFee;
        uint256 amountToUser = amount - amountToBank;
        return (amountToUser, amountToBank);
    }

    /// @notice Set the fee that the bank takes
    /// @param fee The fee that bankFee should be set to
    /// @return bankFee The new value of the bank fee
    function setBankFee(uint256 fee) public returns (uint256) {
        bankFee = fee;
        return bankFee;
    }
    
    function getDaiBalance() public view returns(uint) {
        return daiToken.balanceOf(address(this));
    }
    
    function UsdcBalance() public view returns(uint) {
        return usdcToken.balanceOf(address(this));
    }
    
    function getERC20Balance(address _erc20Address) public view returns(uint) {
        DepositableERC20 erc20 = DepositableERC20(_erc20Address);
        return erc20.balanceOf(address(this));
    }
    
    function addMoneyToContract() public payable {
        Balance += msg.value;
    }
    
    receive() external payable {
        
    }

    /// @notice Get the user's bank balance
    /// @return balance The balance of the user
    
}
