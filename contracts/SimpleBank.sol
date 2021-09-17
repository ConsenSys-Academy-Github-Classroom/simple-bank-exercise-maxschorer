/*
 * This exercise has been updated to use Solidity version 0.8.5
 * See the latest Solidity updates at
 * https://solidity.readthedocs.io/en/latest/080-breaking-changes.html
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SimpleBank {

    /* State variables
     */
    mapping (address => uint) private balances ; // internal or private?
    mapping (address => bool) public enrolled;
    address public owner = msg.sender;

    /* Events - publicize actions to external listeners */
    event LogEnrolled(address indexed accountAddress);
    event LogDepositMade(address indexed accountAddress, uint indexed amount);
    event LogWithdrawal(address indexed accountAddress, uint indexed withdrawAmount, uint indexed newBalance);

    /* Functions
     */

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function () external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    function enroll() public returns (bool){
      // 1. enroll of the sender of this transaction
      enrolled[msg.sender] = true;
      emit LogEnrolled(msg.sender);
      return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint) {
      // 1. Add the appropriate keyword so that this function can receive ether
      // 2. Users should be enrolled before they can make deposits
      require(enrolled[msg.sender]);
      require(msg.value >= 0); // is this needed?
      // 3. Add the amount to the user's balance. Hint: the amount can be
      //    accessed from of the global variable `msg`
      balances[msg.sender] += msg.value;
      // 4. Emit the appropriate event associated with this function
      uint balance = balances[msg.sender];
      emit LogDepositMade(msg.sender, balance);
      // 5. return the balance of sndr of this transaction
      return balance;
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public returns (uint) {
      // If the sender's balance is at least the amount they want to withdraw,
      // Subtract the amount from the sender's balance, and try to send that amount of ether
      // to the user attempting to withdraw.
      // return the user's balance.
      // 1. Use a require expression to guard/ensure sender has enough funds
      require(enrolled[msg.sender]);
      uint balance = balances[msg.sender];
      require(balance >= withdrawAmount);
      // 2. Transfer Eth to the sender and decrement the withdrawal amount from
      //    sender's balance
      payable(msg.sender).transfer(withdrawAmount);
      // 3. Emit the appropriate event for this message
      uint newBalance = balance - withdrawAmount;
      balances[msg.sender] = newBalance;
      emit LogWithdrawal(msg.sender, withdrawAmount, newBalance);
      return newBalance;
    }
}
