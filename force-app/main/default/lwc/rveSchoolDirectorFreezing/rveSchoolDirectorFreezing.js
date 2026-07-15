import { LightningElement,track,api,wire } from 'lwc';
import getProgramBatch from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getRelatedProgramBatch';
import getSemester from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getRelatedSemester';
import getCourseEnrollments from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getCourseEnrollments';
//import updateSemFreezingStatus from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.updateSemFreezingStatus';
import fetchDataSchoolDirector from '@salesforce/apex/ASM_IamProfListView.fetchDataSchoolDirector';
import toggleSemesterFreeze from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.toggleSemesterFreeze';
import freezeIAMarksLabel from '@salesforce/label/c.FreezeSchoolDirector';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RveSchoolDirectorFreezing extends LightningElement {

    // Array for Handling Program, Semester and Course
    @track ProgramOption = [];
    @track SemesterOption = [];
    @track CourseOption = [];
    @track courseList=[];

    // Variables for handling the selected values
    Buttonlabel;
    EnableIA;
    
    IAType='IA1';
    hasCourses;
    NoCourses;

    // variables for enable and disable the dropdowns
    EnableCourse;
    DisableCourse;
    EnableSem;
    DisableSem;
    courseType;
    theory;
    project;
    practical;
    profid;
    courseName;
    section;
    course;
    isShowModal = false;
    isLoaded = false;
    isShowModalFreeze = false;
    freezeIAMarksLabel = freezeIAMarksLabel;
    semId;
    
    @track GetIATypeOption=[
        {label:'IA1',value:'IA1'},
        {label:'IA2',value:'IA2'},
    ]

    // Based on profile Get Related Program Batch
    @wire(getProgramBatch)
    wiredProgramBatch({error,data}){
        if(data){
            // console.log('Data: '+JSON.stringify(data));
            for(let key in data){
                // console.log('Key: '+JSON.stringify(data[key]));
                let tempArray = [...this.ProgramOption]; // Clone the existing array
                tempArray.push({ label: data[key].Name, value: data[key].Id });
                this.ProgramOption = tempArray; // Assign a new reference
                // console.log('ProgramOption: '+JSON.stringify(this.ProgramOption));
            }
        }
        else if(error){
            console.error('Error: '+error.message);
        }
    }

    // Based on IA Type fetching the IA Marks Data and also formatting the IA_Allowed_End_Date__c before rendering
    
    updateIAType(event){
        try{
        this.IAType = event.target.value;
        this.courseList = []; 
        fetchDataSchoolDirector({iaType:this.IAType})
        .then(res=>{
        // console.log('CourseEnrollmentsIA: '+JSON.stringify(res.list_CrsCons));
        this.courseList = res.list_CrsCons;
       // console.log('76=> ',this.courseList);
        if (Array.isArray(this.courseList)) {
        this.courseList = this.courseList.map((crs, index) => {
        let updatedCrs = { ...crs }; // Clone to avoid mutation
        updatedCrs.rowIndex = index + 1;
        updatedCrs.courseName = updatedCrs.hed__Course_Offering__r.hed__Course__r?.Name || '';
        updatedCrs.semester = updatedCrs.hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__r?.Name || '';
        // Safely check for nested property
        updatedCrs.isAcknowledgedByExamHead = 
            updatedCrs.hed__Course_Offering__r &&
            updatedCrs.hed__Course_Offering__r.Acknowledged__c === 'Frozen by Exam Vertical Head';

        // Format IA2 end date if available
        if (updatedCrs.IA2_End_Date__c) {
            let iaEndDate = new Date(updatedCrs.IA2_End_Date__c);
          //  console.log('91=> ',iaEndDate);
            updatedCrs.IA_Allowed_End_Date__c = this.formatToDDMMYYYY(iaEndDate);
        } else {
            updatedCrs.IA_Allowed_End_Date__c = null;
        }

        return updatedCrs;
    });
} else {
    console.warn('courseList is not an array or is undefined:', this.courseList);
}

       
        // console.log('CourseList: '+JSON.stringify(this.courseList));
        this.hasCourses = this.courseList.length > 0?true:false;
        this.NoCourses = this.courseList.length > 0?false:true;

      })
      .catch(error => {
        console.error('Error fetching course enrollments:', error.message);
    });
        }
        catch(error){
          console.log('Main Block Error',error.message);
        }
    }

    // Method for formating the date to DD-MM-YYYY
    // This method takes a Date object and returns a string in the format "DD-MM-YYYY"
     
    formatToDDMMYYYY(date) {
        try{
        // console.log('123date=> '+date)
        let day = String(date.getDate()).padStart(2, '0'); // Pad day to 2 digits
        let month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
        let year = date.getFullYear();
        return `${day}-${month}-${year}`;
        }
        catch(error){
           console.log('InFormat Method',error.message);
        }
    }
    getSemester(event) {
    const selectedProgramBatch = event.target.value;    
    this.SemesterOption = [];
    this.CourseOption = [];
    this.EnableIA = false;
    this.EnableCourse = false;
    this.DisableSem = false;
    this.EnableSem = false;

    getSemester({ ProgramBatch: selectedProgramBatch })
       .then(res => {
            if (res && res.length > 0) {
                this.EnableSem = true;
                
                // --- FIX: SET TODAY TO MIDNIGHT ---
                const today = new Date();
                today.setHours(0, 0, 0, 0); 
                // ----------------------------------

                this.SemesterOption = res.map((item, index) => {
                    let formattedLastDate = 'N/A';
                    let calendarDeadlinePassed = false;

                    if (item.IA_2_Result_Date__c) {
                        let dateParts = item.IA_2_Result_Date__c.split('-');
                        let deadlineDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);
                        
                        const bufferDays = parseInt(this.freezeIAMarksLabel, 10) || 0;
                        deadlineDate.setDate(deadlineDate.getDate() + bufferDays);
                        
                        // Set deadline time to midnight to ensure clean comparison
                        deadlineDate.setHours(0, 0, 0, 0);

                        formattedLastDate = this.formatToDDMMYYYY(deadlineDate);
                        
                        // Now Jan 9 (midnight) > Jan 9 (midnight) will be FALSE
                        calendarDeadlinePassed = today > deadlineDate;
                    }

                    const sdFrozen = item.SchoolDirectorFreeze__c;
                    const evhFrozen = item.ExamVerticalHeadFreeze__c;
                    const lockByDeadline = calendarDeadlinePassed && sdFrozen;

                    return {
                        index: index + 1,
                        id: item.Id,
                        name: item.Name,
                        sdStatus: sdFrozen,
                        sdLabel: sdFrozen ? 'Unfreeze IA Marks' : 'Freeze IA Marks',
                        sdVariant: sdFrozen ? 'destructive' : 'success',
                        evhStatus: evhFrozen,
                        isAcknowledgedBy: item.ExamVHAcknowledged__c,
                        lastdate: formattedLastDate,
                        calendarDeadlinePassed: calendarDeadlinePassed,
                        isPastDeadline: lockByDeadline,
                        sdDisabled: lockByDeadline || !evhFrozen,
                        evhDisabled: lockByDeadline || sdFrozen 
                    };
                });
            }
        });
}

handleToggleFreeze(event) {
    const semId = event.target.dataset.id;
    const field = event.target.dataset.field;
    const currentStatus = event.target.dataset.status === 'true';
    const newStatus = !currentStatus;

    toggleSemesterFreeze({ semId: semId, fieldName: field, status: newStatus })
        .then(() => {
            let successMessage = (field === 'SchoolDirector') 
                ? (newStatus ? 'School Director Frozen IA Marks Successfully' : 'School Director UnFrozen IA Marks Successfully')
                : (newStatus ? 'Verified successfully' : 'Unverification Successfully Done By School Director');

            this.showToast('Status Updated', successMessage, 'success');
            
            this.SemesterOption = this.SemesterOption.map(item => {
                if (item.id === semId) {
                    if (field === 'SchoolDirector') {
                        item.sdStatus = newStatus;
                        item.sdLabel = newStatus ? 'Unfreeze IA Marks' : 'Freeze IA Marks';
                        item.sdVariant = newStatus ? 'destructive' : 'success';
                    } else if (field === 'EVH') {
                        item.evhStatus = newStatus;
                    }
                    const lockByDeadline = item.calendarDeadlinePassed && item.sdStatus;
                    item.sdDisabled = lockByDeadline || !item.evhStatus;
                    item.evhDisabled = lockByDeadline || item.sdStatus;
                    item.isPastDeadline = lockByDeadline;
                }
                return item;
            });
        })
        .catch(error => {
            this.showToast('Error', 'Update failed', 'error');
        });
}
    formatToDDMMYYYY(date) {
        let day = String(date.getDate()).padStart(2, '0');
        let month = String(date.getMonth() + 1).padStart(2, '0');
        let year = date.getFullYear();
        return `${day}/${month}/${year}`;
    }
    
    getCourses(event){
        this.IAType = event.target.value;
        this.EnableCourse = true;
        this.DisableCourse = false;
        this.DisableSem = false;
        this.CourseOption=[]

        // console.log('UnFreeze=> '+event.target.dataset.id);
        let semId = event.target.dataset.id;
        getCourseEnrollments({
            SemesterID: semId
        })
        .then(res=>{
            console.log('CourseEnrollments: '+JSON.stringify(res));
            this.EnableCourse = res.length>0?true:false;
            this.DisableCourse = res.length === 0 ? true : false;
            for(let key in res){            
                const instance = {
                    index: parseInt(key)+1,
                    id: res[key].Id,
                    course: res[key].hed__Course_Offering__r.hed__Course__r.Name ,
                    coursecode: res[key].hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                    courseid: res[key].hed__Course_Offering__r.hed__Course__c,
                    section: res[key].Section__r.Name,
                    faculty: res[key].hed__Contact__r.Name
                  
                }
                this.CourseOption.push(instance);
    
            }
             console.log('CourseOption: '+JSON.stringify(this.CourseOption));
        })
        .catch(error => {
            console.error('Error fetching course enrollments:', error.message);
        });
    }

    handleViewMarks(event){
        // console.log('ViewMarks=> '+event.target.dataset.id);
        this.course = event.target.dataset.id;
         console.log('Course ID Set: ', this.course);
        this.isShowModal = true;
    }

    hideModalBox(){
        this.isShowModal = false;
    }

    hideModalBox2(){
        this.isShowModalFreeze = false;
    }

    EditStudentMarks(event){
        this.EnableIA = true;
    }

    // checking the course type and setting the values accordingly
    updateIaMarks(event){
        // console.log('UnFreeze=> '+event.target.dataset.id);
        this.EnableCourse = false;
        this.DisableSem = false;
        this.hasCourses = false;
        this.DisableCourse = false;
        let crsid = event.target.dataset.id;
        this.courseList.forEach(option => {
            // console.log('option => ' + JSON.stringify(option));
            if (option.Id === crsid) {
                    this.theory = option.hed__Course_Offering__r?.hed__Course__r?.Course_Type_Logisys__c === 'Theory'?true:false;
                    this.practical = option.hed__Course_Offering__r?.hed__Course__r?.Course_Type_Logisys__c === 'Practical'?true:false;
                    this.project = option.hed__Course_Offering__r?.hed__Course__r?.Course_Type_Logisys__c === 'Project'?true:false;
                    this.profid = option.Id;
                    this.courseName = option.hed__Course_Offering__r.hed__Course__r.Name;
                    this.section = option.Section_Batch_Group__c;
                    // console.log('127=> '+this.courseName+' '+this.section)      
            }
        }); 
    }

    handleToast(event){
        // console.log('Toast=> '+JSON.stringify(event.detail));
        this.showToast(event.detail.message,'success');
    }

    openModalBoxFreeze(event){
      this.semId = event.target.dataset.id;
      // console.log('SemId: '+this.semId);
      this.isShowModalFreeze = true;
    }

    /*Unfreeze(){
        // console.log('UnFreeze=> ');
      this.isShowModalFreeze = false;
      let semid = this.semId;
      // console.log('UnFreeze=> '+semid);
      updateSemFreezingStatus({
        SemId: semid
      })
      .then(res=>{
        // console.log('res=> '+res);
        this.SemesterOption = this.SemesterOption.map(option => {
            if (option.id === semid) {
                return {
                    ...option,
                    checkstatus: true // or whatever value you want
                };
            }
            return option;
        });
        this.showToast('School Director Frozen IA Marks Successfully','success');
      })
        .catch(error => {
            console.error('Error updating semester freezing status:', error.message);
            this.showToast('Error in Freeze',error.message);
        })
    } */

    DisableStudentList(event){
        // console.log('UnFreeze=> '+event.detail);
        this.hasCourses = true;
        this.theory = false;
        this.practical = false;
        this.project = false;
    }

    showToast(title, msg, variant) {    
    if (arguments.length === 2) {
        variant = msg;
        msg = title;
        title = 'Status';
    }
    const evt = new ShowToastEvent({
        title: title,
        message: msg,
        variant: variant || 'info',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}