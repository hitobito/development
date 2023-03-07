# Tricks and hacks

## How to deal with dublicates

If you test and develop with the duplicate function, you can start the job manually:

```bash
docker-compose exec rails bash
rails c
People::DuplicateLocator.new.run
```
