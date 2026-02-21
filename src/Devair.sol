// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Devair {
    // Owner
    address public deployer;

    // Metadata
    string public name;

    string public symbol;

    uint8 public decimals;

    // supply
    uint256 public totalSupply;

    //leger
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) public allowance;

    //Event
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    constructor() {
        deployer = msg.sender;
        name = "devair";
        symbol = "DEV";
        decimals = 18;
        totalSupply = 1000000 * (10 ** uint256(decimals));
        balances[deployer] = totalSupply;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
    require(balances[msg.sender] >= amount, "Not enough balance");

    balances[msg.sender] -= amount;
    balances[to] += amount;

    emit Transfer(msg.sender, to, amount);
    return true;
}


    function approve(address _spender, uint256 _amount) public returns (bool) {
    allowance[msg.sender][_spender] = _amount;

    emit Approval(msg.sender, _spender, _amount);
    return true;
}


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");

        require(balances[from] >= amount, "Not enough balance");

        balances[from] -= amount;

        allowance[from][msg.sender] -= amount;

        balances[to] += amount;
        emit Transfer(from, to, amount);

        return (true);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function allowanceOf(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return allowance[_owner][_spender];
    }
}