import { LightningElement , api, wire} from 'lwc';
import getAllInterviews from '@salesforce/apex/RPL_InterviewHandler.getAllInterviews';


export default class Rpl_RevaInterviewResults extends LightningElement {

     data;
    @api isResult;
    @api studentRegDriveId;
    isInterviewAvailable;


    @wire(getAllInterviews, { studentRegDriveId: '$studentRegDriveId' })
    wiredInterviews({ error, data }) {
        if (data) {
            try{
               
                 const { interviewList, studentRegistrationDrive } = data;

            // Determine if the student has failed
            const isFailed = studentRegistrationDrive.Rpl_Is_Failed__c;

            //Determine if the result is out
            const isResultOut = studentRegistrationDrive.Rpl_Is_Result_Out__c;

            // Map the interviewList to a new array with modified button attributes
            this.data = interviewList.map((interview, index) => {
                
                // Determine result based on conditions
                const result = !isResultOut && index === interviewList.length - 1 ? 'PENDING' : isResultOut && index === interviewList.length - 1 && !isFailed? 'OFFERED': isFailed && index === interviewList.length - 1 ? 'NOT SHORTLISTED' : 'SHORTLISTED';

                // Determine variant based on result
                const variant = result === 'NOT SHORTLISTED' ? 'slds-text-color_error' : result==='SHORTLISTED' || result === 'OFFERED' ? 'slds-text-color_success': 'slds-text-color_weak';

                // Create a new object with modified attributes
                return {
                    id: interview.Id,
                    sNo : index + 1,
                    interviewName: interview.Name,
                    //interviewTime: interview.Rpl_Interview_Time__c,
                    round: interview.Rpl_Round_Number__c,
                    result: result,
                    variant: variant,
                     interviewTime: interview.Rpl_Interview_Time__c ? new Intl.DateTimeFormat('en-US', {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                    }).format(new Date(interview.Rpl_Interview_Time__c))  : null,
                    
                };
            });
            this.isResult = true;
            this.isInterviewAvailable = (this.data.length > 0) ? true :false;
            // Now, this.data contains the transformed data for rendering in the Lightning Datatable
        }
        catch(error){
            }
            
    }else if (error) {
            console.error(JSON.stringify(error));
        }
    }

}