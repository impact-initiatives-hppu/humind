import os
import re
from github import Github

def get_function_name(issue_body):
    if issue_body is None:
        return None
    match = re.search(r'Tested Function: (.+)', issue_body)
    return match.group(1) if match else None

def are_issues_duplicate(issue1, issue2):
    # Check if issues have the same function name and description
    func1 = get_function_name(issue1.body)
    func2 = get_function_name(issue2.body)
    
    if func1 is None or func2 is None:
        return False
    
    desc1 = re.search(r'Description: (.+)', issue1.body or '')
    desc2 = re.search(r'Description: (.+)', issue2.body or '')
    return func1 == func2 and desc1 and desc2 and desc1.group(1) == desc2.group(1)

def main():
    g = Github(os.environ['GITHUB_TOKEN'])
    repo = g.get_repo(os.environ['GITHUB_REPOSITORY'])

    # Fetch both open and closed issues
    all_issues = list(repo.get_issues(state='all'))
    
    for i, issue in enumerate(all_issues):
        if issue.body is None:
            continue  # Skip issues without a body
        
        function_name = get_function_name(issue.body)
        
        # Check for duplicates
        for other_issue in all_issues[i+1:]:
            if other_issue.body is None:
                continue  # Skip issues without a body
            
            if are_issues_duplicate(issue, other_issue):
                if issue.state == 'open' and other_issue.state == 'open':
                    # If both are open, close the newer one
                    newer_issue = max(issue, other_issue, key=lambda x: x.created_at)
                    newer_issue.create_comment(f"Closing as duplicate of #{min(issue, other_issue, key=lambda x: x.number).number}")
                    newer_issue.edit(state='closed')
                elif issue.state == 'open' and other_issue.state == 'closed':
                    # If one is open and one is closed, close the open one
                    issue.create_comment(f"Closing as duplicate of #{other_issue.number} (previously closed)")
                    issue.edit(state='closed')
                # If both are closed, do nothing
                continue

        # Link issues with the same function name (only for open issues)
        if issue.state == 'open' and function_name:
            related_issues = [other_issue for other_issue in all_issues 
                              if other_issue != issue and other_issue.state == 'open' 
                              and other_issue.body is not None  # Ensure other issue has a body
                              and get_function_name(other_issue.body) == function_name]
            if related_issues:
                comment = "Related open issues for the same function:\n"
                comment += "\n".join([f"#{related.number}" for related in related_issues])
                issue.create_comment(comment)

if __name__ == "__main__":
    main()