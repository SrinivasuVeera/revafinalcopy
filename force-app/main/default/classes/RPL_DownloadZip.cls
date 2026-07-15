public without sharing class RPL_DownloadZip {
	@AuraEnabled(cacheable=true)
	public static List<Id> fetchRelatedFiles(List<String> recordIds, String fileNames) {
		if (recordIds.isEmpty()) {
			return new List<Id>();
		}
		Set<String> fileNameSet = new Set<String>(fileNames.split(';'));
		Set<Id> contentDocIds = new Set<Id>();
		List<Id> contentVersionIds = new List<Id>();
		for (ContentDocumentLink cdl : [
			SELECT ContentDocumentId
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :recordIds
		]) {
			contentDocIds.add(cdl.ContentDocumentId);
		}
		if (!contentDocIds.isEmpty() && contentDocIds.size() > 0) {
			String query = 'SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :contentDocIds AND IsLatest = true AND (';
			for (String fileName : fileNameSet) {
				query += 'Title LIKE \'%' + fileName + '%\' OR ';
			}
			query = query.substring(0, query.length() - 4);
			query += ')';

			List<ContentVersion> contentVersions = Database.query(query);

			for (ContentVersion cv : contentVersions) {
				contentVersionIds.add(cv.Id);
			}

			return contentVersionIds;
		}
		return contentVersionIds;
	}
}