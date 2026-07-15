import { LightningElement,track } from 'lwc';
import searchCourses from '@salesforce/apex/OpenElectiveProfessorAllotment_Ctrl.getCourses';
import getSemesters from '@salesforce/apex/OpenElectiveProfessorAllotment_Ctrl.getSemesters';
import getFaculty from '@salesforce/apex/OpenElectiveProfessorAllotment_Ctrl.getFaculty';
import saveConnections from '@salesforce/apex/OpenElectiveProfessorAllotment_Ctrl.createFacultyCourseConnections';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpenElectiveProfessorAllotment extends LightningElement {
    @track searchTerm = '';
    @track searchProf='';
    @track courses = [];
    @track semesters = [];
    @track faculty = [];
    @track selectedCourse='';
    @track selectedProf='';
    @track selectedCourseId = '';
    @track assignedProf = [];
    @track ChangedCourseType = '';
    @track opensearchCourse = false;
    @track isLoading=false;
    @track showsave = false;
    @track courseType =[{value: 'Open Elective', label: 'Open Elective',},{value: 'RBS Specialization', label: 'RBS Specialization'}];

    handleCourseTypeChange(event){
        this.showsave = false;
        this.selectedCourse = '';
        this.semesters =[];
        this.ChangedCourseType = event.target.value;
        this.opensearchCourse = true;
    }
    handleSearch(event) {
        this.searchTerm = event.target.value;
        console.log('Search Term:', this.searchTerm);
        console.log('Course Category:', this.ChangedCourseType);
        if (this.searchTerm.length > 2) {
            searchCourses({ searchTerm: this.searchTerm , courseCat: this.ChangedCourseType })
                .then(result => {
                    this.courses = result;
                    console.log('this.courses',this.courses);
                })
                .catch(error => {
                    console.error('Error fetching courses:', error);
                });
        }else {
            this.courses = []; // Hide dropdown when search term is too short
        }
    }
    selectCourse(event) {
      console.log('Target:', event.target.dataset);
         this.selectedCourseId = event.target.dataset.id;
        this.selectedCourse = event.target.dataset.name;
        this.searchTerm = this.selectedCourse;
        this.courses = [];
        console.log('Selected Course:', this.selectedCourseId);
        console.log('Selected Course1:', this.selectedCourse);
        this.loadSemesters();
    }
    loadSemesters() {
        getSemesters({courseId: this.selectedCourseId})
            .then(result => {
                this.semesters = result;
                if(result.length){
                    this.showsave = true;
                }
                console.log('line 47 ',this.semesters);
                this.semesters = result.map(fac => ({
                    ...fac, // Preserve existing properties
                    searchValue: fac.Course_Connections__r && fac.Course_Connections__r.length > 0
                    ? (fac.Course_Connections__r[0].hed__Contact__r 
                     ? fac.Course_Connections__r[0].hed__Contact__r.Name 
                     : '')  // Handle missing hed__Contact__r
                     : ''  // Default value if no Course_Connections__r exist
                }));

                console.log('Updated semesters:', JSON.stringify(this.semesters, null, 2));
                 this.assignedProf = result.map(sem => {
                    return {
                        semesterName: sem.Name,
                        Professor: sem.Course_Connections__r && sem.Course_Connections__r.length > 0
                          ? (sem.Course_Connections__r[0].hed__Contact__r 
                          ? sem.Course_Connections__r[0].hed__Contact__r.Id 
                          : '')  // Handle missing hed__Contact__r
                          : '',  // Default empty string if no Course Connections exist
                        courseconnection: sem.Course_Connections__r && sem.Course_Connections__r.length > 0
                                           ? sem.Course_Connections__r[0].Id : ''
                    };
                  });



                console.log('Updated semesters:', this.semesters);
                console.log(result[0].Name);
                
                console.log('this.semesters',this.semesters[0].searchValue);
                console.table('assignedProf',JSON.stringify(this.assignedProf));
                console.log('assignedProf Type:', typeof this.assignedProf);
                console.log('First Element Type:', typeof this.assignedProf[0]);
            
                console.table('assignedProf',this.assignedProf);
                console.log('assignedProf Type:', typeof this.assignedProf);
                console.log('First Element Type:', typeof this.assignedProf[0]);

            })
            .catch(error => {
                console.error('Error loading semesters:', error);
            });
    }
    handleprofSearch(event) {
       
        const index = event.target.dataset.index;
         this.assignedProf[index].Professor='';
        const searchVal = event.target.value;
        this.semesters[index].searchValue = searchVal;
    
        if (searchVal.length > 2) {
            getFaculty({ searchProf: searchVal })
                .then(result => {
                    this.semesters[index].facultyList = result;
                    this.semesters[index].showDropdown = result.length > 0;
                })
                .catch(error => {
                    this.semesters[index].facultyList = [];
                    this.semesters[index].showDropdown = false;
                });
        } else {
            this.semesters[index].facultyList = [];
            this.semesters[index].showDropdown = false;
        }
    }
    selectProfessor(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.dataset.name;
        const index = event.currentTarget.dataset.index;
    
        this.semesters[index].searchValue = selectedName;
        this.semesters[index].showDropdown = false;
        const existingAssignment = this.assignedProf.find(assignment => {
                console.log('Checking:', assignment.Professor, 'vs', selectedId);
                return assignment.Professor === selectedId;
        });
        console.log('existingAssignment',existingAssignment);
            if(existingAssignment){
                const evt = new ShowToastEvent({
                title: 'Error',
                message: 'This assignment already exists.',
                variant: 'error'
               });
                this.dispatchEvent(evt);
                this.assignedProf[index].Professor='';
                this.semesters[index].searchValue = '';
            }else{
               this.assignedProf[index].Professor=selectedId;
            }
        
        console.table('assignedProf-->',this.assignedProf[index].semesterName);
        
        this.semesters = [...this.semesters];
    }
    
    handleSubmit(){
        
            let ProfessorAssignments = [];
            console.log('assignedProf length-->',this.assignedProf.length);
            console.log('assignedProf-->',this.assignedProf[0].Professor);
            // Check if any room assignments do not have a selected professor
            const unassignedSemesers = this.assignedProf.filter(record => record.Professor === '');
            console.table('table',unassignedSemesers.length);

            if (unassignedSemesers.length !=0) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a professor for all groups',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                return; // Stop further execution
            }else{
                this.isLoading=true;
                const finalresult = JSON.stringify(this.assignedProf);
                saveConnections({facultyConnections: finalresult})
                .then(result => {
                     const evt = new ShowToastEvent({
                    title: 'Sucess',
                    message: 'Professor alloted sucessfully.',
                    variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    window.location.reload();
                })
                .catch(error => {
                console.error('Error loading semesters:', error);
            });
                

            }
    }
    
     
}