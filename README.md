# http-echo

HTTP Echo is a small go web server that serves the contents it was started with
as an HTML page.

The default port is 5678, but this is configurable via the `-listen` flag:

```bash
http-echo -listen=:8080 -text="hello world"
```

Then visit <http://localhost:8080/> in your browser.

## Configuration

| Argument       | Required  | Default                     | Description                         |
| -------------- | --------- | --------------------------- | ----------------------------------- |
| `text`         | ✅        |                             | Text to put on the response         |
| `listen`       | ❌        | `:5678`                     | Address and port to listen          |
| `content-type` | ❌        | `text/plain; charset=utf-8` | The Content-Type header of response |
| `status-code`  | ❌        | 200                         | HTTP response code, e.g.: 200       |
