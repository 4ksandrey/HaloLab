import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import myComponentStyles from '@salesforce/resourceUrl/myComponentStyles';
import getCaseTypeNames from "@salesforce/apex/QuestionnaireController.getCaseTypes";
import getQuestionnaireNames from "@salesforce/apex/QuestionnaireController.getQuestionnaireNames";
import getQuestionnaires from "@salesforce/apex/QuestionnaireController.getQuestionnaires";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from "lightning/platformResourceLoader";
import papaparse from "@salesforce/resourceUrl/papaparse";


const COLUMNS = [
    { label: "Questionnaire Id", fieldName: "Id" },
    { label: "Questionnaire Name", fieldName: "Name" },
    { label: "Case Type", fieldName: "Case_Type__c" },
    {
        type: "button",
        label: "View Details",
        initialWidth: 150,
        cellAttributes: { alignment: 'center' },
        typeAttributes: {
            label: 'Open',  
            name: 'Open_Modal',  
            title: 'Open',  
            disabled: false,  
            value: 'view_modal',  
            iconPosition: 'center' 
        }
    },
    {
        type: "button",
        label: "View Record Page",
        initialWidth: 150,
        cellAttributes: { alignment: 'center' },
        typeAttributes: {
            label: 'View',  
            name: 'Open',  
            title: 'Open',  
            disabled: false,  
            value: 'view',  
            iconPosition: 'center' 
        }
    }
];

export default class ViewerEditorTableLWC extends NavigationMixin(LightningElement) {
    @track selectedCaseType;
    @track caseTypeOptions = [];
    @track selectedQuestionnaireName;
    @track questionnaireNameOptions = [];
    @track isQuestionnaireNameDisabled = true;
    @track questionnairesData = [];
    @track tableColumns = COLUMNS;
    @track selectedRows = [];

    @wire(getCaseTypeNames)
    wiredCaseTypes({ error, data }) {
        if (data) {
            this.caseTypeOptions = data.map((caseType) => ({
                label: caseType,
                value: caseType
            }));
        } else if (error) {
            this.showErrorToast("Error fetching Case Types.");
        }
    }

    @wire(getQuestionnaireNames, { caseType: "$selectedCaseType" })
    wiredQuestionnaireNames({ error, data }) {
        if (data) {
            this.questionnaireNameOptions = data.map((questionnaireName) => ({
                label: questionnaireName,
                value: questionnaireName
            }));
            this.isQuestionnaireNameDisabled = false;
        } else if (error) {
            this.showErrorToast("Error fetching Questionnaire Names.");
        }
    }

    refreshQuestionnaires() {
        getQuestionnaires({ caseType: this.selectedCaseType, questionnaireName: this.selectedQuestionnaireName })
            .then((result) => {
                this.questionnairesData = result;
            })
            .catch((error) => {
                this.showErrorToast("Error fetching questionnaires.");
            });
    }

    handleCaseTypeChange(event) {
        this.selectedCaseType = event.detail.value;
        this.selectedQuestionnaireName = null;
        this.isQuestionnaireNameDisabled = true;
        this.questionnairesData = [];
        this.selectedRows = [];
        this.refreshQuestionnaires();
    }

    handleQuestionnaireNameChange(event) {
        this.selectedQuestionnaireName = event.detail.value;
        this.refreshQuestionnaires();
    }

    @track isModalOpen = false;
    @track selectedQuestionnaireDetails = {};
    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    formatFieldsData(fieldsData) {
        const formattedFields = [];
        const fieldsArray = fieldsData.split('\n');
    
        fieldsArray.forEach((field) => {
            const [fieldName, fieldValue] = field.split(': ');
            formattedFields.push({ fieldName, fieldValue });
        });
    
        return formattedFields;
    }

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
    
        if (actionName === 'Open') {
            const recordUrl = `/lightning/r/T_Questionnaire__c/${recId}/view`;
            window.open(recordUrl, '_blank');
        } else if (actionName === 'Open_Modal') {
            const fieldsData = event.detail.row.Fields__c;
            this.selectedQuestionnaireDetails = this.formatFieldsData(fieldsData);
            this.openModal();
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    showErrorToast(message) {
        const toastEvent = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: "error"
        });
        this.dispatchEvent(toastEvent);
    }

    connectedCallback() {
        loadStyle(this, myComponentStyles);
        loadScript(this, papaparse)
            .then(() => {
            })
            .catch(error => {
                this.showErrorToast("Error loading the papaparse library.");
            });
    }

    handleDownloadSelected(event) {
        if (this.selectedRows.length === 0) {
            this.showErrorToast("No rows selected for download.");
            return;
        }

        const selectedData = this.selectedRows.map((row) => ({
            "Questionnaire Id": row.Id,
            "Questionnaire Name": row.Name,
            "Case Type": row.Case_Type__c 
        }));

        this.downloadCSV(selectedData, "selected_questionnaire.csv");
    }

    handleDownloadAll(event) {
        if (this.questionnairesData.length === 0) {
            this.showErrorToast("No data available for download.");
            return;
        }
        this.showModal = true;
        const allData = this.questionnairesData.map((row) => ({
            "Questionnaire Id": row.Id,
            "Questionnaire Name": row.Name,
            "Case Type": row.Case_Type__c
        }));

        this.downloadCSV(allData, "all_questionnaires.csv");
    }

    downloadCSV(data, fileName) {
        const csv = Papa.unparse(data);
        const hiddenElement = document.createElement("a");
        hiddenElement.href = "data:text/csv;charset=utf-8," + encodeURI(csv);
        hiddenElement.target = "_blank";
        hiddenElement.download = fileName;
        hiddenElement.click();
    }

}