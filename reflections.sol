// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ReflectToken {
    string public name = "Reflect Token";
    string public symbol = "RFT";
    uint256 public totalSupply = 100000000 * 10**18; // 100 million tokens
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public buyTaxRate = 300;
    uint256 public sellTaxRate = 300;
    uint256 public reflectionRate = 200;
    uint256 public devRate = 100;

    address public devWallet;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        devWallet = msg.sender;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(value > 0, "Transfer amount must be greater than zero");
        require(balanceOf[from] >= value, "Insufficient balance");

        uint256 buyTax = 0;
        uint256 sellTax = 0;

        if (to == address(this)) { // buy transaction
            buyTax = value * buyTaxRate / 10000;
            balanceOf[devWallet] += buyTax * devRate / 10000;
        } else if (from == address(this)) { // sell transaction
            sellTax = value * sellTaxRate / 10000;
            balanceOf[devWallet] += sellTax * devRate / 10000;
        }

        uint256 reflectionAmount = (buyTax + sellTax) * reflectionRate / 10000;
        balanceOf[address(this)] += reflectionAmount;
        balanceOf[from] -= value;
        balanceOf[to] += value - buyTax - sellTax - reflectionAmount;

        emit Transfer(from, to, value);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function setDevWallet(address newDevWallet) public {
        require(msg.sender == devWallet, "Only the dev wallet can change the dev wallet address");
        devWallet = newDevWallet;
    }

    function getEthReflection() public {
        require(balanceOf[msg.sender] >= 1000 * 10**18, "Minimum balance not met");
        uint256 ethAmount = balanceOf[msg.sender] * reflectionRate / totalSupply;
        balanceOf[msg.sender] -= ethAmount;
        payable(msg.sender).transfer(ethAmount);
    }
}

