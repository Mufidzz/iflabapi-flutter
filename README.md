# iflabapi

Flutter Package for Accessing Infotech API

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Installing
```
dependencies:
  http: ^0.12.2
  flutter_secure_storage: ^3.3.5
  iflabapi:
      git:
        url: git://https://github.com/Mufidzz/iflabapi-flutter.git
        ref: master
```

## Authenticating

```
Auth auth = new Auth(
    client: "your_client_id", 
    secret: "your_client_secreet", 
    username: "infotech_ilab_username", 
    password: "infotech_ilab_password"
  );

isAuthorize = await auth.authorize();

if (isAuthorize) {
  //do what you want here if authorized 
}
```

## Auth Message
if you get rejected handshake while authenticating you can show the response message with

```
auth.getMessage();
```

## Secure Request
you can do secure request after do authorization, you dont need to pass auth class to secure storage, just feel free to using method of this class

```
SecureRequest sr = new SecureRequest();

body = json.encode({
  "User" : "A"
})

sr.get(["user", "3"]);
sr.post(["a"], body: body);

```

or if you need to change URLs of API Resource feel free to use URL parameter

```
SecureRequest sr = new SecureRequest(url: "http://new.url.to.resource");
```

## Parsing Data
for parsing data from resource server just use 
```
var myData = await sr.get(["user", "17"]);
```
get Response Meta
```
print(myData.Meta["Key"])
//or print all available key
print(myData.getMetaKey)
```
get Response Data
```
print(myData.Data["Key"])
//or print all available key
print(myData.getDataKey)
```

## Content of Meta
```
A           string
AccessTime  time.Time
AccessIP    string
Scope       string
Errors      Array of Errors
Request     string
```

A is User Acces Level notated at AIUD where

A = Assistant

I = Instructor

U = User / Practician

D = Admin