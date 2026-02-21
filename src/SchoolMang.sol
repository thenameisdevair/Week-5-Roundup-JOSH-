// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    
}

contract SchoolMang {

    IERC20 public token;
    address public owner;

    struct Student {
        uint256  studentId;
        string studentName;
        uint16 level;

        //payment;
        uint256 amountPaid;
        uint256  paidAt;

        
    }

    struct Staff {
        uint256 staffId;
        string staffName;
        uint16 level;
        uint256 salary;
        uint256 amountPaid;
        uint256 paidAt;
    }

    mapping (address => Staff) public staffs;
    address[] public staffAddresses;
    uint256 public nextStaffId =1;

    mapping (address => Student) students;
    mapping (uint16 => uint256) private levelFee;

    uint256 public nextStudentId =1;
    address[] private studentAddresses;
    

    

     constructor(address _token,
        uint256 fee100, uint256 fee200, uint256 fee300, uint256 fee400) {
        
        require(_token != address(0), "Token address cannot be zero address");

        require(fee100 > 0 && fee200 > 0 && fee300 > 0 && fee400 > 0, "Fee must be greater");

        owner = msg.sender;
        token = IERC20(0x5124778ea2925CA11537D5d63cD4086eEf31c130);

        levelFee[100]  = fee100;
        levelFee[200] = fee200;
        levelFee[300] = fee300;
        levelFee[400] = fee400;
        _addStaff("Alice", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 100, 1000);
        _addStaff("bob", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 200, 2000);
        _addStaff("Charles", 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 300, 3000);
        _addStaff("Deviar", 0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 400, 4000);
    }


    

    function registerStudent(string calldata _name, uint16 level) external{
        require(students[msg.sender].studentId == 0, "Student already registered");
        require(levelFee[level] > 0, "Invalid Level");
        students[msg.sender] = Student({ 
        studentId: nextStudentId,
        studentName: _name,
        level: level,
        amountPaid: 0,
        paidAt: 0
        });

        studentAddresses.push(msg.sender);
        nextStudentId ++;
        
    
    }
    
    function payFees() external {
        require(students[msg.sender].studentId > 0, "Student not registered");
        require(students[msg.sender].amountPaid == 0, "Already paid"); 

        uint16 level = students[msg.sender].level;
        uint256 fee = levelFee[level];

        require(fee > 0, "invalid fee");

        require(token.transferFrom(msg.sender, address(this), fee), "Transfer Failed");

        students[msg.sender].amountPaid = fee;
        students[msg.sender].paidAt = block.timestamp;

    }

    function getStudent(address studentWallet) external view returns (Student memory) {
        return students[studentWallet];
        
    }

    function getAllStudents() external view returns (address[] memory) {
        return studentAddresses;
    }

    function _addStaff(
        string memory _name,
        address _wallet,
        uint16 _level,
        uint256 salary) internal {

        staffs[_wallet] = Staff({
            staffId: nextStaffId,
            staffName: _name,
            level: _level,
            salary: salary,
            amountPaid: 0,
            paidAt: 0
        });

        staffAddresses.push(_wallet);
        nextStaffId++;  
    }

    function payStaff(address staffWallet) external {
        require(msg.sender == owner, " ONly owner");
        require(staffs[staffWallet].staffId != 0, "Staff not found");
        require(staffs[staffWallet].amountPaid == 0, "Already paid");
        
        uint256 salary = staffs[staffWallet].salary;

        require(token.transfer(staffWallet, salary), "Payment failed");

        staffs[staffWallet].amountPaid = salary;
        staffs[staffWallet].paidAt = block.timestamp;
    }

    function getStaff(address staffWallet) external view  returns (Staff memory) {
        return staffs[staffWallet];
    }

    function getAllStaff() external view returns (address[] memory){
        return staffAddresses;
    }
}