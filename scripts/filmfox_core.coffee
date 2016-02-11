###
# Description:
#   Core functionality for Filmfox Hipchat robot
#
###
fs = require 'fs'
module.exports = (robot) ->

  #Get Foxy With it
  robot.respond /get foxy/i, (res) ->
    fs.ReadStream("./assets/foxy.gif")
    return

  ###
  # Summary: Call on FlixFindr to determine if media is streaming
  # Input: Name of target media.
  # Output: Series of resultant data to refine from
  #           OR
  #         Ability to stream media target on various platforms
  ###
  robot.respond /stream (.+)/i, (res) ->
    mediaTitle = res.match[1]

    queryFilter = "{\"filters\":[
      {\"name\":\"title\",\"op\":\"eq\",\"val\":\"#{mediaTitle}\"}
      ,{\"name\":\"availabilities\",\"op\":\"any\",\"val\":
        {\"name\":\"filter_property\",\"op\":\"in\",\"val\":[
          \"itunes:hd rental\"
          ,\"itunes:sd rental\"
          ,\"netflix:\"
          ,\"hulu:free\"
          ,\"hulu:plus\"
          ,\"prime:\"
          ,\"hbogo:\"
          ,\"showtime:\"
          ,\"crackle:\"
        ]}}]}"

    robot.http("http://www.flixfindr.com/api/movie")
      .query(q: queryFilter)
      .headers(Accept: 'application/json')
      .get() (err, httpRes, body) ->
        try
          data = JSON.parse body
        catch error
          res.send "JSON Parsing Error: #{error}"
          return

        #numbers = data[0]
        #res.send "hello #{numbers}"

  ###
  # Summary: Retrieve summary of info about media
  # Input:
  # (1) - Name of show/film to search for [REQUIRED]
  # (2) - Type of data to search for --m/--movie OR --s/--series [OPTIONAL]
  # (3) - Four Digit Year of release --XXXX [OPTIONAL]
  # Output: Series of resultant data to refine from
  #           OR
  #         Summary of target media and critic ratings
  ###
  robot.respond /fetch (.+?(?= --|$))(?: )?(--m(?:ovie)?|--s(?:eries)?)?(?: )?(--[0-9]{4})?/i, (res) ->
    mediaTitle = res.match[1]
    mediaType = res.match[2]
    mediaYear = res.match[3]

    queryURL = "http://www.omdbapi.com?r=json&t=#{mediaTitle}&tomatoes=true"
    if mediaType?
      mediaType = if mediaType[2] == "s" then "series" else "movie"
      queryURL+="&type=#{mediaType}"
    if mediaYear?
      mediaYear = mediaYear.replace "--",""
      queryURL+="&y=#{mediaYear}"

    #Alter to use search results
    #NOTE: Due to optional vars we can't use ".query" operation
    robot.http(queryURL)
      .headers(Accept: 'application/json')
      .get() (err, httpRes, body) ->
        try
          data = JSON.parse body
        catch error
          res.send "JSON Parsing Error"
          return

        if(data.Response == "False")
          res.send data.Error + " Try another search."
          return

        outputMovieData(data, res)
        return

  ###
  # Summary: Retrieve a Random Film/TV show based by targetting an IMDB id
  # Input: N/A
  # Output: Random Media
  # NOTE: IMDB hosts all of it's film/show data under a 7 digit id. IMDB is
  # wasteful in using these so there is no real guarantee that the id in question
  # exists, as they are "recycled".
  # Rough IMDB Stats: http://www.imdb.com/stats
  ###
  robot.respond /random/i, (res) ->
    #Generate IMDB ID and pad with up to 6 zeroes
    imdbID = ("000000" + Math.random(1,3610267+1)).slice(-7)

    robot.http("http://www.omdbapi.com/")
      .headers(Accept: 'application/json')
      .query(r: "json", i: "tt#{imdbID}", tomatoes: "true")
      .get() (err, httpRes, body) ->

      #tell this thing to bug off if not HTTP 200
        try
          data = JSON.parse body
        catch error
          res.send "JSON Parsing Error"
          return

        if(data.Response == "False")
          res.send data.Error + " Try another search."
          return

        outputMovieData(data, res)
        return

outputMovieData = (data, res) ->
  Title = data.Title
  Year = data.Year
  Rating = data.Rated
  Genres = data.Genre
  Plot = data.Plot
  Type = data.Type.charAt(0).toUpperCase() + data.Type.slice(1) #capitalize first letter
  Poster = data.Poster
  Metascore = data.Metascore
  imdbScore = data.imdbRating
  rtCriticScore = data.tomatoMeter
  rtUserScore = data.tomatoUserMeter

  if (Metascore != "N/A")
    Metascore +="/100"

  if (imdbScore != "N/A")
    imdbScore +="/10"

  if (rtCriticScore != "N/A")
    rtCriticScore += "/100"

  if (rtUserScore != "N/A")
    rtUserScore += "/100"

  if Poster is "N/A"
    Poster = fs.ReadStream("./assets/notfound.png")
    res.send "\n"
  else
    res.send "#{Poster}\n"

  res.send "#{Title} - #{Rating} - #{Type} - (#{Year})\n
    Genre(s): #{Genres}\n
    Summary: #{Plot}\n
    IMDB Rating: #{imdbScore}\n
    Metacritic Rating: #{Metascore}\n
    Rotten Tomatoes Critics Rating: #{rtCriticScore}\n
    Rotten Tomatoes User Rating: #{rtUserScore}"
  return
