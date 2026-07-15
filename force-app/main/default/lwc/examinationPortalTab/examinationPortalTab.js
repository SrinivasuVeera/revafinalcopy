import { LightningElement,wire,track } from 'lwc';
import REVA_LOGO_IMAGE from "@salesforce/resourceUrl/REVA_LOGO";
import ContactDetails from "@salesforce/apex/getContactDetails.ContactDetails";
import isPGStudent from '@salesforce/apex/getContactDetails.isPGStudent';
import EnablingPCandRVforStudents from '@salesforce/customPermission/Enabling_PC_and_RV_for_Students';



export default class ExaminationPortalTab extends LightningElement {
    REVA_LOGO = REVA_LOGO_IMAGE;
   @track selectedTabValue;
    loginDetails;
    loginUserName;
    showCourseData = false;
    

    // Name of the key will match the name attribute of navigation-item.
    // selectedTab = {
    //     viewExamTab : true,
    //     viewNotifications : false,
    //     viewIAMarks : false,
    //     viewIAMarks_TT : false,
    //     viewIAMarks_HT : false,
    //     viewHallTicket : false
    // }
    selectedItem = 'Attendance';
    currentContent = 'Attendance';
    
    // @track viewExamTab = false;
    // @track viewNotifications = false;
    // @track otherTabs=false;
    // viewIAMarks = false;
    // viewHallTicket = false;
    // viewIAMarks_TT = false;
    // viewIAMarks_HT = false;

    @track isPGStudent = false;
    @track showPGMessage = false;

    // ✅ Newly added: To control visibility of Photocopy/Revaluation tab
    @track canShowPCandRVTab = true;

    // ✅ connectedCallback safely added to assign custom permission
    connectedCallback() {
        this.canShowPCandRVTab = EnablingPCandRVforStudents;
    }


     handleTabActive(event) {
        this.selectedTabValue = event.target.label;
        // If PG student clicks "Revaluation/Photocopy" tab, prevent full component from loading
        if (this.selectedTabValue === "Photocopy/Revalution" && this.isPGStudent) {
            this.showPGMessage = true;
        } else {
            this.showPGMessage = false;
        }

    }

     @wire(ContactDetails)
    getContactDetails({data,error}){
        if(data){
           // alert(JSON.stringify(data));
            this.loginUserName = data.Name;
            this.loginDetails = data;
            
            if(this.loginDetails.Record_Type_Name__c === 'Student') {
                this.showCourseData = true;
            }  
            else{
                this.showCourseData = false;
            }                     
        }
        if(error){
        }
    }

    /***********Newly added by Veera for checking Prigramtype for PG students ***************** */
        // Fetch PG Student status from Apex
    @wire(isPGStudent)
    wiredPGStudent({ data, error }) {
        if (data !== undefined) {
            this.isPGStudent = data; // Set PG flag
        } else if (error) {
            console.error('Error fetching PG status:', error);
        }
    }

   

}