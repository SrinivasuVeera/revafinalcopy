global class YAI_Wrapper {
    
    public APIRequest apiRequest;
    public APIResponse apiResponse;

    public class APIRequest{
        public String email;
        public String firstName;
        public String lastName;
        public String middleName;
        public String mobile;
        public String countryCode;
        public Id leadOrContactId;
        public String otpDestination;
        public string otpText;
        public string validationType;
        public string transcriptBase64;
        public string fileName;

        
        
    }
    global class APIResponse{
        public boolean found;
        public Id leadOrContactId;
        public String errorDescription;
        public Id leadRec;
        public String otpDestination;
        public String otp;
        public Datetime otpValidTill;
        public String siteUrl;
      //  public Integer otpTimeOutInSeconds;
       public String counselorManagerName;
        public Id counselorMangerId;
        public string reason;
        public string status;
        public integer count;
        public string email;
        public string name;
    }

}