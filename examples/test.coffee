ed = require("../")

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

user.display()