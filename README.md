no_names [Array]   - Blogs listed here will be ignored during processing
summary  [Array]   - Will apply capitalization, add prefix and postfix strings
tag_idx  [[Array]] - Indicated which tag to use as the new comment (Blogs listed in the first tag_idx[0] will use the first tag, tag_idx[1] will use the second)
last_tag [Array]   - Use the last available tag as your comment

Using summary.yml
Available variables
  - summary - the plain text of the current post's caption
  - res     - lower case version of summary, useful for simplified text searching
  - from    - the blog name of the user you reblogged the post from
  - lines   - original summary text, split into lines

Returning
  - using `return value` in your summary.yml will make that string your new comment
  - storing your new comment in the `res` variable, without explicitly returning it, will subject it to a couple more modifications:
    1. capitalization - each word in the string will be capitalized
    2. prefix  - a string passed via the `-p PREFIX` option will be prepended to `res`
    3. postfix - a string passed via the `-P POSTFIX` option will be appended to `res`

Summary Example
# Get the title from the first line, then add the author
:angulargeometry:
- title = summary.split("\n")[0]
- return "#{title} by Angular Geometry"

# -p '**\n' -P '\n--'
:kazu721010:
- title, architect = lines[0].split('/')
- photographer = lines[2].split("©").last
- res = "project: #{title}\narchitect: #{architect}\nphotographer: #{photographer}"
# **
# Project: Project Title
# Architect: Architect Or Firm Name
# Photographer: Photographers Name
# --
