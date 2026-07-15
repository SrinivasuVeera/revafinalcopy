public class ProgrambatchFirstNumberic {
 @InvocableMethod(label='Extract First Four Numeric Characters' description='Extracts the first four numeric characters from a given string')
    public static List<String> extractFirstFourNumbers(List<Request> inputRequests) {
        List<String> output = new List<String>();

        // Loop through each input request
        for (Request request : inputRequests) {
            if (request.textInput != null) {
                // Extract only numeric characters
                String numericCharacters = request.textInput.replaceAll('[^0-9]', '');
                
                // Get the first four numeric characters
                if (numericCharacters.length() > 4) {
                    output.add(numericCharacters.substring(0, 4));
                } else {
                    output.add(numericCharacters);  
                }
            } else {
                output.add('');  
            }
        }
        return output;  
    }
 
    public class Request {
        @InvocableVariable(required=true label='Text Input')
        public String textInput;  // Input string from Flow
    }
}