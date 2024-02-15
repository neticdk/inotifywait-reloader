# What?

This project provides a simple Docker container that utilizes inotifywait to watch for changes in files or directories and trigger a reload of a service when modifications are detected.

# How?

Run the container created by this repo together with your application in a single pod with a shared volume. When files at the watched patch are updated the container can send an HTTP request to specified URL or a SIGHUP to specified Service.

# Features

- Supports HTTP and SIGHUP reload methods
- Configurable paths to monitor for changes
- Retries HTTP requests with configurable delay
- Logs information about reload attempts and success/failure

# Configuration Environment Variables

| name                       | description                                                                                                                                                                                                                                                                                                                         | required | default                                   | type    |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|-------------------------------------------|---------|
| `RELOAD_METHOD`                    | The reload method to use (HTTP or SIGHUP). If SIGHUP Method is used then containers in a pod must [share process namespace](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace)                                                                                                                                                                                                                                                                                               | true     | HTTP                                         | string  |
| `WATCH_PATHS`              | Comma-separated list of paths to watch for changes.                                                                                                                                                                                                                              | true    | -                                         | string  |
| `REQ_URL`                   | The URL of the reload endpoint (required for HTTP reload)                                                                                                                                                                                                                                                                                             | false     | -                                         | string  |
| `REQ_METHOD`        | The HTTP method to use for reload requests (GET or POST).                                                                                                              | false    | GET            | string  |
| `REQ_RETRY_COUNT`                | The number of retries for HTTP requests.                                                                                                                                                 | false    | `5` | integer  |
| `REQ_RETRY_DELAY`                 | The delay between retries (seconds).                                                                                                                                                                                                                                            | false    | `5`                               | integer  |
| `REQ_TIMEOUT`                   | The timeout for HTTP requests (seconds). | false    | `10`                                         | integer  |
| `REQ_STATUS_CODE`               | The expected status code for successful reload requests.                                                                                                                                                                                                                                             | false    | `200`                                      | integer |
| `SERVICE_NAME`                  | The name of the service to reload (required for SIGHUP reload).                                                                                                                                                                                                                                                                   | false    | -                                         | string     |
