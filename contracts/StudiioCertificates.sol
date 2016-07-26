contract StudiioCertificates {
    struct Validator {
        string firstName;
        string lastName;
        string title;
        string comment;
    }
    
    enum CertificateState { Active, Revoked }
    struct Certificate {
        CertificateState state; 
        string firstName;
        string lastName;
        string trainingTitle;
        uint trainingDate;
        uint trainingDuration;
        Validator[] validators;
    }
    
    address creator;
    mapping (address => bool) admins;
    Certificate[] certificates;

    // Certificate added. foreignId is the foreignId variable given to the createCertificate call
    event certificateCreated(uint certId, uint foreignId);
    // Certificate revoked
    event certificateRevoked(uint certId);
    // Certificate validator added. 
    // foreignValidatorId is the foreignValidatorId variable given to the addCertificateValidator call
    event certificateValidatorAdded(uint certId, uint validatorId, uint foreignValidatorId);
    
    modifier onlyCreator() {
        if (msg.sender != creator) throw;
        _
    }

    modifier onlyAdmins() {
        if (admins[msg.sender] == false) throw;
        _
    }

    
    function StudiioCertificates() {
        creator = msg.sender;
        admins[creator] = true;
    }
    
    /**
     * Get a certificate
     */
    function getCertificate(uint certId) constant returns(CertificateState status, string firstName, string lastName, string trainingTitle, uint trainingDate, uint trainingDuration) {

        return (
            certificates[certId].state,
            certificates[certId].firstName,
            certificates[certId].lastName,
            certificates[certId].trainingTitle,
            certificates[certId].trainingDate,
            certificates[certId].trainingDuration
        );
    }
    
    /**
     * Get the certificate count
     */
    function getCertificateCount() constant returns(uint count) {
        count = certificates.length;
    }
    
    /**
     * Get a count of validators for a given certificate
     */
    function getCertificateValidatorCount(uint certId) constant returns(uint count) {
        count = certificates[certId].validators.length;
    }
    
    /**
     * Get a certificate validator.
     */
    function getCertificateValidator(uint certId, uint validatorId) constant returns(string firstName, string lastName, string title, string comment) {
        return (
            certificates[certId].validators[validatorId].firstName, 
            certificates[certId].validators[validatorId].lastName,
            certificates[certId].validators[validatorId].title,
            certificates[certId].validators[validatorId].comment
        );
    }
    
    /**
     * Add a certificate to our database.
     * The foreign key is optional and is only used to be passed back in the event, to be able to link this certificate
     * to a foreign entity.
     */
    function createCertificate(string firstName, string lastName, string trainingTitle, uint trainingDate, uint trainingDuration, uint foreignId) onlyAdmins returns(uint certId) {
        
        if(bytes(firstName).length == 0 || bytes(lastName).length == 0 || bytes(trainingTitle).length == 0) {
            throw;
        }
        
        certId = certificates.length++;
        certificates[certId].state = CertificateState.Active;
        certificates[certId].firstName = firstName;
        certificates[certId].lastName = lastName;
        certificates[certId].trainingTitle = trainingTitle;
        certificates[certId].trainingDate = trainingDate;
        certificates[certId].trainingDuration = trainingDuration;

        certificateCreated(certId, foreignId);
    }
    
    /**
     * Revoke a certificate
     */
    function revokeCertificate(uint certId) onlyAdmins {
        certificates[certId].state = CertificateState.Revoked;

        certificateRevoked(certId);
    }
    
    /**
     * Add a person validating a certificate
     */
    function addCertificateValidator(uint certId, string validatorFirstName, string validatorLastName, string validatorTitle, string validatorComment, uint foreignValidatorId) onlyAdmins returns(uint validatorId) {
        
        validatorId = certificates[certId].validators.length++;
        
        certificates[certId].validators[validatorId].firstName = validatorFirstName;
        certificates[certId].validators[validatorId].lastName = validatorLastName;
        certificates[certId].validators[validatorId].title = validatorTitle;
        certificates[certId].validators[validatorId].comment = validatorComment;
        
        certificateValidatorAdded(certId, validatorId, foreignValidatorId);
    }
    
    
    /**
     * Change admins : Authorize or not an address to do changes
     */
    function changeAllowedRecipients(address person, bool allowed) onlyCreator {
        admins[person] = allowed;
    }
}
