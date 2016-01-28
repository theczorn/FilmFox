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

  ###
  # Summary: Do a series of http calls and retrieve where target media is
  # streaming
  # Input: Name of target media.
  # Output: Series of resultant data to refine from
  #           OR
  #         Ability to stream media target on various platforms
  ###
  robot.respond /streamit (.+)/i, (res) ->
    res.send ""

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
    #CZTODO: get regexp and some way to filter out mis-ordered vars
    mediaType = res.match[2]
    mediaYear = res.match[3]

    queryURL = "http://www.omdbapi.com?r=json&t=#{mediaTitle}&tomatoes=true"
    if mediaType?
      mediaType = if mediaType[2] == "s" then "series" else "movie"
      queryURL+="&type=#{mediaType}"
    if mediaYear?
      mediaYear = mediaYear.replace "--",""
      queryURL+="&y=#{mediaYear}"

    res.send queryURL
    #Alter to use search results
    robot.http(queryURL)
      .header('Accept', 'application/json')
      .get() (err, httpRes, body) ->
        try
          data = JSON.parse body
        catch error
          res.send "JSON Parsing Error"
          return

        if(data.Response == "False")
          res.send data.Error + " Try another search."
          return

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

  ###
  # Summary: Retrieve a Random Film/TV show
  # Input: N/A
  # Output: Random media
  ###
  robot.respond /random/i, (res) ->
    res.send "TacoLazerAnnihilator" #randomize output from arrays
    robot.http("http://www/omdbapi.com/r=json&s=#{foobar}")
