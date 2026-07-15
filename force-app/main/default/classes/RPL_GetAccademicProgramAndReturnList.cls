public class RPL_GetAccademicProgramAndReturnList {
    
    @InvocableMethod(label = 'Get String Input And Output List Of Strings')
    public static List<List<String>> activateRevaPlacement(List<String> input) {
        List<List<String>> result = new List<List<String>>{ input[0].split(',')};
        return result;
    }
}