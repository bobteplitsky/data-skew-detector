import { LightningElement, track } from 'lwc';
import getAccountSettingsWrapped from '@salesforce/apex/DSD_SettingsSupport.getAccountSettingsWrapped'
import startBatchJob from '@salesforce/apex/DSD_AccountDataSkewBatch.startBatchJob'
import checkBatchStatus from '@salesforce/apex/DSD_AccountDataSkewBatch.checkBatchStatus'

export default class DsdHomeContainer extends LightningElement {
	@track accountSettings;
	@track jobId;
	@track error;
	@track progress = 0;
	@track isProgressing = false;
	@track totalRecsToProcess;
	@track batchStatus;
	@track batchObject;
	myInterval;

	constructor(){
		super();
		getAccountSettingsWrapped()
			.then(result => {
				this.accountSettings = result;

			})
			.catch(error => {
				this.error = error;
			});
	}

	handleRun(){
		startBatchJob({ accountSettings: JSON.stringify(this.accountSettings) })
			.then(result => {
				this.isProgressing = true;
				this.totalRecsToProcess = result;
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				this._interval = setInterval(() => { 
					this.checkStatus();
					
				}, 2000);
			})
			.catch(error => {
				this.error = error;
			});
	}

	checkStatus(){
		checkBatchStatus({ accountSettings: JSON.stringify(this.accountSettings )})
			.then(result => { 
				this.batchStatus = result.Status; 
				this.batchObject = result;

				let jobItemsProcessed = 0;
				let totalJobItems = 0;

				if(this.batchStatus === 'Completed') {
					this.progress = 100;
					this.isProgressing = false;
					clearInterval(this._interval);
				}
				else if (this.batchStatus === 'Processing') {
					this.isProgressing = true;
					jobItemsProcessed = this.batchObject.JobItemsProcessed;
					totalJobItems = this.batchObject.TotalJobItems;
				}

				if(this.isProgressing){
					this.progress = parseInt((jobItemsProcessed/totalJobItems) * 100, 10);
				}
			});
	}

	get accountSettingsString() {
		return JSON.stringify(this.accountSettings);
	}
}