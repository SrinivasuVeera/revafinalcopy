import { LightningElement, track, wire } from 'lwc';
import fetchExistingQuartersDetails from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersDetails';
import USER_ID from '@salesforce/user/Id';
import  getCurrentNonTeachingContact  from '@salesforce/apex/RevaHostelRequestController.getCurrentTeachingContact';
import { NavigationMixin } from 'lightning/navigation';
//import updateExixtingReq from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.updateExixtingQuarterReq';



export default class RevaTeachingStaffBookedRoomDetails extends NavigationMixin(LightningElement) {
    revaQuarterRequests;
    @track revaQuarterRequestId;
    @track revaQuarterRequestStatus=false;
    userId = USER_ID;
    isApprovedHistory = false;
    isRejected = false;
    isApplyAgain = false;
    isreApply= false;
    isreApplyform = false;
    isRegisterPageOpen = false ;
    boolSpinner = false;
    isApprovalModelOpen = false;
    connectedCallback() {
        this.fetchData();
    }
    dataAvl = false;
    async fetchData() {
        try {
            const objResult = await fetchExistingQuartersDetails({ userId: this.userId });
            console.log('objResult ==> ' + JSON.stringify(objResult));
            if (objResult && typeof objResult === 'object' && Object.keys(objResult).length) {
                console.log('inside status' +objResult.Status__c);
                this.revaQuarterRequests = objResult;
                this.revaQuarterRequestId = objResult.Id;
                if(objResult.Status__c == 'Room Allotted'){
                    this.revaQuarterRequestStatus = true;
                }

                if(objResult.Status__c == 'Rejected' ){
                    this.isRejected = true;
                 }
                 if(objResult.Status__c != 'Request Submitted'){
                     this.isApprovedHistory = true;
                  }
                  if(objResult.Status__c == 'Vacation Completed'){
                    console.log('inside vacating');
                    
                     this.isApplyAgain = true;
                  }
                  if(objResult.Status__c == 'Vacation Rejected'){
                    console.log('inside vacating rejected');
                    
                     this.revaQuarterRequestStatus = true;
                  }
                console.log('revaQuarterRequestId****'+this.revaQuarterRequests.Id);
            }
            this.dataAvl = true;
        } catch (error) {
            this.dataAvl = true;
        }
    }

    @wire(getCurrentNonTeachingContact)
     wiredCurrentUserContact({ error, data }) {
     if (data) {
        this.currentUserContact = data;
       
    console.log('Current User Contact:', data);
      
    } else if (error) {
         console.error('Error fetching current user contact', error);
     }
}

get formattedJoiningDate() {
    const joiningDate = this.revaQuarterRequests.Staff_Quarters_Joining_Date__c;
    if (joiningDate) {
        const [year, month, day] = joiningDate.split('-'); // Split the date string
        return `${day}-${month}-${year}`; // Format as 'dd-MM-yyyy'
    }
    return ''; // Return an empty string if no date is available
    }

    get formattedVacatedDate() {
        const vacateDate = this.revaQuarterRequests.Vacation_Date__c;
        if (vacateDate) {
            const [year, month, day] = vacateDate.split('-'); // Split the date string
            return `${day}-${month}-${year}`; // Format as 'dd-MM-yyyy'
        }
        return ''; // Return an empty string if no date is available
        }
    

    handleReApply(){
        console.log('is re apply');
        
        this.isreApply = true;
        this.isreApplyform = true;
        console.log('is re this.isreApply'+this.isreApply);
    }
    closeReapplyPopUp(event) {
        console.log('parent re apply'+event.detail.isCloseReApply);
        
        if(event.detail.isCloseReApply){
            this.isreApply = false;
            this.dataAvl = true;
        }
        
    }
    handleApply(){
        console.log('is re Apply');
        
        //this.boolSpinner = true;
           /* try {
                const objResult =  updateExixtingReq();
                console.log('result ' + JSON.stringify(objResult));
                if (objResult && objResult.isError) {
                    this.isRegisterPageOpen = false;
                }
                if (objResult && objResult.isSuccess) {
                    this.isRegisterPageOpen = true;
                
                }

            } catch (error) {
               console.log('error---'+error);
               this.isRegisterPageOpen = false;
               
            } */

          //  this.dispatchEvent(new CustomEvent('isRegistratonOpen',  detail: { omnioutcomponent: true } ));
          this.isRegisterPageOpen = true;
          this.dispatchEvent(new CustomEvent('openregistration', {
            detail: {
                isRegistrationOpen: this.isRegisterPageOpen
            }
        }))
       
      /*  this.event1 = setTimeout(() => {
            window.location.reload();
            
        }, 4000); */

        } 
       

        /*vacating Approval Histroy functionlity:- Jadala Devender*/ 
    handleApprovalHistory(){
        console.log(' orgin---'+window.location.origin);

        console.log('inside Approval Hist'+this.revaQuarterRequests.Id);
       if(window.location.origin.includes('site.com')) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'revahostelleavereqapprovalhistory' 
            },
            state: {
                recordId: this.revaQuarterRequests.Id,
            }
        });
       } else {
          this.isApprovalModelOpen = true;
          
       }


  }
  handleCloseModal(event){
    this.isApprovalModelOpen = false;

  }
 
}