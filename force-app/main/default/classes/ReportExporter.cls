public with sharing class ReportExporter {

    public class RequestWrapper {
        @InvocableVariable(required=true) public String reportId;
        @InvocableVariable(required=true) public String userEmail;
        @InvocableVariable(required=true) public String reportName;
    }

    @InvocableMethod(label='Export Report (Final Clean Version)')
    public static void sendReport(List<RequestWrapper> requests) {
        for (RequestWrapper req : requests) {
            generateCsv(req.reportId, req.userEmail, req.reportName);
        }
    }

    public static void generateCsv(String reportId, String userEmail, String reportName) {
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
        Reports.ReportMetadata metadata = results.getReportMetadata();
        Reports.ReportExtendedMetadata xmeta = results.getReportExtendedMetadata();

        // 1. ADD UTF-8 BOM (Byte Order Mark) - This fixes the strange symbols in Excel
        String csv = '\uFEFF'; 

        // 2. BUILD HEADERS
        List<String> headers = new List<String>();
        List<Reports.GroupingInfo> groupingsDown = metadata.getGroupingsDown();
        for (Reports.GroupingInfo gi : groupingsDown) {
            headers.add(cleanForCsv(xmeta.getGroupingColumnInfo().get(gi.getName()).getLabel()));
        }
        for (String apiName : metadata.getDetailColumns()) {
            headers.add(cleanForCsv(xmeta.getDetailColumnInfo().get(apiName).getLabel()));
        }
        csv += String.join(headers, ',') + '\n';

        // 3. EXTRACT DATA (Flattened)
        Reports.Dimension dimDown = results.getGroupingsDown();
        if (!dimDown.getGroupings().isEmpty()) {
            csv = traverseGroupings(dimDown.getGroupings(), results, 0, new List<String>(), csv);
        } else {
            csv = appendRows((Reports.ReportFactWithDetails)results.getFactMap().get('T!T'), new List<String>(), csv);
        }

        // 4. Send Email
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName(reportName.replaceAll('[^a-zA-Z0-9]', '_') + '.csv');
        // Encode as UTF-8
        attach.setBody(Blob.valueOf(csv));
        attach.setContentType('text/csv; charset=utf-8');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { userEmail });
        email.setSubject('Export: ' + reportName);
        email.setPlainTextBody('Your report data is attached. Groupings have been repeated for every row.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    @TestVisible private static String traverseGroupings(List<Reports.GroupingValue> groupings, Reports.ReportResults results, Integer level, List<String> parentGroupLabels, String csv) {
        for (Reports.GroupingValue gValue : groupings) {
            List<String> currentGroupLabels = new List<String>(parentGroupLabels);
            currentGroupLabels.add(cleanForCsv(gValue.getLabel()));

            if (level < results.getReportMetadata().getGroupingsDown().size() - 1) {
                csv = traverseGroupings(gValue.getGroupings(), results, level + 1, currentGroupLabels, csv);
            } else {
                String factKey = gValue.getKey() + '!T';
                csv = appendRows((Reports.ReportFactWithDetails)results.getFactMap().get(factKey), currentGroupLabels, csv);
            }
        }
        return csv;
    }

    @TestVisible private static String appendRows(Reports.ReportFactWithDetails fact, List<String> groupLabels, String csv) {
        if (fact == null || fact.getRows() == null) return csv;
        for (Reports.ReportDetailRow row : fact.getRows()) {
            List<String> rowValues = new List<String>(groupLabels);
            for (Reports.ReportDataCell cell : row.getDataCells()) {
                rowValues.add(cleanForCsv(cell.getLabel()));
            }
            csv += String.join(rowValues, ',') + '\n';
        }
        return csv;
    }

    // Helper to fix encoding, remove currency symbols, and handle commas
   @TestVisible private static String cleanForCsv(String val) {
        if (val == null) return '""';
        
        // Remove currency symbols (₹, etc) and hidden spaces to keep numbers clean
        // We replace the Indian Rupee symbol and common non-breaking spaces
        String cleaned = val.replace('₹', '').replace('â‚¹', '').trim();
        
        // Standard CSV escaping: wrap in quotes and escape internal quotes
        return '"' + cleaned.replace('"', '""') + '"';
    }
}