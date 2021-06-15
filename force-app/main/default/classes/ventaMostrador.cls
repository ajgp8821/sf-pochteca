public class ventaMostrador{
    public List<Ventas_Mostrador__c> acc {get;set;}
    public ventaMostrador(ApexPages.StandardController controller){
        
        acc = new List<Ventas_Mostrador__c>();
        
        //acc = [Select Name from Stock_of_matrials__c];
        List<Stock_of_matrials__c> materials_object = [Select Name from Stock_of_matrials__c limit 10];
        
        For(Stock_of_matrials__c aaaaa : materials_object)
        {
            Ventas_Mostrador__c test = new Ventas_Mostrador__c();
            test.Name = aaaaa.Name;
            acc.add(test);
        }	
        /*
pe.Name = 'a';
System.debug('...................acc............');
System.debug(acc);
System.debug(pe);
acc.add(pe);
System.debug('...................acc............');
System.debug(acc);
//acc.add(pe);*/
    }
    public ventaMostrador(){
    }
    
}