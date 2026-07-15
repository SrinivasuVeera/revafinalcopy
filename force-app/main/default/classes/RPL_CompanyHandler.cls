public class RPL_CompanyHandler {
	public static Set<String> disallowedTags = new Set<String>{
		'<script>',
		'<div>',
		'<iframe>',
		'<style>',
		'<a>',
		'<form>',
		'<input>',
		'<h1>',
		'<h2>',
		'<h3>',
		'<h4>',
		'<h5>',
		'<h6>'
	};

	public static void companyImageUpdateAndValidation(
		List<Rpl_Company__c> companyList,
		Map<Id, Rpl_Company__c> oldTriggerMap
	) {
		try {
			if (Trigger.isInsert && Trigger.isBefore) {
				for (Rpl_Company__c eachCompany : companyList) {
					if (eachCompany.Company_Image__c != null) {
						for (String tag : disallowedTags) {
							if (eachCompany.Company_Image__c.containsIgnoreCase(tag)) {
								eachCompany.addError('Company Image Can Contain Only Images!');
							}
						}
						Integer closingBracketIndex = eachCompany.Company_Image__c.indexOf('></img>');
						if (closingBracketIndex != -1) {
							String beforeClosingBracket = eachCompany.Company_Image__c.substring(
								0,
								closingBracketIndex
							);
							String modifiedHtml =
								beforeClosingBracket + ' style="height: 135px; width: 135px;"></img>';
							eachCompany.Company_Image__c = modifiedHtml;
						}
					}
				}
			}

			if (Trigger.isUpdate && Trigger.isBefore) {
				for (Rpl_Company__c eachCompany : companyList) {
					if (
						eachCompany.Company_Image__c != oldTriggerMap.get(eachCompany.Id).Company_Image__c &&
						eachCompany.Company_Image__c != null
					) {
						for (String tag : disallowedTags) {
							if (eachCompany.Company_Image__c.containsIgnoreCase(tag)) {
								eachCompany.addError('Company Image Can Contain Only Images!');
							}
						}

						Integer closingBracketIndex = eachCompany.Company_Image__c.indexOf('></img>');
						if (closingBracketIndex != -1) {
							String beforeClosingBracket = eachCompany.Company_Image__c.substring(
								0,
								closingBracketIndex
							);
							String modifiedHtml =
								beforeClosingBracket + ' style="height: 135px; width: 135px;"></img>';
							eachCompany.Company_Image__c = modifiedHtml;
						}
					}
				}
			}
		} catch (Exception ex) {
			ErrorLogUtility.logError(ex);
		}
	}
}