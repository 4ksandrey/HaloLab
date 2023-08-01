public with sharing class QuestionnaireController {
    @AuraEnabled(cacheable=true)
    public static List<String> getCaseTypes() {
        List<String> caseTypes = new List<String>();
        for (T_Case_Type__c caseType : [SELECT Name FROM T_Case_Type__c]) {
            caseTypes.add(caseType.Name);
        }
        return caseTypes;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getQuestionnaireNames(String caseType) {
        List<String> questionnaireNames = new List<String>();
        for (T_Questionnaire__c record : [SELECT Questionnaire_Name__c FROM T_Questionnaire__c WHERE RecordType.Name = 'Mapping' AND Case_Type__c =: caseType]) {
            questionnaireNames.add(record.Questionnaire_Name__c);
        }
        return questionnaireNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<T_Questionnaire__c> getQuestionnaireById(Id id) {
        return [SELECT Name, Id, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c FROM T_Questionnaire__c WHERE Id =: id];
    }

    @AuraEnabled(cacheable=true)
    public static List<T_Questionnaire__c> getQuestionnaires(String caseType, String questionnaireName) {
        return [SELECT Name, Id, Case_Type__c, Questionnaire_Name__c, Questionnaire_Id__c, Fields__c FROM T_Questionnaire__c WHERE Case_Type__c = :caseType AND Name = :questionnaireName];
    }

}