# Tasks
 
A Flutter API to create, edit, delete and get Tasks for the Google Tasks API

## Setup Instructions

Permission is needed for the API to access the Internet

### MacOS

For MacOS include the following in `macos/Runner/DebugProfile.entitlements` 
and in `macos/Runner/Release.entitlements`:

```
	<key>com.apple.security.network.client</key>
	<true/>
```

### iOS

For ios include the following in `ios/Runner/info.plist`:

```
	<key>NSAppTransportSecurity</key>
	<dict>
 	  <key>NSAllowsArbitraryLoads</key><true/>
	</dict>
```

### Google Cloud

You will need to create a project on Google [Cloud](https://cloud.google.com/) and
enable [Tasks API](https://developers.google.com/tasks). Then create oAuth 2.0 Client
IDs and then download the oAuth Client to `assets/client-secrets.json`

```json
{
    "installed": {
        "client_id": "Your Client ID",
        "project_id": "tasks-367812",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_secret": "Top secret",
        "redirect_uris": [
            "http://localhost"
        ]
    }
}
```

Alternatively, create the following envionment variables:

* `Platform.environment['client_id']` // Your Client ID

* `Platform.environment['client_secret']` // Your Client secret

## Usage Instructions

Instatiate the API [Tasks] once.

```dart
Future<bool> hasAccess()
Future<List<TaskList>> getLists()
Future<TaskList> getDefaultList()
Future<List<Task>> getTasksForList(TaskList list, {String options = ''})
Future<Task> createTask({required TaskList list, required Task task})
Future saveTask(Task task)
Future deleteTask(Task task)
```

## Todo

Test on :
- windows
- linux
- web