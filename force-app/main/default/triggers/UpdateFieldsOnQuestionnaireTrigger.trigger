trigger UpdateFieldsOnQuestionnaireTrigger on T_Questionnaire__c (before update) {
    Map<String, T_Questionnaire__c> questionnaireMap = new Map<String, T_Questionnaire__c>();
    Set<String> questionnaireIds = new Set<String>();

    for (T_Questionnaire__c questionnaire : Trigger.new) {
        questionnaireIds.add(questionnaire.Questionnaire_Id__c);
    }

    List<T_Questionnaire__c> questionnaires = [SELECT Id, Questionnaire_Id__c, First_Name__c, Last_Name__c, Picklist__c, Injured__c
                                               FROM T_Questionnaire__c
                                               WHERE Questionnaire_Id__c IN :questionnaireIds AND RecordType.Name = 'Questionnaire'];

    for (T_Questionnaire__c questionnaire : questionnaires) {
        questionnaireMap.put(questionnaire.Questionnaire_Id__c, questionnaire);
    }

    for (T_Questionnaire__c questionnaireToUpdate : Trigger.new) {
        String questionnaireId = questionnaireToUpdate.Questionnaire_Id__c;
        if (String.isNotBlank(questionnaireId) && questionnaireMap.containsKey(questionnaireId)) {
            T_Questionnaire__c relatedQuestionnaire = questionnaireMap.get(questionnaireId);
            String firstName = relatedQuestionnaire.First_Name__c;
            String lastName = relatedQuestionnaire.Last_Name__c;
            String picklist = relatedQuestionnaire.Picklist__c;
            Boolean injured = relatedQuestionnaire.Injured__c;
            String fieldsValue = 'First Name: ' + firstName + '\n' + 'Last Name: '+ lastName + '\n' + 'Picklist: ' + picklist + '\n' + 'Injured: ' + String.valueOf(injured);

            if (Schema.sObjectType.T_Questionnaire__c.fields.Fields__c.isAccessible()) {
                Schema.DescribeFieldResult fieldResult = Schema.sObjectType.T_Questionnaire__c.fields.Fields__c;
                if (fieldResult.getType() == Schema.DisplayType.TEXTAREA && fieldResult.getLength() >= fieldsValue.length()) {
                    questionnaireToUpdate.Fields__c = fieldsValue;
                }
            }
        }
    }
}