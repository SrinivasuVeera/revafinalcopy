public without sharing class FeedbackManagementController {  
   	//public List<Contact> Contacts { get; set; }
    public static List<FeedbackAverageTemp__c> averageList { get; set; }
    public static List<FacultyWrapper> listFw { get; set; }
        
   public FeedbackManagementController() {     
        averageList = new List<FeedbackAverageTemp__c>();
        Decimal overallAverage = 0;	
       
        String semesterId = ApexPages.currentPage().getParameters().get('SemesterID');
        String tempId = ApexPages.currentPage().getParameters().get('tempId');
        String coId = ApexPages.currentPage().getParameters().get('coId');
        String ccId = ApexPages.currentPage().getParameters().get('ccId');
       	String secId = ApexPages.currentPage().getParameters().get('secId');
        
        if (!String.isBlank(semesterId) && !String.isBlank(tempId)) {
        	initData(semesterId, tempId);
        }   
       
        if (!String.isBlank(coId) && !String.isBlank(tempId) && !String.isBlank(ccId) && !String.isBlank(secId)) {
            averageList = [
                SELECT QId__c, Feedback_Average__c, FeedbackQBank__r.Question__c
                FROM FeedbackAverageTemp__c
                WHERE Course_Offering__c = :coId
                AND TemplateId__c = :tempId 
                AND SectionId__c = :secId
            ];
            
            for (FeedbackAverageTemp__c rec : averageList) {
                if (rec.Feedback_Average__c != null) {
                    rec.Feedback_Average__c = rec.Feedback_Average__c.setScale(2, RoundingMode.HALF_UP);
                }
            }


            // Calculate the average
            Decimal total = 0;
            Integer count = 0;

            for (FeedbackAverageTemp__c f : averageList) {
                if (f.Feedback_Average__c != null) {
                    total += f.Feedback_Average__c;
                    count++;
                }
            }

            if (count > 0) {
                overallAverage = (total / count).setScale(2);
            }
            
             listFw = new List<FacultyWrapper>();
             
             			hed__Course_Enrollment__c ccObj = [SELECT Id,  
                                                                   hed__Course_Offering__c, 
                                                                   hed__Course_Offering__r.Name,
                                                                   hed__Contact__r.Name, 
                                                                   hed__Contact__r.Account_Name__c,
                                                                   Program__c,Course_Code__c,
                                                                   Semester_Name__c,
                                                                   Section__r.Name,
                                                                   hed__Program_Enrollment__r.Program_Batch_Portal__c,                   
                                                                   hed__Course_Offering__r.hed__Course__r.Name,
                                                                   hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                                   Director_Feedback__c,
                                                                   Director_Feedback_Status__c
                                                            FROM hed__Course_Enrollment__c 
                                                            WHERE Id =: ccId LIMIT 1];
            	                    
            			listFw.add(new FacultyWrapper(
                            ccObj.hed__Contact__r.Name,
                            ccObj.hed__Contact__r.Account_Name__c,
                            ccObj.Program__c,
                            ccObj.hed__Program_Enrollment__r.Program_Batch_Portal__c,
                            ccObj.Section__r.Name,
                            ccObj.hed__Course_Offering__r.hed__Course__r.Name,
                            ccObj.Course_Code__c,
                            ccObj.Semester_Name__c,
                            ccObj.Director_Feedback__c,
                            averageList,
                            overallAverage
                        ));
        	} 		
    } 
    
    @AuraEnabled
    public static String getStudentEligibility(String contactId) {
            if (contactId == null) {
                return 'INVALID_CONTACT_ID';
            }        
            try {
                Contact con = [
                    SELECT Program_Batch__c, Total_average_current_sem_attendance__c
                    FROM Contact
                    WHERE Id = :contactId
                    LIMIT 1
                ];        
                      
                if (con.Program_Batch__c == null) {
                    return 'MISSING_PROGRAM_BATCH';
                }        
                 List<Feedback_Release__c> feedbackReleases = [
                    SELECT Id, Program_Batch_Id__c, Program_Batch_Name__c, Program_Id__c, Program_Name__c,
                           Semester_Id__c, Semester_Name__c, Start_Date__c, End_Date__c,
                           Template_Type__c, Template_Id__c, Active__c,Minimum_attendance__c
                    FROM Feedback_Release__c
                    WHERE Program_Batch_Id__c = :con.Program_Batch__c 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];   
                if (!feedbackReleases.isEmpty() && 
                    (con.Total_average_current_sem_attendance__c == null || 
                     con.Total_average_current_sem_attendance__c <= feedbackReleases[0].Minimum_attendance__c)) {
                    return 'NO_ATTENDANCE';
                }
                if (feedbackReleases.isEmpty()) {
                    return 'FEEDBACK_NOT_SET';
                }
				                  
                Feedback_Release__c feedbackRelease = feedbackReleases[0];    
                System.debug('feedbackRelease Active');
                if (!feedbackRelease.Active__c) {
                    return 'NOT_ACTIVE';
                } 
                System.debug('Start_Date__c End_Date__c');
                if (feedbackRelease.Start_Date__c == null || feedbackRelease.End_Date__c == null) {
                    return 'IN_COMPLETE_SETUP';
                }        
                Date today = Date.today();
                if (today >= feedbackRelease.Start_Date__c && today <= feedbackRelease.End_Date__c) {
                    return 'SUCCESS';
                } else {
                    return 'NO_DATE_RANGE';
                }
        
            } catch (QueryException qe) {
                // Optional: Log error
                System.debug('QueryException: ' + qe.getMessage());
                return 'Error : QueryException';
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
                return 'Error : Exception';
            }
	}

	@AuraEnabled
	public static List<FeedbackQBankWrapper> getQuestionsByType(String feedbackType) {
        if (String.isBlank(feedbackType)) {
            throw new AuraHandledException('FeedbackType__c is required.');
        }
    
        List<FeedbackQBank__c> questions = [
            SELECT Id,FeedbackTemplate__r.Id, Name, FeedbackTemplate__r.Name, FeedbackTemplate__r.FeedbackType__c, Question__c 
            FROM FeedbackQBank__c 
            WHERE FeedbackTemplate__r.Active__c = true 
              AND FeedbackTemplate__r.FeedbackType__c = :feedbackType
        ];
    
        List<FeedbackQBankWrapper> wrappedQuestions = new List<FeedbackQBankWrapper>();
        Integer idx = 1;
        for (FeedbackQBank__c q : questions) {
          //   wrappedQuestions.add(new FeedbackQBankWrapper('q' + idx, q.Question__c));
          //   wrappedQuestions.add(new FeedbackQBankWrapper(q.Name, q.FeedbackTemplate__r.Name ,idx+'. '+q.Question__c));
          wrappedQuestions.add(new FeedbackQBankWrapper(q.Id,q.FeedbackTemplate__r.Id,q.Name, q.FeedbackTemplate__r.Name, q.FeedbackTemplate__r.FeedbackType__c, idx+'. '+q.Question__c));
            idx++;
        }
        return wrappedQuestions;
	}   
    
   
    
    @AuraEnabled(cacheable=true)
    public static List<CourseEnrollmentWrapper> getFacultyEnrollments() {
     /*   User currentUser = [SELECT Id,FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() AND Profile.Name = 'Professor' LIMIT 1];
        String email = currentUser.FederationIdentifier;
        Contact contact = [SELECT Id,name FROM Contact WHERE hed__WorkEmail__c =: email];
        Id facId = contact.Id; */
        Contact cont = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() LIMIT 1];       
        Id facId = cont.Id;
         System.debug('Faculty Id --> : '+facId);
        List<hed__Course_Enrollment__c> enrollments = [
            SELECT Id, Name, hed__Course_Offering__c, Section__c,hed__Course_Offering__r.hed__Course__r.Name,
                   School__c, Semester__c, Section_Batch_Group__c, 
            	   hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,Feedback_on_course__c
            FROM hed__Course_Enrollment__c
            WHERE hed__Contact__c =: facId
              AND RecordType.Name = 'Faculty'
              AND Active_Connection__c = true
        ];
        //WHERE hed__Contact__c =: facId
        system.debug('Data --> : '+enrollments); // '003Ip00000DRkQpIAL'  '003Ip00000DRkQpIAL' 
        List<CourseEnrollmentWrapper> results = new List<CourseEnrollmentWrapper>();
        for (hed__Course_Enrollment__c ce : enrollments) {
            results.add(new CourseEnrollmentWrapper(
                ce.Id,
                ce.School__c,
                ce.Semester__c,
                ce.Section_Batch_Group__c,
                ce.Section__c,
                ce.hed__Course_Offering__c,
                ce.hed__Course_Offering__r.hed__Course__r.Name,
                ce.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                ce.Feedback_on_course__c
            ));
        }        
        return results;
    }
    
    @AuraEnabled
    public static List<StudentWrapper> getStudentsForEnrollment(Id courseOfferingId, Id sectionId) {
        if (courseOfferingId == null || sectionId == null) {
            return new List<StudentWrapper>();
        }    
        List<hed__Course_Enrollment__c> students = [
            SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Course_Offering__c,
                   Course_Offering_Section_ID__c, hed__Contact__r.SRN_Number__c,
                   Feedback_on_course__c, Feedback_on_faculty__c
            FROM hed__Course_Enrollment__c
            WHERE hed__Course_Offering__c = :courseOfferingId
              AND Section__c = :sectionId
              AND RecordType.Name = 'Student'
            ORDER BY hed__Contact__r.SRN_Number__c ASC
        ];
    
        List<StudentWrapper> result = new List<StudentWrapper>();
        for (hed__Course_Enrollment__c s : students) {
            result.add(new StudentWrapper(
                s.hed__Contact__r.Name,
                s.hed__Contact__r.SRN_Number__c,
                s.Feedback_on_course__c,
                s.Feedback_on_faculty__c
            ));
        }
        return result;
    }
    
	@AuraEnabled(cacheable=false)
	public static List<FeedbackSummary> getFeedbackSummary(String courseOfferingId, String templateId, String sectionId, String courseConnId) {
        System.debug('courseOfferingId :'+courseOfferingId+' -  '+'templateId : '+templateId+' -  '+'sectionID : '+sectionId);     
        // Step 1: Get aggregated feedback data
        List<AggregateResult> feedbackResults = [
            SELECT Course_Connection__r.hed__Course_Offering__c courseOfferingId,TemplateId__c templateId,QId__c qId,FeedbackQBank__c qbId,Course_Connection__r.Section__c secId,AVG(Response__c) avgResponse
            FROM FeedbackResponse__c 
			WHERE Course_Connection__r.hed__Course_Offering__c =: courseOfferingId  AND TemplateId__c =: templateId AND Course_Connection__r.Section__c =: sectionId 
			GROUP BY Course_Connection__r.hed__Course_Offering__c, TemplateId__c, QId__c, FeedbackQBank__c, Course_Connection__r.Section__c
        ];  // 'a0BIp000000JB2rMAG'

        // Step 2: Collect QIds
        Set<String> qIds = new Set<String>();
        for (AggregateResult ar : feedbackResults) {
            qIds.add((String)ar.get('qId'));
        }

        // Step 3: Query questions from FeedbackQBank__c
        Map<String, String> qIdToQuestionMap = new Map<String, String>();
        for (FeedbackQBank__c qbank : [          
            SELECT Name, Question__c
            FROM FeedbackQBank__c
            WHERE Name IN :qIds AND FeedbackTemplate__r.Name =: templateId
        ]) {
            qIdToQuestionMap.put(qbank.Name, qbank.Question__c);
        }
        
    /*    hed__Course_Offering__c courseOff = [SELECT Id, Director_Feedback__c, Director_Feedback_Status__c FROM hed__Course_Offering__c WHERE Id =: courseOfferingId];
        Boolean directorFeedbackStatus = courseOff.Director_Feedback_Status__c;
        String directorFeedbackRemark = courseOff.Director_Feedback__c;		*/
        
        hed__Course_Enrollment__c courseConnection = [SELECT Id, Director_Feedback__c, Director_Feedback_Status__c FROM hed__Course_Enrollment__c WHERE Id =: courseConnId];
        Boolean directorFeedbackStatus = courseConnection.Director_Feedback_Status__c;
        String directorFeedbackRemark = courseConnection.Director_Feedback__c;
        
        // Step 4: Combine results
        List<FeedbackSummary> summaries = new List<FeedbackSummary>();
        for (AggregateResult ar : feedbackResults) {
            String qId = (String)ar.get('qId');
            String qbId = (String)ar.get('qbId');
            Decimal avg = (Decimal)ar.get('avgResponse');
            Decimal roundedAvg = avg.setScale(2, RoundingMode.HALF_UP); // round to 2 decimal places
        
            summaries.add(new FeedbackSummary(
                (String)ar.get('courseOfferingId'),
                (String)ar.get('templateId'),
                (String)ar.get('secId'),
                qId,
                qIdToQuestionMap.get(qId),
              	qbId,
                roundedAvg,
                directorFeedbackStatus,
                directorFeedbackRemark
            ));
		}


        return summaries;
    }
    
     @AuraEnabled
    public static void insertFeedbackResponses(List<FeedbackInput> feedbackList, String feedbackType, String remark) {
        List<FeedbackResponse__c> recordsToInsert = new List<FeedbackResponse__c>();    
        
		Set<Id> courseConnectionIdSet = new Set<Id>();        
        String CoId;
        String TempId;
        String SecId;
        String CCId;
        
        for (FeedbackInput feedback : feedbackList) {
            courseConnectionIdSet.add(feedback.courseConnId);
            //CoId.add(feedback.courseOffId);
            //TempId.add(feedback.templateId);
            CoId = feedback.courseOffId;
        	TempId = feedback.templateId;
            SecId = feedback.sectionId;
            CCId = feedback.courseConnId;
            
            FeedbackResponse__c record = new FeedbackResponse__c(
                TemplateId__c = feedback.templateId,
                QId__c = feedback.id,
                FeedbackQBank__c = feedback.qbId,
                Response__c = feedback.rating,
                Course_Connection__c = feedback.courseConnId,                 
                Course_Offering_Id__c = feedback.courseOffId
            );
            recordsToInsert.add(record);            
        }

        if (!recordsToInsert.isEmpty()) {
            // INSERT
             insert recordsToInsert;
        }
        
        // Update fields Feedback_on_course__c and Feedback_on_faculty__c of hed__Course_Enrollment__c object 
        // Update fields Feedback_on_course__c and Feedback_on_faculty__c once student gave feedback on courses or faculty
		
        if (!courseConnectionIdSet.isEmpty()) {
            List<hed__Course_Enrollment__c> enrollmentsToUpdate = [
                SELECT Id, Feedback_on_course__c, Feedback_on_faculty__c
                FROM hed__Course_Enrollment__c 
                WHERE Id IN :courseConnectionIdSet
            ];
    
            for (hed__Course_Enrollment__c enrollment : enrollmentsToUpdate) {
                if(feedbackType == 'Course') {
                	//enrollment.Preference_2__c = 'AI3 in salesforce';
                    enrollment.Feedback_on_course__c = true;
                    enrollment.Feedback_Remark_on_course__c = remark;
                }
                if(feedbackType == 'Faculty') {
                    enrollment.Feedback_on_faculty__c = true;
                    enrollment.Feedback_Remark_on_faculty__c = remark;
                }
            }
    
            if (!enrollmentsToUpdate.isEmpty()) {
                // UPDATE
                update enrollmentsToUpdate;
                
                List<FeedbackSummary> summaries = getFeedbackSummary(CoId, TempId, SecId, CCId);
                
                System.debug('summaries size : '+summaries.size());
              
                // Steps to check record is already exist then update else insert it
                	// Step 1: Collect all unique keys and field values needed for querying existing records
                    Set<Id> courseOfferingIds = new Set<Id>();
                    Set<String> qIds = new Set<String>();
                    Set<String> templateIds = new Set<String>();
                	Set<String> secIds = new Set<String>();
                    Set<String> keys = new Set<String>();
                    
                    for (FeedbackSummary summary : summaries) {
                        courseOfferingIds.add(summary.courseOfferingId);
                        qIds.add(summary.qbId);
                        templateIds.add(summary.templateId);
                        secIds.add(summary.sectionId);
                        String key = summary.courseOfferingId + '-' + summary.qbId + '-' + summary.templateId+ '-' + summary.sectionId;
                        keys.add(key);
                    }
                    
                    // Step 2: Query existing FeedbackAverage__c records
                    Map<String, FeedbackAverageTemp__c> existingMap = new Map<String, FeedbackAverageTemp__c>();
                    
                    List<FeedbackAverageTemp__c> existingRecords = [
                        SELECT Id, Course_Offering__c, QId__c, FeedbackQBank__c, templateId__c, Feedback_Average__c,SectionId__c
                        FROM FeedbackAverageTemp__c
                        WHERE Course_Offering__c IN :courseOfferingIds
                        AND FeedbackQBank__c IN :qIds 
                        AND templateId__c IN :templateIds 
                        AND SectionId__c IN :secIds
                    ];
                // AND QId__c IN :qIds
                    
                    for (FeedbackAverageTemp__c fa : existingRecords) {
                        String key = fa.Course_Offering__c + '-' + fa.FeedbackQBank__c + '-' + fa.templateId__c+ '-' + fa.SectionId__c;
                        existingMap.put(key, fa);
                    }
                    
                    // Step 3: Prepare records for insert or update
                    List<FeedbackAverageTemp__c> recordsInsertAverage = new List<FeedbackAverageTemp__c>();
                    List<FeedbackAverageTemp__c> recordsUpdateAverage = new List<FeedbackAverageTemp__c>();
                    
                    for (FeedbackSummary summary : summaries) {
                        String key = summary.courseOfferingId + '-' + summary.qbId + '-' + summary.templateId + '-' + summary.sectionId;
                        Decimal avg = summary.averageResponse;
                        Decimal roundedAvg = avg.setScale(2, RoundingMode.HALF_UP); // round to 2 decimal places   
                        
                        if (existingMap.containsKey(key)) {
                            // Update existing record
                            FeedbackAverageTemp__c existing = existingMap.get(key);
                       //     existing.Feedback_Average__c = summary.averageResponse;
                             existing.Feedback_Average__c = roundedAvg;                        
                             recordsUpdateAverage.add(existing);
                        } else {
                            // Create new record
                            FeedbackAverageTemp__c newRecord = new FeedbackAverageTemp__c(
                                Course_Offering__c = summary.courseOfferingId,
                                templateId__c = summary.templateId,
                                FeedbackQBank__c = summary.qbId,
                                QId__c = summary.qId,
                                SectionId__c = summary.sectionId,
                                Feedback_Average__c = roundedAvg
                            //    Feedback_Average__c = summary.averageResponse
                            );
                            recordsInsertAverage.add(newRecord);
                        }
                    }
                    
                    // Step 4: Perform DML
                    if (!recordsUpdateAverage.isEmpty()) {
                        update recordsUpdateAverage;
                    }
                    if (!recordsInsertAverage.isEmpty()) {
                        insert recordsInsertAverage;
                    }
            }
    	}
    }
    
	 public void initData(String semesterId, String tempId) {
        listFw = new List<FacultyWrapper>();

        // 1. Fetch course enrollments
        List<hed__Course_Enrollment__c> enrollments = [
            SELECT Id,  
                   hed__Course_Offering__c, 
                   hed__Course_Offering__r.Name,
                   hed__Contact__r.Name, 
                   hed__Contact__r.Account_Name__c,
				   Program__c,Course_Code__c,
             	   Section__c,
            	   Semester_Name__c,
            	   Section__r.Name,
                   hed__Program_Enrollment__r.Program_Batch_Portal__c,                   
                   hed__Course_Offering__r.hed__Course__r.Name,
                   hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                   Director_Feedback__c,
                   Director_Feedback_Status__c
            FROM hed__Course_Enrollment__c
            WHERE (Section__r.hed__Parent_Term__c =: semesterId
                   OR Section__r.hed__Parent_Term__r.hed__Parent_Term__c =: semesterId)
            AND RecordType.Name = 'Faculty'
        ];

        // 2. Collect unique CourseOffering-Section combinations
        Set<Id> courseOfferingIds = new Set<Id>();
        Set<Id> sectionIds = new Set<Id>();
    	Set<String> comboKeys = new Set<String>();   // composite keys
         
        for (hed__Course_Enrollment__c e : enrollments) {
            if (e.hed__Course_Offering__c != null) {
                courseOfferingIds.add(e.hed__Course_Offering__c);
                sectionIds.add(e.Section__c);

                // Composite Key: CourseOffering + Section
                comboKeys.add(e.hed__Course_Offering__c + '-' + e.Section__c);
            }
        }

        // 3. Fetch FeedbackAverage__c in bulk
        Map<String, List<FeedbackAverageTemp__c>> feedbackMap = new Map<String, List<FeedbackAverageTemp__c>>();
        if (!courseOfferingIds.isEmpty() && !String.isBlank(tempId)) {
            for (FeedbackAverageTemp__c fa : [
                SELECT Course_Offering__c, QId__c, Feedback_Average__c, FeedbackQBank__r.Question__c,SectionId__c
                FROM FeedbackAverageTemp__c
                WHERE Course_Offering__c IN :courseOfferingIds
                AND TemplateId__c = :tempId 
                AND SectionId__c IN :sectionIds
                
            ]) {
                if (fa.Course_Offering__c != null && fa.SectionId__c != null) {
                String key = fa.Course_Offering__c + '-' + fa.SectionId__c;

                if (!feedbackMap.containsKey(key)) {
                    feedbackMap.put(key, new List<FeedbackAverageTemp__c>());
                }
                feedbackMap.get(key).add(fa);
            }
            }
        }

        // 4. Build wrappers
        for (hed__Course_Enrollment__c enroll : enrollments) {
            String key = enroll.hed__Course_Offering__c + '-' + enroll.Section__c;
	        List<FeedbackAverageTemp__c> averages = feedbackMap.get(key);
            
            Decimal overallAverage = 0;

            if (averages != null && !averages.isEmpty()) {
                Decimal total = 0;
                Integer count = 0;
                for (FeedbackAverageTemp__c f : averages) {
                    f.Feedback_Average__c = f.Feedback_Average__c.setScale(2, RoundingMode.HALF_UP);
                    if (f.Feedback_Average__c != null) {
                        total += f.Feedback_Average__c;
                        count++;
                    }
                }
                if (count > 0) {
                    overallAverage = (total / count).setScale(2);
                }
            }           

            listFw.add(new FacultyWrapper(
                enroll.hed__Contact__r.Name,
                enroll.hed__Contact__r.Account_Name__c,
                enroll.Program__c,
                enroll.hed__Program_Enrollment__r.Program_Batch_Portal__c,
                enroll.Section__r.Name,
                enroll.hed__Course_Offering__r.hed__Course__r.Name,
                enroll.Course_Code__c,
                enroll.Semester_Name__c,
                enroll.Director_Feedback__c,
                averages,
                overallAverage
            ));
        }
    }
 
    @AuraEnabled
	public static String generateFeedbackPdf(String courseOfferingId, String templateId, String courseConnectionId,String sectionId) {
        PageReference pdfPage = Page.FacultyFeedbackReportPdf; 
        pdfPage.getParameters().put('coId', courseOfferingId);
        pdfPage.getParameters().put('tempId', templateId);
        pdfPage.getParameters().put('ccId', courseConnectionId);
        pdfPage.getParameters().put('secId', sectionId);
    
        Blob pdfBlob;
        // By adding this check, we avoid the getContentAsPDF() call in a test context.
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('This is a dummy PDF content for testing.');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }    
   		return EncodingUtil.base64Encode(pdfBlob);
	} 
  
    /*
    @AuraEnabled
    public static String generatePdfAndStore(String semesterId, String tempId) {
        // Generate the PDF from Visualforce page
        PageReference pdfPage = Page.ContactPDFPage; // replace with your VF page name
        pdfPage.getParameters().put('SemesterID', semesterId);
        pdfPage.getParameters().put('tempId', tempId);
        Blob pdfBlob = pdfPage.getContentAsPDF();

        // Insert ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Director_Feedback_Report_' + semesterId;
        contentVersion.PathOnClient = 'DirectorFeedback_' + semesterId + '.pdf';
        contentVersion.VersionData = pdfBlob;
        contentVersion.IsMajorVersion = true;
        insert contentVersion;

        // Query ContentDocumentId
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id 
            LIMIT 1
        ];

        // Check if ContentDocumentLink already exists for current user
        List<ContentDocumentLink> existingLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedVersion.ContentDocumentId 
            AND LinkedEntityId = :UserInfo.getUserId()
        ];

        if (existingLinks.isEmpty()) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = insertedVersion.ContentDocumentId;
            link.LinkedEntityId = UserInfo.getUserId(); // current user
            link.ShareType = 'I'; // Inferred share type for user
            link.Visibility = 'AllUsers';
            insert link;
        }

        // Return base64 encoded PDF so LWC can trigger download directly
        return EncodingUtil.base64Encode(pdfBlob);
    }
	*/
    
    @AuraEnabled
	public static String generatePdfAndStore(String semesterId, String tempId) {
        PageReference pdfPage = Page.ContactPDFPage;
        pdfPage.getParameters().put('SemesterID', semesterId);
        pdfPage.getParameters().put('tempId', tempId);
        
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('This is a dummy PDF content for testing.');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }
    
        // The rest of the method remains the same
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Director_Feedback_Report_' + semesterId;
        contentVersion.PathOnClient = 'DirectorFeedback_' + semesterId + '.pdf';
        contentVersion.VersionData = pdfBlob;
        contentVersion.IsMajorVersion = true;
        insert contentVersion;
    
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id 
            LIMIT 1
        ];
    
        List<ContentDocumentLink> existingLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedVersion.ContentDocumentId 
            AND LinkedEntityId = :UserInfo.getUserId()
        ];
    
        if (existingLinks.isEmpty()) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = insertedVersion.ContentDocumentId;
            link.LinkedEntityId = UserInfo.getUserId(); 
            link.ShareType = 'I'; 
            link.Visibility = 'AllUsers';
            insert link;
        }
    
        return EncodingUtil.base64Encode(pdfBlob);
	}
	
	//********************************** Feedback Release Program Details ***************************
	
        @AuraEnabled(cacheable=true)
        public static List<String> getAccountIdBasedOnSchoolName() {
            User currentUser = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId() AND Profile.Name = 'Vertical Head' LIMIT 1];
            if (currentUser.Department != null) {
                List<String> schoolId = new List<String>();
                for (Account acc : [SELECT Id, Name FROM Account WHERE Name = :currentUser.Department LIMIT 1]) {
                    schoolId.add(acc.Id + '##' + acc.Name);
                }
                return schoolId;
            }
            return null;
        }
    
        @AuraEnabled(cacheable=true)
        public static List<String> getAccountBasedOnParentIdList(Id parentId) {
            List<String> facultyList = new List<String>();
            for (Account acc : [SELECT Id, Name FROM Account WHERE ParentId = :parentId]) {
                facultyList.add(acc.Id + '##' + acc.Name);
            }
            return facultyList;
        }
    
        @AuraEnabled(cacheable=true)
        public static List<String> getProgramBatchList(Id programId) {
            List<String> programBatchList = new List<String>();
            for (hed__Program_Plan__c pp : [
                SELECT Id, Name FROM hed__Program_Plan__c 
                WHERE hed__Account__c = :programId AND Active__c = true
            ]) {
                programBatchList.add(pp.Id + '##' + pp.Name);
            }
            return programBatchList;
        }
    
        @AuraEnabled(cacheable=true)
        public static List<String> getSemesterList(Id programBId) {
            List<String> semesterList = new List<String>();
            for (hed__Term__c sem : [SELECT Id, Name FROM hed__Term__c WHERE Active__c = true AND Program_Batch__c = :programBId]) {
                semesterList.add(sem.Id + '##' + sem.Name);
            }
            return semesterList;
        }
    
	//*******************************************************************************
    
    //************************************ Feedback Release Implementation *******************************
   
    @AuraEnabled(cacheable=true)
    public static List<Feedback_Release__c> getAllFeedbackReleases() {     
        List<Feedback_Release__c> feedbackReleaseList = new List<Feedback_Release__c>();
        
        User currentUser = [
            SELECT Department 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            AND Profile.Name = 'Vertical Head' 
            LIMIT 1
        ];       

        
        List<hed__Program_Plan__c> programBatchList = [
            SELECT Id, School__c 
            FROM hed__Program_Plan__c 
            WHERE Active__c = true 
            AND School__c = :currentUser.Department
        ];    
 
        
        Set<Id> programBatchIds = new Set<Id>();
        for (hed__Program_Plan__c pb : programBatchList) {
            programBatchIds.add(pb.Id);
        }
        
        feedbackReleaseList = [
            SELECT Id, Program_Batch_Id__c, Program_Batch_Name__c, Program_Id__c, Program_Name__c,
                   Semester_Id__c, Semester_Name__c, Start_Date__c, End_Date__c,
                   Template_Type__c, Template_Id__c, Active__c, Minimum_attendance__c
            FROM Feedback_Release__c
            WHERE Program_Batch_Id__c IN :programBatchIds
        ];        
        
        return feedbackReleaseList;
    
        
       /*
        List<Feedback_Release__c> feedbackReleaseList = new List<Feedback_Release__c>();
        
        // Query current user with Profile filter
        User currentUser = [
            SELECT Department 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            AND Profile.Name = 'Vertical Head' 
            LIMIT 1
        ];
        
        // Check if user or department is missing
        if (currentUser == null || String.isBlank(currentUser.Department)) {
            return feedbackReleaseList;  // empty list
        }
        
        // Query active program batches for user's department
        List<hed__Program_Plan__c> programBatchList = [
            SELECT Id, School__c 
            FROM hed__Program_Plan__c 
            WHERE Active__c = true 
            AND School__c = :currentUser.Department
        ];
        
        if (programBatchList.isEmpty()) {
            return feedbackReleaseList;  // empty list
        }
        
        // Collect Program Batch Ids
        Set<Id> programBatchIds = new Set<Id>();
        for (hed__Program_Plan__c pb : programBatchList) {
            programBatchIds.add(pb.Id);
        }
        
        // Query Feedback_Release__c records for those Program Batch Ids
        feedbackReleaseList = [
            SELECT Id, Program_Batch_Id__c, Program_Batch_Name__c, Program_Id__c, Program_Name__c,
                   Semester_Id__c, Semester_Name__c, Start_Date__c, End_Date__c,
                   Template_Type__c, Template_Id__c, Active__c, Minimum_attendance__c
            FROM Feedback_Release__c
            WHERE Program_Batch_Id__c IN :programBatchIds
        ];
        
        return feedbackReleaseList; */
    
       /* return [SELECT Id, Program_Batch_Id__c, Program_Batch_Name__c, Program_Id__c, Program_Name__c,
                       Semester_Id__c, Semester_Name__c, Start_Date__c, End_Date__c,
                       Template_Type__c, Template_Id__c, Active__c, Minimum_attendance__c
                FROM Feedback_Release__c]; */
    }

    @AuraEnabled
    public static String insertFeedbackRelease(Feedback_Release__c feedback) {
        List<Feedback_Release__c> existing = [
            SELECT Id FROM Feedback_Release__c
            WHERE Program_Id__c = :feedback.Program_Id__c
            AND Program_Batch_Id__c = :feedback.Program_Batch_Id__c
            AND Semester_Id__c = :feedback.Semester_Id__c
            AND Template_Type__c = :feedback.Template_Type__c
            AND Template_Id__c = :feedback.Template_Id__c
            AND Start_Date__c = :feedback.Start_Date__c
            AND End_Date__c = :feedback.End_Date__c
            AND Active__c = :feedback.Active__c
            AND Minimum_attendance__c  = : feedback.Minimum_attendance__c
        ];

        if (!existing.isEmpty()) {
            System.debug('!existing.isEmpty() is true');
            return 'exists';
        }

        insert feedback;
        return 'success';
    }

    @AuraEnabled
	public static String updateFeedbackRelease(Feedback_Release__c feedback) {
        try {
            Feedback_Release__c existing = [
                SELECT Id, Start_Date__c, End_Date__c, Template_Type__c, FeedbackTemplate__c, Active__c,Minimum_attendance__c
                FROM Feedback_Release__c WHERE Id = :feedback.Id LIMIT 1
            ];
    
            existing.Start_Date__c = feedback.Start_Date__c;
            existing.End_Date__c = feedback.End_Date__c;
            existing.Template_Type__c = feedback.Template_Type__c;
            existing.Template_Id__c = feedback.Template_Id__c;
            existing.Active__c = feedback.Active__c;
    		existing.Minimum_attendance__c = feedback.Minimum_attendance__c;
            update existing;
            return 'success';
        } catch (Exception e) {
            System.debug('Error updating Feedback_Release__c: ' + e.getMessage());
            return 'failed';
        }
	}


    @AuraEnabled
    public static void deleteFeedbackRelease(Id recordId) {
        delete [SELECT Id FROM Feedback_Release__c WHERE Id = :recordId];
    }
    
    @AuraEnabled
    public static List<FeedbackQBankWrapper> getQuestionsBySemesterId(String semesterId, String feedbackType) {        
        
        if (String.isBlank(feedbackType) || String.isBlank(semesterId)) {
            throw new AuraHandledException('feedbackType is required or programBatchId');
        }
        System.debug('semesterId : '+semesterId);
        System.debug('feedbackType : '+feedbackType);
        List<Feedback_Release__c> frList = [SELECT Id, Template_Id__c, Start_Date__c, End_Date__c, Active__c 
                					  FROM Feedback_Release__c 
                                      WHERE Semester_Id__c = :semesterId AND Template_Type__c = :feedbackType AND Active__c = true LIMIT 1]; 
       	if (frList.isEmpty()) {
        	return new List<FeedbackQBankWrapper>();
    	}
        
       // String templateId = FR_Rec.Template_Id__c;
       Feedback_Release__c FR_Rec = frList[0];
       String templateId = FR_Rec.Template_Id__c;
       
        Date today = Date.today();
        List<FeedbackQBankWrapper> wrappedQuestions = new List<FeedbackQBankWrapper>();
        
        if(FR_Rec.Active__c && FR_Rec.Start_Date__c != null && FR_Rec.End_Date__c != null){
           if (today >= FR_Rec.Start_Date__c && today <= FR_Rec.End_Date__c) {                    
         		 List<FeedbackQBank__c> questions = [
                    SELECT Id,FeedbackTemplate__r.Id, Name, FeedbackTemplate__r.Name, FeedbackTemplate__r.FeedbackType__c, Question__c 
                    FROM FeedbackQBank__c 
                    WHERE FeedbackTemplate__r.Active__c = true AND FeedbackTemplate__r.Name =: templateId 
                ];
               
                Integer idx = 1;
                for (FeedbackQBank__c q : questions) {
                  //   wrappedQuestions.add(new FeedbackQBankWrapper('q' + idx, q.Question__c));
                  //   wrappedQuestions.add(new FeedbackQBankWrapper(q.Name, q.FeedbackTemplate__r.Name ,idx+'. '+q.Question__c));
                  wrappedQuestions.add(new FeedbackQBankWrapper(q.Id, q.FeedbackTemplate__r.Id, q.Name, q.FeedbackTemplate__r.Name, q.FeedbackTemplate__r.FeedbackType__c, idx+'. '+q.Question__c));
                  idx++;
                }                
           } 
        } 
        return wrappedQuestions;
    }
    
    /*
    @AuraEnabled
    public static List<FeedbackQBankWrapper> getQuestionsBySemester(String semester, String feedbackType) {        
        
        if (String.isBlank(feedbackType) || String.isBlank(semester)) {
            throw new AuraHandledException('feedbackType is required or programBatchId');
        }
        System.debug('semester : '+semester);
        System.debug('feedbackType : '+feedbackType);
        Feedback_Release__c FR_Rec = [SELECT Id, Template_Id__c, Start_Date__c, End_Date__c, Active__c 
                					  FROM Feedback_Release__c 
                                      WHERE Semester_Name__c  = :semester AND Template_Type__c = :feedbackType LIMIT 1]; 
        String templateId = FR_Rec.Template_Id__c;
       
        Date today = Date.today();
        List<FeedbackQBankWrapper> wrappedQuestions = new List<FeedbackQBankWrapper>();
        
        if(FR_Rec.Active__c && FR_Rec.Start_Date__c != null && FR_Rec.End_Date__c != null){
           if (today >= FR_Rec.Start_Date__c && today <= FR_Rec.End_Date__c) {                    
         		 List<FeedbackQBank__c> questions = [
                    SELECT Id,FeedbackTemplate__r.Id, Name, FeedbackTemplate__r.Name, FeedbackTemplate__r.FeedbackType__c, Question__c 
                    FROM FeedbackQBank__c 
                    WHERE FeedbackTemplate__r.Active__c = true AND FeedbackTemplate__r.Name =: templateId 
                ];
               
                Integer idx = 1;
                for (FeedbackQBank__c q : questions) {
                  //   wrappedQuestions.add(new FeedbackQBankWrapper('q' + idx, q.Question__c));
                  //   wrappedQuestions.add(new FeedbackQBankWrapper(q.Name, q.FeedbackTemplate__r.Name ,idx+'. '+q.Question__c));
                  wrappedQuestions.add(new FeedbackQBankWrapper(q.Id, q.FeedbackTemplate__r.Id, q.Name, q.FeedbackTemplate__r.Name, q.FeedbackTemplate__r.FeedbackType__c, idx+'. '+q.Question__c));
                  idx++;
                }                
           } 
        } 
        return wrappedQuestions;
    } */
    	@AuraEnabled
    	public static List<FeedbackQBankWrapper> getQuestionsBySemester(String semester, String feedbackType) { 
       
        	if (String.isBlank(feedbackType) || String.isBlank(semester)) {
                throw new AuraHandledException('feedbackType and semester are required.');
            }
        
            System.debug('semester : ' + semester);
            System.debug('feedbackType : ' + feedbackType);
        
            List<Feedback_Release__c> FR_List = [
                SELECT Id, Template_Id__c, Start_Date__c, End_Date__c, Active__c
                FROM Feedback_Release__c
                WHERE Semester_Name__c = :semester
                AND Template_Type__c = :feedbackType
                AND Active__c = true
                LIMIT 1
            ];
        
            if (FR_List.isEmpty()) {
                throw new AuraHandledException('FEEDBACK_NOT_SET');
            }
        
            Feedback_Release__c FR_Rec = FR_List[0];
        
            if (!FR_Rec.Active__c) {
                throw new AuraHandledException('NOT_ACTIVE');
            }
        
            if (FR_Rec.Start_Date__c == null || FR_Rec.End_Date__c == null) {
                throw new AuraHandledException('IN_COMPLETE_SETUP');
            }
        
            Date today = Date.today();
            if (today < FR_Rec.Start_Date__c || today > FR_Rec.End_Date__c) {
                throw new AuraHandledException('NO_DATE_RANGE');
            }
        
            // Only continue if all above checks passed (i.e., SUCCESS)
            String templateId = FR_Rec.Template_Id__c;
        
            List<FeedbackQBankWrapper> wrappedQuestions = new List<FeedbackQBankWrapper>();
            List<FeedbackQBank__c> questions = [
                SELECT Id, FeedbackTemplate__r.Id, Name, FeedbackTemplate__r.Name, FeedbackTemplate__r.FeedbackType__c, Question__c
                FROM FeedbackQBank__c
                WHERE FeedbackTemplate__r.Active__c = true
                AND FeedbackTemplate__r.Name = :templateId
            ];
        
            Integer idx = 1;
            for (FeedbackQBank__c q : questions) {
                wrappedQuestions.add(new FeedbackQBankWrapper(
                    q.Id,
                    q.FeedbackTemplate__r.Id,
                    q.Name,
                    q.FeedbackTemplate__r.Name,
                    q.FeedbackTemplate__r.FeedbackType__c,
                    idx + '. ' + q.Question__c
                ));
                idx++;
            }
        
            return wrappedQuestions;     
		}

    
    /***************************************** School Director Start ***************************************************/
     @AuraEnabled(cacheable=true)
    public static list<hed__Program_Plan__c> getRelatedProgramBatch(){
        String UserId = UserInfo.getUserId();
        return [Select id,name from hed__Program_Plan__c where ((hed__Account__r.parent.Examination_Vertical_Head__c =: UserId OR hed__Account__r.Examination_Vertical_Head__c =: UserId) or hed__Account__r.parent.School_Head__c=:UserId)];
    } 
    
    @AuraEnabled
    public static list<hed__term__c> getRelatedSemester(String ProgramBatch){
        return [Select id,name from hed__term__c where Program_Batch__c =: ProgramBatch and Active__c=true];
     //   return [Select id,name,Rve_SEE_Result_Date__c,IA_2_Result_Date__c,ExamVerticalHeadFreeze__c,SchoolDirectorFreeze__c from hed__term__c where Program_Batch__c =: ProgramBatch and Active__c=true];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<hed__term__c> getAllActiveSemesters(){
         String UserId = UserInfo.getUserId();
         List<hed__Program_Plan__c> progList = [Select id,name from hed__Program_Plan__c where ((hed__Account__r.parent.Examination_Vertical_Head__c =: UserId OR hed__Account__r.Examination_Vertical_Head__c =: UserId) or hed__Account__r.parent.School_Head__c=:UserId)];
         return [Select id,name from hed__term__c where Program_Batch__c =: progList and Active__c=true];
    }
    
    @AuraEnabled
    public static List<hed__Course_Enrollment__c> getCourseEnrollments(String SemesterID){
        try {
            List<hed__Course_Enrollment__c> CourseEnrollments = [Select id,hed__Course_Offering__c,hed__Course_Offering__r.Name,hed__Contact__r.Name,section__r.Name,section__c,
                                                                hed__Course_Offering__r.hed__Course__c,hed__Course_Offering__r.hed__Course__r.Name,
                                                                hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,Director_Feedback__c,
                                                                Director_Feedback_Status__c 
                                                                from hed__Course_Enrollment__c where (Section__r.hed__Parent_Term__c =: SemesterID
                                                                                                      or Section__r.hed__Parent_Term__r.hed__Parent_Term__c=:SemesterID)
                                                                and
                                                                recordtype.name='Faculty'];
            return CourseEnrollments;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateDirectorFeedbackonFaculty(String remark, String courseConnId){        
            try {
                System.debug('remark => '+remark+' : '+'courseConnId => '+courseConnId);
            /*    hed__Course_Offering__c CourseOffObj = [SELECT Id, Director_Feedback__c, Director_Feedback_Status__c 
                                                        FROM hed__Course_Offering__c
                                                        WHERE Id =: courseOffId];
                CourseOffObj.Director_Feedback__c = remark;
                CourseOffObj.Director_Feedback_Status__c = true;
                update CourseOffObj; */
                hed__Course_Enrollment__c courseConnection = [SELECT Id, Director_Feedback__c, Director_Feedback_Status__c 
                                                              FROM hed__Course_Enrollment__c 
                                                              WHERE Id =: courseConnId];
                courseConnection.Director_Feedback__c = remark;
                courseConnection.Director_Feedback_Status__c = true;
				update courseConnection;
                
                return 'Success';                
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }        
    }
   /* 
    @AuraEnabled
    public static String generateAndStorePDFAndLinkToUser() {
        // Generate PDF Blob from VF page
        PageReference pdfPage = Page.ContactPDFPage;
        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContent();
        } catch(Exception e) {
            throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
        }
        
        // Create ContentVersion (Salesforce File)
        ContentVersion cv = new ContentVersion();
        cv.Title = 'AccountDetails_' + Datetime.now().format('yyyyMMdd_HHmmss');
        cv.PathOnClient = cv.Title + '.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        
        try {
            insert cv;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
        
        // Get ContentDocumentId from ContentVersion
        ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Link ContentDocument to current user
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.LinkedEntityId = UserInfo.getUserId();
        cdl.ShareType = 'V'; // Viewer permission
        cdl.Visibility = 'AllUsers';
        
        try {
            insert cdl;
        } catch (Exception e) {
            // If linking fails, don't block download; just log error
            System.debug('Error linking file to user: ' + e.getMessage());
        }
        
        // Return ContentVersion Id for download
        return cv.Id;
    }
*/
    	@AuraEnabled
        public static String generateAndStorePDFAndLinkToUser() {
            PageReference pdfPage = Page.ContactPDFPage;
            Blob pdfBlob;
            
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('This is a dummy PDF content for testing.');
            } else {
                try {
                    pdfBlob = pdfPage.getContent();
                } catch(Exception e) {
                    throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
                }
            }
            
            // The rest of the method remains the same
            ContentVersion cv = new ContentVersion();
            cv.Title = 'AccountDetails_' + Datetime.now().format('yyyyMMdd_HHmmss');
            cv.PathOnClient = cv.Title + '.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true;
            
            try {
                insert cv;
            } catch (Exception e) {
                throw new AuraHandledException('Error saving file: ' + e.getMessage());
            }
            
            ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = insertedCV.ContentDocumentId;
            cdl.LinkedEntityId = UserInfo.getUserId();
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            
            try {
                insert cdl;
            } catch (Exception e) {
                System.debug('Error linking file to user: ' + e.getMessage());
            }
            
            return cv.Id;
        }
     /***************************************** School Director End***************************************************/
    // Wrapper classes
    
    public class FeedbackSummary {
        @AuraEnabled public String courseOfferingId;
        @AuraEnabled public String templateId;
        @AuraEnabled public String sectionId;
        @AuraEnabled public String qId;
        @AuraEnabled public String qbId;
        @AuraEnabled public String question;
        @AuraEnabled public Decimal averageResponse;
        @AuraEnabled public Boolean directorFeedbackStatus;
        @AuraEnabled public String directorFeedbackRemark;

        public FeedbackSummary(String courseOfferingId, String templateId,String sectionId,String qId, String question, String qbId,
                               Decimal avg, Boolean directorFeedbackStatus, String directorFeedbackRemark) {   
            this.courseOfferingId = courseOfferingId;
            this.templateId = templateId;
			this.sectionId = sectionId;
            this.qId = qId;
            this.qbId = qbId;
            this.question = question;
            this.averageResponse = avg;
            this.directorFeedbackStatus = directorFeedbackStatus;
			this.directorFeedbackRemark = directorFeedbackRemark;
        }
    }
    
    public class StudentWrapper {
        @AuraEnabled public String studentName;
        @AuraEnabled public String srn;
        @AuraEnabled public Boolean courseFeedback;
        @AuraEnabled public Boolean facultyFeedback;
    
        public StudentWrapper(String studentName, String srn, Boolean courseFeedback, Boolean facultyFeedback) {
            this.studentName = studentName;
            this.srn = srn;
            this.courseFeedback = courseFeedback;
            this.facultyFeedback = facultyFeedback; 
        }
    }

    public class CourseEnrollmentWrapper {
        @AuraEnabled public Id enrollmentId;
        @AuraEnabled public String school;
        @AuraEnabled public String semester;
        @AuraEnabled public String section;
        @AuraEnabled public String sectionId;
        @AuraEnabled public String courseOfferingId;
        @AuraEnabled public String courseOfferingName;       
        @AuraEnabled public String courseCode;
        @AuraEnabled public Boolean courseFeedbackCheck;

        public CourseEnrollmentWrapper(Id enrollmentId, String school, String semester, String section, String sectionId, 
                                       String courseOfferingId,String courseOfferingName, String courseCode,Boolean courseFeedbackCheck) {
            this.enrollmentId = enrollmentId;
            this.school = school;
            this.semester = semester;
            this.section = section;
            this.sectionId = sectionId;
            this.courseOfferingId = courseOfferingId;
            this.courseOfferingName = courseOfferingName;
			this.courseCode = courseCode;
			this.courseFeedbackCheck = courseFeedbackCheck;                                           
        }
    }
    
    public class FeedbackInput {
        @AuraEnabled public String templateId { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public Integer rating { get; set; }
        @AuraEnabled public String courseConnId { get; set; }
        @AuraEnabled public String courseOffId { get; set; }
        @AuraEnabled public String sectionId { get; set; }
        @AuraEnabled public String qbId { get; set; }
        
    }
    
    public class FeedbackQBankWrapper {
        @AuraEnabled public String tempRecordId { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String templateId { get; set; }
        @AuraEnabled public String templateType { get; set; }
        @AuraEnabled public String text { get; set; }
        @AuraEnabled public String qbId { get; set; }

        public FeedbackQBankWrapper(String qbId, String tempRecordId, String id, String templateId, String templateType, String text) {            
            this.qbId = qbId;
            this.tempRecordId = tempRecordId;
            this.id = id;
            this.templateId = templateId;
            this.templateType = templateType;
            this.text = text;            
        }
    } 
    
    public class FacultyWrapper {
        public String facultyName { get; set; }
        public String schoolName { get; set; }
        public String programName { get; set; }
        public String programBatch { get; set; }
        public String semesterName { get; set; }
        public String sectionName { get; set; }
        public String courseName { get; set; }
        public String courseCode { get; set; }
        public String feedbackText { get; set; }
        public Decimal overallAverage { get; set; }
        public List<FeedbackAverageTemp__c> aveList { get; set; }

        public FacultyWrapper(String fn, String schoolName, String proName,String proBatch,String secName, String course,
                              String courseCode,String sem,
                              String feedText, List<FeedbackAverageTemp__c> averageList,
                              Decimal overallAvg) {
            this.facultyName = fn;
            this.courseName = course;                                  
            this.schoolName = schoolName;
            this.programName = proName;
            this.programBatch = proBatch;
            this.sectionName = secName;
            this.semesterName = sem;
            this.courseCode = courseCode;  
            this.feedbackText = feedText;
            this.aveList = averageList;
            this.overallAverage = overallAvg;
        }
    }
}