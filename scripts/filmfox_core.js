/*
 * Description:
 *   Core functionality for Filmfox Hipchat robot
 *
 */

(function() {
  var fs, handleHttpResponse, outputMovieData, outputStreamingData, parseServiceList;

  fs = require('fs');

  module.exports = function(robot) {
    robot.respond(/get foxy/i, function(res) {
      fs.ReadStream("./assets/foxy.gif");
    });

    /*
     * Summary: Call on FlixFindr to determine if media is streaming
     * Input: Name of target media.
     * Output: Series of resultant data to refine from
     *           OR
     *         Ability to stream media target on various platforms
     */
    robot.respond(/stream (.+)/i, function(res) {
      var mediaTitle, queryFilter;
      mediaTitle = res.match[1];
      queryFilter = "{\"filters\":[ {\"name\":\"title\",\"op\":\"eq\",\"val\":\"" + mediaTitle + "\"} ,{\"name\":\"availabilities\",\"op\":\"any\",\"val\": {\"name\":\"filter_property\",\"op\":\"in\",\"val\":[ \"itunes:hd rental\" ,\"itunes:sd rental\" ,\"netflix:\" ,\"hulu:free\" ,\"hulu:plus\" ,\"prime:\" ,\"hbogo:\" ,\"showtime:\" ,\"crackle:\" ]}}]}";
      return robot.http("http://www.flixfindr.com/api/movie").query({
        q: queryFilter
      }).headers({
        Accept: 'application/json'
      }).get()(function(err, httpRes, body) {
        var data, error, error1, rawData;
        try {
          rawData = JSON.parse(body);
          data = rawData.objects[0];
        } catch (error1) {
          error = error1;
          res.send("JSON Parsing Error: " + error);
          return;
        }
        outputStreamingData(data, res);
      });
    });

    /*
     * Summary: Retrieve summary of info about media
     * Input:
     * (1) - Name of show/film to search for [REQUIRED]
     * (2) - Type of data to search for --m/--movie OR --s/--series [OPTIONAL]
     * (3) - Four Digit Year of release --XXXX [OPTIONAL]
     * Output: Series of resultant data to refine from
     *           OR
     *         Summary of target media and critic ratings
     */
    robot.respond(/fetch (.+?(?= --|$))(?: )?(--m(?:ovie)?|--s(?:eries)?)?(?: )?(--[0-9]{4})?/i, function(res) {
      var mediaTitle, mediaType, mediaYear, queryURL;
      mediaTitle = res.match[1];
      mediaType = res.match[2];
      mediaYear = res.match[3];
      queryURL = "http://www.omdbapi.com?r=json&t=" + mediaTitle + "&tomatoes=true";
      if (mediaType != null) {
        mediaType = mediaType[2] === "s" ? "series" : "movie";
        queryURL += "&type=" + mediaType;
      }
      if (mediaYear != null) {
        mediaYear = mediaYear.replace("--", "");
        queryURL += "&y=" + mediaYear;
      }
      return robot.http(queryURL).headers({
        Accept: 'application/json'
      }).get()(function(err, httpRes, body) {
        var data, error, error1;
        try {
          data = JSON.parse(body);
        } catch (error1) {
          error = error1;
          res.send("JSON Parsing Error");
          return;
        }
        if (data.Response === "False") {
          res.send(data.Error + " Try another search.");
          return;
        }
        outputMovieData(data, res);
      });
    });

    /*
     * Summary: Retrieve a Random Film/TV show based by targetting an IMDB id
     * Input: N/A
     * Output: Random Media
     * NOTE: IMDB hosts all of it's film/show data under a 7 digit id. IMDB is
     * wasteful in using these so there is no real guarantee that the id in question
     * exists, as they are "recycled".
     * Rough IMDB Stats: http://www.imdb.com/stats
     */
    return robot.respond(/random/i, function(res) {
      var imdbID;
      imdbID = ("000000" + Math.random(1, 3610267 + 1)).slice(-7);
      return robot.http("http://www.omdbapi.com/").headers({
        Accept: 'application/json'
      }).query({
        r: "json",
        i: "tt" + imdbID,
        tomatoes: "true"
      }).get()(function(err, httpRes, body) {
        var data, error, error1;
        try {
          data = JSON.parse(body);
        } catch (error1) {
          error = error1;
          res.send("JSON Parsing Error");
          return;
        }
        if (data.Response === "False") {
          res.send(data.Error + " Try another search.");
          return;
        }
        outputMovieData(data, res);
      });
    });
  };


  /*
   * Summary: Handles finer parsing and output of OMDBapi data
   * Input: http GET data and response stream
   * Output: Parsed JSON data from OMDBapi to chatroom
   */

  outputMovieData = function(data, res) {
    var Genres, Metascore, Plot, Poster, Rating, Title, Type, Year, imdbScore, rtCriticScore, rtUserScore;
    Title = data.Title;
    Year = data.Year;
    Rating = data.Rated;
    Genres = data.Genre;
    Plot = data.Plot;
    Type = data.Type.charAt(0).toUpperCase() + data.Type.slice(1);
    Poster = data.Poster;
    Metascore = data.Metascore;
    imdbScore = data.imdbRating;
    rtCriticScore = data.tomatoMeter;
    rtUserScore = data.tomatoUserMeter;

    if (Metascore !== "N/A") {
      Metascore += "/100";
    }
    if (imdbScore !== "N/A") {
      imdbScore += "/10";
    }
    if (rtCriticScore !== "N/A") {
      rtCriticScore += "/100";
    }
    if (rtUserScore !== "N/A") {
      rtUserScore += "/100";
    }
    if (Poster === "N/A") {
      Poster = fs.ReadStream("./assets/notfound.png");
      res.send("\n");
    } else {
      res.send(Poster + "\n");
    }

    res.send(Title + " - " + Rating + " - " + Type
      + " - (" + Year + ")\n Genre(s): " + Genres
      + "\n Summary: " + Plot + "\n IMDB Rating: " + imdbScore
      + "\n Metacritic Rating: " + Metascore
      + "\n Rotten Tomatoes Critics Rating: " + rtCriticScore
      + "\n Rotten Tomatoes User Rating: " + rtUserScore);
  };


  /*
   * Summary: Handles finer parsing and output of FlixFindr data
   * Input: http GET data and response stream
   * Output: Parsed JSON data from FlixFindr to chatroom
   */

  outputStreamingData = function(data, res) {
    var Plot, Poster, Rating, Services, Title, Year;
    Title = data.title;
    Year = data.year;
    Rating = data.mpaa_rating;
    Plot = data.synopsis;
    Poster = data.poster;
    Services = parseServiceList(data, res);

    if (Poster === "N/A") {
      Poster = fs.ReadStream("./assets/notfound.png");
      res.send("\n");
    } else {
      res.send(Poster + "\n");
      res.send(Title + " - " + Rating
        + " - (" + Year + ")\n Summary: "
        + Plot + "\n\n " + Services);
    }
  };

  parseServiceList = function(data, res) {
    var i, len, price, rawServices, service, servicesList;
    rawServices = data.availabilities;
    servicesList = "";

    for (i = 0, len = rawServices.length; i < len; i++) {
      service = rawServices[i];
      if (service.price == null) {
        price = "0.00";
      } else {
        price = service.price;
      }
      servicesList += (service.source.charAt(0).toUpperCase()
        + service.source.slice(1))
        + " - " + service.channel
        + "\n Cost: $" + price
        + "\n Link: " + service.link + "\n\n";
    }
    return servicesList;
  };


  /*
   * Summary: Call on FlixFindr to determine if media is streaming
   * Input: Name of target media.
   * Output: Returns to calling method
   *         OR
   *         Raises appropriate error message due to failed request
   */

  handleHttpResponse = function() {};
}).call(this);
