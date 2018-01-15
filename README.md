# About  
\- tumblr_autofix is a configurable comment generator for Tumblr.  
\- Two configuration files are created in your home directory: taf_data.yml & taf_summary.yml  
\- Careful when editing configuration files, as with all YAML files, indentation is crucial!   

# Using ~/taf_data.yml
no_names [Array]   - Blogs listed here will be ignored during processing  
summary  [Array]   - Will apply capitalization, add prefix and postfix strings  
last_tag [Array]   - Use the last available tag as your comment  
tag_idx  [[Array]] - Indicated which tag to use as the new comment  
  - Blogs listed in the first tag_idx[0] will use the first tag  
  - Blogs listed in tag_idx[1] will use the second  


# Using ~/taf_summary.yml  
## Available variables  
  \- `summary` - the plain text of the current post's caption  
  \- `res`     - lower case version of summary, useful for simplified text searching  
  \- `from`    - the blog name of the user you reblogged the post from  
  \- `lines`   - original summary text, split into lines  

## Returning  
  \- using `return <value>` in your summary.yml will make that string your new comment  
  \- storing your new comment in the `res` variable, without explicitly returning it, will subject it to a couple more modifications:  
  1. capitalization - each word in the string will be capitalized  
  2. prefix  - a string passed via the `-p <PREFIX>` option will be prepended to `res`  
  3. postfix - a string passed via the `-P <POSTFIX>` option will be appended to `res`  

## Summary Example  

### Get the title from the first line, then add the author  
Update ~/taf_summary.yml   
```
:angulargeometry:  
\- title = summary.split("\n")[0]  
\- return "#{title} by Angular Geometry"  
```

###  Add prefix & postfix to formatted strings  
Update ~/taf_summary.yml  
```
:kazu721010:  
- title, architect = lines[0].split('/')  
- photographer = lines[2].split("©").last  
- res = "project: #{title}\narchitect: #{architect}\nphotographer: #{photographer}"  
```
Run Autofixer with options: `taf -p '**\n' -P '\n--'`   


Resulting caption for kazu721010 posts:  
```
**  
Project: Project Title  
Architect: Architect Or Firm Name  
Photographer: Photographers Name  
--  
```
