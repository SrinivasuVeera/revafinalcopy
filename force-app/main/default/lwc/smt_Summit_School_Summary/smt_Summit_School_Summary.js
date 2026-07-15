import { LightningElement, track } from 'lwc';

export default class Smt_Summit_School_Summary extends LightningElement {

    @track currentScreen = 1;
    selectedMonth;
    filteredFaculties = [];
    selectedFacultyName;
    selectedFacultyDetails = [];


    schoolData = {
        target: 3000,
        achieved: 2650,
        percentage: 88
    };

    teams = [
        { id: 1, name: 'Team A', target: 1500, achieved: 1350, percentage: 90 },
        { id: 2, name: 'Team B', target: 1500, achieved: 1300, percentage: 87 }
    ];

    months = [
        { id: 1, name: 'January', target: 200, achieved: 180, percentage: 90 },
        { id: 2, name: 'February', target: 180, achieved: 160, percentage: 89 },
        { id: 3, name: 'March', target: 220, achieved: 200, percentage: 91 },
        { id: 4, name: 'April', target: 210, achieved: 190, percentage: 90 },
        { id: 5, name: 'May', target: 230, achieved: 210, percentage: 91 },
        { id: 6, name: 'June', target: 240, achieved: 220, percentage: 92 },
        { id: 7, name: 'July', target: 250, achieved: 230, percentage: 92 },
        { id: 8, name: 'August', target: 260, achieved: 240, percentage: 92 },
        { id: 9, name: 'September', target: 270, achieved: 250, percentage: 93 },
        { id: 10, name: 'October', target: 280, achieved: 260, percentage: 93 },
        { id: 11, name: 'November', target: 290, achieved: 265, percentage: 91 },
        { id: 12, name: 'December', target: 300, achieved: 280, percentage: 93 }
    ];

    faculties = [
        { id: 1, month: 'January', name: 'A Ajil', target: 100, achieved: 90, percentage: 90 },
        { id: 2, month: 'January', name: 'Dhananjay B', target: 100, achieved: 85, percentage: 85 },
        { id: 3, month: 'February', name: 'Sameer K', target: 90, achieved: 80, percentage: 89 },
        { id: 4, month: 'February', name: 'Harish G', target: 90, achieved: 80, percentage: 89 },
        { id: 5, month: 'March', name: 'Madhayya H', target: 110, achieved: 100, percentage: 91 },
        { id: 6, month: 'March', name: 'Ajith M', target: 110, achieved: 100, percentage: 91 },
        { id: 7, month: 'April', name: 'Gunashekhara B', target: 105, achieved: 95, percentage: 90 },
        { id: 8, month: 'April', name: 'Sneha M', target: 105, achieved: 95, percentage: 90 },
        { id: 9, month: 'May', name: 'Kantiraj Channappa', target: 115, achieved: 105, percentage: 91 },
        { id: 10, month: 'May', name: 'Mallesh M K', target: 115, achieved: 105, percentage: 91 },
        { id: 11, month: 'June', name: 'Balayya R', target: 120, achieved: 110, percentage: 92 },
        { id: 12, month: 'June', name: 'Vinodkumar Balesh', target: 120, achieved: 110, percentage: 92 },
        { id: 13, month: 'July', name: 'Nagineni Chaitanya', target: 125, achieved: 115, percentage: 92 },
        { id: 14, month: 'July', name: 'Vasudevan M K', target: 125, achieved: 115, percentage: 92 },
        { id: 15, month: 'August', name: 'Santoshkumar N M', target: 130, achieved: 120, percentage: 92 },
        { id: 16, month: 'August', name: 'Vinodkumar K L', target: 130, achieved: 120, percentage: 92 },
        { id: 17, month: 'September', name: 'Johnson Bole', target: 135, achieved: 125, percentage: 93 },
        { id: 18, month: 'September', name: 'Basavaraj A P', target: 135, achieved: 125, percentage: 93 },
        { id: 19, month: 'October', name: 'Ajith Malur', target: 140, achieved: 130, percentage: 93 },
        { id: 20, month: 'October', name: 'Naveen Kumar Gowda', target: 140, achieved: 130, percentage: 93 },
        { id: 21, month: 'November', name: 'Billesha Tumkur', target: 145, achieved: 132, percentage: 91 },
        { id: 22, month: 'November', name: 'Michel B', target: 145, achieved: 133, percentage: 92 },
        { id: 23, month: 'December', name: 'Swaroop T', target: 150, achieved: 140, percentage: 93 },
        { id: 24, month: 'December', name: 'Jitendra Bolenath', target: 150, achieved: 140, percentage: 93 }
    ];

  /*  facultyDetail = {
        name: 'Faculty A',
        section: 'Academics',
        particular: 'Academic Calendar',
        target: 100,
        achieved: 90,
        percentage: 90
       // path: 'School > Team A > January > Faculty A'
    }; */

    facultyDetailsData = [
        {
            facultyName: 'Faculty A',
            details: [
                { id: 1, section: 'Section A', particular: 'Math', target: 40, achieved: 35, percentage: 88, path: 'Math > Algebra' },
                { id: 2, section: 'Section B', particular: 'Science', target: 30, achieved: 28, percentage: 93, path: 'Science > Physics' },
                { id: 3, section: 'Section C', particular: 'English', target: 30, achieved: 27, percentage: 90, path: 'English > Grammar' }
            ]
        },
        {
            facultyName: 'Faculty B',
            details: [
                { id: 4, section: 'Section A', particular: 'Math', target: 50, achieved: 45, percentage: 90, path: 'Math > Geometry' },
                { id: 5, section: 'Section B', particular: 'Science', target: 30, achieved: 26, percentage: 87, path: 'Science > Chemistry' },
                { id: 6, section: 'Section C', particular: 'Social', target: 20, achieved: 18, percentage: 90, path: 'Social > History' }
            ]
        }
    ];
    

    get isScreen1() { return this.currentScreen === 1; }
    get isScreen2() { return this.currentScreen === 2; }
    get isScreen3() { return this.currentScreen === 3; }
    get isScreen4() { return this.currentScreen === 4; }
    get isScreen5() { return this.currentScreen === 5; }

    goToScreen2() {
        this.currentScreen = 2;
    }

    openTeam() {
        this.currentScreen = 3;
    }

    openMonth(event) {
        const monthId = event.target.dataset.id;
        const selected = this.months.find(m => m.id == monthId);
        this.selectedMonth = selected.name;
        this.filteredFaculties = this.faculties.filter(f => f.month === this.selectedMonth);
        this.currentScreen = 4;
    }

    openFaculty(event) {
        const facultyId = event.target.dataset.id;
        const faculty = this.filteredFaculties.find(f => f.id == facultyId);
    
        this.selectedFacultyName = faculty.name;
    
        const detailObj = this.facultyDetailsData.find(
            f => f.facultyName === this.selectedFacultyName
        );
    
        this.selectedFacultyDetails = detailObj ? detailObj.details : [];
    
        this.currentScreen = 5;
    }
    

    goBack() {
        this.currentScreen -= 1;
    }
}