// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "./IERC20.sol";

contract SchoolMang {

    IERC20 public token;
    address public owner;

    struct Student {
        uint256 studentId;
        string studentName;
        uint16 level;
        uint256 amountPaid;
        uint256 paidAt;
    }

    struct Staff {
        uint256 staffId;
        string staffName;
        uint16 level;
        uint256 salary;
        uint256 amountPaid;
        uint256 paidAt;
        bool isSuspended;
    }

    mapping(address => Student) public students;
    mapping(address => Staff) public staffs;

    address[] public studentAddresses;
    address[] public staffAddresses;

    uint256 public nextStudentId = 1;
    uint256 public staff_Id = 1;

    mapping(uint16 => uint256) public levelFee;
    mapping(address => mapping(address => uint256)) public allowance;

     
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event StaffSuspended(address indexed staffAddress);
    event StaffReinstated(address indexed staffAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _token, uint256 fee100, uint256 fee200, uint256 fee300, uint256 fee400) {
        require(_token != address(0), "Token address cannot be zero address");
        require(fee100 > 0 && fee200 > 0 && fee300 > 0 && fee400 > 0, "Fee must be greater");
        
        owner = msg.sender;
        token = IERC20(_token);

        levelFee[100] = fee100;
        levelFee[200] = fee200;
        levelFee[300] = fee300;
        levelFee[400] = fee400;
    }

    function registerStudent(string calldata _name, uint16 level) external {
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
        nextStudentId++;
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

    function addStaff(string calldata _name, uint16 _level, uint256 _salary, address _staff) external onlyOwner {
        require(_staff != address(0), "Staff address cannot be zero");
        require(staffs[_staff].staffId == 0, "Staff already added");
        
        Staff memory newStaff = Staff({
            staffId: staff_Id,
            staffName: _name,
            level: _level,
            salary: _salary,
            amountPaid: 0,
            paidAt: 0,
            isSuspended: false
        });

        staffs[_staff] = newStaff;
        staffAddresses.push(_staff);
        staff_Id++;
    }

    function payStaff(address staffWallet) external onlyOwner {
        Staff storage staffMember = staffs[staffWallet];
        require(staffMember.staffId != 0, "Staff not found");
        require(!staffMember.isSuspended, "Staff is suspended");
        require(staffMember.amountPaid == 0, "Already paid");
        
        uint256 salary = staffMember.salary;
        require(token.transfer(staffWallet, salary), "Payment failed");

        staffMember.amountPaid = salary;
        staffMember.paidAt = block.timestamp;
    }

    // Function to suspend a staff member; only the contract owner can call this
    function suspendStaff(address staffWallet) external onlyOwner {
        Staff storage staffMember = staffs[staffWallet];
        require(staffMember.staffId != 0, "Staff not found");
        require(!staffMember.isSuspended, "Staff already suspended");
        staffMember.isSuspended = true;
        emit StaffSuspended(staffWallet);
    }

    // Function to reinstate a suspended staff member; only the contract owner can call this
    function reinstateStaff(address staffWallet) external onlyOwner {
        Staff storage staffMember = staffs[staffWallet];
        require(staffMember.staffId != 0, "Staff not found");
        require(staffMember.isSuspended, "Staff is not suspended");
        staffMember.isSuspended = false;
        emit StaffReinstated(staffWallet);
    }

    function approveOf(address _owner, address _to, uint256 _amount) public returns (bool) {
        allowance[_owner][_to] = _amount;
        emit Approval(msg.sender, _to, _amount);
        return true;
    }

    function allowanceOf(address _owner, address _to) public view returns (uint256) {
        return allowance[_owner][_to];
    }

    // New function to remove a student from the organization
    function removeStudent(address studentWallet) external onlyOwner {
        require(students[studentWallet].studentId != 0, "Student not registered");
        
        // Remove student from the mapping
        delete students[studentWallet];
        
        // Remove the student's address from the studentAddresses array
        // Iterating through the array to find the student address
        for (uint i = 0; i < studentAddresses.length; i++) {
            if (studentAddresses[i] == studentWallet) {
                studentAddresses[i] = studentAddresses[studentAddresses.length - 1];
                studentAddresses.pop();
                break;
            }
        }
    }
}
