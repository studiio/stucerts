contract StuCerts {
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
    
    address owner;
    Certificate[] certs;

    // Certificate added
    event certificateCreated(uint certId, uint foreignId);
    
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _
    }

    
    function StuCerts() {
        owner = msg.sender;
    }
    
    /**
     * Get a certificate
     */
    function getCertificate(uint certId) constant returns(CertificateState status, string firstName, string lastName, string trainingTitle, uint trainingDate, uint trainingDuration) {

        return (
            certs[certId].state,
            certs[certId].firstName,
            certs[certId].lastName,
            certs[certId].trainingTitle,
            certs[certId].trainingDate,
            certs[certId].trainingDuration
        );
    }
    
    /**
     * Get the certificate count
     */
    function getCertificateCount() constant returns(uint count) {
        count = certs.length;
    }
    
    /**
     * Get a count of validators for a given certificate
     */
    function getCertificateValidatorCount(uint certId) constant returns(uint count) {
        count = certs[certId].validators.length;
    }
    
    /**
     * Get a certificate validator.
     */
    function getCertificateValidator(uint certId, uint validatorId) constant returns(string firstName, string lastName, string title, string comment) {
        return (
            certs[certId].validators[validatorId].firstName, 
            certs[certId].validators[validatorId].lastName,
            certs[certId].validators[validatorId].title,
            certs[certId].validators[validatorId].comment
        );
    }
    
    /**
     * Add a certificate to our database.
     * The foreign key is optional and is only used to be passed back in the event, to be able to link this certificate
     * to a foreign entity.
     */
    function createCertificate(string firstName, string lastName, string trainingTitle, uint trainingDate, uint trainingDuration, uint foreignId) onlyOwner returns(uint certId) {
        
        if(bytes(firstName).length == 0 || bytes(lastName).length == 0 || bytes(trainingTitle).length == 0) {
            throw;
        }
        
        certId = certs.length++;
        certs[certId].state = CertificateState.Active;
        certs[certId].firstName = firstName;
        certs[certId].lastName = lastName;
        certs[certId].trainingTitle = trainingTitle;
        certs[certId].trainingDate = trainingDate;
        certs[certId].trainingDuration = trainingDuration;

        certificateCreated(certId, foreignId);
    }
    
    /**
     * Revoke a certificate
     */
    function revokeCertificate(uint certId) onlyOwner {
        certs[certId].state = CertificateState.Revoked;
    }
    
    /**
     * Add a person validating a certificate
     */
    function addCertificateValidator(uint certId, string validatorFirstName, string validatorLastName, string validatorTitle, string validatorComment) onlyOwner returns(uint validatorId) {
        
        validatorId = certs[certId].validators.length++;
        
        certs[certId].validators[validatorId].firstName = validatorFirstName;
        certs[certId].validators[validatorId].lastName = validatorLastName;
        certs[certId].validators[validatorId].title = validatorTitle;
        certs[certId].validators[validatorId].comment = validatorComment;
        
        return validatorId;
    }
    
    
}
