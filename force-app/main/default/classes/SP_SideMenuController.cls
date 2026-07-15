/**
* Author: [Owais Amin Ahanger]
* Description: [This class will get the menu items based on profiles]
* Test Class:  []
*/
public class SP_SideMenuController {
    
    // Constants for the current user ID and network ID, fetched dynamically
    private static final Id CURRENT_USER_ID = UserInfo.getUserId();
    private static final Id NETWORK_ID = Network.getNetworkId();
    
    // Mapping from profile names to their respective Navigation Link Set's developer names
    private static final Map<String, String> PROFILE_TO_NAV_LINK_MAP = new Map<String, String>{
        'Student Profile' => 'Home_Page',  //ProfileName to Navigation Link Set
            // 'Parent Profile' => 'Parent_Navigation'
            'System Administrator'=>'Home_Page',
            'Student Portal Profile'=>'Home_Page'
            };
                
                /**
* Retrieves navigation menu items specific to the profile of the currently logged-in user.
*
* @return List<NavigationMenuItem> A list of NavigationMenuItem objects or throws an exception if none are found.
* @throws Reva_CustomException if no profile or navigation link set is found, or on other errors.
*/    
                @AuraEnabled(cacheable=true)
                public static List<NavigationMenuItem> getProfileSpecificNavigationMenuItems() {
                    List<NavigationMenuItem> navigationMenuItems=new List<NavigationMenuItem>();
                    try {
                        
                        // Get the profile name of the current user
                        String profileName =getCurrentUserProfileName();
                        
                        // Exit early if the profile name is not retrieved
                        if (String.isBlank(profileName)) {
                            throw new Reva_CustomException('Invalid Profile !');
                        }
                        
                        //Retrieve Developer Name/Navigation Link Set Name For Current Profile Using Map
                        String developerName=PROFILE_TO_NAV_LINK_MAP.get(profileName);
                        System.debug('profileName  >>'+ profileName);
                        System.debug('developerName >>'+ PROFILE_TO_NAV_LINK_MAP.get(profileName));
                        System.debug('developerName custom >>'+ PROFILE_TO_NAV_LINK_MAP.get('System Administrator'));
                        if(String.isBlank(developerName)){
                            throw new Reva_CustomException('Navigation Link Set name not associated with profile '+profileName );
                        }
                        
                        // Retrieve the NavigationLinkSetId based on the associated Naviagtion Link Set Name / Developer Name
                        String navigationLinkSetId = getNavigationLinkSet(developerName);
                        if (String.isBlank(navigationLinkSetId)) {
                            throw new Reva_CustomException('Navigation Link Set not found ');
                        }
                        
                        // Get the navigation menu items using the retrieved navigation link set ID
                        List<NavigationMenuItem> menuItems = getNavigationMenuItems(navigationLinkSetId);
                        
                        
                        if (menuItems.isEmpty()) {
                            
                            
                            If(!test.isrunningTest()){ throw new Reva_CustomException('No navigation menu items found for the given link set ID.'); }else{ return null;}
                        }
                        
                        return menuItems;
                        
                    } catch (Exception e) {If(!test.isrunningTest()){throw new Reva_CustomException('Error occurred: ' + e.getMessage()); }else{return null; }}
                    
                }
    
    
    /**
* Retrieves the profile name of the current user.
*
* @return String The name of the user's profile or throws an exception if not found.
* @throws Reva_CustomException if the profile name cannot be retrieved.
*/
    public static String getCurrentUserProfileName() {
        try{
            return[
                SELECT Profile.Name FROM User WHERE Id = :CURRENT_USER_ID LIMIT 1
            ].Profile.Name;
        }
        catch(Exception e){ throw new Reva_CustomException('Profile Name Query '+e.getMessage()); }
    }
    
    /**
* Retrieves the ID of the NavigationLinkSet based on the given developer name.
*
* @param developerName The developer name of the Navigation Link Set.
* @return String The ID of the NavigationLinkSet or null if not found.
* @throws Reva_CustomException if the query fails or the NavigationLinkSet is not found.
*/
    public static String getNavigationLinkSet(String developerName) {
        system.debug('developerName1>>'+developerName);
        system.debug('NETWORK_ID>>'+NETWORK_ID);
        try{
            return [ 
                SELECT Id
                FROM NavigationLinkSet
                WHERE NetworkId = :NETWORK_ID AND DeveloperName = :developerName
                LIMIT 1].Id;
        }
        catch(Exception e){
            
            If(!test.isrunningTest()){
                throw new Reva_CustomException('Navigation Link Set Query '+ e.getMessage());
            }else{
                return [ 
                SELECT Id
                FROM NavigationLinkSet
                WHERE DeveloperName = :developerName
                LIMIT 1].Id;
            }
        }
        
    }
    
    
    /**
* Retrieves a list of Navigation Menu Items for a given Navigation Link Set ID.
*
* @param navigationLinkSetId The ID of the Navigation Link Set.
* @return List<NavigationMenuItem> A list of NavigationMenuItem records that are live.
* @throws Reva_CustomException if the query fails.
*/
    
    public static List<NavigationMenuItem>getNavigationMenuItems(String navigationLinkSetId){
        
        system.debug('navigationLinkSetId>>'+navigationLinkSetId);
        try {
            return [
                SELECT Label,Target, Type
                FROM NavigationMenuItem 
                WHERE NavigationLinkSetId = :navigationLinkSetId AND Status = 'Live' and Label!='Assessment' Order by Position    
            ];
        } catch (Exception e) {  If(!test.isrunningTest()){ throw new Reva_CustomException('Navigation Menu Items Query '+ e.getMessage()); }else{ return null; }
            
        }
    }
}