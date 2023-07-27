public with sharing class CaseTypeController {
    @AuraEnabled(cacheable=true)
    public static List<String> getCaseTypeNames() {
        List<String> caseTypeNames = new List<String>();
        for (T_Case_Type__c caseType : [SELECT Name FROM T_Case_Type__c]) {
            caseTypeNames.add(caseType.Name);
        }
        return caseTypeNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getQuestionnaireNames() {
        List<String> questionnaireNames = new List<String>();
        
        for (T_Questionnaire__c questionnaires : [SELECT Name FROM T_Questionnaire__c 
                                                  WHERE RecordType.Name = 'Mapping']) {
            questionnaireNames.add(questionnaires.Name);
        }
        return questionnaireNames;
    }
}