library(rjson)
library(dplyr)
library(data.table)
library(lubridate)
library(leaflet)


## DEFINE HALTESTELLEN FOR DROPDOWN MENU
## ========================================

## LOAD DATA ------------------------------
wienerlinien_ogd_steige <- read_delim("data/wienerlinien-ogd-steige.csv", 
                                      ";", escape_double = FALSE, trim_ws = TRUE)

wienerlinien_ogd_haltestellen <- read_delim("data/wienerlinien-ogd-haltestellen.csv", 
                                            ";", escape_double = FALSE, trim_ws = TRUE)

# Example Haltepunkt:
# wienerlinien_ogd_steige$RBL_NUMMER: 
# FK_HALTESTELLEN_ID == HALTESTELLEN_ID: 214461074
# wienerlinien_ogd_haltestellen$NAME: OTTAKRING

## SELECT HALTESTELLEN ------------------------------
# haltestellen <- sort(as.matrix(unique(
#   inner_join(wienerlinien_ogd_haltestellen[,c("HALTESTELLEN_ID","NAME", "GEMEINDE")], 
#              wienerlinien_ogd_steige[,c("FK_HALTESTELLEN_ID","RBL_NUMMER")],
#              by = c("HALTESTELLEN_ID" = "FK_HALTESTELLEN_ID")
#   )["NAME"])))

haltestellen <- inner_join(wienerlinien_ogd_haltestellen[,c("HALTESTELLEN_ID","NAME", "GEMEINDE")], 
                           wienerlinien_ogd_steige[,c("FK_HALTESTELLEN_ID","RBL_NUMMER")],
                           by = c("HALTESTELLEN_ID" = "FK_HALTESTELLEN_ID")) %>% 
  filter(GEMEINDE == "Wien") %>% 
  filter(!grepl('^\\d', `NAME`)) %>% 
  select("NAME") %>% 
  unique() %>% 
  as.matrix %>% 
  sort()

## DEPARTURE TABLE FUNCTION
## ========================================
departure_table_fun <- function(station, barrier, type) {
  
  ## LOAD DATA ----------------------------------------
  wienerlinien_ogd_steige <- read_delim("data/wienerlinien-ogd-steige.csv", 
                                        ";", escape_double = FALSE, trim_ws = TRUE)
  
  wienerlinien_ogd_haltestellen <- read_delim("data/wienerlinien-ogd-haltestellen.csv", 
                                              ";", escape_double = FALSE, trim_ws = TRUE)
  
  # Example Haltepunkt:
  # wienerlinien_ogd_steige$RBL_NUMMER: 
  # FK_HALSTELLEN_ID == HALTESTELLEN_ID: 214461074
  # wienerlinien_ogd_haltestellen$NAME: OTTAKRING
  
  haltestellen <- sort(unique(wienerlinien_ogd_haltestellen$NAME))
  
  
  ## GET MONITOR DATA FROM STATION ----------------------------------------
  # via dropdown Station is selected and passed onto this helper function.
  
  #station <- "Ottakringer Bad"
  #station <- "1. Haidequerstraße Mitte"
  
  haltestellen_id <- wienerlinien_ogd_haltestellen %>% 
    filter(NAME == station) %>% 
    select(HALTESTELLEN_ID) %>% 
    as.numeric()
  # 214461074
  
  # RBLNummer: gewünschter Standort für die Monitorabfrage;  
  rbl_numbers <- wienerlinien_ogd_steige %>% 
    filter(FK_HALTESTELLEN_ID == haltestellen_id) %>% 
    select(RBL_NUMMER) %>% 
    filter(!is.na(RBL_NUMMER)) %>% 
    unlist() %>% 
    unique()
  # 4931 4930 1384 1387 8898 1528 1527
  
  # rbl kann 1 bis n Mal angegeben werden z.B. rbl=123&rbl=124
  RBL_link <- paste0(rbl_numbers, collapse = "&rbl=")
  # "4842&rbl=2629"
  
  JSONfile <- paste0("http://www.wienerlinien.at/ogd_realtime/monitor?rbl=",
                     RBL_link,
                     "&activateTrafficInfo=stoerungkurz&a%20ctivateTrafficInfo=stoerunglang&activateTrafficInfo=aufzugsinfo&sender=")
  # "http://www.wienerlinien.at/ogd_realtime/monitor?rbl=8906&rbl=8932&rbl=182&rbl=182&activateTrafficInfo=stoerungkurz&a%20ctivateTrafficInfo=stoerunglang&activateTrafficInfo=aufzugsinfo&sender="
  
  WL <- fromJSON(file=JSONfile)
  monitors <- WL$data$monitors
  
  
  ## EXTRACT MONITOR INFORMATION INTO TABLE 
  table_fun <- function(monitors) {
    #lines <- list()
    
    monitor <- list()
    for (i in 1:length(monitors)){
      monitor[[i]] <- data.frame(line = monitors[[i]][["lines"]][[1]][["name"]],
                                 type = monitors[[i]][["lines"]][[1]][["type"]],
                                 towards = monitors[[i]][["lines"]][[1]][["towards"]],
                                 platform = monitors[[i]][["lines"]][[1]][["platform"]],
                                 departure = format(ymd_hms(monitors[[i]][["lines"]][[1]][["departures"]][["departure"]][[1]][["departureTime"]][["timePlanned"]]), "%H:%M"),
                                 estimated = format(ymd_hms(monitors[[i]][["lines"]][[1]][["departures"]][["departure"]][[1]][["departureTime"]][["timeReal"]]), "%H:%M"),
                                 countdown = monitors[[i]][["lines"]][[1]][["departures"]][["departure"]][[1]][["departureTime"]][["countdown"]],
                                 barrierfree = monitors[[i]][["lines"]][[1]][["barrierFree"]])
      
    }
    
    table = rbindlist(monitor)[order(countdown)]
    
    # rename factor levels for type of transport 
    # ptTram, ptBusCity, ptMetro, ptBusNight, ptTrainS, ptTramWLB
    levels(table$type)[levels(table$type)=="ptTram"] <- "Tram"
    levels(table$type)[levels(table$type)=="ptBusCity"] <- "Bus"
    levels(table$type)[levels(table$type)=="ptMetro"] <- "Metro"
    levels(table$type)[levels(table$type)=="ptBusNight"] <- "Nightbus"
    levels(table$type)[levels(table$type)=="ptTrainS"] <- "S-Train"
    levels(table$type)[levels(table$type)=="ptTramWLB"] <- "Tram WLB"
    
    
    if(barrier == FALSE)  table <- table %>% select(-"barrierfree")
    if(type == FALSE) table <- table %>% select(-"type")
    
    return(table)
  }
  
  ifelse(length(monitors) == 0, 
         table <- data.frame(WARNING = "There are no departure infos available"),
         table <- table_fun(monitors)
         )
  
  return(data.frame(table))
}


## CREATE CITY MAP
## ========================================

station_coord <- wienerlinien_ogd_haltestellen %>% 
  group_by(NAME, WGS84_LAT,WGS84_LON) %>% 
  select(NAME, WGS84_LAT,WGS84_LON)  %>% 
  data.frame()

station_map_fun <- function(station) {
  
  data = station_coord[station_coord$NAME == station,]

  m <- leaflet(data = data) %>% # creates the map widget
    addTiles() %>% # adds the default OpenStreet map tiles
    addMarkers(lng = data$WGS84_LON, 
               lat = data$WGS84_LAT,
               popup = paste("Station: ", station)) %>% #pop-up will appear when we click on the point and it will print the sation name. 
    setView(lng=data$WGS84_LON, lat=data$WGS84_LAT, zoom=12) # sets the view to the provided coordinates with the provided zoom level

  return(m)
}


