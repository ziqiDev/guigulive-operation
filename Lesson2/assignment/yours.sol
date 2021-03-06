pragma solidity ^0.4.14;
contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;

    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
    }

    function _partialPaid(Employee employee) private {
        uint payment= employee.salary*(now-employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }

    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i = 0;i<employees.length;i++){
            if(employees[i].id==employeeId){
                return (employees[i],i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender ==owner&&employees.length<10);
        var(employee,index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        employees.push(Employee(employeeId,salary * 1 ether,now));
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        for(uint index = 0;index<employees.length;index++){
            if(employees[index].id == employeeId){
                _partialPaid(employees[index]);
                delete employees[index];
                employees[index] = employees[employees.length-1];
                employees.length -=1;
                return;
            }
        }
    }

    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender==owner);
        var(employee,index) = _findEmployee(employeeId);
        assert(employee.id!=0x0);
        _partialPaid(employee);
        employees[index].salary = salary*1 ether;
        employees[index].lastPayday = now;
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        uint totalSalary = 0;
       for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway()>0;
    }

    function getPaid() {
        var(employee, index) = _findEmployee(msg.sender);
        assert(employees[index].id !=0x0);
        uint nextPayday = employee.lastPayday+payDuration;
        assert(nextPayday<now);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}

// address for mocking:
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96b
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96c
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96e
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96f
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96g
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96h
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96i
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96g
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96k
// 0x6fFF3806Bbac52A20e0d79BC538d527f6a22c96l
// 0xca35b7d915458ef540ade6068dfe2f44e8fa733c - dummy

// original gas cost: [1694,2475,3256,4037,4818,5599,6380,7161,7942,8723]
// idea optimize, set lastUpdateTotalSal global var, every time update it, instead of for loop every employee.
// optimize gas cost: [896,896,......], flat cost

