public class MonthTableExample{
 public String LId {get;set;}
 public List<account> leadList {get;set;}
 public MonthTableExample(ApexPages.StandardController controller){
       LId = '';
       LId=System.currentPageReference().getParameters().get('id');
       System.debug('...................LID=='+LId);
       Id i= Id.valueOf(LId);
       leadList = [Select name from account where Id=:i];
       System.debug('.............................leadlist=='+leadList);
   }
 public MonthTableExample(){
   }
 public void save(){
       update leadList;
       /*PageReference pr = new PageReference('/'+leadList[0].Id);
       pr.setRedirect(true);
       return pr;*/
   }
 }