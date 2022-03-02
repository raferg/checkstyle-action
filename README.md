# Checkstyle GitHub Action

Runs [checkstyle](https://github.com/checkstyle/checkstyle) with [reviewdog](https://github.com/reviewdog/reviewdog) on pull requests.
This modification also provides some metrics for tracking the issues found with checkstyle, these are provided in the 'output' folder: 

```
/github/workspace/src/RunMe.java:10:0: error: Tabs in line (com.puppycrawl.tools.checkstyle.checks.regexp.RegexpSinglelineJavaCheck)
/github/workspace/src/RunMe.java:11:0: error: Tabs in line (com.puppycrawl.tools.checkstyle.checks.regexp.RegexpSinglelineJavaCheck)
/github/workspace/src/RunMe.java:13:0: error: Line matches the illegal pattern 'Trailing whitespace'. (com.puppycrawl.tools.checkstyle.checks.regexp.RegexpCheck)
/github/workspace/src/TestThree.java:4:0: error: Line matches the illegal pattern 'Trailing whitespace'. (com.puppycrawl.tools.checkstyle.checks.regexp.RegexpCheck)      
```

```
raferg, 57/merge, 1, 02de945736ccf8da66584adb206df5fd2397dc04
2 : error: Line matches the illegal pattern 'Trailing whitespace'. 
2 : error: Tabs in line     
```

Example:

[![github-pr-check sample](https://user-images.githubusercontent.com/6826684/107879090-1a1c0500-6ed7-11eb-9260-14acdc94ad36.png)](https://github.com/nikitasavinov/checkstyle-action/pull/2/files)


## Input

### `checkstyle_config`

Required. [Checkstyle config](https://checkstyle.sourceforge.io/config.html)
Default is `google_checks.xml` (`sun_checks.xml` is also built in and available).

### `file_list`
Required. 
If not provided then no files will be processed by Checkstyle

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [github-pr-check,github-pr-review].
It's same as `-reporter` flag of reviewdog.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
Default is `added`.

### `fail_on_error`

Optional.  Exit code for reviewdog when errors are found [true,false].
Default is `false`.

**Important**: this feature only works when `level` is set to `error`.

### `tool_name`
    
Optional. Tool name to use for reviewdog reporter.
Default is 'reviewdog'.

### `checkstyle_version`
Optional. Checkstyle version to use.
Default is `8.40`

### `properties_file`
Optional. Properties file relative to the root directory.

## Example usage

``` yml
name: Checkstyle with attempt at logging

on:
  pull_request:
    branches: [ master ]
jobs:
  run-lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Get changed files
        id: changed-files
        uses: tj-actions/changed-files@v17.2
      - uses: raferg/checkstyle-action@master
        id: checkStyleRaferg
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          checkstyle_config: .checkstyle/checkstyle.xml
          level: error
          fail_on_error: true
          filter_mode: added
          file_list: ${{ steps.changed-files.outputs.all_changed_files }}
      - name: echo violations
        run: echo "${{ steps.checkStyleRaferg.outputs.total_volations }}"
      
      - name: 'Upload Artifact(s)'
        uses: actions/upload-artifact@v2
        with:
          name: checkstyle
          path: output/*
```
