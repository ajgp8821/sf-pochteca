public with sharing class testaccount {

    public Account acc{get;set;}
        
    public string getaccountfields{get;set;}
        
    public Id accountId {get; set;}

    public List<AccountTeamMember> accountTeamMembers {get;set;}

    public List<SelectOption> accountList {get;set;}
        
    public testaccount(ApexPages.StandardController controller) {
       // code for account team
       accountTeamMembers = new List<AccountTeamMember>();

        accountList = new List<SelectOption>();
        accountList.add(new SelectOption('', '--None--'));

        for (Account account: [select Name from Account ]) {
             accountList.add(new SelectOption(account.Id, account.Name));
        }
    }

    public void changeAccount(){
        accountTeamMembers = [Select User.Name,TeamMemberRole,Title From AccountTeamMember Where AccountId = :accountId];
    }

}