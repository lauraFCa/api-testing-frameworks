/// <reference types="cypress" />


describe("Issues API Testing", () => {

    it("Get all issues in repo", () => {
        console.log("Get all issues in repo")
        cy.sendGithubRequest("/issues", "GET", "issuesRequest");

        cy.get("@issuesRequest").then((issues) => {
            console.log("request response: "+issues);
            expect(issues.status).to.eq(200);
            expect(issues.body.length).to.be.greaterThan(1);

            assert.isArray(issues.body, "Issues Response is an array");

            const issueTitles = issues.body.map(issue => issue.title);
            expect(issueTitles).to.include.members(["Fake issue for API Testing purposes", "Pull Request Title (from API)"]);
        });

    });

    it("Create a new issue", () => {
        cy.fixture('issues.json').then((issues) => {
            cy.sendGithubRequest("/issues", "POST", "createIssue", {
                title: issues.newIssueTitle,
                body: issues.newIssueDescription
            });

            cy.get("@createIssue").then((response) => {
                expect(response.status).to.eq(201);
                expect(response.body).to.have.property("id");
                expect(response.body.title).to.eq(issues.newIssueTitle);
                expect(response.body.body).to.eq(issues.newIssueDescription);
            });
        });
    });

    it("Close (update) an issue", () => {
        cy.fixture('issues.json').then((issues) => {
            const allIssues = cy.sendGithubRequest("/issues", "GET", "issuesRequest");
            allIssues.then((theIssue) => {
                const issueToClose = theIssue.body.find(issue => issue.title === issues.newIssueTitle);
                console.log(issueToClose);
                const issueNumber = issueToClose.number;

                cy.sendGithubRequest(`/issues/${issueNumber}`, "PATCH", "closeIssue", {"state": "closed", "state_reason": "completed"});
        
                cy.get("@closeIssue").then((response) => {
                    expect(response.status).to.eq(200);
                    expect(response.body.state).to.eq("closed");
                    expect(response.body.state_reason).to.eq("completed");
                });
            });
        });
        
    });

});

