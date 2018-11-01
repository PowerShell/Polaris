---
name: Request For Comment
about: Used for proposing breaking changes. See CONTRIBUTING.md for more information.

---

# RFC #[Insert RFC # Here]

We would like to avoid making breaking changes where possible. Any time you need to make modifications to an end-to-end test or a unit test you are breaking the contract of functionality developers expect from Polaris and it is classified as a breaking change. If you feel a breaking change needs to happen or should be proposed we will use the following process:

Breaking changes should be proposed in an issue labled RFC ###.
The RFC should sit available for review and comment by the community for at least two weeks before a pull request corresponding to the change can be merged.
The description of the breaking change and the new version number should be added to Breaking-Changes.md for in the pull request for future record.
Not everyone checks Github every day, get some visibility to the RFC by announcing it in powershell.slack.com and/or twitter.

## RFC Checklist (You can remove this or leave it at the bottom of the RFC)

See [RFC 001](https://github.com/PowerShell/Polaris/issues/120) for a sample.

- [ ] Added RFC lable to Github Issue
- [ ] Title matches format **RFC #xxx: Description**  
- [ ] Full description of exactly what the breaking changes will be
- [ ] Full description of why the change will be valuable
- [ ] Code samples (before and after changes)