public with sharing class QuestionnaireCreateUpdateController {
    private static final Integer MAX_LENGTH = 131000;

    @AuraEnabled
    public static void createNewQuestionnaire(String questionnaireName, String caseType, String field) {
        String questionnaireId = questionnaireName + '_' + caseType;

        T_Questionnaire__c newQuestionnaire = new T_Questionnaire__c();
        newQuestionnaire.Name = questionnaireName;
        newQuestionnaire.Questionnaire_Name__c = questionnaireName;
        newQuestionnaire.Questionnaire_Id__c = questionnaireId;
        newQuestionnaire.RecordTypeId = getMappingRecordTypeId();
        newQuestionnaire.Case_Type__c = caseType;

        assignFields(newQuestionnaire, field);

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

            assignFields(questionnaireToUpdate, field);

            update questionnaireToUpdate;
        } else {
            throw new AuraHandledException('Questionnaire record with given recordId not found.');
        }  
    }

    private static Id getMappingRecordTypeId() {
        return Schema.SObjectType.T_Questionnaire__c.getRecordTypeInfosByName().get('Mapping').getRecordTypeId();
    }

    private static void assignFields(T_Questionnaire__c record, String field) {
        List<SObjectField> dataFields = new List<SObjectField>{
            T_Questionnaire__c.Fields__c,
            T_Questionnaire__c.Data_1__c,
            T_Questionnaire__c.Data_2__c,
            T_Questionnaire__c.Data_3__c,
            T_Questionnaire__c.Data_4__c,
            T_Questionnaire__c.Data_5__c,
            T_Questionnaire__c.Data_6__c,
            T_Questionnaire__c.Data_7__c,
            T_Questionnaire__c.Data_8__c,
            T_Questionnaire__c.Data_9__c,
            T_Questionnaire__c.Data_10__c
        };

        for (Integer i = 0; i < dataFields.size(); i++) {
            if (field.length() > i * MAX_LENGTH) {
                record.put(dataFields[i], field.substring(i * MAX_LENGTH, Math.min((i + 1) * MAX_LENGTH, field.length())));
            }
        }
    }
}
