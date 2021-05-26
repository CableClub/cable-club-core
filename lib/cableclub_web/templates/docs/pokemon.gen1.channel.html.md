# Pokemon Gen1 Channel Protocol

## Events

|name|example params|reply|description|
|:-:|:-:|:-:|:-:|
|`session.create`| none | `{"code": "FEABDE"}` | create a new session |
|`session.join`  | `{"code": "FEABDE"}` | none | join an existing session |
|`session.start` | `{"type": "trade"}`  | none | start a session. both connections must send this before the sesssion actually begins |
|`session.stop` | none | none | stop a session |
|`session.status` | `{"ready": true}` | none | flag signaling that a session is ready
|`transfer` | `{"data": 0xfe}` | none | transfer a single byte |

## Event Errors

Each event can reply with `error` with a payload of `{"reason": "some description"}`
