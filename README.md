# Pokemon IoT


## Start Database

```
// first time setup
docker compose up -d --build

// use afterwards
docker compose up -d
```

## Close Database

```
docker compose down

// if you want to delete the data as well
docker compose down -v
```