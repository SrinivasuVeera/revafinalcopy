Public class Utility
{
    Public static string Acc_RecType_University_Department = 'University Department';
    Public static string Acc_RecType_Academic_Program = 'Academic Program';
    Public static string Acc_RecType_Educational_Institution = 'Educational Institution';
    Public static string RBS_Specialization ='RBS Specialization';
    Public static string Acc_RecType_Household = 'Household Account';
    Public static string Contact_RecType_Professor = 'Professor';
    Public static string Contact_RecType_Non_Teaching = 'Non Teaching';
    Public static string Contact_RecType_Student = 'Student';
    Public static string Contact_RecType_Alumni = 'Alumni';
    Public static string Contact_RecType_Parent = 'Parent';
    Public static string Term_Object_RecType_Term = 'Semester';
    Public static string Term_Object_RecType_Sections = 'Sections';
    Public static string Term_Object_RecType_Batches = 'Batches';
    Public static string Educ_History_Object_RecType_Edu_Details = 'Education Details';
    Public static string Educ_History_Object_RecType_Edu_Docu = 'Education Documents';
    Public static string STM_RecType_Section = 'Student Section';
    Public static string STM_RecType_Batch = 'Student Batch';
    Public static string Term_RecType_Group = 'Group Allocation';
    Public static string STM_RecType_Group = 'Student Group Allocation';
    Public static string CC_Stud_RecType = 'Student';
    Public static string CC_App_RecType = 'Applicant';
    Public static string CC_Faculty_RecType = 'Faculty';
    Public static string Case_SupportRequest_RecType = 'Support Request';
    Public static string Case_AlumniAssist_RecType = 'Alumni Assist';
    public static string Alumni_Activities_Event_RecType = 'Events';
    
    Public static boolean LogisysAPI = true;
    Public static boolean ContactOwnerUpdate = true;
    Public static boolean NPF_API_To_Stop_Rollup = false;
    
    @future(callout=true)
    public static void FileCreation(string FileUrl,string recordId,string FileName)
    {
        try
        {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            // req.setEndpoint('https://reva-university.nopaperforms.com//uploads//student//document//97//2162//2022//01//31//61f7830c4b745497654803_Image.jpg');
            req.setEndpoint(FileUrl);
            req.setMethod('GET');
            //req.setHeader('Content-Type', 'application/pdf');
            req.setCompressed(true);
            req.setTimeout(60000);
            HttpResponse res  = h.send(req);
            system.debug('Response from Server: ' + res.getBody());
            blob retFile = res.getBodyAsBlob();
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = FileName;  
            
            contentVersionRec.PathOnClient = 'image.jpg';  
            contentVersionRec.FirstPublishLocationId = recordId;  
            contentVersionRec.VersionData = retFile;  
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;
            
            system.debug('=====>>>>'+contentVersionRec);
        }
        catch(Exception ex)
        {
            system.debug('=====>>>>'+ex.getCause()+ ' ' + ex.getMessage());
        }
        
    }
    
    public static String generateRandomNumber() {
        String randomNumber = generate();
        if (randomNumber.length() < 6) {
            String randomNumber2 = generate();
            randomNumber = randomNumber + randomNumber2.substring(0, 10 - randomNumber.length());
        }      
        
        return randomNumber;
    }
    public static String generateIdentifier(String prefix) {
        return prefix + '-' + generateRandomNumber();
    }
    private static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }
}