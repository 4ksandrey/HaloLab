public with sharing class CustomQuestionnaireSearch {
    @AuraEnabled(cacheable=true)
    public static list<T_Questionnaire__c> getQuestionnaireList(String searchKey) {
        string searchKeyword = '%' + searchKey + '%';
		
        list<T_Questionnaire__c> questionnaireList = new list<T_Questionnaire__c>();
     
        for(T_Questionnaire__c queObj : [Select Id, Name, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c
                                        From T_Questionnaire__c
                                        WHERE Name LIKE : searchKeyword AND RecordType.Name = 'Mapping']){
           questionnaireList.add(queObj);
        }
        
         if(questionnaireList.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
         }
         
        return questionnaireList;
    }
}