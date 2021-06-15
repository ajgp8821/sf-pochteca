/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Trigger tu grant access to Inventary, Apext Test AccountTeamMemberHelperTest
--- CreateDate: 16/04/2021 - JIRA CAM-2085
--- UpdateDate:
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
trigger AccountTeamMemberTrigger on AccountTeamMember (before insert, before update, after insert, after update, before delete) {
    if (Trigger.isAfter){  
        if (Trigger.isInsert){
            AccountTeamMemberHelper.evaluateAccess(Trigger.New);
        } 
        if (Trigger.isUpdate){
            AccountTeamMemberHelper.updateAccountTeam(Trigger.New, Trigger.Old);
        }
    }
    if (Trigger.isBefore){ 
        if (Trigger.isDelete){
            AccountTeamMemberHelper.deleteAccess(Trigger.Old);
        }
    }

    List<AccountShare> shares = new List<AccountShare>();
    
	Map<Id, AccountTeamMember> accMap = new Map<Id, AccountTeamMember>();
    for( AccountTeamMember A : Trigger.New ){
		if( trigger.isInsert || ( trigger.isUpdate && A.AccountId != trigger.oldMap.get( A.Id ).AccountId ))
			accMap.put( A.AccountId, A );
    }

    for( Id i : accMap.KeySet()){
		AccountShare aShare = new AccountShare();
        aShare.AccountId = i;
        System.debug('print in trigger: ' + accMap.get( i ).AccountAccessLevel);
        aShare.UserOrGroupId = accMap.get( i ).UserId;
		shares.add(aShare);
    }

    if( Shares.size() > 0 )
		Insert Shares;
}