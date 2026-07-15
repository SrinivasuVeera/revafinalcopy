import { LightningElement, track,wire} from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import validateData from '@salesforce/apex/ExamQRAttendanceController.checkValidData';
// import validateQRData from '@salesforce/apex/HallTicketQRController.decryptQR';
import validateQRData from '@salesforce/apex/ExamQRAttendanceController.decryptQR';
// import validateStudent from '@salesforce/apex/ExamQRAttendanceController.validateStudent';
// import validateStudent from '@salesforce/apex/HallTicketQRController.validateStudent';
//import getStudentData from '@salesforce/apex/HallTicketQRController.getStudentData';
//import getStudentData from '@salesforce/apex/HallTicketQRController.getMockStudentData';



//  Exam Attendance Coordinator
import getAttCoordinatorData from '@salesforce/apex/ExamQRAttendanceController.getAttendanceCoordinatorData1';
import getExamRoomStudentData from '@salesforce/apex/ExamQRAttendanceController.getExamRoomStudentData';
import updateStudentAttendance from '@salesforce/apex/ExamQRAttendanceController.updateStudentAttendance';
import updateFinalStudentAttendance from '@salesforce/apex/ExamQRAttendanceController.updateFinalAttendance';



export default class QrCodeGenrator extends LightningElement {   
    
    scannedValue;
    myScanner;

    @track resultMessage = '';
    @track errorMessage = '';
    @track contact;
    scanResult;
    @track mesg;

    @track processedLineItems = [];
    studentData;
    error;
    @track isLoadingqr = true;
    //showStudentDetails = true;
    isSuccess = false;
    isFailure = false;
    statusMessage;

    // Get the scanner instance
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
    }

    // Launch the scanner
    scanQRCode() {

        this.resultMessage = '';
        this.errorMessage = '';
        this.mesg = ''; 
     //   this.contact = null;
        this.isSuccess = false;
        this.isFailure = false;
        this.statusMessage = '';

        if (this.myScanner && this.myScanner.isAvailable()) {
            const scanningOptions = {
                // Define the barcode types to scan. QR code is included.
                barcodeTypes: [this.myScanner.barcodeTypes.QR]
            };

            // Start scanning
            this.myScanner.scan(scanningOptions)
                .then((results) => {
                    // Handle the scanned data
                    this.handleScanSuccess(results);
                })
                .catch((error) => {
                    // Handle any errors
                    this.handleScanError(error);
                })
                .finally(() => {
                    // Close the scanner interface and clean up
                    if (this.myScanner) {
                        this.myScanner.dismiss();
                    }
                });
        } else {
            // Display a toast if the scanner is not available
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scanner Not Available',
                    message: 'This device does not support barcode scanning.',
                    variant: 'warning'
                })
            );
        }
    }

    // Method to handle successful scan
    handleScanSuccess(results) {
        this.scannedValue = decodeURIComponent(results[0].value); // Assuming first result is the one you need
        
        this.validateNewCode(this.scannedValue);
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title: 'Scan Successful',
        //         message: this.scannedValue,
        //         variant: 'success'
        //     })
        // );
    }    

    // validate NEW QR code
    validateNewCode(inputString) {
        this.resultMessage = '';
        this.errorMessage = '';
        // this.mesg = '';
       // this.scanResult = null;
     //  console.log('inputQRString : ' + inputString);
    
        // this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Scan Successful',
        //                 message: inputString,
        //                 variant: 'success'
        //             })
        //         );

        const examDate = this.selected.examDate
        ? new Date(this.selected.examDate).toISOString().split('T')[0]
        : null;

        const startTime = this.formatTime24(this.selected.examStart);
        const endTime   = this.formatTime24(this.selected.examEnd);

        // console.log('qrData: ' +this.scannedValue+' examRoom: ' + this.selected.assignmentName+' examDate :'+ examDate+' examDate :'+startTime + 'endTime :'+ endTime);
       // const mesg = 'qrData: ' +this.scannedValue+' examRoom: ' + this.selected.assignmentName+' examDate :'+ examDate+' examDate :'+startTime + 'endTime :'+ endTime;
      //  this.showToast(mesg);
      //  this.mesg = mesg;
        validateQRData({ qrData: this.scannedValue, examRoom: this.selected.assignmentName, examDate : examDate, startTime : startTime, endTime : endTime})
            .then((result) => {
                this.isLoadingqr = false;
                if (result) {
                //    this.scanResult = result;
                 //   this.resultMessage = result;
                 this.studentData = result;
                 if(this.studentData?.status === 'success'){
                    this.isSuccess = true;
                 }
                 if(this.studentData?.status === 'failure'){
                    this.isFailure = true;
                    this.statusMessage = this.studentData.message;
                 }
                  // Process for rendering
                this.processedLineItems = (result.matchedLineItems || []).map((item, index) => ({
                    key: item.Id,
                    slNo: index + 1,
                    courseName: item.Course__r?.Name,
                    courseCode: item.Course__r?.hed__Course_ID__c,
                    sem: result.SemesterTerm,
                    date: result.LineItemWithDate[item.Id],
                    startTime: result.StartTime[item.Id],
                    endTime: result.EndTime[item.Id]
                }));
                } else {
                    this.resultMessage = 'Caution : Invalid Student ID';
                }
            })
            .catch((error) => {
                this.errorMessage = error.body ? error.body.message : 'An error occurred.';
            });
    }

    //  showToast(mesg) {
    //     const event = new ShowToastEvent({
    //         title: 'Success',
    //         message: mesg,
    //         variant: 'success', // success, error, warning, info
    //         mode: 'dismissable' // dismissable, sticky, pester
    //     });

    //     this.dispatchEvent(event);
    // }

    // Method to handle scan errors
    handleScanError(error) {
        console.error('Scan error:', error);
        // Check if the error is due to user dismissal
        if (error.code === 'userDismissedScanner') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scan Cancelled',
                    message: 'You cancelled the scan.',
                    variant: 'info'
                })
            );
        } else {
            // Handle other errors
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scan Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        }
    }

    // get isSuccess() {
    //    return this.studentData?.status === 'success';        
    // }

    // get isFailure() {
    //     return this.studentData?.status === 'failure';        
    // }


    // @wire(getStudentData, { srnNumber: 'R23EF001' })
    // wiredStudent({ data, error }) {
    //      this.isLoadingqr = false;
    //     if (data) {
    //         console.log('⚡ Apex Data Received:', JSON.parse(JSON.stringify(data)));
    //         this.studentData = data;
    //         this.error = undefined;
    
    //         // Log individual parts of the data to verify
    //         console.log('✅ Name:', data.name);
    //         console.log('✅ SRN:', data.srn);
    //         console.log('✅ Matched Line Items:', data.matchedLineItems);
    //         console.log('✅ LineItemWithDate Map:', data.LineItemWithDate);
    //         console.log('✅ StartTime Map:', data.StartTime);
    //         console.log('✅ EndTime Map:', data.EndTime);
    
    //         // Process for rendering
    //         this.processedLineItems = (data.matchedLineItems || []).map((item, index) => ({
    //             key: item.Id,
    //             slNo: index + 1,
    //             courseName: item.Course__r?.Name,
    //             courseCode: item.Course__r?.hed__Course_ID__c,
    //             sem: data.SemesterTerm,
    //             date: data.LineItemWithDate[item.Id],
    //             startTime: data.StartTime[item.Id],
    //             endTime: data.EndTime[item.Id]
    //         }));
    
    //         console.log('🧾 Processed Line Items:', JSON.parse(JSON.stringify(this.processedLineItems)));
    //     } else if (error) {
    //         this.error = error.body ? error.body.message : error.message;
    //         console.error('❌ Apex Error:', JSON.parse(JSON.stringify(error)));
    //         this.studentData = undefined;
    //         this.processedLineItems = [];
    //     }
    // }

    get jsonData() {
        return JSON.stringify(this.studentData, null, 2);
    }

    // handleValidStudent() {
    //     this.loading = true;

    //     validateStudent({
    //         srn:  this.studentData.srn // , courseCode: this.processedLineItems[0].courseCode
    //     })
    //         .then(result => {
    //             console.log('Validate Result:', result);
    //             if(result === 'success'){
    //                 this.dispatchEvent(
    //                     new ShowToastEvent({
    //                         title: 'Success',
    //                         message: 'Student data updated successfully',
    //                         variant: 'success'
    //                     })
    //                 );
    //             }
    //            // this.response = result; 
    //           // this.showStudentDetails = false; 
    //            this.fetchStudents();      
    //            this.isSuccess = false;       
    //         })
    //         .catch(error => {
    //             console.error('Validation Error:', error);
    //             // this.response = {
    //             //     status: 'failure',
    //             //     message: 'Error while validating student.'
    //             // };
    //         })
    //         .finally(() => {
    //             this.loading = false;
    //         });
    // }

    handleInValidStudent(){
        this.isSuccess = false;
        this.isFailure = false;
        this.statusMessage = ''; 
    }

    /******************************************************************** 
                            Exam Attendance Coordinator 
    *********************************************************************/

       /* -------------------------
            * UI State
            * ------------------------- */
           @track assignments = [];
           @track selected = {};
           @track students = [];
           @track studentTableData = [];

           @track showScreen1 = true;
           @track showScreen2 = false;
           @track showStudents = false;
           @track isLoading = false;
           // programBatchName;
           @track finalAttendanceUpdateStatus = false;
            showModal = false;
        //   wiredAssignments; // for refreshApex

            studentColumns = [
                { label: 'SRN', fieldName: 'srn' },
                { label: 'Name', fieldName: 'name' },
                { label: 'Status', fieldName: 'statusText' }
            ];
       
           /* -------------------------
            * Wire: Assignment Data
            * ------------------------- */
           @wire(getAttCoordinatorData)
           wiredData(result) {
            //   this.wiredAssignments = result;
               const { data, error } = result;
       
               if (data) {
                   this.assignments = data.map(item => ({
                       ...item,
                       formattedDate: this.formatDate(item.examDate),
                       formattedStart: this.formatTime12Hour(item.examStart),
                       formattedEnd: this.formatTime12Hour(item.examEnd)
                   }));
               } else if (error) {
                   console.error(error);
                   this.showToast({
                       title: 'Error',
                       message: 'Failed to load assignments',
                       variant: 'error'
                   });
               }
           }
       
           /* -------------------------
            * Open Details
            * ------------------------- */
           openDetails(event) {
               const recId = event.target.dataset.id;
               this.selected = this.assignments.find(a => a.recordId === recId);
               this.finalAttendanceUpdateStatus = this.selected.qrAttendanceUpdate;
               this.showScreen1 = false;
               this.showScreen2 = true;
       
               this.fetchStudents();
           }
       
           /* -------------------------
            * Fetch Students
            * ------------------------- */
           fetchStudents() {
               this.isLoading = true;
       
               const examDate = this.selected.examDate
                   ? new Date(this.selected.examDate).toISOString().split('T')[0]
                   : null;
       
               const startTime = this.formatTime24(this.selected.examStart);
               const endTime   = this.formatTime24(this.selected.examEnd);
       
               getExamRoomStudentData({
                   examRoom: this.selected.assignmentName,
                   examDate: examDate,
                   startTime: startTime,
                   endTime: endTime,
                   progBatchName : this.selected.programBatchName
               })
               .then(data => {
                 //  this.wiredAssignments = data;
                   this.students = data || [];
                   this.showStudents = true;
                   this.prepareStudentTable();
               })
               .catch(error => {
                   console.error(error);
                   this.students = [];
                   this.showStudents = false;
       
                   this.showToast({
                       title: 'Error',
                       message: 'Unable to load student data',
                       variant: 'error',
                       mode: 'sticky'
                   });
               })
               .finally(() => {
                   this.isLoading = false;
               });
           }

           prepareStudentTable() {
                this.studentTableData = this.students.map(stud => {
                    return {
                        srn: stud.srn,
                        name: stud.name,
                        statusText: stud.status ? 'Present' : 'Absent'
                    };
                });
            //    this.programBatchName = [...new Set(this.students.map(obj => obj.programBatchName))];
            //    console.log('programBatchName :'+this.programBatchName);
            }
       
           /* -------------------------
            * Scan / Update Attendance
            * ------------------------- */
           markAttendance() {
               this.isLoading = true;
       
               updateStudentAttendance({
                   examRoom: this.selected.assignmentName,
                   examDate: this.selected.examDate,
                   startTime: this.selected.examStart,
                   endTime: this.selected.examEnd,
                   studSRN: this.studentData.srn
               })
               // eslint-disable-next-line consistent-return
               .then(result => {
                   if (result.startsWith('SUCCESS')) {
                       this.showToast({
                           title: 'Success',
                           message: result.replace('SUCCESS: ', ''),
                           variant: 'success',
                           mode: 'pester'
                       });
       
                     this.students = [];
                    //   return refreshApex(this.wiredAssignments);
                    // ✅ Refresh students list so updated status is visible
                        this.fetchStudents();
                   }
                   else if (result.startsWith('INFO')) {
                       this.showToast({
                           title: 'Info',
                           message: result.replace('INFO: ', ''),
                           variant: 'info'
                       });
                   }
                   else {
                       this.showToast({
                           title: 'Error',
                           message: result.replace('ERROR: ', ''),
                           variant: 'error',
                           mode: 'sticky'
                       });
                   }                      
                   this.isSuccess = false;
               })
               .catch(error => {
                   console.error(error);
                   this.showToast({
                       title: 'Error',
                       message: 'Unexpected system error',
                       variant: 'error',
                       mode: 'sticky'
                   });
               })
               .finally(() => {
                   this.isLoading = false;
               });
           }
       
           /* -------------------------
            * UI Helpers
            * ------------------------- */
           toggleStudents() {
               this.showStudents = !this.showStudents;
           }
       
           goBack() {
               this.showScreen1 = true;
               this.showScreen2 = false;
               this.showStudents = false;
               this.students = [];
               this.isSuccess = false;
               this.isFailure = false;
               this.statusMessage = '';
           }
       
           get toggleButtonLabel() {
               return this.showStudents ? 'Hide Details' : 'Show Details';
           }
       
           get noDataAvailable() {
               return !this.students || this.students.length === 0;
           }
       
           /* -------------------------
            * Toast Utility
            * ------------------------- */
           showToast({ title, message, variant = 'info', mode = 'dismissable' }) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title,
                       message,
                       variant,
                       mode
                   })
               );
           }
       
           /* -------------------------
            * Formatting Helpers
            * ------------------------- */
           formatDate(dateVal) {
               if (!dateVal) return '';
               const d = new Date(dateVal);
               return `${String(d.getDate()).padStart(2,'0')}-${String(d.getMonth()+1).padStart(2,'0')}-${d.getFullYear()}`;
           }
       
           formatTime12Hour(timeVal) {
               if (!timeVal) return '';
               if (timeVal.includes('T')) timeVal = timeVal.split('T')[1].replace('.000Z','');
               if (timeVal.includes('.')) timeVal = timeVal.split('.')[0];
       
               const [h, m] = timeVal.split(':');
               let hour = parseInt(h, 10);
               const ampm = hour >= 12 ? 'PM' : 'AM';
               hour = hour % 12 || 12;
       
               return `${hour}:${m} ${ampm}`;
           }
       
           formatTime24(timeVal) {
               if (!timeVal) return null;
               if (timeVal.includes('T')) timeVal = timeVal.split('T')[1].replace('.000Z','');
               if (timeVal.includes('.')) timeVal = timeVal.split('.')[0];
               return timeVal.length === 5 ? timeVal + ':00' : timeVal;
           }                     

            openModal() {
                this.showModal = true;
            }

            handleYes() {
                this.showModal = false;
                this.updateAttendanceFinal();
                // Your logic here
                console.log('Yes clicked');
            }

            handleNo() {
                this.showModal = false;
                console.log('No clicked');
            } 

            updateAttendanceFinal() {
               this.isLoading = true;
       
               updateFinalStudentAttendance({
                   examRoom: this.selected.assignmentName,
                   examDate: this.selected.examDate,
                   startTime: this.selected.examStart,
                   endTime: this.selected.examEnd,
                   programBatchName : this.selected.programBatchName
               })
               // eslint-disable-next-line consistent-return
               .then(result => {
                   if (result.startsWith('SUCCESS')) {
                       this.showToast({
                           title: 'Success',
                           message: result.replace('SUCCESS: ', 'Records Submitted Successfully'),
                           variant: 'success',
                           mode: 'pester'
                       });      
                     
                   }
                   else if (result.startsWith('INFO')) {
                       this.showToast({
                           title: 'Info',
                           message: result.replace('INFO: ', ''),
                           variant: 'info'
                       });
                   }
                   else {
                       this.showToast({
                           title: 'Error',
                           message: result.replace('ERROR: ', ''),
                           variant: 'error',
                           mode: 'sticky'
                       });
                   }                      
                   this.isSuccess = false;
               })
               .catch(error => {
                   console.error(error);
                   this.showToast({
                       title: 'Error',
                       message: 'Unexpected system error',
                       variant: 'error',
                       mode: 'sticky'
                   });
               })
               .finally(() => {
                   this.isLoading = false;
               });
           }   
}