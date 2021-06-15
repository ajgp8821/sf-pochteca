public class QuoteSample 
{
 public void testQuote(Integer year,Integer month,Integer day)
 {
  Date datobj=Date.newInstance(year, month, day);
  Integer dy = datobj.day();
  Integer mon = datobj.month();
  Integer yr = datobj.year();  
  List<SBQQ__Quote__c> x = [select POCH_EstatusCotizacion__c,Motivos_de_Cancelaci_n__c from SBQQ__Quote__c];
  for(SBQQ__Quote__c p : x)
  {
   if(p.POCH_EstatusCotizacion__c != 'convertida a pedido') 
   {
    if(((mon==1 || mon==3 || mon==5 || mon==7 || mon==8 || mon==10 || mon==12) && dy==31) || (mon==2 && Math.Mod(yr,4)==0) && dy==29 || (mon==2 && Math.mod(yr, 4)!=0) && dy==28 || (mon==4 || mon==6 || mon==9 || mon==11 && (dy==30)))  
      p.Motivos_de_Cancelaci_n__c='Vigencia';   
   }    
  }    
 }    
}