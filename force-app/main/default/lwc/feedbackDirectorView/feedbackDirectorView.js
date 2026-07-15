import { LightningElement,wire,track } from 'lwc';
// import getProgramBatch from '@salesforce/apex/FeedbackManagementController.getRelatedProgramBatch';
// import getSemester from '@salesforce/apex/FeedbackManagementController.getRelatedSemester';
import getAllSemesters from '@salesforce/apex/FeedbackManagementController.getAllActiveSemesters';
import getCourseEnrollments from '@salesforce/apex/FeedbackManagementController.getCourseEnrollments';
import getFeedbackSummary from '@salesforce/apex/FeedbackManagementController.getFeedbackSummary';
import updateDirectorFeedbackOnFaculty from '@salesforce/apex/FeedbackManagementController.updateDirectorFeedbackonFaculty';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import generateAndStorePDFAndLinkToUser from '@salesforce/apex/FeedbackManagementController.generateAndStorePDFAndLinkToUser';
import generatePdfAndStore from '@salesforce/apex/FeedbackManagementController.generatePdfAndStore';
import getStudentsForEnrollment from '@salesforce/apex/FeedbackManagementController.getStudentsForEnrollment';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

export default class FeedbackDirectorView extends LightningElement {

        // Array for Handling Program, Semester and Course
        @track ProgramOption = [];
        @track SemesterOption = [];
        @track CourseOption = [];        
        userId = USER_ID;
        
        EnableSem;
        DisableSem;

        EnableCourse;
        DisableCourse;
        isShowModal = false;
        course;
        courseofferingId;
        sectionId;

        @track feedbackDataFaculty = [];
        @track totalAverageFaculty = 0;
        error;
        remark;
        modelFacName;
        modelSectionName;
        semId;
        isLoading = false;
        studentFeedbackCount;
        studentCount;

        // // Based on profile Get Related Program Batch
        // @wire(getProgramBatch)
        // wiredProgramBatch({error,data}){
        //     if(data){
        //          console.log('Data:>> '+JSON.stringify(data));
                
        //         // eslint-disable-next-line guard-for-in
        //         for(let key in data){
        //             // console.log('Key: '+JSON.stringify(data[key]));
        //             let tempArray = [...this.ProgramOption]; // Clone the existing array
        //             tempArray.push({ label: data[key].Name, value: data[key].Id });
        //             this.ProgramOption = tempArray; // Assign a new reference                    
        //         }
        //         console.log('ProgramOption: '+JSON.stringify(this.ProgramOption));
        //     }
        //     else if(error){
        //         console.error('Error: '+error.message);
        //     }
        // }


        // Based on profile Get Related Active Semsters
        @wire(getAllSemesters)
        wiredSemesters({error,data}){
            this.SemesterOption=[];
            this.CourseOption=[];            
            this.EnableCourse = false;
            this.DisableSem = false;
            this.DisableCourse = false;
            this.EnableSem = false;
            if(data){
                 console.log('Semester: '+JSON.stringify(data));
                 this.DisableSem = data.length === 0 ? true : false;
                 this.EnableSem = data.length>0?true:false;
    
                // eslint-disable-next-line guard-for-in
                for(let key in data){                
                    const instance = {
                    // eslint-disable-next-line radix
                    index: parseInt(key)+1,
                    id: data[key].Id,
                    name: data[key].Name
                }
                 this.SemesterOption.push(instance);
                 console.log('SemOption: '+JSON.stringify(this.SemesterOption));
                }
            }
            else if(error){
                console.error('Error: '+error.message);
            }
        }


        // // Based on Program Batch fetching the Semester
        // // and also enabling/disabling the Semester and Course dropdowns
        // getSemester(event){
        //     // console.log('Event: '+event.target.value);
        //     this.SemesterOption=[];
        //     this.CourseOption=[]
        //     // this.courseList=[]
        //     // this.EnableIA = false;
        //      this.EnableCourse = false;
        //      this.DisableSem = false;
        //      this.DisableCourse = false;
        //     // this.hasCourses = false;
        //     // this.NoCourses = false;

        //     this.EnableSem = false;
        //     // getSemester({
        //     //     ProgramBatch: event.target.value
        //     // })
        //     getAllSemesters()
        //     .then(res=>{
        //          console.log('Semester: '+JSON.stringify(res));
        //          this.DisableSem = res.length === 0 ? true : false;
        //          this.EnableSem = res.length>0?true:false;
    
        //         // eslint-disable-next-line guard-for-in
        //         for(let key in res){               
        //             const instance = {
        //                 // eslint-disable-next-line radix
        //                 index: parseInt(key)+1,
        //                 id: res[key].Id,
        //                 name: res[key].Name     
        //             }
        //         this.SemesterOption.push(instance);
        //          console.log('SemOption: '+JSON.stringify(this.SemesterOption));
        //         }
        //     })
        //     .catch(error => {
        //         console.error('Error fetching semester:', error.message);
        //     });
    
        // } 



        // Based on Semester fetching the Course
            // and also enabling/disabling the Course dropdown
            getCourses(event){
                this.IAType = event.target.value;
                this.EnableCourse = true;
                this.DisableCourse = false;
                this.DisableSem = false;
                this.CourseOption=[]                
                
                this.semId = event.target.dataset.id;                
                this.getCourseData();
            }

            getCourseData(){
                this.isLoading = true;
                console.log('Selected semId => '+this.semId);
                getCourseEnrollments({
                    SemesterID: this.semId
                })
                .then(res=>{
                    console.log('CourseEnrollments: '+JSON.stringify(res));
                    this.EnableCourse = res.length>0?true:false;
                    this.DisableCourse = res.length === 0 ? true : false;
                    // eslint-disable-next-line guard-for-in
                    for(let key in res){            
                        const instance = {
                            // eslint-disable-next-line radix
                            index: parseInt(key)+1,
                            id: res[key].Id,
                            course: res[key].hed__Course_Offering__r.hed__Course__r.Name ,
                            coursecode: res[key].hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                            courseid: res[key].hed__Course_Offering__r.hed__Course__c,
                            sectionid: res[key].Section__c,
                            section: res[key].Section__r.Name,
                            faculty: res[key].hed__Contact__r.Name,
                            courseoffering : res[key].hed__Course_Offering__c,
                            directorRemark : res[key].Director_Feedback__c,
                            directorRemarkStatus : res[key].Director_Feedback_Status__c
                          
                        }
                       
                        this.CourseOption.push(instance);
            
                    }
                     console.log('CourseOption: '+JSON.stringify(this.CourseOption));
                })
                .catch(error => {
                    console.error('Error fetching course enrollments:', error.message);
                })
                .finally(() => {
                    this.isLoading = false;
                }); 
            }

            hideModalBox(){
                this.isShowModal = false;
            }
        
            handleViewFeedback(event){
                // console.log('ViewMarks=> '+event.target.dataset.id);
                this.course = event.target.dataset.id;
                this.courseofferingId = event.target.dataset.co;
                this.sectionId = event.target.dataset.secid;
                this.remark = event.target.dataset.remarkval;
                this.modelFacName = event.target.dataset.facname;
                this.modelSectionName = event.target.dataset.secname;
                console.log('Course ID Set: ', this.course);
                console.log('courseoffering ID : ', this.courseofferingId);
                console.log('section ID : ', this.sectionId);
                this.getFacultySummaryData(this.courseOfferingId, 'FT-0006',this.sectionId);
                this.getStudentCount(event.target.dataset.co, this.sectionId);
                this.isShowModal = true;
            }

            showToast(msg,variant){
                const evt = new ShowToastEvent({
                title: 'Status',
                message: msg,
                variant: variant,
                mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }

            getFacultySummaryData(courseOfferingIdVal , templateIdVal, sectionIdVal){
                    console.log('courseOfferingIdVal : '+this.courseOfferingId);
                    console.log('templateIdVal : '+templateIdVal);
                    console.log('Course Connection : '+this.course);
                    console.log('Current User Id: ', this.userId);
                    if(this.userId === '005J4000000JefwIAC'|| this.userId === '0055j0000071w0TAAQ'){  // || this.userId ==='0055j0000071vohAAA'
                        templateIdVal = 'FT-0001';
                    }
                    this.isLoading = true;
                    getFeedbackSummary({ courseOfferingId: this.courseofferingId, templateId: templateIdVal ,sectionId : sectionIdVal, courseConnId : this.course })
                        .then(result => {                            
                            console.log('getFeedbackSummary -> '+JSON.stringify(result));
                            let total = 0;
                            let count = 0;

                            result.sort((a, b) => {
                                // eslint-disable-next-line radix
                                let numA = parseInt(a.qId.replace(/^\D+/g, "")); 
                                // eslint-disable-next-line radix
                                let numB = parseInt(b.qId.replace(/^\D+/g, ""));
                                return numA - numB;
                            });
                
                            for (let item of result) {
                                const value = parseFloat(item.averageResponse);
                                // this.remark = item.directorFeedbackRemark;

                                if (!isNaN(value)) {
                                    total += value;
                                    count++;
                                }
                            }
                
                            this.totalAverageFaculty = count > 0 ? (total / count).toFixed(2) : 0;
                            this.error = undefined;                
                            this.feedbackDataFaculty = result;            
                        })
                        .catch(error => {
                            this.error = error;
                            this.feedbackDataFaculty = [];
                            this.totalAverageFaculty = 0;
                        })
                        .finally(() => {
                            this.isLoading = false;
                        });
            }

            handleRemarkChange(event){
                this.remark = event.target.value;
                  console.log('Remark'+this.remark);                    
            }   

            handleSubmitRemark(){
                const remarkInput = this.template.querySelector('lightning-textarea[data-id="remarkInput"]');
        
                // Check validity (built-in LWC validation)
                if (!remarkInput.checkValidity()) {
                    remarkInput.reportValidity();  // Show native error message
                    return;  // stop submit if invalid
                }
        
                // Additional custom validation (optional)
                // if(this.remark.length < 5) {
                //     remarkInput.setCustomValidity('Remark must be at least 5 characters long.');
                //     remarkInput.reportValidity();
                //     return;
                // } 
                // remarkInput.setCustomValidity('');

                this.updateDirectorRemarks();
            }

            updateDirectorRemarks(){
                this.hideModalBox();
                this.isLoading = true;
                console.log('Course Connection : '+this.course);
                updateDirectorFeedbackOnFaculty({remark : this.remark, courseConnId : this.course})
                .then(response => {
                        console.log('updateDirectorRemarks: '+JSON.stringify(response));
                        this.showToast('Remark Updated Successfully', 'Success');
                       // Refresh the CourseOption List
                        this.CourseOption = [];
                        this.getCourseData();
                })
                .catch(error => {
                    console.error('Error in updating feedback', error.message);
                    this.showToast('Error in updating feedback',error.message);
                }).finally(() => {
                    this.isLoading = false;
                });
            }

            // PDF Download
            handleBulkPdfDownload(event){
                // Replace with your org's domain and Visualforce page name
               // window.open('/apex/ContactPDFPage', '_blank');

                // const tempId1 = 'FT-0001';
                // const vfPageUrl = `/apex/ContactPDFPage?SemesterID=${this.semId}&tempId=${tempId1}`;
                // window.open(vfPageUrl, '_blank');
                
                // this.isLoading = true;
                // generateAndStorePDFAndLinkToUser()
                //     .then(contentVersionId => {
                //         const downloadUrl = `/sfc/servlet.shepherd/version/download/${contentVersionId}`;
                //         const link = document.createElement('a');
                //         link.href = downloadUrl;
                //         link.download = 'AccountDetails.pdf';
                //         document.body.appendChild(link);
                //         link.click();
                //         document.body.removeChild(link);
                //     })
                //     .catch(error => {
                //         console.error('Error generating or downloading PDF:', error);
                //     //  alert('Error generating PDF: ' + (error?.body?.message || error));
                //     })
                //     .finally(() => {
                //         this.isLoading = false;
                //     });

                this.isLoading = true;
                let tempId1 = 'FT-0006';
                if(this.userId === '005J4000000JefwIAC' || this.userId === '0055j0000071w0TAAQ'){   // || this.userId ==='0055j0000071vohAAA'
                        tempId1 = 'FT-0001';
                }
                console.debug('this.semId : '+this.semId+' : tempId'+tempId1);
                generatePdfAndStore({
                    semesterId: this.semId,
                    tempId: tempId1
                })
                    .then((base64Data) => {
                        // Convert base64 to blob
                        const byteCharacters = atob(base64Data);
                        const byteNumbers = new Array(byteCharacters.length);
                        for (let i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }
                        const byteArray = new Uint8Array(byteNumbers);
                        const blob = new Blob([byteArray], { type: 'application/pdf' });
        
                        // Create download link
                        const downloadLink = document.createElement('a');
                        downloadLink.href = URL.createObjectURL(blob);
                        downloadLink.download = 'DirectorFeedbackReport.pdf';
                        downloadLink.style.display = 'none';
                        document.body.appendChild(downloadLink);
                        downloadLink.click();
                        document.body.removeChild(downloadLink);
                    })
                    .catch((error) => {
                        console.error('Error generating PDF:', error);
                       // alert('Failed to generate PDF');
                    })
                    .finally(() => {
                       this.isLoading = false;
                    });
                
            }

            getStudentCount(coId, secId){
                this.isLoading = true;
                this.studentFeedbackCount = 0;
                this.studentCount = 0;
                getStudentsForEnrollment({courseOfferingId :coId, sectionId :secId})
                .then(result => {
                 this.studentList = result;                       
                    if (this.studentList.length > 0) {
                        this.studentFeedbackCount = this.studentList.filter(student => student.facultyFeedback).length;
                        this.studentCount = this.studentList.length;
                  //      console.log('studentFeedbackCount : ' + this.studentFeedbackCount);
                  //      console.log('studentList.length : ' + this.studentList.length);
                    }                    
                })
                .catch(error => {
                    console.error('Error fetching students', JSON.stringify(error));
                //    this.error = 'Failed to load student data.';
                })
                .finally(() => {
                    this.isLoading = false;
                });
            }
}