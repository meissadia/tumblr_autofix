# About  
\- tumblr_autofix is a configurable comment generator for Tumblr.  
\- Generated files are stored in ~/config_md/taf/  
\- Careful when editing configuration files, as with all YAML files, indentation is crucial!   

# Version 0.1.0
- New: [Tag Matcher](#using-the-tag-matcher)! Use a whitelist of tags to improve Autofixer's ability to
- Ability to include DK::Autofixer in your programs
- Started building out the test suite
- Extensive refactoring
- Please report any [issues](https://github.com/meissadia/tumblr_autofix/issues)

# Using the Tag Matcher
In order to utilize the Tag Matcher we'll need to generate a list of acceptable tags. To do this, we'll collect the tags of your last 1,000 posts as a starting point.

## Basic
`taf g:tags`

This will generate a file in your home directory '~/config_md/taf/tags.yml'
You can edit this file and delete any lines which contain tags you do not want used to automatically generate post comments.

## Advanced
You can specify a few options for the g:tags command   

| Option | Description |  
| :--- | :--- |  
| `-l [LIMIT]` | Maximum number of posts to scan. |  
| `-b [BLOG]` | Blog name to scan. Only required if scanning a secondary blog. |  
| `--source [SOURCE]` | draft, queue, or publish.|  
| `--config [CONFIG]` | Autofixer uses DraftKing to connect to tumblr, specify your saved config here. |   


Example:  
`taf -l 200 -b secondary-blog-name --source queue`

# Using ~/config_md/taf/data.yml
data.yml allows you to configure, on a blog-by-blog basis, the source of the data used to generate new comments.  You may use a specific tag index, the last tag, or simply reuse the existing summary.  

| Field | Type | Description |
| :--- | :---: | :--- |
| `ignore` | Array | Blogs listed here will only be processed with the Tag Matcher
| `last_tag` | Array | Use the last available tag as your comment  
| `summary` | Array | Use full text of existing post.summary
| `tag_idx` | [Array] | Indicates which tag index to use as the new comment  
| | |  - Blogs listed in tag_idx[0] will use the first tag  
| | |  - Blogs listed in tag_idx[1] will use the second  


# Using ~/config_md/taf/summary.yml  
The summary.yml configuration allows you to code the processing steps needed
to extract the information you want from a post's comment.  This can be set up on
a blog-by-blog basis.  

## Available variables
| Variable | Description |
| :--- | :--- |
| `summary` | the plain text of the current post's caption  
| `res` | lower case version of summary, useful for simplified text searching  
| `from` | the blog name of the user you reblogged the post from  
| `lines` | original summary text, split into lines  

## Available methods
| Method | Description |
| :--- | :---: |
| `normalize(string)` | Applies capitalization, adds configured prefix/postfix strings

## Returning  
| Method | Description |
| :--- | :--- |
| `return <value> `| Use the <value> string as the comment for this post
| `res = 'your value'` | storing your new comment in the `res` variable, without explicitly returning it, will subject it to a couple more modifications:
| | 1. capitalization - each word in the string will be capitalized  
| | 2. prefix  - a string passed via the `-p <PREFIX>` option will be prepended to `res`  
| | 3. postfix - a string passed via the `-P <POSTFIX>` option will be appended to `res`  

## Summary Example  

### Get the title from the first line, then add the author  
Update ~/config_md/taf/summary.yml with the following
```
:angulargeometry:  
- title = summary.split("\n")[0]  
- return "#{title} by Angular Geometry"  
```

###  Add prefix & postfix to formatted strings  
1 - Update ~/config_md/taf/summary.yml  
note: string must be stored in the `res` variable for pre/postfixing to work
```
:kazu721010:  
- title, architect = lines[0].split('/')  
- photographer = lines[2].split("©").last  
- res = "project: #{title}\narchitect: #{architect}\nphotographer: #{photographer}"  
```
2 - Run Autofixer with options: `taf -p '**\n' -P '\n--'`   


3 - Resulting caption for kazu721010 posts:  
```
**  
Project: Project Title  
Architect: Architect Or Firm Name  
Photographer: Photographers Name  
--  
```
