# MathematicaSimpleServerCreate[]
---
**MathematicaSimpleServerCreate[**_port_, _handler_**]**
---
## Детали и опции

- MathmeticaSimpleServerCreate[..] возвращает объект MathmeaticaSimpleServer[..]
- _port_ - целое числом больше 1024 и меньше 10000
- _handler_ - обработчик соединения с сокетом, представляет собой объект типа ConnectionHandler[..]

## Примеры

### Основные примеры

```mathematica
port = 8888
handler = ConnectionHandler[]
server = MathematicaSimpleServerCreate[port, handler]
```
