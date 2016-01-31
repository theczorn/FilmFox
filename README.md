# FilmFox
Hipchat Bot to Retrieve Movie and TV Data

## Commands

### Fetch -
Returns a single Movie or Series and it's associated data.

**Format:**
```
filmfox fetch <Title> [Type] [Year]

Parameters:
  Title - Required title of show/movie  
  Type - Either --m(ovie), --s(eries). [OPTIONAL]  
  Year - 4 digit number of the year the entity was released [OPTIONAL]  
```
___
### Random -
Generates a random IMDB id to query and returns info.

**Format:**
```
filmfox random
```

**NOTE:** Has a decent rate of failure. IMDB doesn't offer a public API and doesn't "recycle" their ID's
used to track movies and shows. As a result there is not guarantee running this will return meaningful data.
___
### Streaming -
Work in Progress. Intended to find a given movie/TV show and return what services stream it.
___
### Get Foxy -
**Format:**
```
filmfox get foxy
```
