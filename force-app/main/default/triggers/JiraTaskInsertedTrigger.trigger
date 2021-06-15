trigger JiraTaskInsertedTrigger on Task (after insert) {
    JCFS.API.createJiraIssue('10034', '10002');
}