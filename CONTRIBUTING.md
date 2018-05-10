# Contributing
Your help is greatly appreciated! This project, as all other open-source projects, thrives through an active community. But: With great power comes great responsibility. So we have devised a few ground rules that should be followed when contributing.

## How can you contribute?
There are a couple of ways you can help us out.
* [Issues](#Issues): The easiest way to contribute is to identify that something is broken or that a feature is missing and create an issue from it. Even better would be fixing an open issue that has no assignee yet. You can of course do both - find something that is missing and fix it yourself!
* [Reviews](#Reviews): With more contributions coming in we will likely see more pull requests. Reviewing them is not always the most fun, but it is very necessary and would help a lot.

## Issues
### Standard issues
Opening issues is very easy. Head to our [Issues tab](https://github.com/automatedlab/automatedlab/issues) and open one if it does not exist already. If an issue exists that might have something to do with yours, e.g. is the basis for something your are requesting, please link this issue to yours.  
### Bugs, errors and catastrophies
If you encounter an error during usage of Polaris, there are some basic details we need to be able to help you.
1. The script you used. Feel free to strip out any incriminating details, but it must be able to be executed
2. The verbose and error output of the script! Either set `$VerbosePreference = 'Continue'` or use the verbose switch for Start-Polaris.
### Fixing an issue
Fixing issues also does not require a lot of administrative work. The basic steps are:
1. Leave a comment to tell us that you are working on it
2. Fork our repository, and base your changes off of the **master** branch. Please create a new branch from **master** which contains your changes. How you call it? We don't care.
3. Fix the issue! No biggie...
4. Make sure you have pushed your commits to your new branch and then create a pull request back to the Polaris **master** branch
5. Sit back and wait for us to take credit for your code - just kidding. All the fame and glory is yours.

## Reviews
We are using GitHub's internal capabilites for our code reviews. Either we, the Polaris team, or you, the community, can review the changes and add comments. The author of the pull request can then go through all issues, fix them and add commits to his branch, which will show up in the pull request. When all issues are fixed and there is nothing else to do, we will gladly merge your pull request.

## Breaking Changes
We would like to avoid making breaking changes where possible. Any time you need to make modifications to an end-to-end test or a unit test you are breaking the contract of functionality developers expect from Polaris and it is classified as a breaking change. If you feel a breaking change needs to happen or should be proposed we will use the following process:

1. Breaking changes should be proposed in an issue labled RFC ###. 
2. The RFC should sit available for review and comment by the community for at least **two weeks** before a pull request corresponding to the change can be merged.
3. The description of the breaking change and the new version number should be added to **Breaking-Changes.md** for in the pull request for future record.
4. Not everyone checks Github every day, get some visibility to the RFC by announcing it in powershell.slack.com and/or twitter.
