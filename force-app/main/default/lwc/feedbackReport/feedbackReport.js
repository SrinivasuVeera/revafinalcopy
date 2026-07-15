import { LightningElement, wire, track } from 'lwc';
import getFeedbackSummary from '@salesforce/apex/FeedbackManagementController.getFeedbackSummary';
import getFacultyEnrollments from '@salesforce/apex/FeedbackManagementController.getFacultyEnrollments';
import getStudentsForEnrollment from '@salesforce/apex/FeedbackManagementController.getStudentsForEnrollment';
//import getPDFDownloadUrl from '@salesforce/apex/FeedbackManagementController.getPDFDownloadUrl';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateFeedbackPdf from '@salesforce/apex/FeedbackManagementController.generateFeedbackPdf';
import getQuestionsBySemester from '@salesforce/apex/FeedbackManagementController.getQuestionsBySemester';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertFeedbackResponses from '@salesforce/apex/FeedbackManagementController.insertFeedbackResponses';

export default class FacultyEnrollments extends LightningElement {
    enrollments;
    error;
    showFacultyActiveCC = true;
    showStudentDetails = false;
    showSummaryReport = false;
    ShowInstructions = true;
    ShowEnrollments = false;
    ShowCourses = false;
    studentList;
    SchoolName;
    Semester;
    Section;
    CourseOfferingName;
    courseOfferingId;
    courseConnectionId;
    sectionId;
    tempId;
    directorRemark;
    isLoading = false;
    visibleFeedbackCategory = true;
    questions;
    displayQuestions = false;
    @track feedbackDataCourse = [];
    @track feedbackDataFaculty = [];
    // error;
    @track totalAverageCourse = 0;
    @track totalAverageFaculty = 0;
    directorFeedbackStatus = false;
    displayMessage = false;
    starValues = [1, 2, 3, 4, 5];
    errorMessage;
    
    @track ratings = new Array(15).fill(0);
    @track submitted = false;

    @wire(getFacultyEnrollments)
    wiredData({ data, error }) {
        if (data) {
            this.enrollments = data.map((item, idx) => {
                return { ...item, serialNo: idx + 1 };
            });                        
            this.error = undefined;
            console.log('Data :: '+JSON.stringify(data));
        } else if (error) {
            this.error = 'Error retrieving enrollment data.';
            this.enrollments = undefined;
            console.error(error);
        }
    }    

    handleDetails(event) {
        const enrollmentId = event.currentTarget.dataset.id;
        // alert(`Showing details for enrollment ID: ${enrollmentId}`);
        // Optionally: navigate to a record page or open a modal

        // this.showSuccessToast(enrollmentId);
        
        this.showFacultyActiveCC = false;

     //   const enrollmentId = event.currentTarget.dataset.id;
        const selectedRow = this.enrollments.find(row => row.enrollmentId === enrollmentId);
    
        // You need courseOfferingId and sectionId – make sure they're available
        const courseOfferingId = selectedRow.courseOfferingId;
        const sectionId = selectedRow.sectionId;
        console.log('courseOfferingId : '+courseOfferingId);
        console.log('sectionId : '+sectionId);
        console.log('selectedRow : '+selectedRow);
        // console.log('enrollments :'+this.enrollments);        
        
        this.SchoolName = selectedRow.school;
        this.Semester = selectedRow.semester;
        this.Section = selectedRow.section;
        this.CourseOfferingName = selectedRow.courseOfferingName;
        this.isLoading = true;
        getStudentsForEnrollment({ courseOfferingId, sectionId })
            .then(result => {
               // this.studentList = result;
               this.studentList = result.map((item,index) => {
                return { ...item, serialNo: index + 1 };
            });
                this.showStudentDetails = true;
            })
            .catch(error => {
                console.error('Error fetching students', error);
                this.error = 'Failed to load student data.';
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleReport(event) {
        const enrollmentId = event.currentTarget.dataset.id;
        const selectedRow = this.enrollments.find(row => row.enrollmentId === enrollmentId);
        this.courseOfferingId = selectedRow.courseOfferingId;
        this.courseConnectionId = enrollmentId;
        this.sectionId = selectedRow.sectionId;
        console.log('handleReport() is called !!'+this.courseOfferingId);
        console.log('handle report sectionId : '+ this.sectionId);

        // const courseOfferingId1 = courseOfferingId;
        // const templateId = 'FT-0002';
        this.showFacultyActiveCC = false;        
        this.showSummaryReport = true;

        this.getCourseSummaryData(this.courseOfferingId, 'FT-0007');  //'a0BIp000000JB2rMAG'
        this.getFacultySummaryData(this.courseOfferingId, 'FT-0006', this.sectionId, this.courseConnectionId);
        
    }

    getCourseSummaryData(courseOfferingIdVal, templateIdVal){
        console.log('getCourseSummaryData : '+courseOfferingIdVal);
        console.log('getCourseSummaryData : '+templateIdVal);
        this.isLoading = true;
        getFeedbackSummary({ courseOfferingId: courseOfferingIdVal, templateId: templateIdVal })
            .then(result => {
                this.feedbackDataCourse = result;
                console.log('getCourseSummaryData -> '+JSON.stringify(result));
                let total = 0;
                let count = 0;
    
                for (let item of result) {
                    const value = parseFloat(item.averageResponse);                    
                    if (!isNaN(value)) {
                        total += value;
                        count++;
                    }
                }
    
                this.totalAverageCourse = count > 0 ? (total / count).toFixed(2) : 0;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.feedbackDataCourse = [];
                this.totalAverageCourse = 0;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getFacultySummaryData(courseOfferingIdVal, templateIdVal, sectionIdVal, courseConnIdVal){
        console.log('getFacultySummaryData courseOfferingIdVal : '+courseOfferingIdVal);
        console.log('getFacultySummaryData templateIdVal : '+templateIdVal);
        console.log('getFacultySummaryData sectionIdVal : '+sectionIdVal);
        this.isLoading = true;
        getFeedbackSummary({ courseOfferingId: courseOfferingIdVal, templateId: templateIdVal, sectionId: sectionIdVal, courseConnId : courseConnIdVal })
            .then(result => {                
                console.log('getFeedbackSummary -> '+JSON.stringify(result));
                let total = 0;
                let count = 0;
             //   let index = 1;

             result.sort((a, b) => {
                // eslint-disable-next-line radix
                let numA = parseInt(a.qId.replace(/^\D+/g, "")); 
                // eslint-disable-next-line radix
                let numB = parseInt(b.qId.replace(/^\D+/g, ""));
                return numA - numB;
            });

                for (let item of result) {
                  //  item.qId = index;
                  //  index++;
                    const value = parseFloat(item.averageResponse);
                    this.directorFeedbackStatus = item.directorFeedbackStatus;
                    this.directorRemark = item.directorFeedbackRemark;
                    if (!isNaN(value)) {
                        total += value;
                        count++;
                    }
                }
                // this.directorFeedbackStatus ? directorRemark : '';
    
                this.totalAverageFaculty = count > 0 ? (total / count).toFixed(2) : 0;
                this.error = undefined;
                this.feedbackDataFaculty = result;
            })
            .catch(error => {
                this.error = error;
                this.feedbackDataFaculty = [];
                this.totalAverageFaculty = 0;
            }).finally(() => {
                this.isLoading = false;
            });
    }

    // Helper to display index + 1
    getIndexPlusOne(index) {
        return index + 1;
    }

    handleDownload(event){        
        console.log('Handle Download !!');
        this.isLoading = true;
        if(event.target.name === 'facultyPdf'){
            this.tempId = 'FT-0006';
        } 
                
            //   const courseOfferingId = 'a0BIp000000JB1LMAW';
            //   const templateId = 'FT-0003';
        console.debug('this.courseOfferingId : '+this.courseOfferingId);
        console.debug('this.tempId : '+this.tempId);
        console.debug('this.courseConnectionId : '+this.courseConnectionId);
        console.debug('this.sectionId : '+this.sectionId);
        
        // Call Apex method to get Base64-encoded PDF string
        generateFeedbackPdf({courseOfferingId: this.courseOfferingId, templateId : this.tempId, courseConnectionId : this.courseConnectionId, sectionId :  this.sectionId})
        .then((base64Pdf) => {
            // Decode base64 string to binary
            const byteCharacters = atob(base64Pdf);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }

            const byteArray = new Uint8Array(byteNumbers);
            const blob = new Blob([byteArray], { type: 'application/pdf' });

            // Create temporary link to trigger download
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = 'Feedback_Report.pdf';
            document.body.appendChild(link);
            link.click();

            // Clean up
            URL.revokeObjectURL(url);
            document.body.removeChild(link);
        })
        .catch((error) => {
            console.error('Error downloading PDF:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleBackButton(){
        this.showStudentDetails = false;
        this.showFacultyActiveCC = true;
        this.showSummaryReport = false;
    }

    //  showSuccessToast(enrollmentId) {
    //             const event = new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Feedback submission is successfull'+enrollmentId,
    //                 variant: 'success',
    //                 mode: 'dismissable'
    //             });
    //             this.dispatchEvent(event);
    //         }

    displayFacultyEnrollment(){
        this.ShowInstructions = false;
        this.ShowEnrollments = true;
        this.ShowCourses = true;
    }

    displayQuestionSet(event){
        const enrollmentId = event.currentTarget.dataset.id;
        const selectedRow = this.enrollments.find(row => row.enrollmentId === enrollmentId);        
        const semester = selectedRow.semester;
        this.courseOfferingId = selectedRow.courseOfferingId;
        this.courseConnectionId = enrollmentId;
        this.ShowCourses = false;
        this.displayQuestions = true;
        // this.ShowEnrollments = false;
        this.Semester = selectedRow.semester;
        this.Section = selectedRow.section;
        this.CourseOfferingName = selectedRow.courseOfferingName;

        console.log('courseOfferingId : '+this.courseOfferingId);
        console.log('semester : '+semester);  
        console.log('enrollmentId : '+enrollmentId);

     //   let input = 'BA-PE-2021-2024-Sem-6-F(Batch1)'; // Change this to your input string

        // Regex to match everything up to "Sem-" + one character
        let match = semester.match(/^(.*?Sem-\w)/);

        let trimmedSemester = match ? match[1] : semester;
        console.log(trimmedSemester);
        this.getQuestions(trimmedSemester);

    }

        getQuestions(sem){
            this.isLoading = true;
            console.log('Inside getQuestions Method : Sem : '+sem);
            // getQuestionsBySemester({ feedbackType: 'Course', semester: sem })
            //             .then((result) => {                
            //             //    this.courseQuestions = result;
            //                 this.error = undefined;
            //                 this.questions = result;
            //                 this.displayQuestions = true;
            //                 console.log('data : ->'+JSON.stringify(this.questions));                  
            //             })
            //             .catch((error) => {
            //                 this.error = error;
            //                 this.courseQuestions = [];
            //                 console.error('Error fetching questions:', error);
            //                 this.displayMessage = true;
            //                 this.errorMessage = 'No questions found for the selected course.';
            //             }).finally(() => {
            //                 this.isLoading = false;
            //             }); 

            getQuestionsBySemester({ feedbackType: 'Course', semester: sem })
                .then((result) => {
                    this.error = undefined;
                    this.questions = result;
                    this.displayQuestions = true;
                    this.displayMessage = false; // Hide error message
                    console.log('data : ->' + JSON.stringify(this.questions));
                })
                .catch((error) => {
                    this.questions = [];
                    this.displayQuestions = false;
                    this.displayMessage = true;

                    // Handle specific custom exceptions
                    let errorMsg = (error && error.body && error.body.message) ? error.body.message : 'Unknown error';

                    switch (errorMsg) {
                        case 'FEEDBACK_NOT_SET':
                            this.errorMessage = 'Feedback not configured for the selected semester and course.';
                            break;
                        case 'NOT_ACTIVE':
                            this.errorMessage = 'Feedback is currently not active.';
                            break;
                        case 'IN_COMPLETE_SETUP':
                            this.errorMessage = 'Feedback setup is incomplete. Start or end date is missing.';
                            break;
                        case 'NO_DATE_RANGE':
                            this.errorMessage = 'Feedback is not available in the current date range.';
                            break;
                        default:
                            this.errorMessage = 'No questions found for the selected course.';
                            break;
                    }

                    this.error = error;
                    console.error('Error fetching questions:', errorMsg);
                })
                .finally(() => {
                    this.isLoading = false;
                });

        }    
  
        get questionsWithStars() {
            if(this.questions != null) {
            return this.questions.map((question, qIndex) => {
                const stars = this.starValues.map((starValue) => ({
                    value: starValue,
                    class: starValue <= this.ratings[qIndex] ? 'star filled' : 'star'
                }));
                return { ...question, stars };
                });
            } 
        return this.questions;
        } 

        get questionsWithRatings() {    
            if(this.questions != null) {    
            return this.questions.map((question, index) => {
            const rating = this.ratings[index];
            return {
                id: question.id,
                qbId: question.qbId, 
                templateId: question.templateId,
                text: question.text,
                rating: rating,
                courseConnId:this.courseConnId,
                courseOffId:this.courseOffId,
                suffix: rating > 1 ? 's' : ''
            };
            }); 
            }  
            return this.questions;     
        }

        handleStarClick(event) {
            console.log('Clicked');
            const questionIndex = parseInt(event.target.dataset.index, 10);
            const starValue = parseInt(event.target.dataset.star, 10);
        
            this.ratings[questionIndex] = starValue;
            this.ratings = [...this.ratings];
        }

      handleSubmitQuestions(){
        const payload = this.questionsWithRatings.map(q => ({
            id: q.id,
            qbId: q.qbId, 
            templateId: q.templateId,
            rating: q.rating,
            courseConnId:this.courseConnectionId,
            courseOffId:this.courseOfferingId
        }));
        console.log(JSON.stringify(payload, null, 2));       

                this.isLoading = true;
                insertFeedbackResponses({ feedbackList: payload, feedbackType : 'Course' })            
                    .then(() => {
                        // this.submitted = true;
                        // this.visibleCourseData = true;
                        // this.visibleQuestions = false;
                        this.displayQuestions = false;
                        this.ShowEnrollments = true;
                        this.ShowCourses = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Feedback saved successfully',
                                variant: 'success'
                            })
                        );
                    })
                    .catch(error => {
                        console.error('Error in insert Feedback : ', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error saving feedback',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    })
                    .finally(() => {
                        this.isLoading = false;
                    });
      }

      questionDisplayBackButton(){
        this.displayQuestions = false;
        this.ShowEnrollments = true;
        this.ShowCourses = true;
      }
        
}