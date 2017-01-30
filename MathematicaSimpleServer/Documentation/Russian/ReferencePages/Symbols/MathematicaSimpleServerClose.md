# MathematicaSimpleServerClose[]

---

**MathematicaSimpleServerClose[**_server_**]**

---

## Детали и опции

- `MathematicaSimpleServerClose[server]` - останавливает запущенный сервер
- _server_ - объект типа `MathematicaSimpleServer[...]` 

## Примеры 

### Основные примеры

Сначала запустим сервер выполнив следующий код: 

```mathematica
server = MathematicaSimpleServerCreate[8888, ConnectionHandler[]]
```

Теперь его можно остановить так: 

```mathematica
MathematicaSimpleServerClose[server]
```
