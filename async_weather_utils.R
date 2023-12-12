# async_weather_utils.R

# helper functions for updating pins, etc.

library(dplyr)
library(lubridate)
library(pins)

# Returns weather obs for KWASEATT2743 station
getSeattleWeather <- function() {
  df <- readRDS(url("https://github.com/lagerratrobe/weather_station/raw/main/Data/station_obs.RDS"))
  # Convert obsTimeLocal to proper Posix time object
  df <- mutate(df,
               obsTimeLocal = lubridate::parse_date_time(
                 obsTimeLocal,
                 "Ymd HMS",
                 tz = "UTC",
                 truncated = 0,
                 quiet = FALSE,
                 exact = FALSE)
  )
  df <- filter(df, stationID == "KWASEATT2743")
  return(df)
} 

# Returns board object tied to Seattle_Weather_Data pins 
getBoard <- function() {
  board_connect(
    auth = c("envvar"),
    account = "randre",
    name = "Seattle_Weather_Data",
    versioned = TRUE,
    use_cache_on_failure = FALSE)
}

# Writes a new version of Seattle weather data to Pin set
updateBoard <- function(
    board = NULL,
    df = NULL,
    time_now = NULL
    ) {
  pin_write(board = board,
            x = df,
            name = "randre/Seattle_Weather_Data",
            type = "rds",
            versioned = TRUE,
            metadata = list("load_time" = time_now))
}

# Returns last 48 hours of Seattle weather with a subset of variables
cleanSeattleWeather <- function(
    df = weather_data
) {
  df %>% select("Time" = obsTimeLocal,
                "UV" = uv,
                "Humidity" = humidity,
                "Temperature" = imperial.temp,
                "Pressure" = imperial.pressure,
                "Precip" = imperial.precipTotal) %>%
    arrange(desc(Time)) %>% 
    head(n=48)
}

# Subset to specific variables. Always include:
# - obsTimeLocal,
# in addition to variable
getVariableData <- function(
    df = NULL,
    vars = NULL) {
  df <- select(df,
               Time,
               all_of(vars))
  
  return(df)
}
