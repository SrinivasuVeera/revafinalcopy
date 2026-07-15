import { LightningElement, api, track, wire } from 'lwc';
import fileUploaded from "@salesforce/resourceUrl/FileUploaded";
import updateFileName from '@salesforce/apex/ApplicantDocumentUpload.updateFileName'
import deleteFile from '@salesforce/apex/ApplicantDocumentUpload.deleteFile'
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFiles from '@salesforce/apex/ApplicantDocumentUpload.uploadFiles';
import getFileTypes from '@salesforce/apex/ApplicantDocumentUpload.getFileTypes';
import getCurrentFiles from '@salesforce/apex/ApplicantDocumentUpload.getCurrentFiles';
import getEducationHistories from '@salesforce/apex/ApplicantDocumentUpload.getEducationHistories';
import ID_FIELD from '@salesforce/schema/hed__Application__c.Id';
import PO_FULLY_SIGNED_FIELD from '@salesforce/schema/hed__Application__c.PO_Fully_Signed__c';
import PO_SIGNED_BY_APPLICANT_FIELD from '@salesforce/schema/hed__Application__c.PO_Signed_By_Applicant__c';
import { updateRecord } from 'lightning/uiRecordApi';
import sendPOFullySignedDoc from '@salesforce/apex/AdmissionsProcessUtility.sendPOFullySignedDoc';
import getProgramType from'@salesforce/apex/ApplicantDocumentUpload.getProgramType'
//import notifyUsers from '@salesforce/apex/CustomNotificationFromApex.notifyUsers';
import contactCategory from'@salesforce/apex/ApplicantDocumentUpload.contactCategory'
export default class ApplicantDocuments extends LightningElement {

  @api recordId;
  @api applicationId;
  @api maxFileSize = 5145728; //5 Mb - can be changed in LWC configuration  
  // @api maxFileSize = 3145728;
  @api useLocation = 'primaryApplication';
  @api photoCapture = false;
  //@api useLocation = 'StudentApplication';

  @track filesToUpload = [];
  @track fileTypes;
  @track currentFiles = [];
  progType;err
  passPicUploaded = false;
  picture = fileUploaded;
  uploadedFiles
  isUpdateSuccess
  @track availableFiles = []
  isError
  tenth = false;
  twelfth = false;
  Rank = false;
  Study = false;
  contentVerId
  isPassPicUploaded = false
  isUploadPhoto = false
  isCapturePhoto = false
  @track isValidCategory = false; 
  @track studentCountry ;

  isUG=true; isPG = false; isPhd = false; KSETM = false; SETM = false; NETM = false; DegreeMarks = false; DegreeCertificate = false;
  PgDegreeMarksCard = false; PgDegreeCertificate = false; MPhillCertificate = false; 
  

  //Message for duplicate document upload 
  message = 'File type is already selected please select different file type';
  variant = 'error';

  _wiredCurrentFiles;
  // fileAttached = false;
  fileData; 
  @track applicantPhoto
  selectedFileType = 'Passport Photo'; //on picklist
  selectFileType='';
  fileType = ''; //chosen file's type
  loading = true;
  
  @wire(getEducationHistories, {contactId: '$recordId'}) educationHistories;
 
  @wire(getFileTypes,{useLocation:'$useLocation',contactId: '$recordId'}) wiredFileTypes({data, error}) {
    
    if (data) {
      this.fileTypes = data.map(option => {
        return {label: option, value: option}
      })
      // console.log('fileTypes', JSON.stringify(this.fileTypes));
    }else if (error){
      console.log('An error has occurred:');
      console.log(error);
    }
  }
  get options() {
    return [
        { label: 'Upload Applicant Photo', value: 'Upload Applicant Photo' },
        { label: 'Capture Applicant Photo', value: 'Capture Applicant Photo' },
    ];
  }

  @wire(contactCategory, { contactId: '$recordId' })
  wiredContactCategory({ data, error }) {
      if (data ) {
         const isValid = data.isValidCategory;
        const iscountry = data.country;
        console.log('isValid :'+isValid);
         console.log('country :'+iscountry);
          if (isValid === true) {
          this.isValidCategory =  true;
            this.studentCountry = true;
      
           }if(iscountry === 'Bhutan' || iscountry === 'Nepal'){
            this.studentCountry = false;
           }
           console.log(' this.studentCountry :'+ this.studentCountry);
      } 
      else if (error) {
          console.error('contactCategory error:', error);
          this.isValidCategory = false;
      }
  }


  handlePhotoChange(event){
    this.applicantPhoto = event.target.value
    console.log('===============================================', this.applicantPhoto)
    if(this.applicantPhoto === 'Upload Applicant Photo'){
      console.log('inside if ')
      this.isUploadPhoto = true
      this.isCapturePhoto = false
    }else{
      console.log('inside else ')
      this.isCapturePhoto = true
      this.isUploadPhoto = false
    }
  }

  @wire(getCurrentFiles, {contactId: '$recordId'}) 
    wiredCurrentFiles(result) {
      debugger
      this._wiredCurrentFiles = result;
 
      console.log('Available Files------ ', JSON.stringify(this.availableFiles))
      console.log('Already Uploaded Files...........', this._wiredCurrentFiles)
      
      //this.recordId=this.applicationId
      if (result.data) {
        this.currentFiles = result.data;
        this.currentFiles.forEach(file => {
          if(file.fileType == 'Applicant Photo' || file.fileType == 'Passport Photo'){
            this.passPicUploaded = true
          }else{
            this.isPassPicUploaded = true
          }
          if(file.fileType == '10th/SSLC Marks Card'){
            this.tenth = true
          }
          if(file.fileType == '12th/PUC Marks Card'){
            this.twelfth = true
          }
          if(file.fileType == 'Caste Certificate'){
            this.Caste = true
          }
          if(file.fileType == 'Entrance Exam Rank Card'){
            this.Rank = true
          }
          if(file.fileType == 'Study Certificate'){
            this.Study = true
          }
          if(file.fileType == 'Passport'){
            this.Passport = true
          }
          if(file.fileType == 'Degree Marks Card'){
            this.DegreeMarks = true
          }
          if(file.fileType == 'Degree Certificate'){
            this.DegreeCertificate = true
          }
          if(file.fileType == 'MPhil Certificate'){
            this.MPhillCertificate = true
          }
          if(file.fileType == 'PG Degree MarksCard'){
            this.PgDegreeMarksCard = true
          }
          if(file.fileType == 'PD Degree Certificate'){
            this.PgDegreeCertificate = true
          }
          if(file.fileType == 'NET'){
            this.NETM = true
          }
          if(file.fileType == 'SET'){
            this.SETM = true
          }
          if(file.fileType == 'KSET'){
            this.KSETM = true
          }
        })
        //const fileTypes = this.currentFiles.map(file => file.fileType);
        //console.log('fileTypes', JSON.stringify(fileTypes))

        // console.log('Current files: ', JSON.stringify(this.currentFiles));
        // console.log(this.recordId);
        const getResult = this.currentFiles.find(({fileType})=>fileType==='PO Fully Signed');
        // console.log(getResult);
        const getPO = this.currentFiles.find(({fileType})=>fileType==='PO Signed by Applicant');
        // console.log(getPO);
       // this.recordId=this.applicationId;
        if(getResult){
          const fields = {};
          fields[ID_FIELD.fieldApiName] = this.applicationId;
          //console.log('this.filesToUpload=> ', this.selectFileType);      
          fields[PO_FULLY_SIGNED_FIELD.fieldApiName] = true;

          
          // console.log('PO_FULLY_SIGNED_FIELD =>', fields[PO_FULLY_SIGNED_FIELD.fieldApiName]);
        
          const recordInput = { fields };
          updateRecord(recordInput)
            .then(result => {
              
              // console.log('PO Uploaded Sucessfully')
              // console.log('this.filesToUpload=> ', this.selectFileType);
            })
            .catch(error => {
                console.log('PO Uploaded UnSucessfully');
            });
        }
        
        
        if(getPO){
          const fields = {};
          fields[ID_FIELD.fieldApiName] = this.applicationId;
          //console.log('this.filesToUpload=> ', this.selectFileType);      
          fields[PO_SIGNED_BY_APPLICANT_FIELD.fieldApiName] = true;
          // console.log('PO_SIGNED_BY_APPLICANT_FIELD =>', fields[PO_SIGNED_BY_APPLICANT_FIELD.fieldApiName]);
        
          const recordInput = { fields };
          updateRecord(recordInput)
            .then(result => {
              // console.log('PO By Applicant  Uploaded ')
              // console.log('this.filesToUpload=> ', this.selectFileType);
            })
            .catch(error => {
                console.log('PO By Applicant UnSucessfully');
            });
        }
        this.informOmniScript();
      }
      this.loading = false;
    };
  
  //getter to show selected file size
  get fileSizeDisp() {
    if (this.fileData) {
      const sizeInMb = this.fileData.fileSize / (1024 * 1024);
      // console.log('attached file sizeInMb '+sizeInMb);
      return `${sizeInMb.toFixed(2)} Mb`;
    } else {
      return 'NA';
    }
  }

  //Getter to show max file size message
  get maxFileSizeDisp() {
    const sizeInMb = this.maxFileSize / (1024 * 1024);
    // console.log('sizeInMb '+sizeInMb);
    return `Max file size allowed: ${sizeInMb.toFixed(2)} Mb`;
  }

  //Getter to disable/enable Add File button
  //Passport photo has to be image/jpeg or image/png
  //All other documents have to be application/pdf
  get fileNotUploadable() {
    // console.log('this.fileType ',this.fileType);
    // console.log('selected filedata data '+this.fileData.fileSize);
    // console.log('maxFileSize '+this.maxFileSize);
    return this.selectedFileType === '' || 
           ((this.selectedFileType === 'Passport Photo' && !this.fileType.startsWith('image')) ||
           (this.selectedFileType !== 'Passport Photo' && this.fileType !== 'application/pdf')) &&
           (this.selectedFileType !== 'Degree Marks Card - Semesterwise' && (this.fileType !=='application/zip' || 
            this.fileType !=='application/rar')) ||
           (this.selectedFileType === 'Degree Marks Card - Semesterwise' && this.fileType.startsWith('image')) ||
           this.fileData?.fileSize > this.maxFileSize;
  }

  //Getter to disable/enable Upload button & to show/hide selected files table
  get noFileAdded() {
    return this.filesToUpload.length === 0;
    
  }

  //Getter to show list of currently uploaded files
  get filesUploaded() {
    return this.currentFiles.length !== 0;
  }
  
  async CapturePhoto(){
    this.photoCapture = true;
    // this.fileAttached = false;
    const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
    const video = this.template.querySelector('video');
    video.srcObject = stream;
  }

  @wire(getProgramType, ({applicationId : '$applicationId'}))
  programType({data, error}){
    if(data){
      this.progType = data
      this.err = undefined
      console.log('progType',this.progType)
      if(this.progType == 'PG'){
        this.isPG = true
      }
      if(this.progType == 'Ph.D'){
        this.isPhd = true
      }
    }
    if(error){
      this.progType = undefined
      this.err = error
    } 
  }

  handleApplicantPhotoUpload() {
    debugger
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.passPicUploaded = true;
    const newFileName='Applicant Photo';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
    
}

  handleMarksCard10Upload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.tenth = true;
    const newFileName='10th/SSLC Marks Card';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleMarksCard12Upload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.twelfth = true;
    const newFileName='12th/PUC Marks Card';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleCasteCertificateUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.Caste = true;
    const newFileName = 'Caste Certificate';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleStudyCertificateUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });
    
    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.Study = true;
    const newFileName='Study Certificate';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

handlePassportUpload(){
  this.Passport = true;
 this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });
    
    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.Passport = true;
    const newFileName='Passport';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
}

  handleEntrenceExamRankCardUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

        
    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.Rank = true;
    const newFileName='Entrance Exam Rank Card';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleDegreeMarksCardUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.DegreeMarks = true;
    const newFileName='Degree Marks Card';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleDegreeCertificateUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.DegreeCertificate = true;
    const newFileName='Degree Certificate';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handlePG_MarksCardUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.PgDegreeMarksCard = true;
    const newFileName='PG Degree MarksCard';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handlePG_DergreeCertificateUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.PgDegreeCertificate = true;
    const newFileName='PD Degree Certificate';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleMPhilCertificateUpload(){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.MPhillCertificate = true;
    const newFileName='MPhil Certificate';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleNETUpload(){
    debugger
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.NETM = true;
    const newFileName='NET';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleSETUpload(event){
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.SETM = true;
    const newFileName='SET';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  handleKSETUpload(){
    debugger
    this.uploadedFiles = event.detail.files.map((file) => {
      return {
          cvID: file.contentVersionId,
          file_name: file.name
      };
    });

    // Debug to check if files are correctly mapped
    console.log('==========', JSON.stringify(this.uploadedFiles));
    this.KSETM = true;
    const newFileName='KSET';

    // Loop through uploaded files to send each cvID and file_name to the Apex method
    this.uploadedFiles.forEach(file => {
      console.log('Sending to Apex:', file.cvID, file.file_name);

      // Call Apex method with correct parameters
      updateFileName({ contVerID: file.cvID, fileName: newFileName, fileType : newFileName })
      .then(result => {
        console.log('Insert successful res:',result);
        this.isUpdateSuccess = result;
        this.isError = undefined
        if(this.isUpdateSuccess === 'success'){
          debugger
          console.log('=======================recId', this.recordId)
          deleteFile({contactId: this.recordId, fileName : newFileName, cvId : file.cvID})
          .then(result =>{
            console.log('No of Deleted Files: ', JSON.stringify(result))
            refreshApex(this._wiredCurrentFiles);
          })
          .catch(error=>{
            this.isUpdateSuccess = undefined
            this.isError = error.message
            console.log(this.isError)
          })
        }
      })
          .catch(error => {
              // Handle error
              console.error('Error updating file name:', error);
          });
    });
  }

  // capture image
  clickPhoto() {
    debugger
    const toastEvent = new ShowToastEvent({
      title: 'Success',
      message: ' photo captured successfully',
      variant: 'success'
  });
  this.dispatchEvent(toastEvent);
  var image_data_url;
  var file;
    const video = this.template.querySelector('video');
    const canvas = this.template.querySelector('canvas');
    canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
    // const image_data_url = canvas.toDataURL('image/jpeg');
    // this.file = new File([this.dataURLtoBlob(image_data_url)], "Passport-Photo.jpg", { type: 'image/jpeg' });

    // const blobData = this.dataURLtoBlob(image_data_url); 
   
    image_data_url = canvas.toDataURL('image/jpeg');
    file = new File([this.dataURLtoBlob(image_data_url)], "Application-Photo.jpg", { type: 'image/jpeg' });
              
    if(file.size > this.maxFileSize){
      const reducer = file.size - this.maxFileSize;
      const result = reducer / file.size;
      console.log('Reduced file size >>>' + result);
      image_data_url = canvas.toDataURL('image/jpeg', result);
      file = new File([this.dataURLtoBlob(image_data_url)], "Application-Photo.jpg", { type: 'image/jpeg' });
    }
    var reader = new FileReader();
    reader.onload = () => {
        var base64 = reader.result.split(',')[1]
        console.log('file name ',file.name, file.size, file.type);
        this.fileType = file.type;
        this.fileData = {
            'filename': file.name,
            'fileSize': file.size,
            'base64': base64, //File content
            'recordIds': [this.recordId, this.applicationId] //contact id
        }
    }
    //Read the file
    reader.readAsDataURL(file);
    const take = this.template.querySelector('.button-0');
    take.style.display = "none";
    this.photoCapture = false;
    console.log('inside photo capture ');
    console.log('on camera picture this.filedata.filesize '+this.fileData.fileSize);
    console.log('maximum allowed file size '+this.maxFileSize);
  }

    //Base64 to Blob to make it as a File for compressingdataURItoBlob(dataURI) {
      dataURItoBlob(dataURI) {
        const byteString = window.atob(dataURI.split(",")[1]);
        const arrayBuffer = new ArrayBuffer(byteString.length);
        const int8Array = new Uint8Array(arrayBuffer);
        for (let i = 0; i < byteString.length; i++) {
          int8Array[i] = byteString.charCodeAt(i);
        }
        const blob = new Blob([int8Array], { type: 'image/jpg' });    
        return blob;
      }

      //**dataURL to blob**
      dataURLtoBlob(dataurl) {
        var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
            bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
        while(n--){
            u8arr[n] = bstr.charCodeAt(n);
        }
        return new Blob([u8arr], {type:mime});
      }
      
      get picacceptedFormats() {
        return ['.jpg', '.png','.jpeg'];
    }

      get acceptedFormats(){
        return ['.pdf'];
      }

       get passportacceptedFormats(){
        return ['.pdf','.jpg', '.png','.jpeg'];
      }

  openFileUpload(event) {  
      // console.log('inside open file upload -->event-->',event);
      const file = event.target.files[0]; //We are allowing only one file to be selected
      console.log('inside open file upload -->file-->',file);
      console.log('maximum allowed file size from openFileUpload'+this.maxFileSize);
      var reader = new FileReader();
      //Asynchronously method that will be called when selected file data is available
      reader.onload = () => {
          var base64 = reader.result.split(',')[1]
          // console.log('file name ',file.name, file.size, file.type);
          // console.log('base64 is ',base64);
          this.fileType = file.type;
          this.fileData = {
              'filename': file.name,
              'fileSize': file.size,
              'base64': base64, //File content
              'recordIds': [this.recordId, this.applicationId] //contact id
          }
      }
      // console.log(file);
      //Read the file
      reader.readAsDataURL(file);
      // this.fileAttached = true;
      // console.log('the file data is from normal-->',reader.readAsDataURL(file));
      console.log('on selection of the file this.filedata.filesize '+this.fileData.fileSize);
      console.log('maximum allowed file size '+this.maxFileSize);
          // console.log('selected filedata data '+this.fileData.fileSize);
    // console.log('maxFileSize '+this.maxFileSize);
  }

  onFileTypeSelected(event) {
    this.selectedFileType = event.target.value;
    this.selectFileType=event.target.value;
    console.log('Selected File Type', this.selectedFileType);
  }

  /*onAddFile(event) {
    const newFile = {...this.fileData, fileType: this.selectedFileType};  
    //Check if there is a previous version of this file
    const existingFile = this.currentFiles.find(file => file.fileType === this.selectedFileType);
    if (existingFile) {
      newFile.contentDocumentId = existingFile.contentDocumentId;
    }
    
    //Check if there are relevant education histories to which the documents need to be attached
    let eduHistCourseType;
    //Map document type to edu history's type of course
    switch (this.selectedFileType) {
      case '10th/SSLC Marks Card':
        eduHistCourseType = '10th';
        break;
      case '12th/PUC Marks Card':
        eduHistCourseType = '12th';
        break;
      case 'Degree Marks Card':
        eduHistCourseType = 'UG';
        break;
      case 'Degree Marks Card - Semesterwise':
        eduHistCourseType = 'UG';
        break;
      default:
    }

    if (eduHistCourseType) {
      const eduHistRecord = this.educationHistories.data.find(eduHist => eduHist.courseType === eduHistCourseType);
      if (eduHistRecord) {
        newFile.recordIds.push(eduHistRecord.eduHistoryId);
      }
    }
    
    
    console.log('filestoupload:',JSON.stringify(this.filesToUpload));
    const getFileResult = this.filesToUpload.find(({fileType})=>fileType==newFile.fileType);
    if(!getFileResult)
    {
      this.filesToUpload.push(newFile);
    }
    else{
     
      const evt = new ShowToastEvent({
        message: this.message,
        variant: this.variant,
    });
    this.dispatchEvent(evt);
    }
    
    //
   
    this.fileData = null;
   
    //this.fileTypes = this.fileTypes.filter(fileType => fileType.value !== this.selectedFileType);
    
    
  }*/
 

  onRemoveFile(event) {
    const fileType = event.target.getAttribute('data-pk');
    //this.fileTypes.push({label: fileType, value: fileType});
    this.filesToUpload = this.filesToUpload.filter(file => file.fileType !== fileType);
    
  }
  
  handleUpload() {
    const f = this.filesToUpload[0];
    const fileTypePassport = 'Applicant Photo';
    // console.log(f.filename, f.fileType, f.recordIds. f.contentDocumentId, f.fileSize);
    console.log('inside handle upload 325',JSON.stringify(this.fileData));
    const newFile = {...this.fileData, fileType: this.selectedFileType}; 
    console.log('newFile'+newFile); 
    //Check if there is a previous version of this file
    console.log('this.currentFiles---',JSON.stringify(this.currentFiles));
    console.log('this.selectedFileType'+this.selectedFileType);
    const existingFile = this.currentFiles.find(file => file.fileType === fileTypePassport);
    console.log('Contact id '+this.recordId);
    console.log('Existing File ----'+JSON.stringify(existingFile));
    const matchingFiles = this.currentFiles.find(file => file.fileType === fileTypePassport);
    if (matchingFiles) {
      console.log('Matching files found:', JSON.stringify(matchingFiles));
              
  } else {
      console.log('No matching files found. Proceeding with upload.');
      // Handle logic for uploading the new file
  }
    if (existingFile) {
      newFile.contentDocumentId = existingFile.contentDocumentId;
    }
    
    //Check if there are relevant education histories to which the documents need to be attached
    let eduHistCourseType;
    //Map document type to edu history's type of course
    switch (this.selectedFileType) {
      case '10th/SSLC Marks Card':
        eduHistCourseType = '10th';
        break;
      case '12th/PUC Marks Card':
        eduHistCourseType = '12th';
        break;
      case 'Degree Marks Card':
        eduHistCourseType = 'UG';
        break;
      case 'Degree Marks Card - Semesterwise':
        eduHistCourseType = 'UG';
        break;
      default:
    }

    if (eduHistCourseType) {
      const eduHistRecord = this.educationHistories.data.find(eduHist => eduHist.courseType === eduHistCourseType);
      if (eduHistRecord) {
        newFile.recordIds.push(eduHistRecord.eduHistoryId);
      }
    }
    
    
    // console.log('filestoupload:',JSON.stringify(this.filesToUpload));
    const getFileResult = this.filesToUpload.find(({fileType})=>fileType==newFile.fileType);
    if(!getFileResult)
    {
      console.log('Inside file 364');
      console.log('files without new upload1: 375',JSON.stringify(this.filesToUpload));
      console.log('this.currentFiles',JSON.stringify(this.currentFiles));
      this.filesToUpload.push(newFile);
      console.log('files with new upload1: 375',JSON.stringify(this.filesToUpload));

    }
    else{
     
      const evt = new ShowToastEvent({
        message: this.message,
        variant: this.variant,
    });
    this.dispatchEvent(evt);
    }
    console.log('filestoupload1: 375',JSON.stringify(this.filesToUpload));
    //
   
    this.fileData = null;
   
    //this.fileTypes = this.fileTypes.filter(fileType => fileType.value !== this.selectedFileType);
    
    
    this.loading = true;
    console.log('384');
    uploadFiles({filesToUpload: this.filesToUpload})
      .then(result => {
        console.log('result-----'+JSON.stringify(result));
        
        this.filesToUpload = [];
        this.loading = false;
        console.log('389');
        if(this.selectedFileType =='PO Fully Signed'){
          window.location.reload();
          sendPOFullySignedDoc({applicationId:this.applicationId})
                  .then(result => {
              })
              .catch(error => {
                  this.error = error;
              });
        }
        console.log('Upload successful');
        refreshApex(this._wiredCurrentFiles);
      })
      .error(err => {
        console.log('403');
        console.log(err);
      });
   
    //Send Notification 

    // uploadFiles1({filesToUpload: JSON.stringify(this.filesToUpload)})
    //   .then(result => {
    //     this.filesToUpload = [];
    //     this.loading = false;
    //     console.log('389');
    //     if(this.selectedFileType =='PO Fully Signed'){
    //       window.location.reload();
    //       sendPOFullySignedDoc({applicationId:this.applicationId})
    //               .then(result => {
    //           })
    //           .catch(error => {
    //               this.error = error;
    //           });
    //     }
    //     console.log('Upload successful');
    //     refreshApex(this._wiredCurrentFiles);
    //   })
    //   .error(err => {
    //     console.log('403');
    //     console.log(err);
    //   });

    this.passPicUploaded = true
   
  }

//  informOmniScript() {
   
//     let photoUploaded = false;
//     const photoFile = this.currentFiles.find(file => file.fileType === 'Applicant Photo');
//       //'Passport Photo');
    
//     if (photoFile) {
//       photoUploaded = true;
//     }

//     const omniAggregateEvent = 'omniaggregate';
//     const data = photoUploaded;
//     const detail = {
//         data,
//         elementId: 'photoUploaded'
//     }
//     const myEvent = new CustomEvent(omniAggregateEvent, {
//         bubbles: true,
//         cancelable: true,
//         composed: true,
//         detail: detail,
//     });
//     console.log('Hello:'+JSON.stringify(detail));
//     console.log('Hello:'+ JSON.stringify(myEvent));
//     this.dispatchEvent(myEvent);

  
  //}


  informOmniScript() {
   
    let photoUploaded = false;
    let passportUploaded = false; 

    const photoFile = this.currentFiles.find(file => file.fileType === 'Applicant Photo');
      //'Passport Photo');
    
    if (photoFile) {
      photoUploaded = true;
    }

    const passportFile = this.currentFiles.find(file => file.fileType === 'Passport');
   console.log('Is photoFile:', photoFile);
   console.log('Is passportFile:',passportFile);
   console.log('Is studentCountry:', this.studentCountry);
    if (passportFile ) {
        passportUploaded = true;
    }
     console.log('Is photoUploaded:', this.photoUploaded);
   console.log('Is passportUploaded:',passportUploaded);

    const omniAggregateEvent = 'omniaggregate';
  
    //const data = photoUploaded;
    
    const photoDetail = {
        data : photoUploaded,
        elementId: 'photoUploaded'
    };

   this.dispatchEvent(new CustomEvent(omniAggregateEvent, {
        bubbles: true, cancelable: true, composed: true, detail: photoDetail
    }));
     console.log('Hello:'+JSON.stringify(photoDetail));
    // Event 2: passportUploaded  
    const passportDetail = {
        data: passportUploaded,
        elementId: 'passportUploaded'
    };
    this.dispatchEvent(new CustomEvent(omniAggregateEvent, {
        bubbles: true, cancelable: true, composed: true, detail: passportDetail
    }));
  console.log('Helloo:'+JSON.stringify(passportDetail));
    //Event 3
    const countryDetail = {
        data: this.studentCountry ,
        elementId: 'studentCountry'
    };
    this.dispatchEvent(new CustomEvent(omniAggregateEvent, {
        bubbles: true, cancelable: true, composed: true, detail: countryDetail
    }));
    console.log('Hellooo:'+JSON.stringify(countryDetail));
   // this.dispatchEvent(myEvent);

  
  }
}