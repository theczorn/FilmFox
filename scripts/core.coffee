###
# Description:
#   Core functionality for Filmfox Hipchat robot
#
###
#fs = require("fs");
module.exports = (robot) ->

  #Get Foxy With it
  robot.respond /get foxy/i, (res) ->
    res.send "foobar"
    #img = fs.readfile("./assets/foxy.gif")
    #res.send(img, 'binary')

  ###
  # Summary: Do a series of http calls and retrieve where target media is streaming
  # Input: Name of target media.
  # Output: Series of resultant data to refine from
  #           OR
  #         Ability to stream media target on various platforms
  ###
  robot.respond /streamit (.+)/i, (res) ->
    res.send "watever"
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

        Response = data.Response;

        if(Response == "false")
          res.send "No Results. Try another search."
          return

        Title = data.Title
        Year = data.Year
        Rating = data.Rated
        Genres = data.Genre
        Plot = data.Plot
        Poster= data.Poster
        Metascore = data.Metascore
        imdbScore = data.imdbRating
        rtUserScore = data.tomatoMeter
        rtCriticScore = data.tomatoUserMeter

        if Poster=="N/A"
          Poster="STOCK IMAGE HERE"

        res.send "#{Poster}\n"
        res.send "#{Title} - #{Rating} - (#{Year})\n
                  Genre(s): #{Genres}\n
                  Summary: #{Plot}\n
                  IMDB Rating: #{imdbScore}/10\n
                  Metacritic Rating: #{Metascore}/100\n
                  Rotten Tomatoes Critics Rating: #{rtCriticScore}/100\n
                  Rotten Tomatoes User Rating: #{rtUserScore}/100"
        return

  ###
  # Summary: Retrieve a Random Film/TV show
  # Input: N/A
  # Output: Random media
  ###
  robot.respond /random/i, (res) ->
    res.send "TacoLazerAnnihilator" #make this a random statement based on randomized array concat

    robot.http("http://www/omdbapi.com/r=json&s=#{foobar}")
