// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Reflections {
    string public constant name = "Reflections Token";
    string public constant symbol = "REFL";
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 100000000 * 10 ** decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public constant devWallet = payable(0x1234567890123456789012345678901234567890);

    uint256 public reflectionFee = 2;
    uint256 public devFee = 1;
    uint256 public totalFees = reflectionFee + devFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = totalSupply;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    mapping(address => bool) private _excluded;
    address[] private _excludedAddresses;

    event Transfer(address from, address to, uint256 amount);

    constructor () {
        _balances[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

   

    function balanceOf(address account) public view returns (uint256) {
        if (_excluded[account]) {
            return _balances[account];
        } else {
            return tokenFromReflection(_balances[account]);
        }
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _excluded[account];
    }

    
    function deliver(uint256 tAmount) public {
        address sender = msg.sender;
        uint256 rAmount = reflectionFromToken(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

}
