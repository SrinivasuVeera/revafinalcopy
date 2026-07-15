public class RPL_SendWhatsappNotificationBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
	Map<String, Map<String, String>> mapData;

	public RPL_SendWhatsappNotificationBatch(Map<String, Map<String, String>> data) {
		this.mapData = data;
	}

	public Iterable<String> start(Database.BatchableContext bc) {
		// Convert map keys to list of strings and return as iterable
		return mapData.keySet();
	}

	public void execute(Database.BatchableContext bc, List<String> scope) {
		// Process the scope list in execute method
		// Here, scope is a list of keys from the map
		for (String key : scope) {
			Map<String, Map<String, String>> finalData = new Map<String, Map<String, String>>();
			Map<String, String> innerMap = mapData.get(key);
			String whatsAppType = innerMap.get('whatsAppType');
			finalData.put(key, innerMap);
			try {
				Rpl_UtilityClass.sendWhatsAppNotification(whatsAppType, finalData);
			} catch (Exception e) {
				ErrorLogUtility.logError(e);
			}
		}
	}

	public void finish(Database.BatchableContext bc) {
	}
}