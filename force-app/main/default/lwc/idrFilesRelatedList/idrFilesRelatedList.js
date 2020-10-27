import { LightningElement, api, track } from "lwc";
import getCaseRelatedFiles from "@salesforce/apex/IDRFiledRelatedListController.getCaseRelatedFiles";
import searchFilesContent from "@salesforce/apex/IDRFiledRelatedListController.searchFilesContent";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
    { label: 'File Name', fieldName: 'fileUrl',type: 'url',typeAttributes: {label: { fieldName: 'fileName' }}},
    { label: 'File Type', fieldName:'fileType'},
    { label: 'Owner', fieldName:'OwnerName'},
    { label: 'Created Date',fieldName: 'createdDate'}
];
export default class IDRFilesRelatedList extends LightningElement {
    @api recordId;
    @track files;
    @track filesToDisplay;
    @track commonPath;
    searchFileName;
    searchFileType;
    searchOwner;
    searchContains;
    AllFieldSearchResult;
    allFileIdList;

    columns = columns;
    connectedCallback() {
        getCaseRelatedFiles({ caseId: this.recordId })
          .then((result) => {
            let filelist = result;
            this.files  =  filelist;
            this.filesToDisplay = this.files;
            this.allFileIdList=[];
            for(let i=0;i< filelist.length;i++){
              this.allFileIdList.push(filelist[i].fileId);
              console.log('this.allFileIdList:'+ this.allFileIdList);
            }
          })
          .catch((error) => {
            console.log('error:'+error);
            console.log('errorbody:'+JSON.stringify(error));
            let errorMessage = "Failed to retrive case files";
            if (error.body) {
              if (Array.isArray(error.body)) {
                errorMessage = error.body.map((e) => e.message).join(", ");
              } else if (typeof error.body.message === "string") {
                errorMessage = error.body.message;
              }
            }
            const toastEvent = new ShowToastEvent({
              message: errorMessage,
              variant: 'error'
            });
            this.dispatchEvent(toastEvent);
          });
      }
      UpdateFileNameSearch(event){
        console.log('In UpdateFileNameSearch');
        this.searchFileName = event.target.value;
        this.filterFiles();
      }
      UpdateFileTypeSearch(event){
        this.searchFileType = event.target.value;
        this.filterFiles();
      }
      UpdateFOwnerSearch(event){
        this.searchOwner = event.target.value;
        this.filterFiles();
      }
      UpdateContainsSearch(event){
        this.searchContains = event.target.value;
        //minimum length of 2 characters is required for salesforce search
        try{
        if(this.searchContains.length > 1 && this.allFileIdList.length > 0){
          searchFilesContent({searchString : this.searchContains,validDocIdList : this.allFileIdList})
          .then((result)=>{
              this.AllFieldSearchResult = result;
              this.filterFiles();
          })
          .catch((error)=>{
            let errorMessage = "Failed to search files content";
            if (error.body) {
              if (Array.isArray(error.body)) {
                errorMessage = error.body.map((e) => e.message).join(", ");
              } else if (typeof error.body.message === "string") {
                errorMessage = error.body.message;
              }
            }
            const toastEvent = new ShowToastEvent({
              message: errorMessage,
              variant: 'error'
            });
            this.dispatchEvent(toastEvent);
          });
        }else{
          this.AllFieldSearchResult = [];
          this.filterFiles();
        }
      }catch(err){
        console.log('err'+err);
      }
      }
      filterFiles(){
          this.filesToDisplay = [];
          for(let i=0; i < this.files.length;i++){
          let fileMatch = true;
          if(
            (this.searchFileName && !this.files[i].fileName.includes(this.searchFileName))||
            (this.searchFileType && !this.files[i].fileType.includes(this.searchFileType))|| 
            (this.searchOwner && !this.files[i].OwnerName.includes(this.searchOwner))||
            (this.searchContains && !this.AllFieldSearchResult.includes(this.files[i].fileId))
            ){            
            fileMatch = false;
          }
          if(fileMatch){
            this.filesToDisplay.push(this.files[i]);
          }
        }
      }
  }