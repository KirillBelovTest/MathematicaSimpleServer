# MathematicaSimpleServerClose[]

---

**MathematicaSimpleServerClose[**_server_**]**

---

## Детали

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

## Смотрите Также

**[MathematicaSimpleServerCreate](./MathematicaSimpleServerCreate.md)**

## Руководства

- [Руководство](../../Guides/Guide.md)

## Связанные Туториалы

- [Примеры использования](../../Tutorials/ExampleOfUse.md)
