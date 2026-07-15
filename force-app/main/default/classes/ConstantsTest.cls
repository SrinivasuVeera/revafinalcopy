@isTest
private class ConstantsTest {

    @isTest
    static void testConstants() {
        // Test String constants
        System.assertEquals('Booked', Constants.Booked, 'Booked constant should match expected value');
        System.assertEquals('Room Allotted', Constants.Room_Allotted, 'Room Allotted constant should match expected value');
        System.assertEquals('Student', Constants.Student, 'Student constant should match expected value');
        System.assertEquals('Applicant', Constants.Applicant, 'Applicant constant should match expected value');
        System.assertEquals('Student Portal Profile', Constants.StudentPortalProfile, 'Student Portal Profile constant should match expected value');
        System.assertEquals('Non Teaching Profile', Constants.NonTeachingStaffProfile, 'Non Teaching Profile constant should match expected value');
        System.assertEquals('Non-Teaching Staff', Constants.NonTeachingStaff, 'Non-Teaching Staff constant should match expected value');
        System.assertEquals('Professor', Constants.TeachingStaff, 'Professor constant should match expected value');
        System.assertEquals('Applicant Profile', Constants.ApplicantProfile, 'Applicant Profile constant should match expected value');
        System.assertEquals('Student Profile', Constants.StudentProfile, 'Student Profile constant should match expected value');
        
        // Test Integer constant
        System.assertEquals(0, Constants.baseIndex, 'baseIndex constant should match expected value');
    }
}