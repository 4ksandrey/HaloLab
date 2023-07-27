public with sharing class QuestionnaireCreateUpdateController {
    @AuraEnabled
    public static void createNewQuestionnaire(String questionnaireName, String caseType, String field) {
        String questionnaireId = questionnaireName + '_' + caseType;

        T_Questionnaire__c newQuestionnaire = new T_Questionnaire__c();
        newQuestionnaire.Name = questionnaireName;
        newQuestionnaire.Questionnaire_Id__c = questionnaireId;
        newQuestionnaire.RecordTypeId = getMappingRecordTypeId();
        newQuestionnaire.Case_Type__c = caseType;
        newQuestionnaire.Fields__c = field;
        
        insert newQuestionnaire;
    }

    @AuraEnabled
    public static void updateQuestionnaire(Id recordId, String questionnaireName, String caseType, String field) {
        T_Questionnaire__c questionnaireToUpdate = [SELECT Id, Name, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c
                                                          FROM T_Questionnaire__c
                                                          WHERE Id =:recordId];
        
        if (questionnaireToUpdate != null) {
            String questionnaireId = questionnaireName + '_' + caseType;

            questionnaireToUpdate.Name = questionnaireName;
            questionnaireToUpdate.Questionnaire_Id__c = questionnaireId;
            questionnaireToUpdate.Case_Type__c = caseType;
            questionnaireToUpdate.Fields__c = field;

            update questionnaireToUpdate;
        } else {
            throw new AuraHandledException('Questionnaire record with given recordId not found.');
        }  
    }

    private static Id getMappingRecordTypeId() {
        return Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();
    }
}