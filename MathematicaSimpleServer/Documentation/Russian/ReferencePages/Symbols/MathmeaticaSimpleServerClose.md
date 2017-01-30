# MathematicaSimpleServerClose[]

---

**MathematicaSimpleServerClose[**_server_**]**

---

## Детали и опции

- `MathematicaSimpleServerClose[server]` - останавливает запущенные сервер
- _server_ - объект типа `MathematicaSimpleServer[...]` 

## Примеры 

### Основные примеры

Сначала запустим сервер выполнив следующий код: 

```mathematica
sever = MathematicaSimpleServerCreate[8888, ConnectionHandler[]]
```

Теперь его можно остановить так: 

```mathematica
MathematicaSimpleServerClose[sever]
```
