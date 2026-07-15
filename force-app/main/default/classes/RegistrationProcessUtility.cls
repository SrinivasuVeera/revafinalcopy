public without sharing class RegistrationProcessUtility {
  private static final Integer APPLICATION_NUMBER_SEQ_LENGTH = 5;
  private static final String PAD_STRING = '0';
  private static final String CACHE_NAME = 'local.DefaultCache';
  private static final String COUNSELOR_INDEX_KEY = 'CounselorIndex';
  private static final Integer CACHE_TTL_48_Hours = 48 * 60 * 60;

  private static final Integer CHALLAN_NUMBER_SEQ_LENGTH = 6;

  private static final String SEQUENCE_KEY_CET = 'CDK';
  private static final Integer CET_SEQ_LENGTH = 5;

  public static String generateApplNoSequence(String applNoPrefix){
      return  getApplNumSeqStr(getNextSequence(applNoPrefix));
  }

  public static String generateChallanNoSequence(String challanNoPrefix){
    return  getChallanNumSeqStr(getNextSequence(challanNoPrefix));
  }

  public static String getApplNumSeqStr(Integer seq) {
      String seqStr = seq + ''; //convert number to string
      return(seqStr.leftPad(APPLICATION_NUMBER_SEQ_LENGTH, PAD_STRING));
  }

  public static String getChallanNumSeqStr(Integer seq) {
    String seqStr = seq + ''; //convert number to string
    return(seqStr.leftPad(CHALLAN_NUMBER_SEQ_LENGTH, PAD_STRING));
  }

  /**
   * Pass in program type - UG, PG, or D
   * Returns string in the format UGCET23-00001
   */
  public static String getCETApplicationNumber(String programType , String admissionMode) {
 String enrolmentYear = String.valueOf(Integer.valueOf(RegistrationFormUtility.getCurrentEnrolmentYear())-0);
   /* Every Month july Add comment on above line.
    * Every Year November 1st Add Comment on Below Line.
    * Every month november 1st we changed the currentEnrollemnt Year but GOVT Quota Admissions Still Continue on Junvary.
  */ 
//String enrolmentYear = String.valueOf(Integer.valueOf(RegistrationFormUtility.getCurrentEnrolmentYear()));
      String seqStr = getNextSequence(admissionMode) + ''; //Convert number to string
      if(admissionMode == 'PGCET' || admissionMode == 'DCET' ){
           return (admissionMode + enrolmentYear.substring(2) + 
            seqStr.leftPad(CET_SEQ_LENGTH, PAD_STRING)); 
      }
      else if(admissionMode == 'CET') {
   			 return (programType + admissionMode + enrolmentYear.substring(2) + 
           	 seqStr.leftPad(CET_SEQ_LENGTH, PAD_STRING));
      }
      else{
          
          return (programType + SEQUENCE_KEY_CET + enrolmentYear.substring(2) + 
           	 seqStr.leftPad(CET_SEQ_LENGTH, PAD_STRING));
      }
  }

  public static Integer getNextSequence(String applicationNumberPrefix) {
      Integer nextSequence;
      //Query and lock the object
      List<Sequence_Number__c> seqNums = [select Integer_Five__c
                                          from Sequence_Number__c
                                          where Key_Field__c = :applicationNumberPrefix
                                          FOR UPDATE];
      if (seqNums.size() < 1) {
        Sequence_Number__c sn = new Sequence_Number__c();
        sn.Key_Field__c = applicationNumberPrefix;
        sn.Integer_Five__c = 0;
        insert sn;
        seqNums.add(sn);
        //Handle error
        // System.debug('inside if getNextSequence '+seqNums.size());
      }
      System.debug('outside getNextSequence '+seqNums.size());
      nextSequence = (Integer)seqNums[0].Integer_Five__c + 1;
      seqNums[0].Integer_Five__c = nextSequence;

      update(seqNums);

      return nextSequence;
  }
  
  /*
  * This method uses Platform Cache to get index of the counselor
  * to whom the next Lead or Contact has to be assigned. 
  */
  public static Integer getCounselorIndex() {
    Cache.OrgPartition orgPartition = Cache.Org.getPartition(CACHE_NAME);
    Integer counselorIndex = (Integer)orgPartition.get(COUNSELOR_INDEX_KEY);

    if (counselorIndex == null) {
      System.debug('>>>> Cache miss. Returning default counselorIndex -1');
      counselorIndex = -1;
      RegistrationProcessUtility.setCounselorIndex(counselorIndex);
    }
    return counselorIndex;
  }

  /*
  * This method uses Platform Cache to set index of the counselor
  * to whom the last Lead or Contact was assigned. 
  */
  public static void setCounselorIndex(Integer counselorIndex) {
    Cache.Org.getPartition(CACHE_NAME).put(COUNSELOR_INDEX_KEY, counselorIndex, CACHE_TTL_48_Hours);
  }
}