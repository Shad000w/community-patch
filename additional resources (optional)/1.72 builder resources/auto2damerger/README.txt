AUTO 2DA MERGER 2DILATE

How it works?


Put yours 2da into folder "input" and simply run either: merge-all.bat or merge-only-default.bat. If you want to use additional content from HAK version, after you'll be finished with first task run merge-hak.bat as well.

The program 2daMerger finds out if any of yours 2da was altered in the Community Patch and if was then it automatically merges yours 2da by the selected pattern. The difference betweem merge-all and merge-only-default is that merge-all doesn't take into consideration yours modification. If you run merge-only-default.bat then every field that CPatch changed is first checked against vanilla 1.69 and only if the value in your 2da match vanilla the value is updated. merge-all.bat doesn't check anything just simply insert updated values into your 2das.

Also, the merging is divided to several actions that needs prompt. There is always description of what the changed does and you will be asked to merge (Y) or not to merge (N). You can press A and it will merge everything without confirmation.

Several 2das which has been changed more "drastically" will be merged on more steps in order to help you not to merge specific features you might not want at all.

After merging is done you will find merged 2da files in folder merged. And thats it, thats everything.