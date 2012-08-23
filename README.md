[![build status](https://secure.travis-ci.org/ggoodman/ed.png)](http://travis-ci.org/ggoodman/ed)
# Ed

Ed allows you to make your objects event-driven. Using ed, you can hook into
events of existing objects and you can extend classes to become transparently
event-driven.

## Example

Suppose you are required to work with an existing body of code wherein a 'User'
class is defined and is essentially a black-box. You have the choice of wrapping
that class or simply making its public interface event-driven!

Let's give it a try:

```coffee-script
ed = require("ed")


# Pre-defined that we're going to consider a black box for the purpose of
# this example
class User
  constructor: (@username, @password) ->
    # Constructor logic

  display: ->
    (alert? or console.log)("User", { username: @username, password: @password } )

# Lets add some event-driven logic to this user class
User = ed.ify(User)
  .before "change:username", (event) ->
    # We want to make sure usernames conform to our app's username policy
    event.cancel() unless event.value.match(/^[a-z_][a-z0-9_]+$/i)
  .on "read:password", (event) ->
    # We want to obfuscate the password
    event.change("******")

# Create an instance of User.
# Note that change:* callbacks will be triggered by the constructor
# This is not an issue here because the username conforms
user = new User("ggoodman", "password")

# Lets try and give this user a bad username
user.username = "$$$LOLZ$$$"

# The new username has magically not taken effect
user.display()
```

## Known issues:
 * The toString() method returns undesirable results on classes that have been
   'enhanced' through ed.ify.

## TODO
 * This todo list

## License 

(The MIT License)

Copyright (c) 2011 Geoffrey Goodman

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.