/* eslint-disable no-mixed-spaces-and-tabs */
import { LightningElement,track, wire } from 'lwc';
import DisplayAttendance from "@salesforce/apex/ATT_StudentAttendance_Ctrl.DisplayAttendance";
// import getQuestionsByType from '@salesforce/apex/FeedbackManagementController.getQuestionsByType';
import getQuestionsBySemesterId from '@salesforce/apex/FeedbackManagementController.getQuestionsBySemesterId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertFeedbackResponses from '@salesforce/apex/FeedbackManagementController.insertFeedbackResponses';
import getStudentEligibility from '@salesforce/apex/FeedbackManagementController.getStudentEligibility';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
// const CONTACT_FIELDS = ['Contact.Name', 'Contact.SRN_Number__c', 'Contact.MobilePhone', 'Contact.School_Name__c', 'Contact.Active_Section__c', 'Contact.Program_Batch_Name__c', 'Contact.Student_Status__c', 'Contact.Email','Contact.Program_Batch__c',];
import { refreshApex } from '@salesforce/apex';


export default class RevaFeedbackMain extends LightningElement {
    @track courseData = [];
    @track error;
    visibleFeedbackCategory = true;
    visibleCourseData = false;
    visibleQuestions = false;
    displayMessage = false;
    errorMessage = '';
    feedBackHeader = 'Feedback on Curriculum';
    selectedOption;
    questions;
    courseQuestions = [];
    feedbackTypeValue;
    courseConnId;
    courseOffId;
    ProgramBatch;
    sectionId;

    contactRecId;
    contactRecord;   

    programBatchName;
    ProgramBatchId;
    SemesterId;
    SectionName;
    SemesterNo;
    isLoading = true;
    isLoading1 = true;
    
    underMaintanance =  false;   
    wiredAttendanceResult;
    ///////////////////

    @track remarks = '';
    @track remainingChars = 80;
    @track totalChar = 80;
    @track showRemarksError = false;
    
    handleTextAreaInput(event) {
        this.remarks = event.target.value;
        this.remainingChars = 80 - this.remarks.length;
    }

    // questionsWithStarsValues = [];
  //  questionsWithStars= [];

    // courseQuestions = [
    //     { id: 'q1', text: 'Question 1 : Course objectives and outcomes were explained initially ?' },
    //     { id: 'q2', text: 'Question 2 : Frequent questions were asked to check on comprehension ?' },
    //     { id: 'q3', text: 'Question 3 : Concepts were explained using innovative techniques of teaching considering real-time examples?' },
    //     { id: 'q4', text: 'Question 4 : Professor used digital resources/ICT for classroom lectures ?' },
    //     { id: 'q5', text: 'Question 5 : Professor used board and chalk for classroom lectures ?' },
    //     { id: 'q6', text: 'Question 6 : Classroom teaching increased my interest in the subject ?' },
    //     { id: 'q7', text: 'Question 7 : Students are involved in classroom learning and doubts are cleared ?' },
    //     { id: 'q8', text: 'Question 8 : IA/ Assignments evaluation done in time and feedback shared ?' },
    //     { id: 'q9', text: 'Question 9 : Remedial classes conducted'},
    //     { id: 'q10', text: 'Question 10 : Professor was punctual to class.'},
    //     { id: 'q11', text: 'Question 11 : Class discipline was well maintained.'},
    //     { id: 'q12', text: 'Question 12 : Attendance marking and follow-up on tardines.'},
    //     { id: 'q13', text: 'Question 13 : Clarity in the communication of the professor.'},
    //     { id: 'q14', text: 'Question 14 : Subject knowledge of the Professor.'},
    //     { id: 'q15', text: 'Question 15 : Professor encourages to participate in extracurricular activities.'},
    //   ];
    

      FacultyQuestions = [
        { id: 'q1', text: 'Question 1 : The course content has examples for better understanding' },
        { id: 'q2', text: 'Question 2 : The course exposed you to new knowledge and practices' },
        { id: 'q3', text: 'Question 3 : The course outcomes and objectives of the syllabi are well defined and clear' },
        { id: 'q4', text: 'Question 4 : The course topics were arranged in sequential and connected well' },
        { id: 'q5', text: 'Question 5 : The course content addresses the self-learning concepts' },
        { id: 'q6', text: 'Question 6 : After the completion of this course, you will be able to solve analyze real-life problems related to this course' },
        { id: 'q7', text: 'Question 7 : Students are involved in classroom learning and doubts are cleared ?' },
        { id: 'q8', text: 'Question 8 : This course has given you enough understanding to take next level courses' },
      ];

      starValues = [1, 2, 3, 4, 5];
    
      //@track ratings = new Array(15).fill(0);
      @track ratings = [];
      @track submitted = false;
    
       get questionsWithStars() {
      //   console.log('Inside questionsWithStars : '+JSON.stringify(this.questions));
        
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
    
        questionsDataWithStars(questionsData) {
            if(questionsData.length > 0){
                return questionsData.map((question, qIndex) => {
                const stars = this.starValues.map((starValue) => ({
                    value: starValue,
                    class: starValue <= this.ratings[qIndex] ? 'star filled' : 'star'
                }));
                return { ...question, stars };
                }); 
            }
            return questionsData;    
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
                sectionId :this.sectionId,
                suffix: rating > 1 ? 's' : ''
            };
            }); 
          }  
          return this.questions;     
        }
    
      handleStarClick(event) {
        const questionIndex = parseInt(event.target.dataset.index, 10);
        const starValue = parseInt(event.target.dataset.star, 10);
    
        this.ratings[questionIndex] = starValue;
        this.ratings = [...this.ratings];
      }
    
       handleSubmit() {
            const allAnswered = this.ratings.every(r => r > 0);
            if (!allAnswered) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please answer all questions before submitting',
                        variant: 'error'
                    })
                );
                return;
            }

            if (!this.remarks || this.remarks.trim() === '') {
                this.showRemarksError = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter remarks',
                        variant: 'error'
                    })
                );
                return;
            }else {
    this.showRemarksError = false;
}
                this.submitted = true;
                // this.feedBackHeader = 'Feedback Management';
                // this.visibleQuestions = false;
                // this.visibleCourseData = true;
                // this.ratings = new Array(15).fill(0);     
                // this.showSuccessToast();

            
                // // Insert feedback response
                const payload = this.questionsWithRatings.map(q => ({
                    id: q.id,
                    qbId: q.qbId, 
                    templateId: q.templateId,
                    rating: q.rating,
                    courseConnId:this.courseConnId,
                    courseOffId:this.courseOffId,
                    sectionId :this.sectionId
                }));
                console.log('payLoad Data : ',JSON.stringify(payload, null, 2));
                this.isLoading = true;
                insertFeedbackResponses({ feedbackList: payload, feedbackType : this.feedbackTypeValue, remark : this.remarks })            
                    .then(() => {
                        this.submitted = true;
                        this.visibleCourseData = true;
                        this.visibleQuestions = false;
                        this.ratings = new Array(15).fill(0);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Feedback saved successfully',
                                variant: 'success'
                            })
                        );
                        // ✅ Refresh the wired data after successful insert
                    return refreshApex(this.wiredAttendanceResult);
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
            
            /*else{
                this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Please enter remarks',
                                variant: 'error'
                            })
                        );
            } */   
        }

      @wire(DisplayAttendance)
      wiredAttendance(result) {
        this.wiredAttendanceResult = result; // store the wire result
        const { data, error } = result;
          if (data) {
            this.isLoading1 = false;
            // console.log('wiredAttendance Executed !!');
            this.courseData = [];
            this.programBatchName = data.ProgramName;
            this.ProgramBatchId = data.ProgramBatchId;
            this.SemesterId = data.ActiveSemester;
        //    console.log('programBatch1 : '+this.programBatchName);
        //    console.log('ProgramBatchId : '+this.ProgramBatchId);
            this.SemesterNo = data.SemesterNo;
        //    console.log('SemesterNo1 : '+this.SemesterNo);
            this.SectionName = data.SectionName;
        //    console.log('SectionName1 : '+this.SectionName);

            const mapFaculty = data.map_Faculty;
            this.courseData = Object.values(mapFaculty).map(item => ({
                ccid : item.CourseConnectionId,
                coffid : item.CourseOfferingId,
                sectionid : item.sectionId,
                feedbackFacultyStatus : item.FeedbackFaculty,
                feedbackCourseStatus : item.FeedbackCourse,
                courseName: item.CourseOfferingName,
                courseCode: item.courseCode,
                category: item.Category,
                subject: item.CourseOfferingName,
                batchGroup: `${item.BatchNumber} / ${item.GroupNume}`,
                professor: item.facultyName
            }));
    
            // console.log('Number of courses:', Object.keys(mapFaculty).length);
            // this.courseData.forEach(element => {
            //     console.log('Records : '+ JSON.stringify(element.stringify));
            // });
            // console.log('Course Data:', this.courseData);
          } else if (error) {
              this.isLoading1 = false;
              this.error = error;
              console.error('Error loading attendance data', error);
          }          
      }

        @wire(getRecord, { recordId: USER_ID, fields: CONTACT_ID_FIELD })
        wiredUser({ error, data }) {
            if (data) {
                this.contactRecId = getFieldValue(data, CONTACT_ID_FIELD);
            	// console.log('Selected Contact Id -->'+this.contactRecId);    
                
                this.checkStudentEligibility();    
            } else if (error) {
                // this.showErrorToast(error.body.message);
                console.log('Error : '+error.body.message);
            }
        }

        // // Retrieve the Contact record based on the ContactId retrieved from the User record
        // @wire(getRecord, { recordId: '$contactRecId', fields: CONTACT_FIELDS })
        // wiredContactRecord({ error, data }) {
        //     if (data) {
        //         this.contactRecord = data;
        //         this.ProgramBatch = getFieldValue(this.contactRecord, 'Contact.Program_Batch__r.Name') || 'N/A';
        //         console.log('Contact Record Program Batch -->'+this.ProgramBatch);  
        //         // this.onLoadDisplayData();
        //         // this.checkRegistrationField();
        //     } else if (error) {
        //         // this.showErrorToast(error.body.message);
        //         console.log('Error : '+error.body.message);
        //     }
        // } 

        checkStudentEligibility(){
            // console.log('checkStudentEligibility :: '+this.contactRecId);
            getStudentEligibility({ contactId: this.contactRecId })
            .then((result) => {
                // console.log('result : '+result);
                if(result !== 'SUCCESS'){
                    this.visibleCourseData = false;
                    this.displayMessage = true;
                    if(result === 'NO_ATTENDANCE'){
                        this.errorMessage = 'You are currently ineligible to submit feedback due to not meeting the attendance requirement.';
                    }
                    if(result === 'FEEDBACK_NOT_SET'){
                        this.errorMessage = 'Feedback for the current semester has not been configured. Please check again later.';
                    }
                    if(result === 'NOT_ACTIVE'){
                        this.errorMessage = 'The feedback form is currently inactive. It will be made available upon activation by the vertical head.';
                    }
                    if(result === 'IN_COMPLETE_SETUP'){
                        this.errorMessage = 'Feedback is not setup';
                    }
                    if(result === 'NO_DATE_RANGE'){
                        this.errorMessage = 'The feedback submission window is currently closed. Please refer to the official schedule for relevant dates.';
                    }
                    if(result.includes('Error')){
                        this.errorMessage = 'An unexpected system error has occurred. Kindly try again later or contact the vertical head.';
                    }
                }
            })
            .catch((error) => {
                console.log('Error : '+error);
            })
            .finally(() => {
                this.isLoading = false;
            })
        }


      handleFetchQuestions(type) {
         console.log('Param1 :: '+type );
         console.log('Param2 :: '+this.SemesterId); 
            this.isLoading = true;   
            getQuestionsBySemesterId({ feedbackType: type, semesterId: this.SemesterId })
            .then((result) => {   
                if(result.length === 0){
                    this.errorMessage = 'No questions found for the selected '+type;
                    console.log('Quetions not loaded!!');
                    this.displayMessage = true;
                }else{             
                    this.courseQuestions = result;
                    this.error = undefined;
                    this.questions = this.courseQuestions;
                    this.ratings = new Array(this.questions.length).fill(0);
                    console.log('result =>>'+result);
                    console.log('result =>>'+JSON.stringify(result));
            //     console.log('data : ->'+JSON.stringify(this.questions));
            //     this.questionsWithStars = this.questionsDataWithStars(this.questions);
                    let val = this.questionsWithStars;
                }
            })
            .catch((error) => {
                this.error = error;
                this.courseQuestions = [];
                console.error('Error fetching questions:', error);
                this.displayMessage = true;
                this.errorMessage = 'No questions found for the selected course.';
            }).finally(() => {
                this.isLoading = false;
            }); 
          //  this.questionsWithStars = this.questionsDataWithStars(this.courseQuestions);
        }       

      get questionVisibility(){
          return this.visibleQuestions;
      }    
    

      handleClickSubject(event){
        this.feedbackTypeValue = 'Course';
        this.feedBackHeader = 'Feedback On Course';
        this.visibleQuestions = true;
        this.visibleCourseData = false;
        this.visibleFeedbackCategory = false;        
        const courseName = event.target.dataset.subject;
        this.courseConnId = event.target.dataset.ccid;
        this.courseOffId = event.target.dataset.coid;
        // console.log('Selected Course Connection Id :'+this.courseConnId);
        // console.log('Selected Course courseOffering Id :'+this.courseOffId);
        this.selectedOption = 'Selected Course : '+courseName;
        this.handleFetchQuestions(this.feedbackTypeValue);
     //   this.questions = this.courseQuestions;
        // console.log('course Name :'+courseName);
      }

      handleClickFaculty(event){
        this.feedbackTypeValue = 'Faculty';
        this.feedBackHeader = 'Feedback On Faculty';
        this.visibleQuestions = true;
        this.visibleCourseData = false;
        this.visibleFeedbackCategory = false;
      //  this.questions = this.FacultyQuestions;
        const courseProfessor = event.target.dataset.faculty;
        this.courseConnId = event.target.dataset.ccid;
        this.courseOffId = event.target.dataset.coid;
        this.selectedOption = 'Selected Faculty : '+courseProfessor;
        this.sectionId = event.target.dataset.secid;
        this.handleFetchQuestions(this.feedbackTypeValue);
        console.log('sectionId :'+this.sectionId);
        this.remarks = '';
        this.showRemarksError = false;
      }

      handleBackButton(){
        this.feedBackHeader = 'Feedback';
        this.visibleQuestions = false;
        this.visibleCourseData = true;
        this.displayMessage = false;
        this.visibleFeedbackCategory = false;
        this.ratings = [];
        this.remainingChars = 80; // Reset the remaining characters count
        this.remarks = ''; // Reset the remarks field
      }

      handleBackButtonCourseDisplay(){
        this.visibleQuestions = false;
        this.visibleCourseData = false;
        this.displayMessage = false;
        this.visibleFeedbackCategory = true;
      }
       //Success Notification
        showSuccessToast() {
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Feedback submission is successfull',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }

        enableCurriculumFeedback(){            
            this.visibleFeedbackCategory = false;
            this.visibleCourseData = true;            
        }
}