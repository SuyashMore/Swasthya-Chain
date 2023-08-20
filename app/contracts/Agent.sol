pragma solidity ^0.5.1;

contract Agent {
    
    struct patient {
        string name;
        uint age;
        address[] doctorAccessList;
        address[] insurerAccessList;
        address[] laboratoryAccessList;
        uint[] diagnosis;
        string record;
    }
    
    struct doctor {
        string name;
        uint age;
        address[] patientAccessList;
    }

    struct hospital {
        string name;
        string location;
        address[] doctorEmployeeList;
        address[] patientCustomerList;
    }

    struct laboratory {
        string name;
        string hospitalName;
        address[] patientAccessList;

        
    }

    struct insurer {
        string name;
        // address[] patientInsuredList;
        address[] patientAccessList;
    }

    uint creditPool;

    address[] public patientList;
    address[] public doctorList;
    address[] public hospitalList;
    address[] public laboratoryList;
    address[] public insurerList;

    mapping (address => patient) patientInfo;
    mapping (address => doctor) doctorInfo;
    mapping (address => hospital) hospitalInfo;
    mapping (address => laboratory) laboratoryInfo;
    mapping (address => insurer) insurerInfo;
    mapping (address => address) Empty;
    // might not be necessary
    mapping (address => string) patientRecords;
    


    function add_agent(string memory _name, uint _age, uint _designation, string memory _hash) public returns(string memory){
        address addr = msg.sender;
        
        if(_designation == 0){ //patient
            patient memory p;
            p.name = _name;
            p.age = _age;
            p.record = _hash;
            patientInfo[msg.sender] = p;
            patientList.push(addr)-1;
           
        }
       else if (_designation == 1){ //doctor
            doctorInfo[addr].name = _name;
            doctorInfo[addr].age = _age;
            doctorList.push(addr)-1;
            
       } 
       else{
           revert();
       }
    }

    function add_insurer(string memory _name, uint _designation, string memory _hash) public returns(string memory){
        address addr = msg.sender;
        if(_designation == 2){ 
            insurerInfo[addr].name = _name;
            insurerList.push(addr)-1;
        } else{
           revert();
       }
    }

    function add_laboratory(string memory _name, uint _designation, string memory _hash) public returns(string memory){
        address addr = msg.sender;
        if(_designation == 3){ 
            laboratoryInfo[addr].name = _name;
            laboratoryList.push(addr)-1;
        } else{
           revert();
       }
    }


    function get_patient(address addr) view public returns (string memory , uint, uint[] memory, address[] memory, string memory, address[] memory){
        // if(keccak256(patientInfo[addr].name) == keccak256(""))revert();
        return (patientInfo[addr].name, patientInfo[addr].age, patientInfo[addr].diagnosis, patientInfo[addr].insurerAccessList, patientInfo[addr].record, patientInfo[addr].laboratoryAccessList);
    }

    function get_doctor(address addr) view public returns (string memory , uint){
        // if(keccak256(doctorInfo[addr].name)==keccak256(""))revert();
        return (doctorInfo[addr].name, doctorInfo[addr].age);
    }

    function get_insurer(address addr) view public returns (string memory){
        // if(keccak256(insurerInfo[addr].name) == keccak256(""))revert();
        return (insurerInfo[addr].name);
    }

    function get_laboratory(address addr) view public returns (string memory){
        // if(keccak256(insurerInfo[addr].name) == keccak256(""))revert();
        return (laboratoryInfo[addr].name);
    }



    function get_patient_doctor_name(address paddr, address daddr) view public returns (string memory , string memory ){
        return (patientInfo[paddr].name,doctorInfo[daddr].name);
    }

    function permit_access_to_doctor(address addr) payable public {
        require(msg.value == 2 ether);

        creditPool += 2;
        
        doctorInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].doctorAccessList.push(addr)-1;
        
    }

    function permit_access_to_insurer(address addr) payable public {
        require(msg.value == 2 ether);
        creditPool += 2;
        insurerInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].insurerAccessList.push(addr)-1; 
    }

    function permit_access_to_laboratory(address addr) payable public {
        require(msg.value == 2 ether);
        creditPool += 2;
        laboratoryInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].laboratoryAccessList.push(addr)-1; 
    }


    //must be called by doctor
    function insurance_claim(address paddr, uint _diagnosis, string memory  _hash) public payable {
        bool patientFound = false;
        for(uint i = 0;i<doctorInfo[msg.sender].patientAccessList.length;i++){
            if(doctorInfo[msg.sender].patientAccessList[i]==paddr){
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;
                
            }
            
        }
        if(patientFound==true){
            set_hash(paddr, _hash);
            remove_patient_for_doctor(paddr, msg.sender);
        }else {
            revert();
        }

        bool DiagnosisFound = false;
        for(uint j = 0; j < patientInfo[paddr].diagnosis.length;j++){
            if(patientInfo[paddr].diagnosis[j] == _diagnosis)DiagnosisFound = true;
        }
    }

    function remove_element_in_array(address[] storage Array, address addr) internal returns(uint)
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++){
            if(Array[i] == addr){
                check = true;
                del_index = i;
            }
        }
        if(!check) revert();
        else{
            if(Array.length == 1){
                delete Array[del_index];
            }
            else {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];

            }
            Array.length--;
        }
    }

    function remove_patient_for_doctor(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
    }

    function remove_patient_for_insurer(address paddr, address daddr) public {
        remove_element_in_array(insurerInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].insurerAccessList, daddr);
    }

    function remove_patient_for_laboratory(address paddr, address daddr) public {
        remove_element_in_array(laboratoryInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].laboratoryAccessList, daddr);
    }
    
    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }
    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory )
    {
        return doctorInfo[addr].patientAccessList;
    }
    function get_accessed_patientlist_for_insurer(address addr) public view returns (address[] memory )
    { 
        return insurerInfo[addr].patientAccessList;
    }
    function get_accessed_insurerlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage insureraddr = patientInfo[addr].insurerAccessList;
        return insureraddr;
    }
    function get_accessed_patientlist_for_laboratory(address addr) public view returns (address[] memory )
    { 
        return laboratoryInfo[addr].patientAccessList;
    }
    function get_accessed_laboratorylist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage laboratoryaddr = patientInfo[addr].laboratoryAccessList;
        return laboratoryaddr;
    }

    
    function revoke_access_for_doctor(address daddr) public payable{
        remove_patient_for_doctor(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }
    function revoke_access_for_insurer(address daddr) public payable{
        remove_patient_for_insurer(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }
    function revoke_access_for_laboratory(address daddr) public payable{
        remove_patient_for_laboratory(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }

    function get_patient_list() public view returns(address[] memory ){
        return patientList;
    }

    function get_doctor_list() public view returns(address[] memory ){
        return doctorList;
    }
    function get_insurer_list() public view returns(address[] memory ){
        return insurerList;
    }
    function get_laboratory_list() public view returns(address[] memory ){
        return laboratoryList;
    }

    function get_hash(address paddr) public view returns(string memory ){
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }

}

