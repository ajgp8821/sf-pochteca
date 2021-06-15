public class AccountTeamTriggerHelper {
   // @future
    public static boolean addUserToGroup(String invId, List<Id> userIds){
        List<POCH_HojaInventario__Share> shareList = new List<POCH_HojaInventario__Share>();
        for(Id userId : userIds){
            POCH_HojaInventario__Share invShare = new POCH_HojaInventario__Share();
            invShare.ParentId = invId;
            System.debug('---> parentid ' +invShare.ParentId);
            invShare.UserOrGroupId = userId;
            System.debug('---> usergroupid ' +invShare.UserOrGroupId);
            invShare.AccessLevel = 'Edit';
            invShare.RowCause = 'Manual';
            shareList.add(invShare); 
            
        }
        
        List<Database.SaveResult> insertResults = Database.insert(shareList,false);
        List<Id> listOfIds = new List<Id>();
        for (Database.SaveResult sr1 : insertResults) {
        if (sr1.isSuccess()) {
         listOfIds.add(sr1.getId());
         }
         else {
         // Get first save result error.
         Database.Error err = sr1.getErrors()[0];
         
         // Check if the error is related to trival access level.
         // Access level must be more permissive than the object's default.
         // These sharing records are not required and thus an insert exception is acceptable. 
         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            // Indicates success.
            return true;
         }
         else{
            // Indicates failure.
            return false;
         }
       }
        }
 
      // Process the save results.
      //if(sr.isSuccess()){
         // Indicates success
         return true;
     // }
     
   }
        
       /* if(shareList.size() > 0){
            System.debug('SharedList' +shareList);
            insert shareList;
        }
        System.debug('SharedList' +shareList[0].id); */
    
}