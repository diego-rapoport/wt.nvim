# Working Time
Ever wonder how much time do you spend <b>coding</b> on a <b>project</b>? Have you ever wanted to be able to <b>quantify</b> the <b>amount of your work</b> and 
effort you put in a project or even in a <b>freelance job</b>? With this plugin I hope you can easily!  
This plugin is inspired on <b>wakatime</b> but intended to use directly and only with neovim.
You also <b>keep your data</b>, generate your own reports and <b>manage it as you like</b>.

---
### How it works?
<b>WT</b>(Working Time as it'll be called from now on) checks if you're inside a git repo and starts a new folder called `.wt` with a `progress.json` file inside(empty list).  
  
Right now we have those ex commands:
- InitWT
- StartWT
- StopWT

##### InitWT
This command <b>must be run</b> before you start tracking your wt. It'll check if you're already on a git project to create the folder
and file needed to start tracking your progress.

##### StartWT
This command will get the time as a starting point to track your progress.

##### StopWT
This command will get the difference between the starting point and this one to get how much time did you spend.
After that it'll save it as <b>seconds</b>.

---
### Data
Data is saved as `json`. The current structure is:  
```json
[
  {
    "projectOne": {
      "timeSpent": 500
    }
  },
  {
    "projectTwo": {
      "timeSpent": 375
    }
  }
]
```
