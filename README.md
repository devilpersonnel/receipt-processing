# Receipt Processing API Documentation #

### User Registration ###

```
#!plain

POST: /api/v1/users
parameters:
  email: String *required
  password: String *required
results: 
  return user data JSON
  {user_key, api_token, api_secret, :meta => { :code => 200, :message => "Success" }}
```

### User Authentication ###

```
#!plain

POST: /api/v1/login
parameters:
  email: String *required
  password: String *required
results: 
  return user data JSON
  {user_key, api_token, api_secret, :meta => { :code => 200, :message => "Success" }}
```

### Process Receipt ###

```
#!plain

POST: /api/v1/receipts
headers:
  Rest-Signature: String *required
parameters:
  timestamp: UNIX timestamp *required
  api_token: String *required
  receipt_image: Image file to process *required
results: 
  return receipt processed data JSON
  {totalLines, accuracy, lines[{line: "0", text: "something"}, ...], :meta => { :code => 200, :message => "Success" }}
```