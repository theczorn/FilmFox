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
  # Input: Name of target media
  # Output: Series of resultant data to refine from
  #           OR
  #         Summary of target media and critic ratings
  ###
  robot.respond /fetch (.+)/i, (res) ->
    mediaTitle = res.match[1]

    #Alter to use search results
    robot.http("http://www.omdbapi.com?r=json&t=#{mediaTitle}&tomatoes=true")
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

        res.send "#{Title} - #{Rating} - (#{Year})\n
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
